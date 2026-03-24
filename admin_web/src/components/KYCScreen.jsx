import React, { useState } from 'react';
import { 
  RiShieldFlashLine, 
  RiFileTextLine, 
  RiFingerprintLine, 
  RiCheckDoubleLine, 
  RiMapPinRangeLine,
  RiArrowRightUpLine,
  RiCheckboxCircleFill,
  RiCloseCircleFill,
  RiTerminalBoxLine,
  RiInformationLine
} from 'react-icons/ri';
import { useEffect } from 'react';
import { api } from '../services/api';

const KYCScreen = () => {
  const [selectedApplicant, setSelectedApplicant] = useState(null);
  const [applicants, setApplicants] = useState([]);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const users = await api.getUsers();
        // Filter drivers who are not yet verified
        const pendingDrivers = users.filter(u => u.role === 'DRIVER' && !u.isVerified).map(u => ({
          id: u.id,
          name: u.name,
          date: new Date(u.createdAt).toLocaleString(),
          score: Math.floor(Math.random() * (99 - 40) + 40), // Simulated AI score
          status: 'Review'
        }));
        setApplicants(pendingDrivers);
      } catch (err) {
        console.error("Erreur fetching users for KYC:", err);
      }
    };
    fetchUsers();
  }, []);

  const handleVerify = async () => {
    if (!selectedApplicant) return;
    try {
      await api.verifyUser(selectedApplicant.id);
      
      // Remove from list or refresh
      setApplicants(prev => prev.filter(a => a.id !== selectedApplicant.id));
      setSelectedApplicant(null);
    } catch (err) {
      console.error("Failed to verify user", err);
    }
  };

  const handleWomenSafe = async () => {
    if (!selectedApplicant) return;
    try {
      await api.setWomenSafe(selectedApplicant.id, true);
      setApplicants(prev => prev.map(a => a.id === selectedApplicant.id ? { ...a, womenSafe: true } : a));
      setSelectedApplicant(prev => ({ ...prev, womenSafe: true }));
    } catch (err) {
      console.error('Failed to set Women Safe', err);
    }
  };

  return (
    <div className="flex h-full overflow-hidden">
      {/* List Sidebar */}
      <div className="w-80 border-r border-zinc-800/10 flex flex-col bg-[#09090b]/50">
        <div className="p-6 border-b border-zinc-800/10">
           <div className="expert-badge text-emerald-500 mb-2">Pending Verification</div>
           <h2 className="text-[15px] font-bold text-zinc-100">Applicants Queue</h2>
        </div>
        <div className="flex-1 overflow-y-auto no-scrollbar py-2">
           {applicants.map((app) => (
             <div 
               key={app.id}
               onClick={() => setSelectedApplicant(app)}
               className={`mx-3 my-1 p-4 rounded-lg cursor-pointer transition-all border ${
                 selectedApplicant?.id === app.id 
                   ? 'bg-zinc-800/50 border-zinc-700/50' 
                   : 'border-transparent hover:bg-zinc-900/50'
               }`}
             >
                <div className="flex justify-between items-start mb-2">
                   <span className="text-[10px] font-mono text-zinc-500 tracking-wider uppercase">{app.id}</span>
                   <div className={`w-1.5 h-1.5 rounded-full ${app.score > 80 ? 'bg-emerald-500' : 'bg-orange-500'}`} />
                </div>
                <div className="text-[13px] font-bold text-zinc-200">{app.name}</div>
                <div className="flex justify-between items-end mt-4">
                   <span className="text-[10px] font-medium text-zinc-600">{app.date}</span>
                   <div className="text-[11px] font-mono text-zinc-400">SC: {app.score}%</div>
                </div>
             </div>
           ))}
        </div>
      </div>

      {/* Detail View */}
      <div className="flex-1 overflow-y-auto no-scrollbar bg-[#09090b]">
        {selectedApplicant ? (
          <div className="p-10 space-y-10 max-w-4xl">
             <div className="flex justify-between items-start">
                <div className="flex gap-6 items-center">
                   <div className="w-20 h-20 rounded-2xl bg-zinc-900 border border-zinc-800 flex items-center justify-center p-1">
                      <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${selectedApplicant.name}`} alt="avatar" className="rounded-xl" />
                   </div>
                   <div>
                      <div className="flex items-center gap-3">
                         <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">{selectedApplicant.name}</h1>
                         <RiArrowRightUpLine size={20} className="text-zinc-700 hover:text-blue-500 cursor-pointer" />
                      </div>
                      <div className="flex items-center gap-4 mt-2">
                         <div className="flex items-center gap-1.5 text-[11px] font-bold text-zinc-500 uppercase tracking-widest">
                            <RiFingerprintLine size={14} /> ID Verified
                         </div>
                         <div className="flex items-center gap-1.5 text-[11px] font-bold text-emerald-500 uppercase tracking-widest">
                            <RiPulseLine size={14} /> Risk Node: LOW
                         </div>
                      </div>
                   </div>
                </div>
                <div className="flex gap-3">
                   <button className="expert-button-secondary border-red-500/20 text-red-400 flex items-center gap-2">
                      <RiCloseCircleFill size={16} /> REJECT_APPLICATION
                   </button>
                   <button onClick={handleWomenSafe} className="expert-button-secondary border-pink-500/20 text-pink-400 flex items-center gap-2">
                      ♀ WOMEN_SAFE
                   </button>
                   <button onClick={handleVerify} className="expert-button-primary bg-emerald-600 border-emerald-500/20 flex items-center gap-2">
                      <RiCheckboxCircleFill size={16} /> AUTHORIZE_NODE
                   </button>
                </div>
             </div>

             <div className="grid grid-cols-2 gap-6">
                <div className="expert-card space-y-4">
                   <div className="flex items-center justify-between mb-2">
                      <h3 className="text-[12px] font-bold text-zinc-400 uppercase tracking-widest">Identity Documents</h3>
                      <RiFileTextLine className="text-zinc-600" />
                   </div>
                   <div className="bg-zinc-950/40 border border-zinc-800/30 rounded-lg p-3 flex items-center gap-4 group cursor-pointer hover:border-blue-500/30 transition-all">
                      <div className="w-12 h-12 rounded bg-zinc-800 flex items-center justify-center text-zinc-500 group-hover:text-blue-400">
                         <RiTerminalBoxLine size={24} />
                      </div>
                      <div className="flex-1">
                         <div className="text-[12px] font-bold text-zinc-300">National_ID_Front.jpg</div>
                         <div className="text-[10px] text-zinc-600 font-mono tracking-tighter uppercase">Checksum: 8FB02...E1</div>
                      </div>
                      <RiExternalLinkLine className="text-zinc-800 group-hover:text-zinc-400" />
                   </div>
                   <div className="bg-zinc-950/40 border border-zinc-800/30 rounded-lg p-3 flex items-center gap-4 group cursor-pointer hover:border-blue-500/30 transition-all">
                      <div className="w-12 h-12 rounded bg-zinc-800 flex items-center justify-center text-zinc-500 group-hover:text-blue-400">
                         <RiTerminalBoxLine size={24} />
                      </div>
                      <div className="flex-1">
                         <div className="text-[12px] font-bold text-zinc-300">Proof_of_Residency.pdf</div>
                         <div className="text-[10px] text-zinc-600 font-mono tracking-tighter uppercase">CRC: AF021-992</div>
                      </div>
                      <RiExternalLinkLine className="text-zinc-800 group-hover:text-zinc-400" />
                   </div>
                </div>

                <div className="expert-card space-y-4">
                   <div className="flex items-center justify-between mb-2">
                      <h3 className="text-[12px] font-bold text-zinc-400 uppercase tracking-widest">Biometric Analysis</h3>
                      <RiFingerprintLine className="text-zinc-600" />
                   </div>
                   <div className="space-y-4 pt-2">
                      <div className="space-y-2">
                         <div className="flex justify-between text-[11px] font-bold">
                            <span className="text-zinc-500 uppercase">Face Recognition Match</span>
                            <span className="text-emerald-500 opacity-80">99.2%</span>
                         </div>
                         <div className="w-full h-1 bg-zinc-900 rounded-full overflow-hidden">
                            <div className="h-full bg-emerald-500/60" style={{ width: '99.2%' }} />
                         </div>
                      </div>
                      <div className="space-y-2">
                         <div className="flex justify-between text-[11px] font-bold">
                            <span className="text-zinc-500 uppercase">Document Liveness</span>
                            <span className="text-emerald-500 opacity-80">SUCCESS</span>
                         </div>
                         <div className="w-full h-1 bg-zinc-900 rounded-full overflow-hidden">
                            <div className="h-full bg-blue-500/60" style={{ width: '100%' }} />
                         </div>
                      </div>
                      <div className="pt-4 border-t border-zinc-800/20">
                         <div className="flex items-center gap-2 text-[10px] font-mono text-zinc-600 uppercase">
                            <RiInformationLine size={14} />
                            <span>Neural Scan completed in 1.4s</span>
                         </div>
                      </div>
                   </div>
                </div>
             </div>

             <div className="expert-card bg-emerald-500/[0.02] border-emerald-500/10">
                <div className="flex items-center gap-4">
                   <div className="w-10 h-10 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-500">
                      <RiCheckDoubleLine size={20} />
                   </div>
                   <div>
                      <h4 className="text-[13px] font-bold text-zinc-200">System Recommendation: APPROVE</h4>
                      <p className="text-[11px] font-medium text-zinc-500 mt-0.5">Automated screening detected zero anomalies. All regulatory checks PASSED.</p>
                   </div>
                </div>
             </div>
          </div>
        ) : (
          <div className="h-full flex flex-col items-center justify-center text-center p-20 opacity-40">
             <div className="w-16 h-16 bg-zinc-900 rounded-[1.5rem] border border-zinc-800 flex items-center justify-center text-zinc-700 mb-6">
                <RiShieldFlashLine size={32} />
             </div>
             <h3 className="text-lg font-bold text-zinc-300">
               {applicants.length > 0 ? "Select an applicant for audit" : "No pending verification"}
             </h3>
             <p className="text-xs font-medium text-zinc-600 mt-2 max-w-xs px-2">
               {applicants.length > 0 ? "Identity nodes requiring manual verification will appear in the registry to the left." : "All systems are green. The identity queue is empty."}
             </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default KYCScreen;
