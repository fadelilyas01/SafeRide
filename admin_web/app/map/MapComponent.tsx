"use client";

import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { createClient } from '../../lib/supabase/client';

// Fix for default marker icons in Leaflet with Next.js
// Premium Car Icon for Drivers
const driverIcon = L.divIcon({
  className: 'custom-driver-icon',
  html: `
    <div class="relative flex items-center justify-center">
      <div class="absolute w-10 h-10 bg-blue-500/20 rounded-full animate-ping"></div>
      <div class="relative bg-blue-600 p-2 rounded-lg shadow-lg border-2 border-white">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/>
        </svg>
      </div>
    </div>
  `,
  iconSize: [40, 40],
  iconAnchor: [20, 20],
});

type DriverLocation = {
  driver_id: string;
  lat: number;
  lng: number;
  updated_at: string;
};

export default function MapComponent() {
  const [locations, setLocations] = useState<Record<string, DriverLocation>>({});
  const supabase = createClient();

  useEffect(() => {
    // Listen to Supabase Realtime Broadcast for driver locations
    const channel = supabase.channel('driverLocation')
      .on(
        'broadcast',
        { event: 'location_update' },
        (payload) => {
          console.log('Driver location update received:', payload);
          const data = payload.payload as DriverLocation;
          if (data && data.driver_id) {
            setLocations((prev) => ({
              ...prev,
              [data.driver_id]: data
            }));
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  // Center of the map (mock default, e.g. Montreal/Gatineau or wherever your base is)
  const defaultCenter: [number, number] = [45.4215, -75.6972]; // Ottawa/Gatineau area default
  const activeLocations = Object.values(locations);

  return (
    <div className="w-full h-[600px] rounded-xl overflow-hidden shadow-lg border border-border-color z-0 relative">
      <MapContainer 
        center={defaultCenter} 
        zoom={12} 
        style={{ height: '100%', width: '100%', zIndex: 0 }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {activeLocations.map((loc) => (
          <Marker 
            key={loc.driver_id} 
            position={[loc.lat, loc.lng]} 
            icon={driverIcon}
          >
            <Popup>
              <div className="text-sm">
                <strong>Driver ID:</strong> {loc.driver_id.substring(0, 8)}...<br/>
                <strong>Last Updated:</strong> {new Date(loc.updated_at).toLocaleTimeString()}
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
      
      {activeLocations.length === 0 && (
        <div className="absolute top-4 left-1/2 transform -translate-x-1/2 bg-card-bg/90 backdrop-blur-sm px-4 py-2 rounded-full shadow-lg border border-border-color flex items-center gap-2 z-[1000] text-sm font-medium">
          <span className="w-2 h-2 rounded-full bg-blue-500 animate-ping"></span>
          Waiting for live driver locations...
        </div>
      )}
    </div>
  );
}
