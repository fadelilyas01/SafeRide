/**
 * Service Alertes - Declenchement SOS en temps reel et generation de rapports d'incidents
 */

import { db } from "@/lib/db";
import { generateIncidentSummary, GeneratedIncidentReport } from "@/lib/ai";
import { CreateAlertDTO } from "@/types";
import { NotFoundError, logger } from "@/utils";

export interface TriggeredSOSResult {
  alertId: string;
  tripId: string;
  status: string;
  report: GeneratedIncidentReport;
}

export class AlertService {
  /**
   * Declenche une alerte SOS sur un trajet, bascule son statut en ALERT et genere le rapport d'incident scelle.
   */
  async triggerSOS(data: CreateAlertDTO): Promise<TriggeredSOSResult> {
    const trip = await db.trip.findUnique({
      where: { id: data.tripId },
      include: {
        user: {
          select: { name: true, email: true },
        },
        pings: {
          orderBy: { timestamp: "asc" },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError("Trajet");
    }

    const [updatedTrip, alertRecord] = await db.$transaction([
      db.trip.update({
        where: { id: data.tripId },
        data: { status: "ALERT" },
      }),
      db.emergencyAlert.create({
        data: {
          tripId: data.tripId,
          userId: data.userId,
          status: "ACTIVE",
        },
      }),
    ]);

    logger.warn("Signal SOS declenche par l'utilisateur", {
      alertId: alertRecord.id,
      tripId: data.tripId,
      userId: data.userId,
    });

    const report = await generateIncidentSummary(
      {
        ...trip,
        status: updatedTrip.status,
      },
      trip.pings,
      data.reason || "Actionnement manuel du bouton d'urgence SOS"
    );

    return {
      alertId: alertRecord.id,
      tripId: data.tripId,
      status: updatedTrip.status,
      report,
    };
  }
}

export const alertService = new AlertService();
