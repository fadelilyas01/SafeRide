/**
 * Utilitaires - Gestion d'erreurs typees, journalisation structuree et formatage
 */

import { APIError, APIResponse } from "@/types";
export * from "./security";

export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = "AppError";
  }

  toJSON(): APIError {
    return {
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      details: this.details,
    };
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super("VALIDATION_ERROR", message, 400, details);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super("NOT_FOUND", `${resource} introuvable.`, 404);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = "Authentification requise.") {
    super("UNAUTHORIZED", message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = "Acces refuse.") {
    super("FORBIDDEN", message, 403);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super("CONFLICT", message, 409);
  }
}

export class RateLimitError extends AppError {
  constructor(message: string, retryAfterSeconds: number) {
    super("RATE_LIMITED", message, 429, { retryAfterSeconds });
  }
}

export class InternalServerError extends AppError {
  constructor(
    message: string = "Une erreur interne est survenue. Veuillez reessayer.",
    details?: Record<string, unknown>
  ) {
    super("INTERNAL_SERVER_ERROR", message, 500, details);
  }
}

interface LogEntry {
  timestamp: string;
  level: string;
  message: string;
  meta?: Record<string, unknown>;
  error?: string;
}

export const logger = {
  debug: (message: string, meta?: Record<string, unknown>) => {
    logEntry("DEBUG", message, meta);
  },
  info: (message: string, meta?: Record<string, unknown>) => {
    logEntry("INFO", message, meta);
  },
  warn: (message: string, meta?: Record<string, unknown>) => {
    logEntry("WARN", message, meta);
  },
  error: (message: string, error?: unknown) => {
    logEntry("ERROR", message, undefined, error);
  },
};

function logEntry(
  level: string,
  message: string,
  meta?: Record<string, unknown>,
  error?: unknown
) {
  const entry: LogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
  };

  if (meta) entry.meta = meta;
  if (error) {
    entry.error = error instanceof Error ? error.message : String(error);
  }

  if (level === "ERROR") {
    console.error(JSON.stringify(entry));
  } else if (level === "WARN") {
    console.warn(JSON.stringify(entry));
  } else if (process.env.NODE_ENV !== "production") {
    console.info(JSON.stringify(entry));
  }
}

export function successResponse<T>(data: T): APIResponse<T> {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
  };
}

export function errorResponse(error: AppError): APIResponse {
  return {
    success: false,
    error: {
      code: error.code,
      message: error.message,
      details: error.details,
    },
    timestamp: new Date().toISOString(),
  };
}

export const validators = {
  isValidEmail: (email: string): boolean => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  },
  isValidUUID: (uuid: string): boolean => {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
      uuid
    );
  },
  isValidCoordinates: (lat: number, lng: number): boolean => {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  },
  isValidPIN: (pin: string): boolean => {
    return /^\d{4}$/.test(pin);
  },
};

export const formatters = {
  formatCoordinates: (lat: number, lng: number): string => {
    return `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
  },
  formatDistance: (meters: number): string => {
    if (meters < 1000) return `${Math.round(meters)}m`;
    return `${(meters / 1000).toFixed(1)}km`;
  },
  formatDuration: (seconds: number): string => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) return `${hours}h ${minutes}min`;
    if (minutes > 0) return `${minutes}min ${secs}s`;
    return `${secs}s`;
  },
  formatSpeed: (mps: number): string => {
    const kmh = mps * 3.6;
    return `${Math.round(kmh)} km/h`;
  },
};

export const calculatePagination = (page: number, limit: number) => {
  return {
    page: Math.max(1, page),
    limit: Math.min(100, Math.max(1, limit)),
    offset: Math.max(0, (page - 1) * limit),
  };
};
