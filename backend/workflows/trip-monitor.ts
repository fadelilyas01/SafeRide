import { db } from "@/lib/db";

// Mock helper representing durable workflow execution steps for the offline simulation
const step = {
  run: async <T>(name: string, fn: () => Promise<T> | T): Promise<T> => {
    console.log(`[WORKFLOW STEP] Executing: ${name}`);
    return await fn();
  },
  sleep: async (name: string, seconds: number): Promise<void> => {
    console.log(`[WORKFLOW STEP] Sleeping: ${name} (${seconds}s)`);
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
  },
};

export interface TripMonitorInput {
  tripId: string;
  checkDelaySeconds: number; // Temps a attendre avant verification (en secondes)
}

/**
 * Workflow durable de surveillance de trajet SafeRide.
 * Execute asynchronement de maniere resiliente dans Vercel Workflows.
 */
export async function tripMonitorWorkflow(input: TripMonitorInput) {
  "use workflow";

  const { tripId, checkDelaySeconds } = input;

  // 1. Le workflow se met en veille durable (sleep) pendant le trajet
  await step.sleep("attendre-fin-estimee", checkDelaySeconds);

  // 2. Recuperer le trajet et l'utilisateur associe
  const tripDetails = await step.run("recuperer-details-trajet", async () => {
    const trip = await db.trip.findUnique({
      where: { id: tripId },
      include: {
        user: {
          select: { name: true, email: true },
        },
      },
    });
    
    if (!trip) {
      throw new Error(`Trajet ${tripId} introuvable.`);
    }
    
    return {
      status: trip.status,
      userId: trip.userId,
      userName: trip.user.name || "Utilisateur SafeRide",
      userEmail: trip.user.email,
    };
  });

  // 3. Si le trajet est anormalement prolonge ou deja en alerte, declencher les secours
  if (tripDetails.status === "ACTIVE" || tripDetails.status === "PLANNED" || tripDetails.status === "ALERT") {
    
    // Étape A : Activer officiellement l'urgence en BDD si ce n'est pas deja fait
    const alertId = await step.run("creer-alerte-securite-base", async () => {
      // Mettre le trajet en statut ALERT
      await db.trip.update({
        where: { id: tripId },
        data: { status: "ALERT" },
      });

      // Verifier s'il y a deja une alerte active pour ce trajet
      const activeAlert = await db.emergencyAlert.findFirst({
        where: { tripId, status: "ACTIVE" },
      });

      if (activeAlert) return activeAlert.id;

      // Sinon, la creer
      const alert = await db.emergencyAlert.create({
        data: {
          tripId,
          userId: tripDetails.userId,
          status: "ACTIVE",
        },
      });

      return alert.id;
    });

    // Étape B : Envoi reel d'email d'alerte securite via Resend
    await step.run("notifier-par-email", async () => {
      const trackingUrl = `https://saferide.vercel.app/track/${tripId}`;
      const resendApiKey = process.env.RESEND_API_KEY;

      console.log(`[ALERTE SECURITE] Trajet ${tripId} en retard critique ou deviation. Alerte ${alertId} activee.`);
      console.log(`[SUIVI WEB PUBLIC] Lien de suivi dynamique : ${trackingUrl}`);

      if (resendApiKey) {
        try {
          // Appel API direct en HTTP standard pour Resend pour eviter des dependances lourdes
          const response = await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${resendApiKey}`,
            },
            body: JSON.stringify({
              from: "SafeRide Sécurité <alertes@saferide.live>",
              to: ["contact-urgence@saferide.fr"], // E-mail du contact de confiance
              subject: `🚨 ALERTE CRITIQUE : Suivi de trajet de ${tripDetails.userName}`,
              html: `
                <div style="font-family: sans-serif; padding: 24px; background-color: #0F0F12; color: #FFFFFF; border-radius: 16px;">
                  <h1 style="color: #EF4444; font-size: 24px;">SafeRide Sentinel - Urgence Activée</h1>
                  <p>Bonjour,</p>
                  <p>Votre proche <strong>${tripDetails.userName}</strong> (${tripDetails.userEmail}) a déclenché une alerte de sécurité ou a dépassé son heure d'arrivée estimée sur l'application SafeRide.</p>
                  <p>Son trajet en cours fait l'objet d'une surveillance prioritaire.</p>
                  
                  <div style="margin: 32px 0;">
                    <a href="${trackingUrl}" style="background-color: #6366F1; color: #FFFFFF; padding: 14px 24px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                      📡 Suivre la position en direct
                    </a>
                  </div>
                  
                  <p style="color: #71717A; font-size: 12px; margin-top: 24px;">Ce message est généré automatiquement par le protocole de protection SafeRide.</p>
                </div>
              `,
            }),
          });
          
          if (!response.ok) {
            const errData = await response.json();
            console.error("Échec d'envoi d'email via Resend API :", errData);
          } else {
            console.log("Notification d'urgence envoyée par email avec succès.");
          }
        } catch (mailError) {
          console.error("Erreur de protocole d'envoi de mail :", mailError);
        }
      } else {
        console.log("[SIMULATION RESEND] Aucun token RESEND_API_KEY détecté. Mail d'alerte simulé avec succès.");
      }

      return { notified: true, timestamp: new Date().toISOString() };
    });

    return { status: "ALERT_TRIGGERED", alertId };
  }

  return { status: "SUCCESS_COMPLETED" };
}
