import React from 'react';
import { 
  RiHistoryLine, 
  RiUser3Line, 
  RiShieldLine, 
  RiLockLine, 
  RiArrowRightSLine,
  RiSearchLine,
  RiFilter3Line,
  RiDownload2Line,
  RiTimeLine,
  RiInformationLine,
  RiTerminalLine
} from 'react-icons/ri';
import { useState, useEffect } from 'react';
import { api } from '../services/api';

const AuditLogs = () => {
  const [logs, setLogs] = useState([]);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const data = await api.getLogs();
        setLogs(data);
      } catch (err) {
        console.error('Failed to fetch logs:', err);
      }
    };
    fetchLogs();
  }, []);

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      <div className="flex justify-between items-end mb-8">
        <div>
           <div className="expert-badge text-zinc-500 mb-2">Immune Ledger</div>
           <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">System Audit Logs</h1>
           <p className="text-[11px] font-medium text-zinc-500 mt-1">Immutable forensic record of all administrative and system operations</p>
        </div>
        <div className="flex gap-3">
           <button className="expert-button-secondary">Sync Ledger</button>
           <button className="expert-button-primary bg-zinc-100 flex items-center gap-2">
              <RiDownload2Line size={16} /> Export Archive
           </button>
        </div>
      </div>

      <div className="expert-container bg-zinc-950/20">
        <div className="p-4 border-b border-zinc-800/10 flex items-center gap-4 bg-zinc-900/10">
           <div className="relative flex-1 max-w-md">
              <RiSearchLine className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-600" size={14} />
              <input 
                type="text" 
                placeholder="Search Action, Actor or Node..." 
                className="w-full bg-zinc-900/30 border border-zinc-800/50 rounded-md py-1.5 pl-9 pr-4 text-[12px] text-zinc-200 focus:border-blue-500/50 outline-none transition-all"
              />
           </div>
           <button className="flex items-center gap-2 px-3 py-1.5 bg-zinc-900 border border-zinc-800 rounded-md text-[12px] font-semibold text-zinc-400 hover:text-zinc-200 transition-all">
              <RiFilter3Line size={14} /> Log Filters
           </button>
           <div className="h-6 w-[1px] bg-zinc-800/50" />
           <div className="flex items-center gap-2 text-[10px] font-mono text-zinc-600 uppercase">
              <RiTerminalLine size={14} />
              <span>LOG_STREAM_V4_SECURE</span>
           </div>
        </div>

        <div className="overflow-x-auto">
           <table className="w-full text-left">
              <thead>
                 <tr className="bg-zinc-950 border-b border-zinc-800/10">
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Entry ID</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Action Vector</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Target Entity</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Actor ID</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Operational State</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Age</th>
                    <th className="px-6 py-4 text-right"></th>
                 </tr>
              </thead>
              <tbody className="divide-y divide-zinc-800/10 font-mono text-[11px]">
                 {logs.map((log) => (
                   <tr key={log.id} className="group hover:bg-white/[0.02] transition-colors">
                      <td className="px-6 py-4 text-zinc-600">{log.id}</td>
                      <td className="px-6 py-4 font-bold text-zinc-300">{log.action}</td>
                      <td className="px-6 py-4 text-zinc-500">{log.target}</td>
                      <td className="px-6 py-4">
                         <div className="flex items-center gap-2">
                            <RiUser3Line className="text-zinc-700" size={14} />
                            <span className="text-zinc-400">{log.actor}</span>
                         </div>
                      </td>
                      <td className="px-6 py-4">
                         <div className={`inline-flex items-center gap-2 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${
                           log.status === 'Success' ? 'text-emerald-500' :
                           log.status === 'Error' ? 'text-red-500 shadow-[0_0_8px_rgba(239,68,68,0.2)]' :
                           log.status === 'Warning' ? 'text-orange-400' : 'text-blue-400'
                         }`}>
                           {log.status}
                         </div>
                      </td>
                      <td className="px-6 py-4 text-zinc-600">{log.time}</td>
                      <td className="px-6 py-4 text-right opacity-0 group-hover:opacity-100 transition-opacity">
                         <button className="p-1 px-2 border border-zinc-800 rounded bg-zinc-900 text-zinc-400 hover:text-zinc-100">DETAILS</button>
                      </td>
                   </tr>
                 ))}
              </tbody>
           </table>
        </div>

        <div className="p-4 border-t border-zinc-800/10 flex items-center justify-between text-[11px] font-mono text-zinc-600">
           <div className="flex gap-6">
              <span>LEDGER_BLOCK: 9.2M</span>
              <span>INDEX: HASH_256</span>
           </div>
           <div className="flex items-center gap-2">
              <RiInformationLine size={14} className="text-zinc-800" />
              <span className="italic uppercase">Data persistence guaranteed for 2,555 days</span>
           </div>
        </div>
      </div>
    </div>
  );
};

export default AuditLogs;
