"use client";

import React, { useEffect, useState, useRef } from "react";
import { useParams } from "next/navigation";
import type { Map as MapLibreMap, Marker as MapLibreMarker } from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

interface Ping {
  id: string;
  latitude: number;
  longitude: number;
  speed: number | null;
  heading: number | null;
  timestamp: string;
}

interface TripData {
  id: string;
  status: string;
  originLabel?: string;
  destinationLabel?: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  routeGeometry: string | null;
  endTimeEst: string;
  user: {
    name: string;
    email: string;
  };
  pings: Ping[];
}

export default function PublicLiveTracker() {
  const { tripId } = useParams<{ tripId: string }>();
  const [trip, setTrip] = useState<TripData | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const markerRef = useRef<MapLibreMarker | null>(null);

  useEffect(() => {
    if (!tripId) return;

    let activeController: AbortController | null = null;

    const fetchTripData = async () => {
      if (activeController) {
        activeController.abort();
      }
      const controller = new AbortController();
      activeController = controller;
      const timeoutId = setTimeout(() => controller.abort(), 8000);

      try {
        const res = await fetch(`/api/trips/${tripId}`, {
          signal: controller.signal,
        });
        const data = (await res.json()) as { trip?: TripData; error?: string };

        if (!res.ok || !data.trip) {
          throw new Error(
            data.error ||
              "Impossible de recuperer les informations de suivi en direct."
          );
        }

        setTrip(data.trip);
        setErrorMsg(null);
      } catch (err: unknown) {
        if (err instanceof Error && err.name === "AbortError") {
          return;
        }
        setErrorMsg(
          err instanceof Error
            ? err.message
            : "Connexion au suivi temporairement interrompue."
        );
      } finally {
        clearTimeout(timeoutId);
        setIsLoading(false);
      }
    };

    fetchTripData();
    const interval = setInterval(fetchTripData, 5000);

    return () => {
      clearInterval(interval);
      if (activeController) {
        activeController.abort();
      }
    };
  }, [tripId]);

  useEffect(() => {
    if (!trip || !mapContainerRef.current || mapRef.current) return;

    const maptilerKey = process.env.NEXT_PUBLIC_MAPTILER_API_KEY || "";
    const styleUrl = maptilerKey
      ? `https://api.maptiler.com/maps/streets-v2-dark/style.json?key=${maptilerKey}`
      : "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json";

    import("maplibre-gl").then((maplibregl) => {
      if (!mapContainerRef.current) return;

      const initialCenter: [number, number] =
        trip.pings.length > 0
          ? [
              trip.pings[trip.pings.length - 1].longitude,
              trip.pings[trip.pings.length - 1].latitude,
            ]
          : [trip.startLng, trip.startLat];

      const map = new maplibregl.Map({
        container: mapContainerRef.current,
        style: styleUrl,
        center: initialCenter,
        zoom: 13.5,
      });

      map.addControl(new maplibregl.NavigationControl(), "bottom-right");
      mapRef.current = map;

      const el = document.createElement("div");
      el.className = "pulse-marker";
      el.style.width = "20px";
      el.style.height = "20px";
      el.style.borderRadius = "50%";
      el.style.backgroundColor = "#6366F1";
      el.style.border = "3px solid #FFFFFF";
      el.style.boxShadow = "0 0 10px rgba(99, 102, 241, 0.8)";

      const marker = new maplibregl.Marker({ element: el })
        .setLngLat(initialCenter)
        .addTo(map);

      markerRef.current = marker;

      map.on("load", () => {
        if (trip.routeGeometry) {
          try {
            const coords = JSON.parse(trip.routeGeometry) as [number, number][];
            map.addSource("route", {
              type: "geojson",
              data: {
                type: "Feature",
                properties: {},
                geometry: {
                  type: "LineString",
                  coordinates: coords,
                },
              },
            });

            map.addLayer({
              id: "route",
              type: "line",
              source: "route",
              layout: {
                "line-join": "round",
                "line-cap": "round",
              },
              paint: {
                "line-color": "#6366F1",
                "line-width": 5,
                "line-opacity": 0.9,
              },
            });
          } catch (e: unknown) {
            console.error("Erreur de trace de l'itineraire theorique:", e);
          }
        }
      });
    });
  }, [trip]);

  useEffect(() => {
    if (!trip || !markerRef.current) return;

    const latestPing = trip.pings[trip.pings.length - 1];
    if (latestPing) {
      markerRef.current.setLngLat([latestPing.longitude, latestPing.latitude]);

      if (mapRef.current) {
        mapRef.current.easeTo({
          center: [latestPing.longitude, latestPing.latitude],
          duration: 1000,
        });
      }
    }
  }, [trip?.pings]);

  if (isLoading) {
    return (
      <div style={styles.centerContainer}>
        <div style={styles.spinner}></div>
        <p style={styles.loadingText}>
          Connexion securisee au canal de suivi...
        </p>
      </div>
    );
  }

  if (errorMsg || !trip) {
    return (
      <div style={styles.centerContainer}>
        <h2 style={styles.errorTitle}>Lien expire ou indisponible</h2>
        <p style={styles.errorText}>
          {errorMsg || "Ce trajet est introuvable ou a pris fin."}
        </p>
      </div>
    );
  }

  const latestPing = trip.pings[trip.pings.length - 1];

  return (
    <div style={styles.container}>
      <div style={styles.panel}>
        <div style={styles.panelRow}>
          <div>
            <h1 style={styles.title}>Suivi en Direct de {trip.user.name}</h1>
            <p style={styles.subtitle}>
              {trip.originLabel || "Point de depart"} →{" "}
              {trip.destinationLabel || "Destination"}
            </p>
          </div>
          <div
            style={{
              ...styles.badge,
              ...(trip.status === "ALERT"
                ? styles.badgeAlert
                : trip.status === "ACTIVE"
                ? styles.badgeActive
                : styles.badgeCompleted),
            }}
          >
            {trip.status === "ALERT"
              ? "SIGNAL D'ALERTE SOS"
              : trip.status === "ACTIVE"
              ? "En cours"
              : "Termine"}
          </div>
        </div>

        <div style={styles.divider}></div>

        <div style={styles.telemetryRow}>
          <div style={styles.telemetryItem}>
            <span style={styles.telemetryLabel}>Vitesse Actuelle</span>
            <span style={styles.telemetryVal}>
              {latestPing?.speed
                ? `${Math.round(latestPing.speed * 3.6)} km/h`
                : "A l'arret"}
            </span>
          </div>
          <div style={styles.telemetryItem}>
            <span style={styles.telemetryLabel}>Dernier Signal</span>
            <span style={styles.telemetryVal}>
              {latestPing
                ? new Date(latestPing.timestamp).toLocaleTimeString("fr-FR")
                : "Position initiale"}
            </span>
          </div>
          <div style={styles.telemetryItem}>
            <span style={styles.telemetryLabel}>Arrivee Estimee</span>
            <span style={styles.telemetryVal}>
              {new Date(trip.endTimeEst).toLocaleTimeString("fr-FR")}
            </span>
          </div>
        </div>
      </div>

      <div ref={mapContainerRef} style={styles.mapContainer}></div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    display: "flex",
    flexDirection: "column",
    width: "100vw",
    height: "100vh",
    backgroundColor: "#090D16",
    fontFamily: "'Inter', sans-serif",
    position: "relative",
    overflow: "hidden",
  },
  centerContainer: {
    display: "flex",
    flexDirection: "column",
    width: "100vw",
    height: "100vh",
    backgroundColor: "#090D16",
    alignItems: "center",
    justifyContent: "center",
    color: "#F8FAFC",
    fontFamily: "'Inter', sans-serif",
  },
  spinner: {
    width: "48px",
    height: "48px",
    borderRadius: "50%",
    border: "3px solid #1E293B",
    borderTopColor: "#6366F1",
    marginBottom: "16px",
  },
  loadingText: {
    color: "#94A3B8",
    fontSize: "15px",
    fontWeight: 600,
  },
  errorTitle: {
    fontSize: "24px",
    fontWeight: 800,
    color: "#F8FAFC",
    marginBottom: "8px",
  },
  errorText: {
    color: "#94A3B8",
    fontSize: "14px",
    textAlign: "center",
    maxWidth: "360px",
    lineHeight: "20px",
  },
  panel: {
    position: "absolute",
    top: "24px",
    left: "24px",
    right: "24px",
    backgroundColor: "rgba(19, 27, 46, 0.95)",
    border: "1px solid #1E293B",
    borderRadius: "16px",
    padding: "24px",
    zIndex: 10,
    color: "#F8FAFC",
    boxShadow: "0 10px 25px rgba(0,0,0,0.5)",
  },
  panelRow: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  title: {
    fontSize: "18px",
    fontWeight: 800,
    margin: 0,
  },
  subtitle: {
    fontSize: "13px",
    color: "#6366F1",
    fontWeight: 700,
    marginTop: "4px",
    marginBottom: 0,
  },
  badge: {
    padding: "8px 16px",
    borderRadius: "12px",
    fontSize: "12px",
    fontWeight: 800,
  },
  badgeActive: {
    backgroundColor: "rgba(16, 185, 129, 0.15)",
    color: "#34D399",
    border: "1px solid #10B981",
  },
  badgeAlert: {
    backgroundColor: "rgba(239, 68, 68, 0.15)",
    color: "#F87171",
    border: "1px solid #EF4444",
  },
  badgeCompleted: {
    backgroundColor: "rgba(30, 41, 59, 0.6)",
    color: "#94A3B8",
    border: "1px solid #334155",
  },
  divider: {
    height: "1px",
    backgroundColor: "#1E293B",
    margin: "16px 0",
  },
  telemetryRow: {
    display: "flex",
    justifyContent: "space-between",
    gap: "12px",
  },
  telemetryItem: {
    display: "flex",
    flexDirection: "column",
    flex: 1,
    backgroundColor: "#090D16",
    padding: "12px 16px",
    borderRadius: "12px",
    border: "1px solid #1E293B",
  },
  telemetryLabel: {
    color: "#94A3B8",
    fontSize: "10px",
    fontWeight: 600,
    textTransform: "uppercase",
    letterSpacing: "0.5px",
  },
  telemetryVal: {
    color: "#F8FAFC",
    fontSize: "14px",
    fontWeight: 700,
    marginTop: "4px",
  },
  mapContainer: {
    width: "100%",
    height: "100%",
  },
};
