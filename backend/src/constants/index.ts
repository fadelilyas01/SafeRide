/**
 * Constantes globales
 */

export const ROLES = {
  USER: 'USER',
  DRIVER: 'DRIVER',
  ADMIN: 'ADMIN',
} as const;

export const RIDE_STATUS = {
  ACTIVE: 'ACTIVE',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

export const RESERVATION_STATUS = {
  PENDING: 'PENDING',
  CONFIRMED: 'CONFIRMED',
  ACTIVE: 'ACTIVE',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

export const TRIP_STATUS = {
  PLANNED: 'PLANNED',
  ACTIVE: 'ACTIVE',
  COMPLETED: 'COMPLETED',
  ALERT: 'ALERT',
  CANCELLED: 'CANCELLED',
} as const;

export const ALERT_STATUS = {
  ACTIVE: 'ACTIVE',
  RESOLVED: 'RESOLVED',
} as const;

export const THRESHOLDS = {
  GPS_MAX_DEVIATION_METERS: 150,
  GPS_PING_INTERVAL_SECONDS: 30,
  DEAD_MAN_SWITCH_SECONDS: 60,
  TRIP_TIMEOUT_MINUTES: 120,
  RESERVATION_EXPIRY_MINUTES: 15,
} as const;

export const MESSAGES = {
  // Success
  USER_CREATED: 'Utilisateur créé avec succès',
  USER_LOGGED_IN: 'Connexion réussie',
  RIDE_CREATED: 'Course créée avec succès',
  RIDE_DELETED: 'Course supprimée avec succès',
  RESERVATION_CREATED: 'Réservation effectuée avec succès',
  RESERVATION_CONFIRMED: 'Réservation confirmée',
  TRIP_STARTED: 'Trajet commencé',
  TRIP_COMPLETED: 'Trajet complété',
  ALERT_TRIGGERED: 'Alerte de sécurité déclenchée',

  // Errors
  USER_NOT_FOUND: 'Utilisateur non trouvé',
  RIDE_NOT_FOUND: 'Course non trouvée',
  RESERVATION_NOT_FOUND: 'Réservation non trouvée',
  TRIP_NOT_FOUND: 'Trajet non trouvé',
  INVALID_COORDINATES: 'Coordonnées invalides',
  INVALID_EMAIL: 'Email invalide',
  MISSING_REQUIRED_FIELDS: 'Champs obligatoires manquants',
  ROUTE_DEVIATION_DETECTED: 'Déviation d\'itinéraire détectée',
  TRIP_TIMEOUT: 'Trajet expiré',
} as const;

export const ERROR_CODES = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  CONFLICT: 'CONFLICT',
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',
  ROUTE_DEVIATION: 'ROUTE_DEVIATION',
  TRIP_EXPIRED: 'TRIP_EXPIRED',
  INVALID_RESERVATION_CODE: 'INVALID_RESERVATION_CODE',
} as const;

export const API_ENDPOINTS = {
  // Auth
  LOGIN: '/api/v1/auth/login',
  LOGOUT: '/api/v1/auth/logout',

  // Users
  USERS: '/api/v1/users',
  USER_PROFILE: '/api/v1/users/profile',

  // Rides
  RIDES: '/api/v1/rides',
  RIDE_DETAIL: '/api/v1/rides/:id',

  // Reservations
  RESERVATIONS: '/api/v1/reservations',
  RESERVATION_VERIFY: '/api/v1/reservations/verify',

  // Trips
  TRIPS: '/api/v1/trips',
  TRIP_DETAIL: '/api/v1/trips/:id',
  TRIP_REPORT: '/api/v1/trips/:id/report',

  // GPS
  GPS_PING: '/api/v1/gps/ping',
  GPS_HISTORY: '/api/v1/gps/history/:tripId',

  // Alerts
  ALERTS: '/api/v1/alerts',
  ALERT_DETAIL: '/api/v1/alerts/:id',

  // Health
  HEALTH: '/api/health',
} as const;
