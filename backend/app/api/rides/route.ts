import { NextResponse } from "next/server";
import { createRideSchema } from "@/schemas";
import { rideService } from "@/services";
import { AppError, logger } from "@/utils";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = createRideSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Veuillez verifier les informations du trajet.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const ride = await rideService.createRide(parsed.data);

    return NextResponse.json(
      {
        success: true,
        message: "Offre de covoiturage publiee avec succes.",
        ride,
      },
      { status: 201 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors de la creation de la course", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible de publier ce trajet pour le moment." },
      { status: 500 }
    );
  }
}

export async function GET() {
  try {
    const rides = await rideService.listAllRides();
    return NextResponse.json({ success: true, rides }, { status: 200 });
  } catch (error: unknown) {
    logger.error("Erreur lors de la recuperation des courses", error);
    return NextResponse.json(
      { error: "Impossible de charger les trajets disponibles." },
      { status: 500 }
    );
  }
}
