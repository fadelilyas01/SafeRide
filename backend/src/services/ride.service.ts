/**
 * Service Rides - Logique metier pour les offres de covoiturage et le calcul d'itineraire OSRM
 */

import { db } from "@/lib/db";
import { IRide, CreateRideDTO } from "@/types";
import { NotFoundError, AppError, logger } from "@/utils";
import { config } from "@/config/env";

interface RouteResponse {
  routes?: Array<{
    geometry: { coordinates: [number, number][] };
    distance: number;
    duration: number;
  }>;
}

export class RideService {
  /**
   * Cree une nouvelle offre de covoiturage avec calcul d'itineraire OSRM sous timeout strict.
   */
  async createRide(data: CreateRideDTO): Promise<IRide> {
    const driver = await db.user.findUnique({
      where: { id: data.driverId },
    });

    if (!driver) {
      throw new NotFoundError("Conducteur");
    }

    let routeGeometry = JSON.stringify([
      [data.startLng, data.startLat],
      [data.endLng, data.endLat],
    ]);

    if (config.features.osrmRouting) {
      try {
        routeGeometry = await this.fetchOSRMRoute(
          data.startLng,
          data.startLat,
          data.endLng,
          data.endLat
        );
      } catch (error: unknown) {
        logger.warn("Echec recuperation OSRM, trace direct utilise", {
          reason: error instanceof Error ? error.message : "unknown",
        });
      }
    }

    const ride = await db.ride.create({
      data: {
        driverId: data.driverId,
        originLabel: data.originLabel || "Paris - Gare de Lyon",
        destinationLabel: data.destinationLabel || "Campus de Versailles",
        startLat: data.startLat,
        startLng: data.startLng,
        endLat: data.endLat,
        endLng: data.endLng,
        departureTime: new Date(data.departureTime),
        routeGeometry,
      },
    });

    logger.info("Course creee", { rideId: ride.id, driverId: data.driverId });
    return ride;
  }

  /**
   * Recupere l'itineraire routier via OSRM avec un AbortController de 6 secondes.
   */
  async fetchOSRMRoute(
    startLng: number,
    startLat: number,
    endLng: number,
    endLat: number
  ): Promise<string> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 6000);

    try {
      const url = `${config.maps.osrmUrl}/${startLng},${startLat};${endLng},${endLat}?overview=full&geometries=geojson`;
      const response = await fetch(url, { signal: controller.signal });

      if (!response.ok) {
        throw new Error(`OSRM HTTP ${response.status}`);
      }

      const data = (await response.json()) as RouteResponse;
      if (data.routes && data.routes.length > 0) {
        return JSON.stringify(data.routes[0].geometry.coordinates);
      }

      throw new Error("Aucun itineraire OSRM trouve");
    } finally {
      clearTimeout(timeoutId);
    }
  }

  /**
   * Liste toutes les offres de covoiturage disponibles.
   * Si la base locale est vide, initialise 2 offres reelles en base de donnees.
   */
  async listAllRides() {
    let rides = await db.ride.findMany({
      include: {
        driver: {
          select: { id: true, name: true, email: true },
        },
      },
      orderBy: { departureTime: "asc" },
    });

    if (rides.length === 0) {
      let defaultDriver = await db.user.findUnique({
        where: { email: "sophie.conductrice@saferide.fr" },
      });

      if (!defaultDriver) {
        defaultDriver = await db.user.create({
          data: {
            email: "sophie.conductrice@saferide.fr",
            name: "Sophie Martin",
            role: "DRIVER",
          },
        });
      }

      const now = Date.now();
      await db.ride.createMany({
        data: [
          {
            driverId: defaultDriver.id,
            originLabel: "Paris - Gare de Lyon",
            destinationLabel: "Campus de Versailles",
            startLat: 48.8443,
            startLng: 2.3744,
            endLat: 48.8049,
            endLng: 2.1204,
            departureTime: new Date(now + 35 * 60 * 1000),
            routeGeometry: JSON.stringify([
              [2.3744, 48.8443],
              [2.3364, 48.853],
              [2.2945, 48.8584],
              [2.225, 48.835],
              [2.1204, 48.8049],
            ]),
          },
          {
            driverId: defaultDriver.id,
            originLabel: "Paris - Chatelet",
            destinationLabel: "Plateau de Saclay (Universite)",
            startLat: 48.8584,
            startLng: 2.347,
            endLat: 48.7098,
            endLng: 2.1691,
            departureTime: new Date(now + 75 * 60 * 1000),
            routeGeometry: JSON.stringify([
              [2.347, 48.8584],
              [2.332, 48.821],
              [2.275, 48.765],
              [2.1691, 48.7098],
            ]),
          },
        ],
      });

      rides = await db.ride.findMany({
        include: {
          driver: {
            select: { id: true, name: true, email: true },
          },
        },
        orderBy: { departureTime: "asc" },
      });
    }

    return rides;
  }

  /**
   * Supprime une course si aucune reservation n'y est rattachee.
   */
  async deleteRide(rideId: string): Promise<void> {
    const ride = await db.ride.findUnique({
      where: { id: rideId },
    });

    if (!ride) {
      throw new NotFoundError("Course");
    }

    const reservationCount = await db.reservation.count({
      where: { rideId },
    });

    if (reservationCount > 0) {
      throw new AppError(
        "RIDE_HAS_RESERVATIONS",
        "Impossible de supprimer une course comportant des reservations actives.",
        400
      );
    }

    await db.ride.delete({
      where: { id: rideId },
    });
  }
}

export const rideService = new RideService();
