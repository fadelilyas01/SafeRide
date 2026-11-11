/**
 * Configuration centralisee - Variables d'environnement avec validation
 */

export const config = {
  server: {
    port: parseInt(process.env.PORT || "3001", 10),
    isDev: process.env.NODE_ENV !== "production",
    isProduction: process.env.NODE_ENV === "production",
  },
  database: {
    url: process.env.DATABASE_URL || "file:./dev.db",
    logQueries: process.env.DATABASE_LOG === "true",
  },
  api: {
    version: "v1",
    prefix: "/api/v1",
    baseUrl: process.env.API_BASE_URL || "http://localhost:3001",
  },
  gps: {
    maxDeviationMeters: parseInt(process.env.GPS_MAX_DEVIATION || "150", 10),
    pingIntervalSeconds: parseInt(process.env.GPS_INTERVAL || "30", 10),
  },
  ai: {
    apiKey: process.env.GEMINI_API_KEY || "",
    enabled: Boolean(process.env.GEMINI_API_KEY),
    model: "gemini-1.5-flash",
  },
  maps: {
    maptilerApiKey: process.env.NEXT_PUBLIC_MAPTILER_API_KEY || "",
    osrmUrl: "https://router.project-osrm.org/route/v1/driving",
  },
  cors: {
    origin: process.env.CORS_ORIGIN?.split(",") || [
      "http://localhost:3000",
      "http://localhost:3001",
      "http://localhost:8081",
      "http://localhost:19000",
    ],
    credentials: true,
  },
  logging: {
    level: process.env.LOG_LEVEL || "info",
    format: process.env.LOG_FORMAT || "json",
  },
  features: {
    osrmRouting: process.env.ENABLE_OSRM !== "false",
    aiReports: process.env.ENABLE_AI !== "false",
    emailNotifications: process.env.ENABLE_EMAIL !== "false",
  },
} as const;

export type Config = typeof config;
