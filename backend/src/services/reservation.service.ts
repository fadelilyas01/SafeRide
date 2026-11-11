/**
 * Service Reservations - Gestion securisee du cycle de vie des reservations et verification PIN
 */

import { db } from "@/lib/db";
import { CreateReservationDTO } from "@/types";
import {
  ForbiddenError,
  NotFoundError,
  RateLimitError,
  ValidationError,
  clearRateLimit,
  computeCanonicalSha256,
  constantTimePinCompare,
  generateSecurePin,
  logger,
  recordFailedAttempt,
  verifyRateLimit,
} from "@/utils";
import { start } from "workflow/api";
import { bookingLifecycleWorkflow } from "@/workflows/booking-lifecycle";
import { tripMonitorWorkflow } from "@/workflows/trip-monitor";

export class ReservationService {
  /**
   * Cree une reservation avec un code PIN genere par CSPRNG (crypto.randomInt).
   */
  async createReservation(data: CreateReservationDTO) {
    const ride = await db.ride.findUnique({
      where: { id: data.rideId },
    });

    if (!ride) {
      throw new NotFoundError("Trajet");
    }

    const passenger = await db.user.findUnique({
      where: { id: data.passengerId },
    });

    if (!passenger) {
      throw new NotFoundError("Passager");
    }

    const securePin = generateSecurePin();

    const reservation = await db.reservation.create({
      data: {
        rideId: data.rideId,
        passengerId: data.passengerId,
        startLat: ride.startLat,
        startLng: ride.startLng,
        endLat: ride.endLat,
        endLng: ride.endLng,
        verificationCode: securePin,
        status: "PENDING",
      },
      include: {
        ride: {
          include: {
            driver: {
              select: { name: true, email: true },
            },
          },
        },
      },
    });

    logger.info("Reservation creee avec code PIN CSPRNG", {
      reservationId: reservation.id,
      rideId: data.rideId,
    });

    return reservation;
  }

  /**
   * Permet au conducteur d'accepter ou d'annuler une demande de reservation.
   */
  async updateReservationStatus(
    reservationId: string,
    driverId: string,
    action: "accept" | "cancel"
  ) {
    const reservation = await db.reservation.findUnique({
      where: { id: reservationId },
      include: { ride: true },
    });

    if (!reservation) {
      throw new NotFoundError("Reservation");
    }

    if (reservation.ride.driverId !== driverId) {
      throw new ForbiddenError(
        "Seul le conducteur titulaire de ce trajet peut modifier cette reservation."
      );
    }

    if (action === "cancel") {
      return db.reservation.update({
        where: { id: reservationId },
        data: { status: "CANCELLED" },
      });
    }

    const updatedReservation = await db.reservation.update({
      where: { id: reservationId },
      data: { status: "CONFIRMED" },
    });

    try {
      await start(bookingLifecycleWorkflow, [
        {
          reservationId: updatedReservation.id,
        },
      ]);
    } catch (workflowError: unknown) {
      logger.warn("Workflow durable de reservation execute en mode autonome", {
        reservationId: updatedReservation.id,
        reason:
          workflowError instanceof Error ? workflowError.message : "unknown",
      });
    }

    return updatedReservation;
  }

