"use client";

import React, { useEffect, useState } from 'react';
import { ShieldAlert, AlertTriangle, X } from 'lucide-react';
import { createClient } from '../../lib/supabase/client';

export interface ToastMessage {
  id: string;
  type: 'critical' | 'warning' | 'info';
  title: string;
  message: string;
}

export default function GlobalToast() {
  const [toasts, setToasts] = useState<ToastMessage[]>([]);
  const supabase = createClient();

  useEffect(() => {
    const channel = supabase.channel('emergency_toasts')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'audit_logs' },
        (payload) => {
          interface AuditLog {
            id: string;
            action: string;
            details?: { message?: string };
          }
          const log = payload.new as AuditLog;
          if (log.action === 'SOS_ALERT' || log.action === 'SILENT_ANOMALY') {
            const newToast: ToastMessage = {
              id: log.id,
              type: log.action === 'SOS_ALERT' ? 'critical' : 'warning',
              title: log.action === 'SOS_ALERT' ? "URGENCE SOS Déclenchée !" : "Anomalie SafeGate Détectée",
              message: log.details?.message || "Une activité suspecte a été signalée.",
            };
            
            setToasts(prev => [newToast, ...prev]);

            // Auto-dismiss after 10 seconds
            setTimeout(() => {
              setToasts(prev => prev.filter(t => t.id !== newToast.id));
            }, 10000);
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  const removeToast = (id: string) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  };

  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-6 right-6 z-[9999] flex flex-col gap-3 max-w-sm w-full">
      {toasts.map((toast) => (
        <div 
          key={toast.id}
          className={`glass premium-shadow rounded-2xl p-4 border flex items-start gap-4 animate-in slide-in-from-right-full duration-500 overflow-hidden relative ${
            toast.type === 'critical' ? 'bg-red-500/10 border-red-500/30' : 'bg-orange-500/10 border-orange-500/30'
          }`}
        >
          {/* Progress bar for 10s */}
          <div className="absolute bottom-0 left-0 h-1 bg-current opacity-20 animate-out fade-out fill-mode-forwards w-full origin-left duration-[10000ms]" />
          
          <div className={`mt-0.5 p-2 rounded-lg ${toast.type === 'critical' ? 'bg-red-500/20 text-red-500' : 'bg-orange-500/20 text-orange-500'}`}>
            {toast.type === 'critical' ? <ShieldAlert className="w-5 h-5" /> : <AlertTriangle className="w-5 h-5" />}
          </div>
          
          <div className="flex-1 min-w-0">
            <h4 className="font-bold text-sm mb-1 uppercase tracking-tight">{toast.title}</h4>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 line-clamp-2">{toast.message}</p>
          </div>

          <button 
            onClick={() => removeToast(toast.id)}
            className="p-1 hover:bg-white/10 rounded-full transition-colors text-zinc-500"
            aria-label="Fermer la notification"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      ))}
    </div>
  );
}
