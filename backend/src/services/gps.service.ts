/**
 * Service GPS - Suivi telemetrique temps reel et detection de deviation d'itineraire Haversine
 */

import { db } from "@/lib/db";
import { getRouteDeviation } from "@/lib/geofence";
import { GPSPingDTO } from "@/types";
import { NotFoundError, logger } from "@/utils";
import { THRESHOLDS, MESSAGES } from "@/constants";

export interface RecordedPingResult {
  pingId: string;
  deviationMeters: number;
  limitExceeded: boolean;
  tripStatus: string;
}

export class GPSService {
  /**
   * Enregistre un releve GPS et declenche une alerte immediate si l'ecart depasse 150m.
   */
  async recordGPSPing(data: GPSPingDTO): Promise<RecordedPingResult> {
    const trip = await db.trip.findUnique({
      where: { id: data.tripId },
      select: {
        id: true,
        routeGeometry: true,
        status: true,
        userId: true,
      },
    });

    if (!trip) {
      throw new NotFoundError("Trajet");
    }

    const ping = await db.locationPing.create({
      data: {
        tripId: data.tripId,
        latitude: data.latitude,
        longitude: data.longitude,
        speed: data.speed ?? null,
        heading: data.heading ?? null,
      },
    });

    let deviation = 0;
    let limitExceeded = false;
    let currentStatus = trip.status;

    if (trip.routeGeometry && trip.status === "ACTIVE") {
      try {
        const routeCoords = JSON.parse(trip.routeGeometry) as [number, number][];
        deviation = getRouteDeviation(data.latitude, data.longitude, routeCoords);

        if (deviation > THRESHOLDS.GPS_MAX_DEVIATION_METERS) {
          limitExceeded = true;
          currentStatus = "ALERT";

          await db.$transaction([
            db.trip.update({
              where: { id: data.tripId },
              data: { status: "ALERT" },
            }),
            db.emergencyAlert.create({
              data: {
                tripId: data.tripId,
                userId: trip.userId,
                status: "ACTIVE",
              },
            }),
          ]);

          logger.warn(MESSAGES.ROUTE_DEVIATION_DETECTED, {
            tripId: data.tripId,
            deviationMeters: Math.round(deviation),
          });
        }
      } catch (parseError: unknown) {
        logger.error("Erreur d'analyse de la geometrie d'itineraire", parseError);
      }
    }

    return {
      pingId: ping.id,
      deviationMeters: Math.round(deviation),
      limitExceeded,
      tripStatus: currentStatus,
    };
  }

  /**
   * Obtient l'historique GPS complet d'un trajet.
   */
  async getTripGPSHistory(tripId: string, limit: number = 100) {
    return db.locationPing.findMany({
      where: { tripId },
      take: limit,
      orderBy: { timestamp: "desc" },
    });
  }
}

export const gpsService = new GPSService();
