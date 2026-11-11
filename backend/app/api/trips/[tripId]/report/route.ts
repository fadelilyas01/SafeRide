import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import { generateIncidentSummary } from "@/lib/ai";
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

    const reportResult = await generateIncidentSummary(trip, trip.pings);

    return NextResponse.json(
      {
        success: true,
        tripId,
        status: trip.status,
        reportMarkdown: reportResult.reportMarkdown,
        integritySealSha256: reportResult.integritySealSha256,
        generatedAt: reportResult.generatedAt,
      },
      { status: 200 }
    );
  } catch (error: unknown) {
    logger.error("Erreur API de generation du rapport d'incident", error);
    return NextResponse.json(
      { error: "Impossible de generer le rapport d'incident pour le moment." },
      { status: 500 }
    );
  }
}
