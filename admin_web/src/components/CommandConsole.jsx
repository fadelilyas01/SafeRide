import React, { useState, useEffect, useRef } from 'react';
import { AnimatePresence } from 'framer-motion';
import { 
  Terminal as TerminalIcon, 
  ChevronRight, 
  Activity, 
  Cpu, 
  Command,
  Zap
} from 'lucide-react';

const CommandConsole = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [input, setInput] = useState('');
  const [history, setHistory] = useState([
    { type: 'sys', content: 'SafeRide Command Console v2.0.4-stable init...' },
    { type: 'sys', content: 'Liaison orbitale établie. En attente de directive.' },
  ]);
  const scrollRef = useRef(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [history]);

  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setIsOpen(prev => !prev);
      }
      if (e.key === 'Escape') setIsOpen(false);
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const handleCommand = (e) => {
    if (e.key === 'Enter' && input.trim()) {
      const cmd = input.trim().toLowerCase();
      setHistory(prev => [...prev, { type: 'user', content: `> ${input}` }]);
      
      // Simulated command processing
      setTimeout(() => {
        let response = { type: 'sys', content: `Command not found: ${cmd}` };
        
        if (cmd === 'help') {
          response = { type: 'sys', content: 'Available: status, fleet, boost [area], lockdown [id], clear' };
        } else if (cmd === 'status') {
          response = { type: 'sys', content: 'SYSTEM: ACTIVE | LOAD: 14% | LATENCY: 38ms | NODES: 12' };
        } else if (cmd === 'fleet') {
          response = { type: 'sys', content: 'ACTIVE DRIVERS: 142 | PENDING: 12 | OFF-DUTY: 54' };
        } else if (cmd === 'clear') {
          setHistory([]);
          setInput('');
          return;
        }

        setHistory(prev => [...prev, response]);
      }, 100);
      
      setInput('');
    }
  };

  return (
    <>
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-0 bottom-10 mx-auto w-full max-w-2xl z-[100] px-4"
          >
            <div className="bg-[var(--surface)]/95 backdrop-blur-xl border border-[var(--border)] shadow-2xl rounded-[2rem] overflow-hidden transition-all duration-300">
               <div className="p-4 border-b border-[var(--border)] bg-[var(--background)]/30 flex justify-between items-center">
                  <div className="flex items-center gap-3">
                     <div className="p-2 bg-blue-500/20 rounded-lg">
                        <TerminalIcon size={14} className="text-blue-500" />
                     </div>
                     <span className="text-[10px] font-black uppercase text-[var(--text-muted)] tracking-widest">SafeRide_Expert_Shell.exe</span>
                  </div>
                  <div className="flex gap-2">
                     <div className="w-2 h-2 rounded-full bg-[var(--border)]" />
                     <div className="w-2 h-2 rounded-full bg-[var(--border)]" />
                     <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />
                  </div>
               </div>

               <div 
                 ref={scrollRef}
                 className="p-6 h-64 overflow-y-auto font-mono text-xs space-y-2 no-scrollbar"
               >
                  {history.map((line, i) => (
                    <div key={i} className={`flex gap-3 leading-relaxed ${
                      line.type === 'user' ? 'text-blue-500 font-bold' : 'text-[var(--text-muted)]'
                    }`}>
                       <span className="opacity-30 shrink-0">[{i.toString().padStart(2, '0')}]</span>
                       <span className="break-all">{line.content}</span>
                    </div>
                  ))}
               </div>

               <div className="p-6 bg-[var(--background)]/30 border-t border-[var(--border)]">
                  <div className="relative flex items-center">
                     <ChevronRight className="absolute left-0 text-blue-500" size={16} />
                     <input 
                       autoFocus
                       type="text" 
                       value={input}
                       onChange={(e) => setInput(e.target.value)}
                       onKeyDown={handleCommand}
                       placeholder="Saisir une directive système..."
                       className="w-full bg-transparent border-none outline-none text-[var(--text)] font-mono text-sm pl-6"
                     />
                  </div>
               </div>

               <div className="px-6 py-2 bg-blue-600 flex justify-between items-center">
                  <div className="text-[9px] font-black text-white uppercase tracking-widest flex items-center gap-4">
                     <span className="flex items-center gap-1"><Command size={10} /> + K : Toggle</span>
                     <span className="flex items-center gap-1"><Cpu size={10} /> Kernel: Stable</span>
                  </div>
                  <div className="text-[9px] font-bold text-white/70">Montreal_Region_Node_01</div>
               </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Floating Toggle Button (if closed) */}
      {!isOpen && (
        <motion.button
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          onClick={() => setIsOpen(true)}
          className="fixed bottom-10 right-10 w-16 h-16 bg-blue-600 rounded-[2rem] flex items-center justify-center text-white shadow-2xl z-[90] hover:scale-110 active:scale-95 transition-all group border border-white/20"
        >
          <div className="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 rounded-[2rem] transition-opacity" />
          <Command size={24} />
          <div className="absolute -top-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full border-2 border-[var(--background)] transition-colors duration-300" />
        </motion.button>
      )}
    </>
  );
};

export default CommandConsole;
