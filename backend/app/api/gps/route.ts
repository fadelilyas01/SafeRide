import { NextResponse } from "next/server";
import { gpsLocationSchema } from "@/schemas";
import { gpsService } from "@/services";
import { AppError, logger } from "@/utils";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = gpsLocationSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message || "Coordonnees GPS invalides.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const result = await gpsService.recordGPSPing(parsed.data);

    return NextResponse.json(
      {
        success: true,
        pingId: result.pingId,
        deviationMeters: result.deviationMeters,
        limitExceeded: result.limitExceeded,
        tripStatus: result.tripStatus,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors du traitement du ping GPS", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible d'enregistrer la position GPS." },
      { status: 500 }
    );
  }
}
