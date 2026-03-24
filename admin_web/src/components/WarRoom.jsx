import React, { useState, useEffect } from 'react';
import { 
  RiRadarLine, 
  RiAlarmWarningLine, 
  RiMapPinRangeLine, 
  RiCpuLine, 
  RiSignalTowerLine,
  RiTerminalBoxLine,
  RiFocus3Line,
  RiCloseLargeLine,
  RiShieldFlashFill,
  RiHistoryLine
} from 'react-icons/ri';
import LiveMap from './LiveMap';
import { io } from 'socket.io-client';
import { api } from '../services/api';

const socket = io('http://localhost:3000', {
  transports: ['websocket'],
});

const WarRoom = () => {
  const [activeRidesCount, setActiveRidesCount] = useState(0);

  useEffect(() => {
    const fetchActiveRides = async () => {
      try {
        const data = await api.getRides();
        setActiveRidesCount(data.length);
      } catch (err) {
        console.error("Erreur trajets", err);
      }
    };
    fetchActiveRides();

    socket.on('ride_requested', () => {
      setActiveRidesCount(prev => prev + 1);
    });

    socket.on('statusUpdate', () => fetchActiveRides());

    return () => {
      socket.off('ride_requested');
      socket.off('statusUpdate');
    };
  }, []);

  const incidents = [
    { id: 'INC-4021', type: 'Speed Violation', location: 'Dakar-Plateau', severity: 'High', time: '1m ago' },
    { id: 'INC-4018', type: 'Route Deviation', location: 'Almadies-East', severity: 'Critical', time: '5m ago' },
    { id: 'INC-3995', type: 'SOS Trigger', location: 'Unknown Coordinate', severity: 'Critical', time: '12m ago' },
  ];

  return (
    <div className="flex h-full overflow-hidden">
      {/* Tactical Map Placeholder */}
      <div className="flex-1 relative overflow-hidden flex items-center justify-center">
         <LiveMap embedded={true} />

         {/* Floating Map Overlays */}
         <div className="absolute top-6 left-6 p-4 expert-card bg-zinc-950/80 backdrop-blur-md border border-zinc-700/30 w-64">
            <div className="flex items-center justify-between mb-4 pb-2 border-b border-zinc-800">
               <span className="text-[10px] font-bold text-zinc-500 uppercase">Tracked Assets</span>
               <RiSignalTowerLine className="text-emerald-500" />
            </div>
            <div className="space-y-3">
               <div className="flex justify-between items-center text-[11px] font-medium">
                  <span className="text-zinc-400">Total Rides Active</span>
                  <span className="font-mono text-zinc-200">{activeRidesCount}</span>
               </div>
               <div className="flex justify-between items-center text-[11px] font-medium">
                  <span className="text-zinc-400">Critical Alerts</span>
                  <span className="font-mono text-red-500">03</span>
               </div>
               <div className="flex justify-between items-center text-[11px] font-medium text-zinc-600">
                  <span>GPS Precision</span>
                  <span>±0.4m</span>
               </div>
            </div>
         </div>

         {/* Active Incident Pin */}
         <div className="absolute left-[40%] top-[40%] group animate-bounce">
            <div className="w-4 h-4 rounded-full bg-red-500 shadow-[0_0_20px_rgba(239,68,68,0.8)] relative">
               <div className="absolute inset-0 rounded-full border border-red-500 animate-[ping_2s_infinite]" />
            </div>
            <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 p-2 bg-zinc-900 border border-zinc-700 rounded text-[9px] font-mono whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity">
               ID: RT-8821 | TYPE: CRITICAL_SOS
            </div>
         </div>
      </div>

      {/* Incident Panel */}
      <div className="w-96 border-l border-zinc-800/10 flex flex-col bg-[#09090b]/80 backdrop-blur-xl">
         <div className="p-6 border-b border-zinc-800/20">
            <h3 className="text-[12px] font-bold text-zinc-400 uppercase tracking-widest mb-4">Active Deployments</h3>
            <div className="flex gap-2">
               <button className="flex-1 py-1.5 bg-red-500/10 border border-red-500/20 text-red-500 rounded text-[10px] font-bold uppercase tracking-wider">Crit: 03</button>
               <button className="flex-1 py-1.5 bg-zinc-800 border border-zinc-700 text-zinc-400 rounded text-[10px] font-bold uppercase tracking-wider">Warn: 11</button>
            </div>
         </div>

         <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4">
            {incidents.map((inc) => (
              <div key={inc.id} className="expert-card p-4 hover:border-red-500/30 group">
                 <div className="flex justify-between items-start mb-3">
                    <div className="flex items-center gap-2">
                       <RiAlarmWarningLine size={16} className={inc.severity === 'Critical' ? 'text-red-500' : 'text-orange-400'} />
                       <span className="text-[12px] font-bold text-zinc-200">{inc.type}</span>
                    </div>
                    <span className="text-[10px] font-mono text-zinc-600">{inc.time}</span>
                 </div>
                 <div className="space-y-3">
                    <div className="flex items-center gap-2 text-[11px] font-medium text-zinc-500">
                       <RiMapPinRangeLine size={14} />
                       <span className="mono">{inc.location}</span>
                    </div>
                    <div className="flex gap-2 pt-2">
                       <button className="flex-1 py-1.5 bg-zinc-800 hover:bg-zinc-700 border border-zinc-700 rounded text-[10px] font-bold text-zinc-300">DISPATCH</button>
                       <button className="p-1.5 bg-zinc-800 hover:bg-zinc-700 border border-zinc-700 rounded text-zinc-400">
                          <RiFocus3Line size={14} />
                       </button>
                    </div>
                 </div>
              </div>
            ))}
         </div>

         <div className="p-4 border-t border-zinc-800/20 bg-zinc-950/40">
            <div className="expert-card p-3 border-dashed border-zinc-800 bg-transparent flex items-center justify-between">
               <div className="flex items-center gap-3">
                  <RiSignalTowerLine className="text-emerald-500" />
                  <span className="text-[10px] font-bold text-zinc-500 uppercase">Emergency Override Locked</span>
               </div>
               <RiShieldFlashFill className="text-zinc-700" />
            </div>
         </div>
      </div>
    </div>
  );
};

export default WarRoom;
