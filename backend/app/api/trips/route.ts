import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import { createTripRequestSchema } from "@/schemas";
import { rideService } from "@/services";
import { logger } from "@/utils";
import { start } from "workflow/api";
import { tripMonitorWorkflow } from "@/workflows/trip-monitor";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = createTripRequestSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Informations de trajet incompletes.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const { userId, startLat, startLng, endLat, endLng, durationSeconds } =
      parsed.data;

    let routeGeometry = JSON.stringify([
      [startLng, startLat],
      [endLng, endLat],
    ]);

    try {
      routeGeometry = await rideService.fetchOSRMRoute(
        startLng,
        startLat,
        endLng,
        endLat
      );
    } catch (osrmError: unknown) {
      logger.warn("Echec d'appel d'OSRM, trace direct de secours", {
        reason: osrmError instanceof Error ? osrmError.message : "unknown",
      });
    }

    const now = new Date();
    const endTimeEst = new Date(now.getTime() + durationSeconds * 1000);

    const trip = await db.trip.create({
      data: {
        userId,
        startLat,
        startLng,
        endLat,
        endLng,
        routeGeometry,
        status: "ACTIVE",
        endTimeEst,
      },
    });

    try {
      await start(tripMonitorWorkflow, [
        {
          tripId: trip.id,
          checkDelaySeconds: durationSeconds + 300,
        },
      ]);
    } catch (workflowError: unknown) {
      logger.warn("Workflow de surveillance execute en mode autonome", {
        tripId: trip.id,
        reason: workflowError instanceof Error ? workflowError.message : "unknown",
      });
    }

    return NextResponse.json(
      {
        success: true,
        message: "Trajet initialise et surveillance activee.",
        trip,
      },
      { status: 201 }
    );
  } catch (error: unknown) {
    logger.error("Erreur d'initialisation du trajet", error);
    return NextResponse.json(
      { error: "Impossible d'initialiser le trajet." },
      { status: 500 }
    );
  }
}
