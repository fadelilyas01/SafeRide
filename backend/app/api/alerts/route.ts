import { NextResponse } from "next/server";
import { createAlertSchema } from "@/schemas";
import { alertService } from "@/services";
import { AppError, logger } from "@/utils";

export async function POST(request: Request) {
  try {
    const rawBody: unknown = await request.json();
    const parsed = createAlertSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message ||
        "Informations d'alerte d'urgence invalides.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const sosResult = await alertService.triggerSOS(parsed.data);

    return NextResponse.json(
      {
        success: true,
        message: "Alerte SOS transmise et rapport d'incident scelle.",
        alertId: sosResult.alertId,
        tripId: sosResult.tripId,
        status: sosResult.status,
        reportMarkdown: sosResult.report.reportMarkdown,
        integritySealSha256: sosResult.report.integritySealSha256,
        generatedAt: sosResult.report.generatedAt,
      },
      { status: 201 }
    );
  } catch (error: unknown) {
    logger.error("Erreur lors du declenchement de l'alerte SOS", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Impossible de transmettre l'alerte SOS au serveur." },
      { status: 500 }
    );
  }
}
