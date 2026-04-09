"use client";

import React from 'react';
import dynamic from 'next/dynamic';
import { Activity } from 'lucide-react';

// Dynamic import with no SSR to prevent Leaflet window errors on build
const LiveMap = dynamic(() => import('./MapComponent'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-[600px] flex items-center justify-center bg-muted rounded-xl border border-border-color">
      <div className="flex flex-col items-center gap-4">
        <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
        <p className="text-zinc-500 font-medium">Loading Map...</p>
      </div>
    </div>
  )
});

export default function MapPage() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Live Driver Map</h1>
          <p className="text-zinc-500 mt-1">Real-time overview of active drivers on the field.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 px-3 py-1.5 bg-green-100 dark:bg-green-500/20 text-green-700 dark:text-green-400 rounded-full text-sm font-semibold border border-green-200 dark:border-green-500/30">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-500 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-green-600"></span>
            </span>
            System Online
          </div>
        </div>
      </div>

      <div className="glass rounded-xl p-4 md:p-6 premium-shadow flex flex-col">
        <div className="flex items-center gap-2 mb-6 text-foreground font-semibold">
          <Activity className="w-5 h-5 text-blue-500" />
          <span>Real-time Broadcast Channel: driverLocation</span>
        </div>
        
        <LiveMap />
      </div>
    </div>
  );
}
