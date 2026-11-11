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

export interface BookingLifecycleInput {
  reservationId: string;
}

/**
 * Workflow durable de gestion du cycle de vie des réservations SafeRide.
 * Exécuté de manière résiliente et distribuée par Vercel Workflows.
 */
export async function bookingLifecycleWorkflow(input: BookingLifecycleInput) {
  "use workflow";

  const { reservationId } = input;

  // 1. Récupérer les détails de la réservation
  const reservationDetails = await step.run("recuperer-reservation", async () => {
    const reservation = await db.reservation.findUnique({
      where: { id: reservationId },
      include: {
        passenger: {
          select: { name: true, email: true },
        },
        ride: {
          include: {
            driver: {
              select: { name: true, email: true },
            },
          },
        },
      },
    });

    if (!reservation) {
      throw new Error(`Réservation ${reservationId} introuvable.`);
    }

    return {
      passengerName: reservation.passenger.name || "Passager SafeRide",
      passengerEmail: reservation.passenger.email,
      driverName: reservation.ride.driver.name || "Conducteur SafeRide",
      driverEmail: reservation.ride.driver.email,
      departureTime: reservation.ride.departureTime.toISOString(),
      startLat: reservation.startLat,
      startLng: reservation.startLng,
      status: reservation.status,
    };
  });

  // 2. Planifier un rappel le jour J (1 heure avant le départ)
  const departureDate = new Date(reservationDetails.departureTime);
  const now = new Date();
  const timeUntilDepartureSeconds = Math.floor((departureDate.getTime() - now.getTime()) / 1000);
  const reminderDelaySeconds = timeUntilDepartureSeconds - 3600; // 1 heure avant le départ

  if (reminderDelaySeconds > 0) {
    await step.sleep("attendre-rappel-jour-j", reminderDelaySeconds);

    await step.run("envoyer-email-rappel", async () => {
      const resendApiKey = process.env.RESEND_API_KEY;
      console.log(`[RAPPEL] Covoiturage SafeRide : le départ approche pour ${reservationDetails.passengerName} avec ${reservationDetails.driverName}`);

      if (resendApiKey) {
        try {
          await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${resendApiKey}`,
            },
            body: JSON.stringify({
              from: "SafeRide Covoiturage <covoiturage@saferide.live>",
              to: [reservationDetails.passengerEmail],
              subject: `📅 Rappel SafeRide : Votre trajet démarre dans 1 heure !`,
              html: `
                <div style="font-family: sans-serif; padding: 24px; background-color: #0F0F12; color: #FFFFFF; border-radius: 16px;">
                  <h1 style="color: #6366F1; font-size: 24px;">Votre trajet approche</h1>
                  <p>Bonjour <strong>${reservationDetails.passengerName}</strong>,</p>
                  <p>Ceci est un rappel que votre trajet de covoiturage sécurisé avec <strong>${reservationDetails.driverName}</strong> est prévu pour aujourd'hui à <strong>${departureDate.toLocaleTimeString()}</strong>.</p>
                  <p>N'oubliez pas de fournir de vive voix votre <strong>code PIN unique</strong> à votre conducteur à son arrivée pour valider la prise en charge et activer votre surveillance en temps réel.</p>
                  <div style="color: #71717A; font-size: 12px; margin-top: 24px;">Équipe SafeRide Security</div>
                </div>
              `,
            }),
          });
        } catch (err) {
          console.error("Erreur envoi email rappel:", err);
        }
      }
    });
  }

  // 3. Attendre l'heure de départ prévue
  const remainingTimeSeconds = Math.floor((departureDate.getTime() - new Date().getTime()) / 1000);
  if (remainingTimeSeconds > 0) {
    await step.sleep("attendre-heure-depart", remainingTimeSeconds);
  }

  // 4. Délai de grâce (15 minutes soit 900 secondes) pour valider la prise en charge (saisie du PIN)
  // On effectue un polling toutes les 60 secondes pour vérifier si le statut est passé à ACTIVE
  let isVerified = false;
  for (let attempt = 0; attempt < 15; attempt++) {
    isVerified = await step.run(`verifier-saisie-pin-essai-${attempt}`, async () => {
      const res = await db.reservation.findUnique({
        where: { id: reservationId },
        select: { status: true },
      });
      return res?.status === "ACTIVE";
    });

    if (isVerified) {
      break;
    }

    if (attempt < 14) {
      await step.sleep(`attendre-saisie-pin-essai-${attempt}`, 60); // Attendre 1 minute
    }
  }

  // 5. Si après 15 minutes le trajet n'a toujours pas été validé par code PIN : lever une alerte de sécurité ou expirer
  if (!isVerified) {
    await step.run("declencher-alerte-securite-retard-critique", async () => {
      // Marquer la réservation comme annulée
      await db.reservation.update({
        where: { id: reservationId },
        data: { status: "CANCELLED" },
      });

      console.warn(`🚨 [ALERTE SECURITE] La réservation de covoiturage ${reservationId} n'a pas démarré à temps. Aucun PIN saisi dans les 15 minutes.`);

      const resendApiKey = process.env.RESEND_API_KEY;
      if (resendApiKey) {
        try {
          await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${resendApiKey}`,
            },
            body: JSON.stringify({
              from: "SafeRide Sécurité <alertes@saferide.live>",
              to: ["contact-urgence@saferide.fr", reservationDetails.passengerEmail],
              subject: `🚨 ALERTE SECURITE : Non-démarrage du trajet SafeRide`,
              html: `
                <div style="font-family: sans-serif; padding: 24px; background-color: #0F0F12; color: #FFFFFF; border-radius: 16px; border: 2px solid #EF4444;">
                  <h1 style="color: #EF4444; font-size: 24px;">Alerte de Sécurité - Non-démarrage</h1>
                  <p>Bonjour,</p>
                  <p>Le trajet de covoiturage de <strong>${reservationDetails.passengerName}</strong> (${reservationDetails.passengerEmail}) qui devait démarrer à <strong>${departureDate.toLocaleTimeString()}</strong> n'a pas officiellement commencé.</p>
                  <p>Le conducteur <strong>${reservationDetails.driverName}</strong> n'a pas validé le code PIN d'authentification requis.</p>
                  <p>Par mesure de sécurité, nous vous invitons à contacter votre proche immédiatement pour vous assurer que tout va bien.</p>
                </div>
              `,
            }),
          });
        } catch (err) {
          console.error("Erreur envoi email alerte non-démarrage:", err);
        }
      }
    });

    return { status: "EXPIRED_ALERT_TRIGGERED" };
  }

  return { status: "STARTED_SUCCESSFULLY" };
}
