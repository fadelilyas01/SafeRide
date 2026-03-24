import React, { useState, useEffect } from 'react';
import { 
  RiMapPinLine, 
  RiNavigationLine, 
  RiSignalTowerLine, 
  RiPulseLine, 
  RiTimeLine, 
  RiCarLine,
  RiDashboardLine
} from 'react-icons/ri';
import { io } from 'socket.io-client';
import { api } from '../services/api';

const socket = io('http://localhost:3000', {
  transports: ['websocket'],
});

const LiveMap = ({ embedded = false }) => {
  const [selectedRide, setSelectedRide] = useState(null);
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString());
  const [activeRides, setActiveRides] = useState([]);
  const [driverLocations, setDriverLocations] = useState({});

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString());
    }, 1000);

    const fetchActiveRides = async () => {
      try {
        const data = await api.getRides();
        setActiveRides(data);
      } catch (err) {
        console.error("Erreur trajets", err);
      }
    };
    fetchActiveRides();

    socket.on('connect', () => {
      console.log('Connected to SafeRide WebSocket');
    });

    socket.on('ride_requested', (newRide) => {
      setActiveRides(prev => {
        // Prevent duplicates
        if (prev.some(r => r.id === newRide.id)) return prev;
        return [newRide, ...prev];
      });
    });

    // Listen to specific ride structure
    socket.on('statusUpdate', () => fetchActiveRides());

    // Listen for real-time driver GPS updates
    socket.on('driverLocation', (data) => {
      setDriverLocations(prev => ({
        ...prev,
        [data.userId]: { lat: data.lat, lng: data.lng }
      }));
    });

    return () => {
      clearInterval(timer);
      socket.off('ride_requested');
      socket.off('statusUpdate');
      socket.off('driverLocation');
    };
  }, []);

  return (
    <div className={`${embedded ? 'w-full h-full p-0' : 'p-8 h-[calc(100vh-100px)]'} flex flex-col space-y-6 w-full max-w-[1600px] mx-auto bg-[var(--background)] transition-colors duration-300`}>
      {!embedded && (
        <div className="flex justify-between items-end">
          <div>
            <h1 className="text-3xl font-bold text-[var(--text)] tracking-tight">Carte en direct</h1>
            <p className="text-[var(--text-muted)]">Surveillance de la flotte en temps réel</p>
          </div>
          <div className="flex items-center gap-4 bg-[var(--surface)] border border-[var(--border)] px-4 py-2 rounded-xl shadow-sm transition-colors duration-300">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-emerald-500 rounded-full animate-ping" />
              <span className="text-xs font-bold text-[var(--text)] uppercase">Réseau Actif</span>
            </div>
            <div className="w-px h-4 bg-[var(--border)]" />
            <div className="flex items-center gap-2 text-[var(--text-muted)] font-bold text-xs uppercase">
              <RiTimeLine size={14} />
              {currentTime}
            </div>
          </div>
        </div>
      )}

      <div className={`flex-1 flex gap-8 min-h-0 ${embedded ? 'pr-4' : ''}`}>
        {/* Map Area */}
        <div className={`flex-1 bg-[var(--surface)] border border-[var(--border)] relative overflow-hidden shadow-inner transition-colors duration-300 ${embedded ? '' : 'rounded-[2rem]'}`}>
          <div className="absolute inset-0 flex items-center justify-center text-[var(--text-muted)] opacity-5">
            <RiDashboardLine size={120} />
          </div>
          <div className="absolute inset-0" style={{ 
            backgroundImage: `radial-gradient(var(--border) 1px, transparent 1px)`, 
            backgroundSize: '40px 40px' 
          }} />

          {/* Markers Simulation */}
          {activeRides.map((ride, i) => {
            // Pour l'Admin Web on place les riders aléatoirement s'ils n'ont pas de coordonnées complètes,
            // ou bien on utilise pickupLat/pickupLng envoyés par le backend
            const top = ride.pickupLat ? `${((ride.pickupLat - 45.4) / 0.2) * 100}%` : `${20 + (i * 15 % 60)}%`;
            const left = ride.pickupLng ? `${((ride.pickupLng - (-73.7)) / 0.3) * 100}%` : `${30 + (i * 20 % 60)}%`;
            
            return (
              <div 
                key={ride.id}
                className={`absolute cursor-pointer transition-all duration-700 ease-in-out ${selectedRide?.id === ride.id ? 'z-20' : 'z-10'}`}
                style={{ top, left }}
                onClick={() => setSelectedRide(ride)}
              >
                <div className={`p-2 rounded-xl shadow-lg border-2 transition-all ${
                  selectedRide?.id === ride.id 
                    ? 'bg-blue-600 border-white scale-125 shadow-blue-500/50' 
                    : ride.status === 'PENDING' 
                        ? 'bg-[var(--surface)] border-amber-500 hover:scale-110 animate-pulse' 
                        : 'bg-[var(--surface)] border-blue-600 hover:scale-110'
                }`}>
                  <RiNavigationLine className={`transform rotate-45 ${
                    selectedRide?.id === ride.id ? 'text-white' : ride.status === 'PENDING' ? 'text-amber-500' : 'text-blue-600'
                  }`} />
                </div>
              </div>
            );
          })}

          {/* Map HUD */}
          <div className="absolute bottom-6 left-6 right-6 flex justify-between items-end">
            <div className="bg-[var(--surface)]/80 backdrop-blur-md p-4 rounded-xl border border-[var(--border)] shadow-lg text-[10px] font-bold text-[var(--text-muted)] space-y-1 transition-colors duration-300">
              <div className="flex justify-between gap-8">
                <span>COORDINATES</span>
                <span className="text-[var(--text)]">45.5017° N, 73.5673° W</span>
              </div>
              <div className="flex justify-between gap-8">
                <span>REGION</span>
                <span className="text-[var(--text)]">MONTREAL, QC</span>
              </div>
            </div>
            <div className="flex gap-2">
               <div className="bg-[var(--surface)] p-2 rounded-xl border border-[var(--border)] shadow-lg transition-colors duration-300 text-blue-500">
                 <RiSignalTowerLine size={18} />
               </div>
            </div>
          </div>
        </div>

        {/* Info Panel */}
        {!embedded && (
          <div className="w-80 flex flex-col gap-6 shrink-0 h-full overflow-hidden">
            <div className="bg-[var(--surface)] border border-[var(--border)] rounded-[2rem] shadow-sm flex-1 flex flex-col min-h-0 overflow-hidden transition-colors duration-300">
              <div className="p-6 border-b border-[var(--border)] flex justify-between items-center bg-[var(--background)]/30">
              <h3 className="text-sm font-black text-[var(--text)] uppercase tracking-wider">Activité Flotte</h3>
              <RiPulseLine className="text-blue-500" />
            </div>
            <div className="flex-1 overflow-y-auto no-scrollbar p-6 space-y-4">
              {activeRides.map((ride) => (
                <div 
                  key={ride.id}
                  onClick={() => setSelectedRide(ride)}
                  className={`p-4 rounded-xl border transition-all cursor-pointer ${
                    selectedRide?.id === ride.id 
                      ? 'bg-blue-500/10 border-blue-500/50' 
                      : 'bg-[var(--background)]/50 border-[var(--border)] hover:border-blue-500/30'
                  }`}
                >
                  <div className="flex justify-between items-start mb-2">
                    <div className="flex items-center gap-2">
                      <div className={`p-1.5 rounded-lg ${ride.status === 'PENDING' ? 'bg-amber-500/10 text-amber-500' : 'bg-blue-500/10 text-blue-500'}`}>
                        <RiCarLine size={14} />
                      </div>
                      <span className="text-xs font-bold text-[var(--text)]">{ride.id.substring(0, 8)}...</span>
                    </div>
                    <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded-md ${
                       ride.status === 'PENDING' ? 'text-amber-500 bg-amber-500/10' : 'text-blue-500 bg-blue-500/10'
                    }`}>
                      {ride.status}
                    </span>
                  </div>
                  <div className="text-[10px] font-black text-[var(--text-muted)] uppercase tracking-wider">
                    Driver: {ride.driver?.name || 'Recherche en cours...'}
                  </div>
                  <div className="text-[10px] font-black text-[var(--text-muted)] uppercase tracking-wider mt-1 truncate">
                    From: {ride.pickupAddress}
                  </div>
                </div>
              ))}
              {activeRides.length === 0 && (
                <div className="text-center py-8 text-[var(--text-muted)] text-xs italic">
                  Aucun trajet actif
                </div>
              )}
            </div>
          </div>
          
          <div className="bg-blue-600 p-6 rounded-[2rem] text-white shadow-xl shadow-blue-500/20 space-y-3 relative overflow-hidden">
            <div className="relative z-10">
              <h4 className="text-xs font-black uppercase tracking-widest mb-1">Alertes Réseau</h4>
              <p className="text-[11px] opacity-90 leading-relaxed font-bold uppercase tracking-wider">Demande élevée détectée dans le centre-ville. Redéploiement suggéré.</p>
            </div>
            <div className="absolute -bottom-4 -right-4 w-20 h-20 bg-white/10 rounded-full blur-2xl" />
          </div>
        </div>
        )}
      </div>
    </div>
  );
};

export default LiveMap;
