/**
 * Schemas de validation Zod pour l'ensemble des routes API SafeRide
 */

import { z } from "zod";

export const createUserSchema = z.object({
  email: z.string().trim().email("Veuillez saisir une adresse email valide."),
  password: z
    .string()
    .min(6, "Le mot de passe doit contenir au moins 6 caracteres.")
    .max(128)
    .optional(),
  name: z.string().trim().min(1).max(100).optional(),
  role: z.enum(["USER", "DRIVER", "ADMIN"]).default("USER"),
});

export const userResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().nullable(),
  role: z.enum(["USER", "DRIVER", "ADMIN"]),
});

export const createRideSchema = z.object({
  driverId: z.string().min(1, "L'identifiant du conducteur est requis."),
  originLabel: z
    .string()
    .trim()
    .min(2)
    .max(120)
    .default("Paris - Gare de Lyon"),
  destinationLabel: z
    .string()
    .trim()
    .min(2)
    .max(120)
    .default("Campus de Versailles"),
  startLat: z.number().min(-90).max(90),
  startLng: z.number().min(-180).max(180),
  endLat: z.number().min(-90).max(90),
  endLng: z.number().min(-180).max(180),
  departureTime: z.string().refine((val) => !Number.isNaN(Date.parse(val)), {
    message: "La date de depart est invalide.",
  }),
});

export const createReservationSchema = z.object({
  rideId: z.string().min(1, "L'identifiant du trajet est requis."),
  passengerId: z.string().min(1, "L'identifiant du passager est requis."),
  startLat: z.number().min(-90).max(90),
  startLng: z.number().min(-180).max(180),
  endLat: z.number().min(-90).max(90),
  endLng: z.number().min(-180).max(180),
});

export const patchReservationSchema = z.object({
  reservationId: z
    .string()
    .min(1, "L'identifiant de la reservation est requis."),
  driverId: z.string().min(1, "L'identifiant du conducteur est requis."),
  action: z.enum(["accept", "cancel"]),
});

export const verifyReservationSchema = z.object({
  reservationId: z
    .string()
    .min(1, "L'identifiant de la reservation est requis."),
  verificationCode: z
    .string()
    .regex(/^\d{4}$/, "Le code PIN doit comporter exactement 4 chiffres."),
});

export const createTripRequestSchema = z.object({
  userId: z.string().min(1, "L'identifiant de l'utilisateur est requis."),
  driverId: z.string().optional(),
  reservationId: z.string().optional(),
  originLabel: z.string().trim().min(2).max(120).optional(),
  destinationLabel: z.string().trim().min(2).max(120).optional(),
  startLat: z.number().min(-90).max(90),
  startLng: z.number().min(-180).max(180),
  endLat: z.number().min(-90).max(90),
  endLng: z.number().min(-180).max(180),
  durationSeconds: z.number().int().min(60).max(86400),
});

export const updateTripStatusSchema = z.object({
  status: z.enum(["PLANNED", "ACTIVE", "COMPLETED", "ALERT", "CANCELLED"]),
});

export const gpsLocationSchema = z.object({
  tripId: z.string().min(1, "L'identifiant du trajet est requis."),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  speed: z.number().min(0).nullable().optional(),
  heading: z.number().min(0).max(360).nullable().optional(),
});

export const createAlertSchema = z.object({
  tripId: z.string().min(1, "L'identifiant du trajet est requis."),
  userId: z.string().min(1, "L'identifiant de l'utilisateur est requis."),
  reason: z.string().max(500).optional(),
});

export const paginationSchema = z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(10),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type CreateRideInput = z.infer<typeof createRideSchema>;
export type CreateReservationInput = z.infer<typeof createReservationSchema>;
export type PatchReservationInput = z.infer<typeof patchReservationSchema>;
export type VerifyReservationInput = z.infer<typeof verifyReservationSchema>;
export type CreateTripRequestInput = z.infer<typeof createTripRequestSchema>;
export type GPSLocationInput = z.infer<typeof gpsLocationSchema>;
export type CreateAlertInput = z.infer<typeof createAlertSchema>;
