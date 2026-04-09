"use client";

import React, { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import { createClient } from '../../../lib/supabase/client';
import { Shield, Clock } from 'lucide-react';

// Dynamically import Map to avoid SSR issues with Leaflet
const PublicMap = dynamic(() => import('../../map/MapComponent'), { ssr: false });

export default function TrackRidePage({ params }: { params: { id: string } }) {
  const [rideData, setRideData] = useState<RideInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const supabase = createClient();

  interface RideInfo {
    id: string;
    status: string;
    pickup_address: string;
    dropoff_address: string;
    driver?: {
      first_name: string;
      last_name: string;
      trust_score: number;
    };
  }

  useEffect(() => {
    async function fetchRideInfo() {
      const { data, error } = await supabase
        .from('rides')
        .select(`
          id, status, pickup_address, dropoff_address, price,
          driver_id,
          driver:profiles!driver_id (first_name, last_name, trust_score)
        `)
        .eq('id', params.id)
        .single();

      if (!error && data) {
        setRideData(data);
      }
      setLoading(false);
    }

    fetchRideInfo();
  }, [params.id, supabase]);

  if (loading) return (
    <div className="min-h-screen bg-[#0F172A] flex items-center justify-center">
      <div className="text-blue-500 animate-pulse font-bold tracking-widest text-xl">SAFERIDE SECURE LINK...</div>
    </div>
  );

  if (!rideData) return (
    <div className="min-h-screen bg-[#0F172A] flex items-center justify-center text-zinc-500">
      Invalid link or ride has expired.
    </div>
  );

  return (
    <div className="min-h-screen bg-[#0F172A] text-white flex flex-col font-sans">
      {/* Header Branding */}
      <header className="p-4 border-b border-white10 flex items-center justify-between bg-[#1E293B]/50 backdrop-blur-md sticky top-0 z-50">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
            <Shield className="text-white w-5 h-5" />
          </div>
          <span className="text-lg font-bold">SafeRide <span className="text-blue-500">Shield</span></span>
        </div>
        <div className="bg-green-500/10 text-green-500 px-3 py-1 rounded-full text-xs font-bold border border-green-500/20 animate-pulse">
          LIVE TRACKING
        </div>
      </header>

      {/* Main Map View */}
      <div className="flex-1 relative">
        <PublicMap />
        
        {/* Floating Info Overlay */}
        <div className="absolute bottom-6 left-6 right-6 z-[1000]">
          <div className="glass rounded-2xl p-5 premium-shadow border border-white10 max-w-md mx-auto">
            <div className="flex items-center gap-4 mb-4">
              <div className="w-12 h-12 rounded-full bg-blue-600/20 flex items-center justify-center border border-blue-500/30">
                <span className="font-bold text-blue-500">{rideData.driver?.first_name?.[0]}</span>
              </div>
              <div className="flex-1">
                <h3 className="font-bold text-lg">{rideData.driver?.first_name} {rideData.driver?.last_name}</h3>
                <div className="flex items-center gap-1 text-xs text-zinc-400">
                  <Clock className="w-3 h-3" />
                  <span>En route pour {rideData.dropoff_address}</span>
                </div>
              </div>
              <div className="text-right">
                <div className="text-sm font-bold text-blue-500">{rideData.driver?.trust_score} ⭐</div>
                <div className="text-[10px] uppercase text-zinc-500">Trust Score</div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="bg-[#0F172A]/50 p-3 rounded-xl border border-white5">
                <p className="text-zinc-500 text-[10px] uppercase mb-1">Pick up</p>
                <p className="truncate font-medium">{rideData.pickup_address}</p>
              </div>
              <div className="bg-[#0F172A]/50 p-3 rounded-xl border border-white5">
                <p className="text-zinc-500 text-[10px] uppercase mb-1">Destination</p>
                <p className="truncate font-medium">{rideData.dropoff_address}</p>
              </div>
            </div>
            
            <p className="text-center text-zinc-500 text-[10px] mt-4 italic">
              SafeRide Family Link • This link expires automatically.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
