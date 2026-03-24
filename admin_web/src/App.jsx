import React from 'react';
import { Routes, Route, Link, useLocation } from 'react-router-dom';
import { RiSearchLine, RiNotification3Line, RiCommandLine, RiWifiLine, RiMapPinRangeLine, RiArrowRightSLine } from 'react-icons/ri';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import UserList from './components/UserList';
import KYCScreen from './components/KYCScreen';
import WarRoom from './components/WarRoom';
import FinanceDashboard from './components/FinanceDashboard';
import FraudAI from './components/FraudAI';
import AuditLogs from './components/AuditLogs';
import Settings from './components/Settings';
import Support from './components/Support';

const App = () => {
  const location = useLocation();
  const pathParts = location.pathname.split('/').filter(p => p);
  
  return (
    <div className="flex h-screen w-full bg-[#050505] text-zinc-300 overflow-hidden font-sans relative selection:bg-primary-500/30 selection:text-white">
      <Sidebar />
      
      <main className="flex-1 flex flex-col min-w-0 relative z-10">
        {/* Top Header Navigation */}
        <header className="h-16 border-b border-white/[0.04] flex items-center justify-between px-8 bg-zinc-950/60 backdrop-blur-2xl z-20 shrink-0">
          <div className="flex items-center gap-8">
             {/* Breadcrumbs */}
             <div className="flex items-center gap-2 text-[11px] font-medium text-zinc-500 uppercase tracking-widest">
                <RiCommandLine size={14} className="text-zinc-400" />
                <Link to="/" className="hover:text-zinc-200 transition-colors">Workspace</Link>
                {pathParts.map((part, i) => (
                  <React.Fragment key={i}>
                     <RiArrowRightSLine size={14} className="text-zinc-700" />
                     <span className={i === pathParts.length - 1 ? 'text-zinc-200 font-bold' : 'text-zinc-500'}>{part}</span>
                  </React.Fragment>
                ))}
             </div>
             
             <div className="h-4 w-px bg-white/[0.06]" />
             
             {/* Infrastructure Metrics */}
             <div className="flex items-center gap-4">
                <div className="flex items-center gap-2 bg-zinc-900/50 border border-white/[0.03] px-2.5 py-1 rounded-md shadow-inner">
                   <RiWifiLine size={12} className="text-emerald-500 drop-shadow-[0_0_4px_rgba(16,185,129,0.5)]" />
                   <span className="text-[10px] font-mono text-zinc-400">12ms</span>
                </div>
                <div className="flex items-center gap-2 bg-zinc-900/50 border border-white/[0.03] px-2.5 py-1 rounded-md shadow-inner">
                   <RiMapPinRangeLine size={12} className="text-primary-400" />
                   <span className="text-[10px] font-mono text-zinc-400">EU-WEST-3</span>
                </div>
             </div>
          </div>

          <div className="flex items-center gap-6">
             {/* Global Search */}
             <div className="relative group">
                <RiSearchLine className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500 group-focus-within:text-primary-400 transition-colors" size={14} />
                <input 
                  type="text" 
                  placeholder="Ask intelligence (⌘K)" 
                  className="bg-zinc-900/40 border border-white/[0.05] rounded-xl py-[7px] pl-9 pr-4 text-[13px] w-72 focus:bg-zinc-800 focus:border-primary-500/50 focus:ring-1 focus:ring-primary-500/50 outline-none transition-all text-zinc-200 placeholder:text-zinc-600 shadow-inner"
                />
             </div>
             
             {/* Notifications */}
             <button className="relative p-2 text-zinc-500 hover:text-zinc-200 transition-colors rounded-lg hover:bg-zinc-800/50">
                <RiNotification3Line size={18} />
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-primary-500 rounded-full border-2 border-[#0a0a0a] shadow-glow-primary" />
             </button>
             
             {/* Profile Block */}
             <div className="flex items-center gap-3 pl-6 border-l border-white/[0.06]">
                <div className="text-right">
                   <div className="text-[12px] font-bold text-zinc-200 leading-none tracking-tight">E. Admin</div>
                   <div className="text-[10px] text-zinc-500 font-mono mt-1">Lvl 5 Clearance</div>
                </div>
                <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-zinc-800 to-zinc-700 p-0.5 shadow-sm cursor-pointer hover:scale-105 transition-transform border border-white/[0.05]">
                   <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Admin&backgroundColor=transparent" alt="Avatar" className="w-full h-full rounded-full bg-zinc-950" />
                </div>
             </div>
          </div>
        </header>

        {/* Dynamic Route Content */}
        <div className="flex-1 overflow-y-auto custom-scrollbar p-8">
           <div className="max-w-[1600px] mx-auto w-full">
             <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/users" element={<UserList />} />
                <Route path="/kyc" element={<KYCScreen />} />
                <Route path="/war-room" element={<WarRoom />} />
                <Route path="/finance" element={<FinanceDashboard />} />
                <Route path="/ai" element={<FraudAI />} />
                <Route path="/logs" element={<AuditLogs />} />
                <Route path="/settings" element={<Settings />} />
                <Route path="/support" element={<Support />} />
             </Routes>
           </div>
        </div>
      </main>
    </div>
  );
};

export default App;
