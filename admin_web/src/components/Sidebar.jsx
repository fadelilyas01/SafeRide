import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  RiDashboard3Line, 
  RiGroupLine, 
  RiShieldFlashLine, 
  RiPulseLine, 
  RiSignalTowerLine, 
  RiHistoryLine, 
  RiSettings3Line, 
  RiQuestionLine,
  RiDatabase2Line,
  RiScan2Line
} from 'react-icons/ri';

const Sidebar = () => {
  const categories = [
    {
      title: 'Infrastructure',
      items: [
        { path: '/', icon: <RiDashboard3Line />, label: 'System Overview' },
        { path: '/ai', icon: <RiPulseLine />, label: 'Intelligence Core' },
        { path: '/war-room', icon: <RiSignalTowerLine />, label: 'Tactical War Room' },
      ]
    },
    {
      title: 'Governance',
      items: [
        { path: '/users', icon: <RiGroupLine />, label: 'Directory' },
        { path: '/kyc', icon: <RiShieldFlashLine />, label: 'Identity Verification' },
        { path: '/finance', icon: <RiDatabase2Line />, label: 'Fiscal Controller' },
      ]
    },
    {
      title: 'System',
      items: [
        { path: '/logs', icon: <RiHistoryLine />, label: 'Audit Logs' },
        { path: '/settings', icon: <RiSettings3Line />, label: 'Parameters' },
        { path: '/support', icon: <RiQuestionLine />, label: 'Support Desk' },
      ]
    }
  ];

  return (
    <aside className="w-[260px] h-full glass-panel relative flex flex-col z-20">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 border-b border-white/[0.04] shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-zinc-800 to-zinc-950 border border-zinc-700 shadow-inner flex items-center justify-center text-zinc-100 relative overflow-hidden group">
             <div className="absolute inset-0 bg-primary-500/10 opacity-0 group-hover:opacity-100 transition-opacity" />
             <RiScan2Line size={18} className="text-primary-400" />
          </div>
          <div className="flex flex-col">
            <span className="text-[14px] font-extrabold tracking-tight text-zinc-100 text-gradient leading-none">SafeRide</span>
            <span className="text-[9px] font-bold text-zinc-500 tracking-[0.2em] uppercase mt-1">Admin Command</span>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto custom-scrollbar py-6 px-4 space-y-8">
        {categories.map((cat, i) => (
          <div key={i} className="space-y-1.5">
            <h4 className="px-3 text-[10px] font-bold text-zinc-600 uppercase tracking-[0.15em] mb-3">{cat.title}</h4>
            {cat.items.map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) => `
                  relative flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-300 group overflow-hidden
                  ${isActive 
                    ? 'bg-zinc-800/60 text-zinc-100 border border-zinc-700/50 shadow-sm' 
                    : 'text-zinc-500 hover:text-zinc-200 hover:bg-zinc-800/30 border border-transparent'
                  }
                `}
              >
                {({ isActive }) => (
                  <>
                    {/* Active state styling line */}
                    {isActive && (
                      <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-primary-500 rounded-r-full shadow-glow-primary" />
                    )}
                    
                    {/* Icon with hover bounce */}
                    <span className={`shrink-0 transition-transform duration-300 ${isActive ? 'text-primary-400 scale-110 drop-shadow-[0_0_8px_rgba(59,130,246,0.3)]' : 'text-zinc-500 group-hover:text-zinc-300 group-hover:scale-110'}`}>
                       {React.cloneElement(item.icon, { size: 18 })}
                    </span>
                    
                    {/* Label */}
                    <span className={`text-[13px] font-medium tracking-tight mt-[1px] ${isActive ? 'font-semibold' : ''}`}>
                       {item.label}
                    </span>
                  </>
                )}
              </NavLink>
            ))}
          </div>
        ))}
      </nav>

      {/* Status Footer */}
      <div className="p-4 border-t border-white/[0.04] bg-zinc-950/40 shrink-0">
        <div className="bg-zinc-900/60 border border-white/[0.05] rounded-xl p-3.5 space-y-3 hover:border-white/[0.1] transition-colors cursor-default">
           <div className="flex items-center justify-between">
              <span className="text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Global State</span>
              <div className="flex items-center gap-1.5">
                 <span className="relative flex h-2 w-2">
                   <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                   <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                 </span>
                 <span className="text-[10px] font-bold text-emerald-500">NOMINAL</span>
              </div>
           </div>
           <div className="space-y-1.5 mt-2">
              <div className="flex justify-between items-center text-[10px] leading-none">
                 <span className="text-zinc-400 font-medium">Cluster-Alpha</span>
                 <span className="text-zinc-300 font-mono tracking-tighter">99.9%</span>
              </div>
              <div className="w-full bg-zinc-950 h-1.5 rounded-full overflow-hidden border border-white/[0.02]">
                 <div className="w-[99.9%] h-full bg-gradient-to-r from-emerald-600 to-emerald-400 shadow-glow-emerald" />
              </div>
           </div>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
