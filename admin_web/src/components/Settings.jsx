import React from 'react';
import { 
  RiUser3Line, 
  RiShieldKeyholeLine, 
  RiNotification3Line, 
  RiGlobalLine, 
  RiDatabase2Line,
  RiArrowRightSLine,
  RiCheckLine,
  RiPaintBrushLine,
  RiSettingsLine,
  RiCpuLine,
  RiTerminalBoxLine
} from 'react-icons/ri';

const Settings = () => {
  const sections = [
    { id: 'profile', label: 'Identity Control', icon: <RiUser3Line />, active: true },
    { id: 'security', label: 'Security & Auth Gates', icon: <RiShieldKeyholeLine /> },
    { id: 'nodes', label: 'Regional Edge Nodes', icon: <RiGlobalLine /> },
    { id: 'logic', label: 'Core Heuristics', icon: <RiCpuLine /> },
    { id: 'appearance', label: 'UI Parameters', icon: <RiPaintBrushLine /> },
    { id: 'api', label: 'API Connectors', icon: <RiTerminalBoxLine /> },
  ];

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      <div className="flex justify-between items-end mb-8">
        <div>
           <div className="expert-badge text-blue-500 mb-2">Platform Configuration</div>
           <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">System Parameters</h1>
           <p className="text-[11px] font-medium text-zinc-500 mt-1">High-level control over operational logic and security protocols</p>
        </div>
        <button className="expert-button-primary flex items-center gap-2 px-6">
           <RiCheckLine size={18} /> COMMIT_CHANGES
        </button>
      </div>

      <div className="grid grid-cols-12 gap-8">
        <aside className="col-span-3 space-y-1">
           {sections.map((section) => (
             <button
               key={section.id}
               className={`w-full flex items-center justify-between p-3 px-4 rounded-md transition-all group ${
                 section.active 
                   ? 'bg-zinc-800/10 border border-zinc-700/50 text-zinc-100 shadow-sm' 
                   : 'text-zinc-600 hover:bg-zinc-900 hover:text-zinc-400 border border-transparent'
               }`}
             >
               <div className="flex items-center gap-3">
                  <span className={section.active ? 'text-blue-500' : 'text-zinc-700 group-hover:text-zinc-600'}>
                     {React.cloneElement(section.icon, { size: 18 })}
                  </span>
                  <span className="text-[13px] font-bold tracking-tight">{section.label}</span>
               </div>
               {section.active && <RiArrowRightSLine size={18} className="text-zinc-700" />}
             </button>
           ))}
        </aside>

        <section className="col-span-9 expert-container">
           <div className="expert-header border-b border-zinc-900/50">
              <h3 className="text-[13px] font-bold text-zinc-300">Section: Identity Control</h3>
           </div>
           
           <div className="p-10 space-y-10">
              <div className="grid grid-cols-2 gap-8">
                 <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-600 uppercase tracking-widest pl-1">Authorized Identity Name</label>
                    <input 
                      type="text" 
                      defaultValue="Administrative Unit 01" 
                      className="w-full bg-zinc-950 border border-zinc-800 rounded-md p-3 text-[13px] font-mono text-zinc-200 focus:border-blue-500/50 outline-none transition-all"
                    />
                 </div>
                 <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-600 uppercase tracking-widest pl-1">Primary Access Hash (E-mail)</label>
                    <input 
                      type="email" 
                      defaultValue="security-01@saferide.pro" 
                      className="w-full bg-zinc-950 border border-zinc-800 rounded-md p-3 text-[13px] font-mono text-zinc-200 focus:border-blue-500/50 outline-none transition-all"
                    />
                 </div>
                 <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-600 uppercase tracking-widest pl-1">Default Node Assignment</label>
                    <select className="w-full bg-zinc-950 border border-zinc-800 rounded-md p-3 text-[13px] font-bold text-zinc-200 focus:border-blue-500/50 outline-none transition-all appearance-none cursor-pointer">
                       <option>SN-DKR-NORTH.NODE</option>
                       <option>SN-DKR-SOUTH.NODE</option>
                       <option>SN-STL-MAIN.NODE</option>
                    </select>
                 </div>
                 <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-600 uppercase tracking-widest pl-1">Session Data Protocol</label>
                    <select className="w-full bg-zinc-950 border border-zinc-800 rounded-md p-3 text-[13px] font-bold text-zinc-200 focus:border-blue-500/50 outline-none transition-all appearance-none cursor-pointer">
                       <option>REST_XHR_STABLE</option>
                       <option>WEB_SOCKET_FULL</option>
                    </select>
                 </div>
              </div>

              <div className="pt-8 border-t border-zinc-900">
                 <div className="flex items-center gap-3 mb-6">
                    <RiShieldKeyholeLine className="text-zinc-600" />
                    <h3 className="text-[14px] font-bold text-zinc-100">Enhanced Security Protocols</h3>
                 </div>
                 <div className="space-y-4">
                    <div className="flex items-center justify-between p-4 bg-zinc-950 rounded-lg border border-zinc-800 group hover:border-zinc-700 transition-all">
                       <div>
                          <div className="text-[13px] font-bold text-zinc-300 tracking-tight">Multi-Factor Neural Auth</div>
                          <div className="text-[11px] font-medium text-zinc-600 mt-0.5">Extra validation layer via authenticated clusters</div>
                       </div>
                       <div className="w-10 h-5 bg-blue-600 rounded-full flex items-center px-1">
                          <div className="w-3.5 h-3.5 bg-white rounded-full ml-auto shadow-sm" />
                       </div>
                    </div>
                    <div className="flex items-center justify-between p-4 bg-zinc-950 rounded-lg border border-zinc-800 group hover:border-zinc-700 transition-all">
                       <div>
                          <div className="text-[13px] font-bold text-zinc-300 tracking-tight">API Key Management</div>
                          <div className="text-[11px] font-medium text-zinc-600 mt-0.5">Control tokens for external infrastructure integrations</div>
                       </div>
                       <button className="text-[11px] font-bold px-3 py-1.5 border border-zinc-800 rounded text-zinc-400 hover:bg-zinc-900 transition-all uppercase tracking-widest">REGENERATE</button>
                    </div>
                 </div>
              </div>
           </div>
        </section>
      </div>
    </div>
  );
};

export default Settings;
