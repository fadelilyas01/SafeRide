import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import { rideService } from "@/services";
import { logger } from "@/utils";

export async function GET() {
  try {
    await rideService.listAllRides();

    const [trips, alerts, rides, totalPings] = await Promise.all([
      db.trip.findMany({
        include: {
          user: { select: { name: true, email: true } },
          driver: { select: { name: true, email: true } },
          pings: {
            orderBy: { timestamp: "desc" },
            take: 1,
          },
        },
        orderBy: { createdAt: "desc" },
        take: 20,
      }),
      db.emergencyAlert.findMany({
        include: {
          trip: {
            select: {
              id: true,
              originLabel: true,
              destinationLabel: true,
              status: true,
              user: { select: { name: true, email: true } },
            },
          },
        },
        orderBy: { triggeredAt: "desc" },
        take: 15,
      }),
      db.ride.findMany({
        include: {
          driver: { select: { name: true, email: true } },
          reservations: { select: { id: true, status: true } },
        },
        orderBy: { departureTime: "asc" },
        take: 10,
      }),
      db.locationPing.count(),
    ]);

    return NextResponse.json(
      {
        success: true,
        stats: {
          activeTrips: trips.filter(
            (t) => t.status === "ACTIVE" || t.status === "ALERT"
          ).length,
          activeAlerts: alerts.filter((a) => a.status === "ACTIVE").length,
          availableRides: rides.length,
          totalPings,
        },
        trips,
        alerts,
        rides,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors du chargement de la supervision", error);
    return NextResponse.json(
      { error: "Impossible de charger les donnees de supervision." },
      { status: 500 }
    );
  }
}