  /**
   * Valide le code PIN en temps constant (CWE-208) avec protection anti-force brute (3 tentatives max).
   */
  async verifyPinAndStartTrip(reservationId: string, submittedPin: string) {
    const rateLimitKey = `pin_verify:${reservationId}`;
    const rateCheck = verifyRateLimit(rateLimitKey, 3, 5 * 60 * 1000);

    if (!rateCheck.allowed) {
      throw new RateLimitError(
        `Trop de tentatives incorrectes. Veuillez patienter ${rateCheck.retryAfterSeconds} secondes avant de reessayer.`,
        rateCheck.retryAfterSeconds
      );
    }

    const reservation = await db.reservation.findUnique({
      where: { id: reservationId },
      include: {
        ride: true,
        passenger: true,
      },
    });

    if (!reservation) {
      throw new NotFoundError("Reservation");
    }

    if (reservation.status !== "CONFIRMED") {
      throw new ValidationError(
        `Cette reservation ne peut pas etre demarree (statut actuel : ${reservation.status}).`
      );
    }

    const isPinValid = constantTimePinCompare(
      reservation.verificationCode,
      submittedPin
    );

    if (!isPinValid) {
      const failure = recordFailedAttempt(rateLimitKey, 3, 5 * 60 * 1000);
      if (failure.locked) {
        throw new RateLimitError(
          `Code PIN incorrect. Par mesure de securite, la validation est verrouillee pendant ${failure.retryAfterSeconds} secondes.`,
          failure.retryAfterSeconds
        );
      }

      throw new ValidationError(
        `Code PIN incorrect. Il vous reste ${failure.remainingAttempts} tentative(s).`,
        { remainingAttempts: failure.remainingAttempts }
      );
    }

    clearRateLimit(rateLimitKey);

    const now = new Date();
    const endTimeEst = new Date(now.getTime() + 45 * 60 * 1000);

    const [updatedReservation, trip] = await db.$transaction([
      db.reservation.update({
        where: { id: reservationId },
        data: { status: "ACTIVE" },
      }),
      db.trip.create({
        data: {
          userId: reservation.passengerId,
          driverId: reservation.ride.driverId,
          reservationId: reservationId,
          status: "ACTIVE",
          originLabel: reservation.ride.originLabel,
          destinationLabel: reservation.ride.destinationLabel,
          startLat: reservation.ride.startLat,
          startLng: reservation.ride.startLng,
          endLat: reservation.ride.endLat,
          endLng: reservation.ride.endLng,
          routeGeometry: reservation.ride.routeGeometry,
          startTime: now,
          endTimeEst: endTimeEst,
        },
      }),
    ]);

    await db.locationPing.create({
      data: {
        tripId: trip.id,
        latitude: trip.startLat,
        longitude: trip.startLng,
        speed: 8.5,
        heading: 245,
      },
    });

    const integritySeal = computeCanonicalSha256({
      tripId: trip.id,
      reservationId: updatedReservation.id,
      passengerId: reservation.passengerId,
      driverId: reservation.ride.driverId,
      startedAt: now.toISOString(),
    });

    try {
      await start(tripMonitorWorkflow, [
        {
          tripId: trip.id,
          checkDelaySeconds: 7200 + 300,
        },
      ]);
    } catch (workflowError: unknown) {
      logger.warn("Workflow de surveillance execute en mode autonome", {
        tripId: trip.id,
        reason:
          workflowError instanceof Error ? workflowError.message : "unknown",
      });
    }

    return {
      reservation: updatedReservation,
      trip,
      integritySeal,
    };
  }

  /**
   * Liste les reservations pour un passager ou un conducteur.
   */
  async listReservations(params: { passengerId?: string; driverId?: string }) {
    if (params.passengerId) {
      return db.reservation.findMany({
        where: { passengerId: params.passengerId },
        include: {
          ride: {
            include: {
              driver: {
                select: { name: true, email: true },
              },
            },
          },
          trip: {
            select: {
              id: true,
              status: true,
              originLabel: true,
              destinationLabel: true,
              routeGeometry: true,
              startLat: true,
              startLng: true,
              endLat: true,
              endLng: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
      });
    }

    if (params.driverId) {
      return db.reservation.findMany({
        where: {
          ride: {
            driverId: params.driverId,
          },
        },
        include: {
          passenger: {
            select: { name: true, email: true },
          },
          ride: true,
          trip: {
            select: {
              id: true,
              status: true,
              originLabel: true,
              destinationLabel: true,
              routeGeometry: true,
              startLat: true,
              startLng: true,
              endLat: true,
              endLng: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
      });
    }

    throw new ValidationError(
      "L'identifiant passengerId ou driverId est requis."
    );
  }
}

export const reservationService = new ReservationService();
