"use client";

import React, { useEffect, useState, useCallback } from "react";

interface OverviewStats {
  activeTrips: number;
  activeAlerts: number;
  availableRides: number;
  totalPings: number;
}

interface TripSummary {
  id: string;
  status: string;
  originLabel: string;
  destinationLabel: string;
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  startTime: string;
  endTimeEst: string;
  user: { name: string | null; email: string };
  driver?: { name: string | null; email: string } | null;
  pings: Array<{
    latitude: number;
    longitude: number;
    speed: number | null;
    timestamp: string;
  }>;
}

interface AlertSummary {
  id: string;
  tripId: string;
  status: string;
  triggeredAt: string;
  trip: {
    id: string;
    originLabel: string;
    destinationLabel: string;
    status: string;
    user: { name: string | null; email: string };
  };
}

interface OverviewPayload {
  success: boolean;
  stats: OverviewStats;
  trips: TripSummary[];
  alerts: AlertSummary[];
}

interface IncidentReportPayload {
  success: boolean;
  tripId: string;
  reportMarkdown: string;
  integritySealSha256: string;
  generatedAt: string;
}

export default function SupervisionCenterPage() {
  const [data, setData] = useState<OverviewPayload | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [selectedReport, setSelectedReport] =
    useState<IncidentReportPayload | null>(null);
  const [loadingReportTripId, setLoadingReportTripId] = useState<string | null>(
    null
  );

  const loadOverview = useCallback(async () => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 8000);

    try {
      const res = await fetch("/api/overview", { signal: controller.signal });
      const json = (await res.json()) as OverviewPayload & { error?: string };
      if (!res.ok) {
        throw new Error(json.error || "Connexion interrompue.");
      }
      setData(json);
      setErrorMsg(null);
    } catch (err: unknown) {
      if (err instanceof Error && err.name === "AbortError") return;
      setErrorMsg(
        err instanceof Error
          ? err.message
          : "Impossible de synchroniser les donnees de supervision."
      );
    } finally {
      clearTimeout(timeoutId);
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadOverview();
    const interval = setInterval(loadOverview, 6000);
    return () => clearInterval(interval);
  }, [loadOverview]);

  const handleOpenReport = async (tripId: string) => {
    if (loadingReportTripId) return;
    setLoadingReportTripId(tripId);

    try {
      const res = await fetch(`/api/trips/${encodeURIComponent(tripId)}/report`);
      const json = (await res.json()) as IncidentReportPayload;
      if (res.ok && json.reportMarkdown) {
        setSelectedReport(json);
      }
    } finally {
      setLoadingReportTripId(null);
    }
  };

  return (
    <div style={styles.page}>
      <header style={styles.header}>
        <div>
          <span style={styles.kicker}>POSTE DE COMMANDEMENT TEMPS REEL</span>
          <h1 style={styles.title}>SafeRide Sentinel — Supervision</h1>
        </div>
        <button
          type="button"
          onClick={loadOverview}
          style={styles.refreshBtn}
          aria-label="Actualiser les donnees de supervision"
        >
          Actualiser la flotte
        </button>
      </header>

      {errorMsg ? (
        <div style={styles.errorBanner}>
          <span>{errorMsg}</span>
          <button
            type="button"
            onClick={loadOverview}
            style={styles.retryBtn}
          >
            Reessayer
          </button>
        </div>
      ) : null}

      <section style={styles.kpiGrid}>
        <div style={styles.kpiCard}>
          <span style={styles.kpiLabel}>Trajets sous surveillance</span>
          <strong style={styles.kpiValue}>
            {isLoading ? "..." : data?.stats.activeTrips ?? 0}
          </strong>
        </div>
        <div
          style={{
            ...styles.kpiCard,
            borderColor:
              (data?.stats.activeAlerts ?? 0) > 0 ? "#EF4444" : "#1E293B",
          }}
        >
          <span style={styles.kpiLabel}>Alertes SOS actives</span>
          <strong
            style={{
              ...styles.kpiValue,
              color:
                (data?.stats.activeAlerts ?? 0) > 0 ? "#EF4444" : "#10B981",
            }}
          >
            {isLoading ? "..." : data?.stats.activeAlerts ?? 0}
          </strong>
        </div>
        <div style={styles.kpiCard}>
          <span style={styles.kpiLabel}>Offres de covoiturage</span>
          <strong style={styles.kpiValue}>
            {isLoading ? "..." : data?.stats.availableRides ?? 0}
          </strong>
        </div>
        <div style={styles.kpiCard}>
          <span style={styles.kpiLabel}>Releves GPS enregistres</span>
          <strong style={styles.kpiValue}>
            {isLoading ? "..." : data?.stats.totalPings ?? 0}
          </strong>
        </div>
      </section>

      <div style={styles.mainGrid}>
        <section style={styles.sectionCard}>
          <h2 style={styles.sectionTitle}>Trajets & Telemetrie en Direct</h2>

          {!data || data.trips.length === 0 ? (
            <div style={styles.emptyBox}>
              Aucun trajet actif ou recent. Demarrez une course depuis
              l'application mobile pour observer la telemetrie en temps reel.
            </div>
          ) : (
            <div style={styles.listStack}>
              {data.trips.map((trip) => {
                const lastPing = trip.pings[0];
                const isAlert = trip.status === "ALERT";
                const isActive = trip.status === "ACTIVE";
                return (
                  <div
                    key={trip.id}
                    style={{
                      ...styles.itemCard,
                      borderColor: isAlert ? "#EF4444" : "#1E293B",
                    }}
                  >
                    <div style={styles.itemHeader}>
                      <div>
                        <div style={styles.routeTitle}>
                          {trip.originLabel} → {trip.destinationLabel}
                        </div>
                        <div style={styles.metaText}>
                          Passager : {trip.user.name || trip.user.email}
                          {trip.driver
                            ? ` • Conducteur : ${
                                trip.driver.name || trip.driver.email
                              }`
                            : ""}
                        </div>
                      </div>

                      <span
                        style={{
                          ...styles.badge,
                          ...(isAlert
                            ? styles.badgeDanger
                            : isActive
                            ? styles.badgeSuccess
                            : styles.badgeNeutral),
                        }}
                      >
                        {isAlert
                          ? "Alerte SOS / Deviation"
                          : isActive
                          ? "En cours"
                          : "Termine"}
                      </span>
                    </div>

                    <div style={styles.itemFooter}>
                      <span style={styles.coordText}>
                        {lastPing
                          ? `Dernier signal : ${lastPing.latitude.toFixed(
                              4
                            )}, ${lastPing.longitude.toFixed(4)} (${
                              lastPing.speed
                                ? Math.round(lastPing.speed * 3.6) + " km/h"
                                : "0 km/h"
                            })`
                          : "En attente du premier signal GPS"}
                      </span>

                      <div style={styles.actionGroup}>
                        <a
                          href={`/track/${trip.id}`}
                          style={styles.linkBtn}
                        >
                          Carte Live
                        </a>
                        <button
                          type="button"
                          onClick={() => handleOpenReport(trip.id)}
                          disabled={loadingReportTripId === trip.id}
                          style={styles.reportBtn}
                        >
                          {loadingReportTripId === trip.id
                            ? "Generation..."
                            : "Rapport Certifie"}
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>

        <section style={styles.sectionCard}>
          <h2 style={styles.sectionTitle}>
            Journal des Alertes & Rapports d'Incident
          </h2>

          {selectedReport ? (
            <div style={styles.reportBox}>
              <div style={styles.reportHeader}>
                <div>
                  <span style={styles.certifiedBadge}>
                    Rapport d'incident certifie et horodate
                  </span>
                  <div style={styles.metaText}>
                    Genere a{" "}
                    {new Date(selectedReport.generatedAt).toLocaleTimeString(
                      "fr-FR"
                    )}
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setSelectedReport(null)}
                  style={styles.closeBtn}
                >
                  Fermer
                </button>
              </div>
              <pre style={styles.reportPre}>
                {selectedReport.reportMarkdown}
              </pre>
            </div>
          ) : null}

          {!data || data.alerts.length === 0 ? (
            <div style={styles.emptyBox}>
              Aucune alerte de securite declenchee. Tous les trajets respectent
              leur couloir d'itineraire.
            </div>
          ) : (
            <div style={styles.listStack}>
              {data.alerts.map((alertItem) => (
                <div key={alertItem.id} style={styles.alertCard}>
                  <div style={styles.itemHeader}>
                    <div>
                      <div style={styles.routeTitle}>
                        {alertItem.trip.originLabel} →{" "}
                        {alertItem.trip.destinationLabel}
                      </div>
                      <div style={styles.metaText}>
                        Passager :{" "}
                        {alertItem.trip.user.name ||
                          alertItem.trip.user.email}{" "}
                        •{" "}
                        {new Date(alertItem.triggeredAt).toLocaleTimeString(
                          "fr-FR"
                        )}
                      </div>
                    </div>
                    <button
                      type="button"
                      onClick={() => handleOpenReport(alertItem.tripId)}
                      style={styles.reportBtn}
                    >
                      Consulter le rapport
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  page: {
    minHeight: "100vh",
    backgroundColor: "#090D16",
    color: "#F8FAFC",
    fontFamily: "Inter, system-ui, -apple-system, sans-serif",
    padding: "32px",
    boxSizing: "border-box",
  },
  header: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "32px",
    borderBottom: "1px solid #1E293B",
    paddingBottom: "24px",
  },
  kicker: {
    fontSize: "11px",
    fontWeight: 800,
    color: "#6366F1",
    letterSpacing: "1.5px",
  },
  title: {
    fontSize: "28px",
    fontWeight: 800,
    margin: "4px 0 0 0",
  },
  refreshBtn: {
    backgroundColor: "#6366F1",
    color: "#FFFFFF",
    border: "none",
    borderRadius: "12px",
    padding: "12px 20px",
    fontSize: "14px",
    fontWeight: 700,
    cursor: "pointer",
  },
  errorBanner: {
    backgroundColor: "rgba(239, 68, 68, 0.16)",
    border: "1px solid #EF4444",
    borderRadius: "12px",
    padding: "16px",
    marginBottom: "24px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  retryBtn: {
    backgroundColor: "#131B2E",
    color: "#F8FAFC",
    border: "1px solid #1E293B",
    borderRadius: "8px",
    padding: "8px 16px",
    cursor: "pointer",
    fontWeight: 700,
  },
  kpiGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
    gap: "16px",
    marginBottom: "32px",
  },
  kpiCard: {
    backgroundColor: "#131B2E",
    border: "1px solid #1E293B",
    borderRadius: "16px",
    padding: "24px",
    display: "flex",
    flexDirection: "column",
    gap: "8px",
  },
  kpiLabel: {
    color: "#94A3B8",
    fontSize: "13px",
    fontWeight: 600,
  },
  kpiValue: {
    fontSize: "32px",
    fontWeight: 800,
  },
  mainGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(420px, 1fr))",
    gap: "24px",
  },
  sectionCard: {
    backgroundColor: "#131B2E",
    border: "1px solid #1E293B",
    borderRadius: "20px",
    padding: "24px",
  },
  sectionTitle: {
    fontSize: "18px",
    fontWeight: 800,
    marginTop: 0,
    marginBottom: "16px",
  },
  emptyBox: {
    backgroundColor: "#0D1322",
    border: "1px solid #1E293B",
    borderRadius: "12px",
    padding: "24px",
    color: "#94A3B8",
    fontSize: "14px",
    lineHeight: "20px",
    textAlign: "center",
  },
  listStack: {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  },
  itemCard: {
    backgroundColor: "#0D1322",
    border: "1px solid #1E293B",
    borderRadius: "14px",
    padding: "16px",
  },
  alertCard: {
    backgroundColor: "rgba(239, 68, 68, 0.08)",
    border: "1px solid #EF4444",
    borderRadius: "14px",
    padding: "16px",
  },
  itemHeader: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: "12px",
  },
  routeTitle: {
    fontSize: "15px",
    fontWeight: 800,
    color: "#F8FAFC",
  },
  metaText: {
    fontSize: "12px",
    color: "#94A3B8",
    marginTop: "4px",
  },
  badge: {
    padding: "6px 12px",
    borderRadius: "8px",
    fontSize: "11px",
    fontWeight: 800,
    whiteSpace: "nowrap",
  },
  badgeSuccess: {
    backgroundColor: "rgba(16, 185, 129, 0.16)",
    color: "#34D399",
    border: "1px solid #10B981",
  },
  badgeDanger: {
    backgroundColor: "rgba(239, 68, 68, 0.16)",
    color: "#F87171",
    border: "1px solid #EF4444",
  },
  badgeNeutral: {
    backgroundColor: "rgba(148, 163, 184, 0.12)",
    color: "#94A3B8",
    border: "1px solid #334155",
  },
  itemFooter: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: "16px",
    paddingTop: "12px",
    borderTop: "1px solid #1E293B",
    flexWrap: "wrap",
    gap: "8px",
  },
  coordText: {
    fontSize: "12px",
    color: "#94A3B8",
    fontFamily: "monospace",
  },
  actionGroup: {
    display: "flex",
    gap: "8px",
  },
  linkBtn: {
    backgroundColor: "#1E293B",
    color: "#F8FAFC",
    textDecoration: "none",
    padding: "8px 14px",
    borderRadius: "8px",
    fontSize: "12px",
    fontWeight: 700,
  },
  reportBtn: {
    backgroundColor: "#6366F1",
    color: "#FFFFFF",
    border: "none",
    padding: "8px 14px",
    borderRadius: "8px",
    fontSize: "12px",
    fontWeight: 700,
    cursor: "pointer",
  },
  reportBox: {
    backgroundColor: "#0D1322",
    border: "1px solid #6366F1",
    borderRadius: "14px",
    padding: "16px",
    marginBottom: "16px",
  },
  reportHeader: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "12px",
  },
  certifiedBadge: {
    color: "#10B981",
    fontSize: "12px",
    fontWeight: 800,
    textTransform: "uppercase",
  },
  closeBtn: {
    backgroundColor: "transparent",
    color: "#94A3B8",
    border: "1px solid #1E293B",
    borderRadius: "8px",
    padding: "6px 12px",
    cursor: "pointer",
    fontSize: "12px",
  },
  reportPre: {
    whiteSpace: "pre-wrap",
    fontFamily: "Inter, system-ui, sans-serif",
    fontSize: "13px",
    color: "#E2E8F0",
    lineHeight: "20px",
    margin: 0,
  },
};
