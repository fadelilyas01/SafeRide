import { z } from "zod";
import { computeCanonicalSha256, logger } from "@/utils";

export interface IncidentTripPayload {
  id: string;
  status: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  endTimeEst: Date | string;
  user: {
    name: string | null;
    email: string;
  };
}

export interface IncidentPingPayload {
  latitude: number;
  longitude: number;
  speed: number | null;
  heading?: number | null;
  timestamp: Date | string;
}

export interface GeneratedIncidentReport {
  reportMarkdown: string;
  integritySealSha256: string;
  generatedAt: string;
}

const geminiResponseSchema = z.object({
  candidates: z
    .array(
      z.object({
        content: z.object({
          parts: z.array(
            z.object({
              text: z.string().optional(),
            })
          ),
        }),
      })
    )
    .optional(),
});

/**
 * Construit un rapport d'incident factuel, structure et scelle cryptographiquement (SHA-256).
 * En l'absence de cle API Gemini ou en cas d'indisponibilite reseau, genere une synthese deterministe
 * basee sur la telemetrie reelle sans jamais divulguer de details techniques internes (CWE-209).
 */
export async function generateIncidentSummary(
  tripData: IncidentTripPayload,
  locationPings: IncidentPingPayload[],
  reason?: string
): Promise<GeneratedIncidentReport> {
  const generatedAt = new Date().toISOString();
  const recentPings = locationPings.slice(-30);
  const lastPing = recentPings[recentPings.length - 1];

  const sealPayload: Record<string, unknown> = {
    tripId: tripData.id,
    status: tripData.status,
    passengerEmail: tripData.user.email,
    pingCount: locationPings.length,
    lastLat: lastPing ? lastPing.latitude : tripData.startLat,
    lastLng: lastPing ? lastPing.longitude : tripData.startLng,
    generatedAt,
  };
  const integritySealSha256 = computeCanonicalSha256(sealPayload);

  const geminiApiKey = process.env.GEMINI_API_KEY;

  const pingsSummary =
    recentPings.length > 0
      ? recentPings
          .map(
            (p) =>
              `- Position : [Lat: ${p.latitude.toFixed(5)}, Lng: ${p.longitude.toFixed(5)}] | Vitesse : ${
                p.speed ? Math.round(p.speed * 3.6) + " km/h" : "0 km/h"
              } | Heure : ${new Date(p.timestamp).toLocaleTimeString("fr-FR")}`
          )
          .join("\n")
      : "- Aucun releve GPS additionnel enregistre depuis le point de depart.";

  if (!geminiApiKey) {
    const deterministicReport = [
      `# Rapport d'Incident de Securite SafeRide`,
      ``,
      `- **Identifiant du trajet :** \`${tripData.id}\``,
      `- **Passager :** ${tripData.user.name || "Passager SafeRide"} (${tripData.user.email})`,
      `- **Statut du trajet :** \`${tripData.status}\``,
      `- **Motif du signalement :** ${reason || "Declenchement d'urgence ou anomalie d'itineraire"}`,
      `- **Derniere position connue :** Lat ${
        lastPing ? lastPing.latitude.toFixed(5) : tripData.startLat.toFixed(5)
      }, Lng ${lastPing ? lastPing.longitude.toFixed(5) : tripData.startLng.toFixed(5)}`,
      `- **Horodatage UTC :** ${generatedAt}`,
      `- **Empreinte d'integrite SHA-256 :** \`${integritySealSha256}\``,
      ``,
      `## Releves Telemetriques Recents`,
      pingsSummary,
    ].join("\n");

    return {
      reportMarkdown: deterministicReport,
      integritySealSha256,
      generatedAt,
    };
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 8000);

  try {
    const prompt = `
      Tu es un analyste en securite des transports pour l'application SafeRide.
      Redige un rapport d'incident clair, structure et factuel destine aux contacts de confiance et aux equipes d'assistance.

      Details du trajet :
      - Identifiant du trajet : ${tripData.id}
      - Passager : ${tripData.user.name || "Non renseigne"} (${tripData.user.email})
      - Statut actuel : ${tripData.status}
      - Motif : ${reason || "Alerte de securite"}
      - Point de depart : [Lat: ${tripData.startLat}, Lng: ${tripData.startLng}]
      - Destination prevue : [Lat: ${tripData.endLat}, Lng: ${tripData.endLng}]
      - Heure d'arrivee estimee : ${new Date(tripData.endTimeEst).toLocaleTimeString("fr-FR")}

      Historique des derniers releves GPS :
      ${pingsSummary}

      Instructions :
      1. Redige une synthese chronologique (depart, derniers signaux recus).
      2. Evalue la cinematique (vitesse, arrets prolonges ou ecart de trajectoire).
      3. Mentionne l'empreinte d'integrite SHA-256 : ${integritySealSha256}.
      4. Redige en francais professionnel au format Markdown.
    `;

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${encodeURIComponent(
        geminiApiKey
      )}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
        signal: controller.signal,
      }
    );

    if (!response.ok) {
      throw new Error(`Gemini HTTP ${response.status}`);
    }

    const rawJson: unknown = await response.json();
    const parsed = geminiResponseSchema.safeParse(rawJson);
    const generatedText =
      parsed.success &&
      parsed.data.candidates?.[0]?.content.parts[0]?.text;

    if (!generatedText) {
      throw new Error("Reponse Gemini vide");
    }

    return {
      reportMarkdown: generatedText,
      integritySealSha256,
      generatedAt,
    };
  } catch (error: unknown) {
    logger.error("Echec de generation du rapport IA Gemini", error);
    const fallbackReport = [
      `# Rapport d'Incident de Securite SafeRide (Synthese de Secours)`,
      ``,
      `- **Identifiant du trajet :** \`${tripData.id}\``,
      `- **Passager :** ${tripData.user.name || "Passager SafeRide"}`,
      `- **Statut :** \`${tripData.status}\``,
      `- **Derniere position connue :** Lat ${
        lastPing ? lastPing.latitude.toFixed(5) : tripData.startLat.toFixed(5)
      }, Lng ${lastPing ? lastPing.longitude.toFixed(5) : tripData.startLng.toFixed(5)}`,
      `- **Empreinte d'integrite SHA-256 :** \`${integritySealSha256}\``,
      ``,
      `## Releves Telemetriques Recents`,
      pingsSummary,
    ].join("\n");

    return {
      reportMarkdown: fallbackReport,
      integritySealSha256,
      generatedAt,
    };
  } finally {
    clearTimeout(timeoutId);
  }
}
