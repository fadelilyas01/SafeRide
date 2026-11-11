import { NextResponse } from "next/server";
import { createReservationSchema, patchReservationSchema } from "@/schemas";
import { reservationService } from "@/services";
import { AppError, logger } from "@/utils";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = createReservationSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Les informations de reservation sont incompletes.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const reservation = await reservationService.createReservation(parsed.data);

    return NextResponse.json(
      {
        success: true,
        message: "Demande de reservation creee. En attente du conducteur.",
        reservation,
      },
      { status: 201 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors de la creation de la reservation", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible d'enregistrer votre reservation pour le moment." },
      { status: 500 }
    );
  }
}

export async function PATCH(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = patchReservationSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Requete de mise a jour de reservation invalide.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const updatedReservation = await reservationService.updateReservationStatus(
      parsed.data.reservationId,
      parsed.data.driverId,
      parsed.data.action
    );

    return NextResponse.json(
      {
        success: true,
        message: "Statut de la reservation mis a jour avec succes.",
        reservation: updatedReservation,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors de la mise a jour de la reservation", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible de modifier cette reservation pour le moment." },
      { status: 500 }
    );
  }
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const passengerId = searchParams.get("passengerId") || undefined;
    const driverId = searchParams.get("driverId") || undefined;

    const reservations = await reservationService.listReservations({
      passengerId,
      driverId,
    });

    return NextResponse.json({ success: true, reservations }, { status: 200 });
  } catch (error: unknown) {
    logger.error("Erreur lors de la lecture des reservations", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible de recuperer les reservations." },
      { status: 500 }
    );
  }
}
