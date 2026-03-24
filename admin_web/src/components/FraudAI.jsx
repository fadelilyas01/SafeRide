import React from 'react';
import { 
  RiCpuLine, 
  RiShieldFlashLine, 
  RiEyeLine, 
  RiHistoryLine, 
  RiAlertLine,
  RiTerminalLine,
  RiFocus3Line,
  RiExternalLinkLine,
  RiPulseFill
} from 'react-icons/ri';

const FraudAI = () => {
  const alerts = [
    { id: 'AL-9012', user: 'Moussa F.', type: 'Velocity Jump', risk: 84, time: '2m ago' },
    { id: 'AL-8995', user: 'Aline D.', type: 'IP Mismatch', risk: 62, time: '12m ago' },
    { id: 'AL-8982', user: 'Cheikh T.', type: 'Shadow Account', risk: 45, time: '45m ago' },
  ];

  return (
    <div className="p-8 space-y-8 max-w-[1600px] mx-auto">
      <div className="flex justify-between items-end mb-8">
        <div>
           <div className="expert-badge text-blue-400 mb-2">Neural Engine: Nominal</div>
           <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">Fraud Intelligence AI</h1>
           <p className="text-[11px] font-medium text-zinc-500 mt-1">Heuristic and machine learning behavior analysis</p>
        </div>
        <div className="flex gap-3">
           <button className="expert-button-secondary">Retrain Model</button>
           <button className="expert-button-primary bg-zinc-100 flex items-center gap-2">
              <RiShieldFlashLine size={16} /> Global Lockdown
           </button>
        </div>
      </div>

      <div className="grid grid-cols-12 gap-6">
        {/* Risk Metrics */}
        <div className="col-span-12 grid grid-cols-3 gap-6">
           <div className="expert-card">
              <div className="metric-label mb-4">Neural Scan Density</div>
              <div className="flex items-end gap-3">
                 <div className="metric-value">94.2%</div>
                 <div className="text-[10px] font-bold text-emerald-500 pb-1">+0.4% CONFIDENCE</div>
              </div>
              <div className="mt-4 flex gap-1 h-8">
                 {[40, 55, 30, 80, 45, 90, 60, 75, 50, 85, 40, 95].map((h, i) => (
                   <div key={i} className="flex-1 bg-zinc-800 rounded-sm" style={{ height: `${h}%` }} />
                 ))}
              </div>
           </div>
           <div className="expert-card">
              <div className="metric-label mb-4">Blocked Anomaly Cluster</div>
              <div className="flex items-end gap-3">
                 <div className="metric-value">128</div>
                 <div className="text-[10px] font-bold text-zinc-500 pb-1">LAST 24 HOURS</div>
              </div>
              <div className="mt-4 w-full h-8 bg-zinc-900 rounded-lg flex items-center px-3 gap-2 overflow-hidden">
                 <RiAlertLine className="text-orange-500/50" size={14} />
                 <div className="text-[10px] font-mono text-zinc-600 truncate">PATTERNMATCH: MULTIDRIVER_PROXY_DETECTED</div>
              </div>
           </div>
           <div className="expert-card">
              <div className="metric-label mb-4">Risk Level Distribution</div>
              <div className="flex items-end gap-3">
                 <div className="metric-value">LOW</div>
                 <div className="text-[10px] font-bold text-blue-500 pb-1">SYSTEM STATE</div>
              </div>
              <div className="mt-4 flex items-center gap-2">
                 <div className="flex-1 h-1.5 bg-emerald-500/30 rounded-full" />
                 <div className="flex-1 h-1.5 bg-blue-500/30 rounded-full" />
                 <div className="flex-1 h-1.5 bg-zinc-800 rounded-full" />
              </div>
           </div>
        </div>

        {/* Intelligence Stream */}
        <div className="col-span-7 expert-container bg-zinc-950/20">
           <div className="expert-header justify-between border-b border-zinc-900/50">
              <div className="flex items-center gap-3">
                 <RiTerminalLine className="text-zinc-600" />
                 <span className="text-[12px] font-bold text-zinc-300">Behavioral Anomaly Feed</span>
              </div>
              <RiPulseFill size={14} className="text-blue-500/50" />
           </div>
           <div className="p-4 space-y-4">
              {alerts.map((al) => (
                <div key={al.id} className="p-4 bg-zinc-900/40 border border-zinc-800/50 rounded-lg group hover:border-blue-500/20 transition-all">
                   <div className="flex justify-between items-start">
                      <div className="flex gap-4">
                         <div className="w-10 h-10 rounded bg-zinc-800 flex items-center justify-center text-zinc-600 group-hover:text-zinc-400">
                            <RiEyeLine size={20} />
                         </div>
                         <div>
                            <div className="text-[13px] font-bold text-zinc-200">{al.user} <span className="text-[10px] font-mono text-zinc-600 ml-2">UID:{al.id}</span></div>
                            <div className="text-[11px] font-medium text-zinc-500 mt-1">Detected <span className="text-orange-400">{al.type}</span> via Heuristic_B2</div>
                         </div>
                      </div>
                      <div className="text-right">
                         <div className={`text-[11px] font-bold ${al.risk > 80 ? 'text-red-500' : 'text-orange-400'}`}>RISK {al.risk}%</div>
                         <div className="text-[9px] font-mono text-zinc-700 uppercase mt-1">{al.time}</div>
                      </div>
                   </div>
                   <div className="mt-4 flex gap-2">
                      <button className="flex-1 py-1.5 bg-zinc-800/50 hover:bg-zinc-800 border border-zinc-800 rounded text-[10px] font-bold text-zinc-400 uppercase tracking-wider">Shadow Ban</button>
                      <button className="flex-1 py-1.5 bg-zinc-800/50 hover:bg-zinc-800 border border-zinc-800 rounded text-[10px] font-bold text-zinc-400 uppercase tracking-wider">Request KYC</button>
                      <button className="p-1.5 bg-blue-500/10 border border-blue-500/20 text-blue-400 rounded">
                         <RiFocus3Line size={14} />
                      </button>
                   </div>
                </div>
              ))}
           </div>
        </div>

        {/* Intelligence Config */}
        <div className="col-span-5 expert-card flex flex-col justify-between">
           <div>
              <h3 className="text-[15px] font-bold text-zinc-200 mb-6">Heuristic Parameters</h3>
              <div className="space-y-6">
                 {[
                   { label: 'Network Proximity Sensitivity', val: 78 },
                   { label: 'Behavioral Deviation Multiplier', val: 42 },
                   { label: 'Payment Velocity Threshold', val: 91 },
                 ].map((p, i) => (
                   <div key={i} className="space-y-3">
                      <div className="flex justify-between text-[11px] font-bold">
                         <span className="text-zinc-500 uppercase">{p.label}</span>
                         <span className="text-blue-500 mono">{p.val}%</span>
                      </div>
                      <input type="range" className="w-full h-1 bg-zinc-900 rounded-full appearance-none accent-blue-600" defaultValue={p.val} />
                   </div>
                 ))}
              </div>
           </div>
           
           <div className="pt-8 border-t border-zinc-800/50">
              <div className="p-4 bg-blue-500/[0.03] border border-blue-500/10 rounded-lg">
                 <div className="flex items-center gap-3 mb-2">
                    <RiCpuLine className="text-blue-500" />
                    <span className="text-[12px] font-bold text-zinc-300">AI Cluster Status</span>
                 </div>
                 <p className="text-[11px] text-zinc-500 font-medium leading-relaxed">Cluster is operating at 1.2M events/sec. Auto-scaling is enabled. No bottlenecks detected.</p>
                 <button className="w-full mt-4 text-[11px] font-bold text-zinc-400 flex items-center justify-between hover:text-zinc-100 transition-colors">
                    <span>Cluster Performance Logs</span>
                    <RiExternalLinkLine />
                 </button>
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default FraudAI;
