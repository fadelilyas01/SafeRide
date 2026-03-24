import React from 'react';
import { 
  RiSearchLine, 
  RiFilter3Line, 
  RiMore2Line, 
  RiUser3Line,
  RiArrowLeftSLine,
  RiArrowRightSLine,
  RiCheckboxCircleLine,
  RiTimeLine,
  RiCloseCircleLine
} from 'react-icons/ri';

const UserList = () => {
  const users = [
    { id: 'USR-8012', name: 'Abdoulaye Diop', email: 'a.diop@orange.sn', status: 'Active', type: 'Driver', lastActive: '2 min ago' },
    { id: 'USR-7944', name: 'Marie Sow', email: 'marie.sow@gmail.com', status: 'Pending', type: 'Passenger', lastActive: '15 min ago' },
    { id: 'USR-7931', name: 'Oumar Sy', email: 'o.sy@tech.sn', status: 'Suspended', type: 'Driver', lastActive: '1h ago' },
    { id: 'USR-7890', name: 'Awa Ndiaye', email: 'awa.nd@outlook.com', status: 'Active', type: 'Passenger', lastActive: '3h ago' },
    { id: 'USR-7855', name: 'Cheikh Tidiane', email: 'tidiane@freelance.sn', status: 'Active', type: 'Driver', lastActive: '5h ago' },
  ];

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      <div className="flex justify-between items-end mb-8">
        <div>
           <div className="expert-badge text-blue-500 mb-2">Entity Registry</div>
           <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">Identity Directory</h1>
           <p className="text-[11px] font-medium text-zinc-500 mt-1">Authorized access to the global SafeRide user database</p>
        </div>
        <div className="flex gap-3">
           <button className="expert-button-secondary">Sync Database</button>
           <button className="expert-button-primary">+ Provision User</button>
        </div>
      </div>

      <div className="expert-container bg-zinc-950/20">
        <div className="p-4 border-b border-zinc-800/10 flex items-center gap-4">
           <div className="relative flex-1 max-w-md">
              <RiSearchLine className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-600" size={14} />
              <input 
                type="text" 
                placeholder="Lookup UID, Name, or Email..." 
                className="w-full bg-zinc-900/30 border border-zinc-800/50 rounded-md py-1.5 pl-9 pr-4 text-[12px] text-zinc-200 focus:border-blue-500/50 outline-none transition-all"
              />
           </div>
           <button className="flex items-center gap-2 px-3 py-1.5 bg-zinc-900 border border-zinc-800 rounded-md text-[12px] font-semibold text-zinc-400 hover:text-zinc-200 transition-all">
              <RiFilter3Line size={14} /> Advanced Filters
           </button>
           <div className="h-6 w-[1px] bg-zinc-800/50" />
           <span className="text-[11px] font-mono text-zinc-600 uppercase tracking-widest">Query: ALL_ENTITIES_V4</span>
        </div>

        <div className="overflow-x-auto">
           <table className="w-full text-left">
              <thead>
                 <tr className="bg-zinc-900/50 border-b border-zinc-800/10">
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Identity Node</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Registry ID</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Classification</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Status Vector</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Last Auth</th>
                    <th className="px-6 py-4 text-right"></th>
                 </tr>
              </thead>
              <tbody className="divide-y divide-zinc-800/10">
                 {users.map((user) => (
                   <tr key={user.id} className="group hover:bg-zinc-900/20 transition-colors">
                      <td className="px-6 py-4">
                         <div className="flex items-center gap-3">
                            <div className="w-9 h-9 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-500 font-bold group-hover:border-zinc-700 transition-all overflow-hidden">
                               <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${user.name}`} alt="avatar" />
                            </div>
                            <div>
                               <div className="text-[13px] font-bold text-zinc-200">{user.name}</div>
                               <div className="text-[11px] font-medium text-zinc-500">{user.email}</div>
                            </div>
                         </div>
                      </td>
                      <td className="px-6 py-4 font-mono text-[11px] text-zinc-400">{user.id}</td>
                      <td className="px-6 py-4">
                         <div className={`inline-flex items-center gap-2 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${
                           user.type === 'Driver' ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20' : 'bg-purple-500/10 text-purple-400 border border-purple-500/20'
                         }`}>
                           {user.type}
                         </div>
                      </td>
                      <td className="px-6 py-4">
                         <div className="flex items-center gap-2">
                           {user.status === 'Active' && <RiCheckboxCircleLine className="text-emerald-500" />}
                           {user.status === 'Pending' && <RiTimeLine className="text-orange-400" />}
                           {user.status === 'Suspended' && <RiCloseCircleLine className="text-red-500" />}
                           <span className="text-[11px] font-bold uppercase tracking-widest text-zinc-400">{user.status}</span>
                         </div>
                      </td>
                      <td className="px-6 py-4">
                         <div className="text-[11px] font-medium text-zinc-500">{user.lastActive}</div>
                      </td>
                      <td className="px-6 py-4 text-right">
                         <button className="p-2 text-zinc-700 hover:text-zinc-200 transition-colors">
                            <RiMore2Line size={18} />
                         </button>
                      </td>
                   </tr>
                 ))}
              </tbody>
           </table>
        </div>

        <div className="p-4 border-t border-zinc-800/10 flex items-center justify-between bg-zinc-900/10">
           <div className="text-[11px] font-medium text-zinc-600">Showing 5 of 2,401 verified identities</div>
           <div className="flex items-center gap-2">
              <button className="p-1.5 text-zinc-600 hover:text-zinc-300 transition-all border border-zinc-800 rounded disabled:opacity-30">
                 <RiArrowLeftSLine size={18} />
              </button>
              <div className="px-3 text-[11px] font-mono text-zinc-400">PAGE 01 / 480</div>
              <button className="p-1.5 text-zinc-600 hover:text-zinc-300 transition-all border border-zinc-800 rounded">
                 <RiArrowRightSLine size={18} />
              </button>
           </div>
        </div>
      </div>
    </div>
  );
};

export default UserList;
