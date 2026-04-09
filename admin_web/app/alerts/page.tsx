"use client";

import React, { useEffect, useState } from "react";
import { ShieldAlert, AlertTriangle, Info, CheckCircle2 } from "lucide-react";
import { createClient } from "../../lib/supabase/client";

interface SystemAlert {
  id: string;
  type: "critical" | "warning" | "info";
  title: string;
  description: string;
  time: string;
  status: string;
}

interface AuditLog {
  id: string;
  action: string;
  status: string;
  details?: {
    message?: string;
  };
  created_at: string;
}

function getAlertStyle(type: string) {
  switch (type) {
    case "critical":
      return {
        border: "border-red-200 dark:border-red-500/30",
        bg: "bg-red-50 dark:bg-red-500/10",
        icon: <AlertTriangle className="w-5 h-5 text-red-600 dark:text-red-400" />,
        badge: "bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400",
      };
    case "warning":
      return {
        border: "border-orange-200 dark:border-orange-500/30",
        bg: "bg-orange-50 dark:bg-orange-500/10",
        icon: <ShieldAlert className="w-5 h-5 text-orange-600 dark:text-orange-400" />,
        badge: "bg-orange-100 text-orange-700 dark:bg-orange-500/20 dark:text-orange-400",
      };
    default:
      return {
        border: "border-blue-200 dark:border-blue-500/30",
        bg: "bg-blue-50 dark:bg-blue-500/10",
        icon: <Info className="w-5 h-5 text-blue-600 dark:text-blue-400" />,
        badge: "bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-400",
      };
  }
}

export default function AlertsPage() {
  const [alerts, setAlerts] = useState<SystemAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const supabase = createClient();

  useEffect(() => {
    async function fetchAlerts() {
      setLoading(true);
      const { data, error } = await supabase
        .from("audit_logs")
        .select("*")
        .order("created_at", { ascending: false });

      if (!error && data) {
        const formattedAlerts: SystemAlert[] = (data as AuditLog[]).map((log) => ({
          id: log.id,
          type: log.action === "SOS_ALERT" ? "critical" : (log.action === "SILENT_ANOMALY" ? "warning" : "info"),
          title: log.action.replace(/_/g, " "),
          description: log.details?.message || `Activity log for ${log.action}`,
          time: new Date(log.created_at).toLocaleString(),
          status: log.status,
        }));
        setAlerts(formattedAlerts);
      }
      setLoading(false);
    }

    fetchAlerts();

    // Subscribe to real-time SOS alerts
    const channel = supabase.channel('realtime_alerts')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'audit_logs' },
        (payload) => {
          const newLog = payload.new as AuditLog;
          const formatted: SystemAlert = {
            id: newLog.id,
            type: newLog.action === "SOS_ALERT" ? "critical" : (newLog.action === "SILENT_ANOMALY" ? "warning" : "info"),
            title: newLog.action.replace(/_/g, " "),
            description: newLog.details?.message || `New ${newLog.action} recorded`,
            time: new Date(newLog.created_at).toLocaleString(),
            status: newLog.status,
          };
          setAlerts(prev => [formatted, ...prev]);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">System Alerts</h1>
          <p className="text-zinc-500 mt-1">Important notifications requiring your attention.</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors shadow-sm self-start md:self-auto">
          <CheckCircle2 className="w-4 h-4" />
          Mark All as Read
        </button>
      </div>

      <div className="space-y-4">
        {loading ? (
          <div className="text-center p-8 text-zinc-500">Loading live alerts...</div>
        ) : alerts.length > 0 ? (
          alerts.map((alert) => {
            const style = getAlertStyle(alert.type);
            return (
              <div
                key={alert.id}
                className={`glass rounded-xl p-5 premium-shadow border ${style.border} ${style.bg} flex items-start gap-4 transition-all hover:-translate-y-0.5`}
              >
                <div className="mt-0.5 flex-shrink-0">{style.icon}</div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-semibold text-foreground uppercase tracking-tight text-sm">{alert.title}</h3>
                    <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${style.badge}`}>
                      {alert.type}
                    </span>
                  </div>
                  <p className="text-sm text-zinc-600 dark:text-zinc-400">{alert.description}</p>
                  <p className="text-xs text-zinc-400 mt-2">{alert.time}</p>
                </div>
                <button className="text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors flex-shrink-0">
                  Dismiss
                </button>
              </div>
            );
          })
        ) : (
          <div className="text-center p-12 glass rounded-xl border border-dashed border-border-color text-zinc-500">
            No system alerts found. All systems operational.
          </div>
        )}
      </div>
    </div>
  );
}
