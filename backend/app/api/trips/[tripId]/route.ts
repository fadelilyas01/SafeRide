import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import { updateTripStatusSchema } from "@/schemas";
import { logger } from "@/utils";

export async function GET(
  _request: Request,
  { params }: { params: { tripId: string } }
) {
  try {
    const { tripId } = params;

    if (!tripId) {
      return NextResponse.json(
        { error: "L'identifiant du trajet est requis." },
        { status: 400 }
      );
    }

    const trip = await db.trip.findUnique({
      where: { id: tripId },
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
      return NextResponse.json(
        { error: "Trajet introuvable." },
        { status: 404 }
      );
    }

    if (trip.status === "COMPLETED" && trip.completedAt) {
      const expirationLimit = new Date(
        trip.completedAt.getTime() + 2 * 60 * 60 * 1000
      );
      if (new Date() > expirationLimit) {
        return NextResponse.json(
          {
            error:
              "Ce lien de suivi de trajet a expire pour des raisons de confidentialite.",
            expired: true,
          },
          { status: 410 }
        );
      }
    }

    return NextResponse.json(
      {
        success: true,
        trip,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur de recuperation du trajet de suivi", error);
    return NextResponse.json(
      { error: "Impossible de charger les details du trajet." },
      { status: 500 }
    );
  }
}

export async function PATCH(
  request: Request,
  { params }: { params: { tripId: string } }
) {
  try {
    const { tripId } = params;
    const rawBody: unknown = await request.json();
    const parsed = updateTripStatusSchema.safeParse(rawBody);

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Statut de trajet invalide." },
        { status: 400 }
      );
    }

    const existing = await db.trip.findUnique({
      where: { id: tripId },
      select: { id: true, reservationId: true },
    });

    if (!existing) {
      return NextResponse.json(
        { error: "Trajet introuvable." },
        { status: 404 }
      );
    }

    const updatedTrip = await db.trip.update({
      where: { id: tripId },
      data: {
        status: parsed.data.status,
        completedAt:
          parsed.data.status === "COMPLETED" ? new Date() : undefined,
      },
    });

    if (existing.reservationId && parsed.data.status === "COMPLETED") {
      await db.reservation.update({
        where: { id: existing.reservationId },
        data: { status: "COMPLETED" },
      });
    }

    return NextResponse.json(
      {
        success: true,
        trip: updatedTrip,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors de la cloture du trajet", error);
    return NextResponse.json(
      { error: "Impossible de mettre a jour le statut du trajet." },
      { status: 500 }
    );
  }
}
