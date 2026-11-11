/**
 * Types centralises - Toutes les interfaces TypeScript du domaine SafeRide
 */

export type UserRole = "USER" | "DRIVER" | "ADMIN";

export interface IUser {
  id: string;
  email: string;
  name: string | null;
  role: UserRole;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateUserDTO {
  email: string;
  password?: string;
  name?: string;
  role: UserRole;
}

export type RideStatus = "ACTIVE" | "COMPLETED" | "CANCELLED";

export interface IRide {
  id: string;
  driverId: string;
  originLabel: string;
  destinationLabel: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  departureTime: Date;
  routeGeometry?: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateRideDTO {
  driverId: string;
  originLabel?: string;
  destinationLabel?: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  departureTime: string;
}

export type ReservationStatus =
  | "PENDING"
  | "CONFIRMED"
  | "ACTIVE"
  | "COMPLETED"
  | "CANCELLED";

export interface IReservation {
  id: string;
  rideId: string;
  passengerId: string;
  status: ReservationStatus;
  verificationCode: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateReservationDTO {
  rideId: string;
  passengerId: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
}

export type TripStatus =
  | "PLANNED"
  | "ACTIVE"
  | "COMPLETED"
  | "ALERT"
  | "CANCELLED";

export interface ITrip {
  id: string;
  userId: string;
  driverId?: string | null;
  reservationId?: string | null;
  status: TripStatus;
  originLabel: string;
  destinationLabel: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  routeGeometry?: string | null;
  startTime: Date;
  endTimeEst: Date;
  completedAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateTripDTO {
  userId: string;
  driverId?: string;
  reservationId?: string;
  originLabel?: string;
  destinationLabel?: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  endTimeEst: string;
}

export interface ILocationPing {
  id: string;
  tripId: string;
  latitude: number;
  longitude: number;
  speed?: number | null;
  heading?: number | null;
  timestamp: Date;
}

export interface GPSPingDTO {
  tripId: string;
  latitude: number;
  longitude: number;
  speed?: number | null;
  heading?: number | null;
}

export type AlertStatus = "ACTIVE" | "RESOLVED";

export interface IEmergencyAlert {
  id: string;
  tripId: string;
  userId: string;
  status: AlertStatus;
  triggeredAt: Date;
  resolvedAt?: Date | null;
}

export interface CreateAlertDTO {
  tripId: string;
  userId: string;
  reason?: string;
}

export interface APIResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  timestamp: string;
}

export interface APIError {
  code: string;
  message: string;
  statusCode: number;
  details?: Record<string, unknown>;
}

export interface PaginationParams {
  page: number;
  limit: number;
  offset: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}
