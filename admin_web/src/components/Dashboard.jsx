import React from 'react';
import { 
  RiArrowUpSLine, 
  RiArrowDownSLine, 
  RiExternalLinkLine, 
  RiMapPin2Line, 
  RiUserFollowLine,
  RiDatabaseLine,
  RiSecurePaymentLine,
  RiTimeLine,
  RiPulseFill
} from 'react-icons/ri';

const Dashboard = () => {
  const metrics = [
    { label: 'Network Throughput', value: '1.2M', trend: '+12%', isUp: true, icon: <RiPulseFill /> },
    { label: 'Active Sessions', value: '44,201', trend: '+5.2%', isUp: true, icon: <RiUserFollowLine /> },
    { label: 'Secure Revenue', value: '$890.4k', trend: '-2.1%', isUp: false, icon: <RiSecurePaymentLine /> },
    { label: 'Global Latency', value: '42ms', trend: 'Stable', isUp: true, icon: <RiTimeLine /> },
  ];

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex justify-between items-end">
        <div>
           <div className="flex items-center gap-2 text-primary-500 mb-2">
              <RiDatabaseLine size={16} className="drop-shadow-[0_0_8px_rgba(59,130,246,0.6)]" />
              <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-primary-400">Global Intelligence Center</span>
           </div>
           <h1 className="text-3xl font-extrabold text-white tracking-tight text-gradient">System Overview</h1>
        </div>
        <div className="flex gap-3">
           <button className="px-4 py-2 rounded-lg bg-zinc-900/50 border border-white/[0.05] text-[12px] font-bold text-zinc-300 hover:text-white hover:bg-zinc-800/80 hover:border-white/[0.1] transition-all shadow-sm">Export Matrix</button>
           <button className="px-4 py-2 rounded-lg bg-primary-600/20 border border-primary-500/30 text-[12px] font-bold text-primary-400 hover:bg-primary-500 hover:text-white transition-all shadow-glow-primary hover:shadow-[0_0_30px_-5px_var(--color-primary-500)]">Deploy Report</button>
        </div>
      </div>

      {/* Primary Metrics */}
      <div className="grid grid-cols-4 gap-6">
        {metrics.map((m, i) => (
          <div key={i} className="glass-card group flex flex-col justify-between h-36 relative overflow-hidden p-6 cursor-default">
             <div className="absolute top-0 right-0 p-5 opacity-5 text-zinc-100 group-hover:opacity-[0.08] transition-opacity duration-500 group-hover:scale-110 group-hover:-rotate-3">
                {React.cloneElement(m.icon, { size: 64 })}
             </div>
             <div className="absolute inset-0 bg-gradient-to-br from-white/[0.02] to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
             
             <div className="text-[11px] font-bold text-zinc-500 uppercase tracking-widest relative z-10">{m.label}</div>
             <div className="flex items-end justify-between relative z-10">
                <div className="text-3xl font-mono font-bold text-white tracking-tighter drop-shadow-md">{m.value}</div>
                <div className={`flex items-center gap-1 text-[11px] font-bold px-2 py-1 rounded-md backdrop-blur-sm border ${m.isUp ? 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20' : 'text-rose-400 bg-rose-500/10 border-rose-500/20'}`}>
                   {m.isUp ? <RiArrowUpSLine /> : <RiArrowDownSLine />} {m.trend}
                </div>
             </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-12 gap-6">
        {/* Main Analytics Engine */}
        <div className="col-span-8 glass-card h-[450px] flex flex-col p-6">
           <div className="flex items-center justify-between mb-10">
              <div>
                 <h3 className="text-[15px] font-bold text-zinc-100 drop-shadow-sm">Traffic Distribution</h3>
                 <p className="text-[11px] font-medium text-zinc-500 mt-1 uppercase tracking-wider">Real-time data stream across operational nodes</p>
              </div>
              <div className="flex gap-1.5 p-1 bg-zinc-950/50 rounded-lg border border-white/[0.02]">
                 {['1H', '1D', '1W', '1M'].map((t) => (
                   <button key={t} className={`px-3 py-1 text-[10px] font-bold rounded-md transition-colors ${t === '1D' ? 'bg-zinc-800 text-white shadow-sm' : 'text-zinc-500 hover:text-zinc-300 hover:bg-zinc-800/50'}`}>
                      {t}
                   </button>
                 ))}
              </div>
           </div>
           
           <div className="flex-1 flex items-end gap-3 pb-2 relative">
              {/* Grid lines */}
              <div className="absolute inset-x-0 bottom-2 top-0 flex flex-col justify-between pointer-events-none">
                 {[1, 2, 3, 4].map((l) => (
                    <div key={l} className="w-full h-px bg-white/[0.02]" />
                 ))}
              </div>
           
              {[40, 60, 45, 80, 55, 90, 70, 85, 60, 75, 50, 65, 95, 80, 60].map((h, i) => (
                <div key={i} className="flex-1 rounded-t-sm relative group cursor-crosshair flex flex-col justify-end" style={{ height: '100%' }}>
                   <div 
                     className="w-full bg-gradient-to-t from-primary-600/20 to-primary-400/50 rounded-t-md relative group-hover:to-primary-400 group-hover:from-primary-600 group-hover:shadow-[0_0_15px_rgba(59,130,246,0.5)] transition-all duration-300"
                     style={{ height: `${h}%` }}
                   >
                     <div className="absolute top-0 inset-x-0 h-px bg-primary-300/50" />
                   </div>
                   <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 bg-zinc-900 border border-zinc-700 text-[10px] font-mono p-1.5 rounded-md opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10 text-white shadow-xl shadow-black/50">
                      VAL_{h*120}
                   </div>
                </div>
              ))}
           </div>
        </div>

        {/* Regional Pulse */}
        <div className="col-span-4 glass-card flex flex-col p-6">
           <h3 className="text-[15px] font-bold text-zinc-100 mb-8 drop-shadow-sm">Regional Performance</h3>
           <div className="space-y-6">
              {[
                { name: 'Dakar Central', load: 84, status: 'NOMINAL' },
                { name: 'Saint-Louis North', load: 32, status: 'IDLE' },
                { name: 'Thiès Corridor', load: 68, status: 'BUSY' },
                { name: 'Mbour Hub', load: 12, status: 'IDLE' },
              ].map((region, i) => (
                <div key={i} className="space-y-2.5">
                   <div className="flex justify-between text-[11px] font-bold tracking-tight">
                      <div className="flex items-center gap-2">
                         <RiMapPin2Line className="text-zinc-500" />
                         <span className="text-zinc-200">{region.name}</span>
                      </div>
                      <span className={region.load > 75 ? 'text-rose-400' : 'text-emerald-500 opacity-80'}>{region.status}</span>
                   </div>
                   <div className="w-full h-1.5 bg-zinc-950 rounded-full overflow-hidden border border-white/[0.02]">
                      <div className={`h-full transition-all duration-1000 ease-out relative ${region.load > 75 ? 'bg-gradient-to-r from-rose-600 to-rose-400' : 'bg-gradient-to-r from-primary-600 to-primary-400'}`} style={{ width: `${region.load}%` }}>
                         <div className="absolute inset-0 bg-white/20 w-full" style={{ clipPath: 'polygon(0 0, 10px 0, 0 100%, -10px 100%)' }} />
                      </div>
                   </div>
                </div>
              ))}
           </div>
           
           <div className="mt-auto pt-6 border-t border-white/[0.04]">
              <button className="w-full flex items-center justify-between text-[11px] font-bold text-zinc-500 hover:text-primary-400 transition-colors uppercase tracking-widest group">
                 <span>View Full Topography</span>
                 <RiExternalLinkLine className="group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />
              </button>
           </div>
        </div>
      </div>

      {/* Technical Terminal Overlay */}
      <div className="glass-card p-0 h-48 bg-[#050505]/80 overflow-hidden group">
         <div className="flex items-center justify-between px-6 py-3 border-b border-white/[0.04] bg-zinc-900/30">
            <div className="flex items-center gap-2.5">
               <div className="w-2 h-2 rounded-full bg-emerald-500 shadow-glow-emerald animate-pulse" />
               <span className="text-[10px] font-bold text-zinc-400 uppercase tracking-[0.2em] drop-shadow-sm">Global Audit Stream</span>
            </div>
            <span className="text-[10px] font-mono text-zinc-600 bg-zinc-950/50 px-2 py-0.5 rounded border border-white/[0.02]">ENCRYPTION: AES-256-GCM</span>
         </div>
         <div className="p-5 px-6 font-mono text-[11px] space-y-2 text-zinc-500 leading-relaxed overflow-y-auto h-full custom-scrollbar">
            <div className="flex gap-4 opacity-70"><span className="text-zinc-600 w-16">20:18:36</span> <span className="text-emerald-500 w-8">[OK]</span> <span className="text-zinc-400">Node sync verified across 12 sector zones</span></div>
            <div className="flex gap-4"><span className="text-zinc-600 w-16">20:18:37</span> <span className="text-emerald-500 w-8 drop-shadow-[0_0_2px_rgba(16,185,129,0.8)]">[OK]</span> <span className="text-zinc-300">Authentication successful for UID-9021 from 192.168.1.44</span></div>
            <div className="flex gap-4"><span className="text-zinc-600 w-16">20:18:37</span> <span className="text-primary-500 w-8">[INF]</span> <span className="text-zinc-300">Synchronizing ledger across 4 regional clusters...</span></div>
            <div className="flex gap-4 bg-rose-500/5 -mx-6 px-6 py-0.5 border-l-2 border-rose-500"><span className="text-zinc-600 w-16">20:18:38</span> <span className="text-rose-400 w-8">[WRN]</span> <span className="text-rose-200">Low signal detected in Thiès-East node. Auto-failover initiated.</span></div>
            <div className="flex gap-4 group-hover:opacity-100 opacity-50 transition-opacity"><span className="text-zinc-600 w-16">20:18:39</span> <span className="text-emerald-500 w-8">[OK]</span> <span className="text-zinc-300">KYC Verification completed for request #AX-901</span></div>
         </div>
      </div>
    </div>
  );
};

export default Dashboard;
