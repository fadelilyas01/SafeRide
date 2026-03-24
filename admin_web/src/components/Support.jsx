import React, { useState } from 'react';
import { 
  RiMessage3Line, 
  RiSearchLine, 
  RiMore2Line,
  RiSendPlane2Fill,
  RiAttachment2,
  RiInformationLine,
  RiUserVoiceLine,
  RiTerminalBoxLine,
  RiFocus3Line
} from 'react-icons/ri';

const Support = () => {
  const [selectedTicket, setSelectedTicket] = useState(null);

  const entries = [
    { id: 'TKT-1021', entity: 'A. Diop', subject: 'PAYMENT_PROTOCOL_FAILURE', status: 'ACTIVE', time: '2m', priority: 'HIGH' },
    { id: 'TKT-1020', entity: 'Marie Sow', subject: 'GEOLOCATION_SKEW_ERROR', status: 'PENDING', time: '14m', priority: 'NORMAL' },
    { id: 'TKT-1018', entity: 'Oumar Sy', subject: 'IDENTITY_GRANT_REJECTED', status: 'CLOSED', time: '1h', priority: 'LOW' },
  ];

  return (
    <div className="flex h-full overflow-hidden">
      {/* Help Desk Sidebar */}
      <div className="w-96 border-r border-zinc-800/10 flex flex-col bg-[#09090b]">
        <div className="p-6 border-b border-zinc-800/10">
           <div className="expert-badge text-blue-500 mb-2">Support Interface</div>
           <h2 className="text-[15px] font-bold text-zinc-100 italic">Incoming Signal Queue</h2>
        </div>
        <div className="p-4 border-b border-zinc-900/40">
           <div className="relative">
              <RiSearchLine className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-700" size={14} />
              <input 
                type="text" 
                placeholder="Query Ticket ID or Subject..." 
                className="w-full bg-zinc-950 border border-zinc-900 rounded-md py-1.5 pl-9 pr-4 text-[11px] outline-none focus:border-zinc-700 transition-all font-mono"
              />
           </div>
        </div>
        <div className="flex-1 overflow-y-auto no-scrollbar py-2">
           {entries.map((t) => (
             <div 
               key={t.id}
               onClick={() => setSelectedTicket(t)}
               className={`mx-3 my-1 p-5 rounded-lg border cursor-pointer transition-all ${
                 selectedTicket?.id === t.id 
                   ? 'bg-zinc-900/50 border-zinc-700/50 shadow-sm' 
                   : 'border-transparent hover:bg-zinc-900/20'
               }`}
             >
                <div className="flex justify-between items-start mb-3">
                   <span className="text-[10px] font-mono text-zinc-600 uppercase tracking-tighter">{t.id}</span>
                   <div className={`w-1.5 h-1.5 rounded-full ${t.priority === 'HIGH' ? 'bg-red-500 animate-pulse' : 'bg-blue-500'}`} />
                </div>
                <div className="text-[13px] font-bold text-zinc-200 mb-1">{t.subject}</div>
                <p className="text-[11px] font-medium text-zinc-600 truncate">Emitter: {t.entity}</p>
                <div className="flex justify-between items-end mt-4">
                   <div className={`text-[10px] font-bold tracking-widest uppercase ${
                     t.status === 'ACTIVE' ? 'text-red-400' :
                     t.status === 'CLOSED' ? 'text-zinc-600' : 'text-blue-500'
                   }`}>{t.status}</div>
                   <span className="text-[10px] font-mono text-zinc-700">{t.time}</span>
                </div>
             </div>
           ))}
        </div>
      </div>

      {/* Communications Matrix */}
      <div className="flex-1 flex flex-col bg-[#09090b]">
        {selectedTicket ? (
          <>
            <div className="expert-header justify-between border-b border-zinc-900/50 sticky top-0 bg-[#09090b]/80 backdrop-blur-md">
               <div className="flex items-center gap-4">
                  <div className="w-8 h-8 rounded bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-600">
                     <RiUserVoiceLine size={18} />
                  </div>
                  <div>
                     <h3 className="text-[13px] font-bold text-zinc-100">{selectedTicket.entity}</h3>
                     <p className="text-[10px] font-mono text-zinc-600 uppercase tracking-tighter">{selectedTicket.subject}</p>
                  </div>
               </div>
               <div className="flex gap-2">
                  <button className="p-2 text-zinc-700 hover:text-zinc-300 transition-colors">
                     <RiFocus3Line size={18} />
                  </button>
                  <button className="p-2 text-zinc-700 hover:text-red-500 transition-colors">
                     <RiMore2Line size={18} />
                  </button>
               </div>
            </div>

            <div className="flex-1 overflow-y-auto no-scrollbar p-10 space-y-10">
               <div className="flex gap-4 max-w-2xl px-2">
                  <div className="w-8 h-8 rounded bg-zinc-900 shrink-0 border border-zinc-800" />
                  <div className="bg-zinc-900/30 border border-zinc-800/50 p-5 rounded-lg rounded-tl-none space-y-3">
                     <p className="text-[12px] text-zinc-400 font-medium leading-relaxed italic">"Signal interference detected during last fiscal exchange. Orange Money node returned error [ERR-402]. Can you re-validate the settlement?"</p>
                     <div className="text-[9px] font-mono text-zinc-700 uppercase tracking-widest text-right">SIGNAL RECEIVED_10:42:01</div>
                  </div>
               </div>

               <div className="flex gap-4 max-w-2xl ml-auto flex-row-reverse px-2">
                  <div className="w-8 h-8 rounded bg-blue-600 shrink-0 shadow-[0_0_15px_rgba(59,130,246,0.2)] flex items-center justify-center text-zinc-950">
                     <RiTerminalBoxLine size={16} />
                  </div>
                  <div className="bg-blue-600/5 border border-blue-500/20 p-5 rounded-lg rounded-tr-none space-y-3">
                     <p className="text-[12px] text-zinc-200 font-medium leading-relaxed">"Processing re-validation sequence for UID-{selectedTicket.id}. Please standby while we sync with the regional gateway node. Current latency: 44ms."</p>
                     <div className="text-[9px] font-mono text-blue-500/70 uppercase tracking-widest">ENCRYPTED_SIGNAL_SENT_10:45:12</div>
                  </div>
               </div>
            </div>

            <div className="p-6 border-t border-zinc-800/20 bg-zinc-950/20">
               <div className="flex gap-4 items-center">
                  <button className="text-zinc-700 hover:text-zinc-300">
                     <RiAttachment2 size={24} />
                  </button>
                  <div className="flex-1 relative">
                     <input 
                       type="text" 
                       placeholder="Enter technical response..." 
                       className="w-full bg-zinc-950 border border-zinc-900/80 rounded-md py-3 px-5 text-[12px] font-mono text-zinc-300 outline-none focus:border-zinc-700 transition-all"
                     />
                  </div>
                  <button className="w-12 h-12 bg-zinc-100 text-zinc-950 rounded shadow-lg flex items-center justify-center hover:bg-white transition-all">
                     <RiSendPlane2Fill size={20} />
                  </button>
               </div>
               <div className="mt-3 flex items-center gap-2 text-[10px] font-mono text-zinc-700 uppercase tracking-widest px-11">
                  <RiInformationLine size={12} />
                  <span>TRANSMISSION ENCRYPTED VIA AES_256</span>
               </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-center p-20 opacity-30">
             <div className="w-16 h-16 bg-zinc-900 rounded-lg border border-zinc-800 flex items-center justify-center text-zinc-700 mb-6">
                <RiMessage3Line size={32} />
             </div>
             <h3 className="text-lg font-bold text-zinc-400 tracking-tighter uppercase italic">No Active Signal Session</h3>
             <p className="text-[10px] font-mono text-zinc-600 mt-2 max-w-xs uppercase tracking-widest">Select an incoming TICKET_ID from the left query panel to initiate communication node.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Support;
