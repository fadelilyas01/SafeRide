import { NextResponse } from "next/server";
import { verifyReservationSchema } from "@/schemas";
import { reservationService } from "@/services";
import { AppError, logger } from "@/utils";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = verifyReservationSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Veuillez saisir un code PIN valide a 4 chiffres.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const result = await reservationService.verifyPinAndStartTrip(
      parsed.data.reservationId,
      parsed.data.verificationCode
    );

    return NextResponse.json(
      {
        success: true,
        message: "Code PIN valide. Le suivi GPS securise est desormais actif.",
        reservation: result.reservation,
        trip: result.trip,
        integritySeal: result.integritySeal,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors de la verification du code PIN", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        {
          error: error.message,
          details: error.details,
        },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible de verifier le code PIN pour le moment." },
      { status: 500 }
    );
  }
}
