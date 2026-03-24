import React, { useState, useEffect } from 'react';
import { 
  RiWallet3Line, 
  RiExchangeLine, 
  RiArrowRightUpLine, 
  RiArrowRightDownLine, 
  RiBankCardLine,
  RiFileList3Line,
  RiSearchLine,
  RiDownload2Line,
  RiPieChart2Line,
  RiShieldCheckLine
} from 'react-icons/ri';
import { api } from '../services/api';

const FinanceDashboard = () => {
  const [statsData, setStatsData] = useState(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await api.getStats();
        setStatsData(data);
      } catch (err) {
        console.error('Failed to fetch stats:', err);
      }
    };
    fetchStats();
  }, []);
  const stats = [
    { label: 'Total Revenue', value: statsData ? `$${statsData.revenue.toLocaleString()}` : '$0', trend: '+14.2%', isUp: true, icon: <RiWallet3Line /> },
    { label: 'Active Escrow', value: statsData ? `$${(statsData.revenue * 0.1).toLocaleString()}` : '$0', trend: '+2.1%', isUp: true, icon: <RiShieldCheckLine /> },
    { label: 'Payouts Processed', value: statsData ? `$${(statsData.revenue * 0.75).toLocaleString()}` : '$0', trend: '-1.5%', isUp: false, icon: <RiBankCardLine /> },
    { label: 'Platform Fees', value: statsData ? `$${(statsData.revenue * 0.15).toLocaleString()}` : '$0', trend: 'Stable', isUp: true, icon: <RiPieChart2Line /> },
  ];

  const transactions = [
    { id: 'TX-90210', user: 'Abdoulaye D.', amount: '+$42.50', status: 'Settled', method: 'Orange Money', date: 'Just now' },
    { id: 'TX-90209', user: 'Marie Sow', amount: '-$120.00', status: 'Processing', method: 'Bank Transfer', date: '5m ago' },
    { id: 'TX-90208', user: 'Oumar Sy', amount: '+$15.75', status: 'Settled', method: 'Wave', date: '12m ago' },
    { id: 'TX-90207', user: 'Awa Ndiaye', amount: '+$28.00', status: 'Failed', method: 'Visa Card', date: '30m ago' },
  ];

  return (
    <div className="p-8 space-y-8 max-w-[1600px] mx-auto">
      <div className="flex justify-between items-end mb-8">
        <div>
           <div className="expert-badge text-emerald-500 mb-2">Fiscal Node: Active</div>
           <h1 className="text-2xl font-bold text-zinc-100 tracking-tight">Financial Intelligence</h1>
           <p className="text-[11px] font-medium text-zinc-500 mt-1">Real-time revenue tracking and transaction settlement</p>
        </div>
        <div className="flex gap-3">
           <button className="expert-button-secondary">Sync Ledger</button>
           <button className="expert-button-primary bg-zinc-100 flex items-center gap-2">
              <RiDownload2Line size={16} /> Export CSV
           </button>
        </div>
      </div>

      <div className="grid grid-cols-4 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="expert-card group relative">
             <div className="flex justify-between items-start mb-4">
                <div className="w-10 h-10 rounded-lg bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-500 group-hover:text-emerald-500 transition-colors">
                   {React.cloneElement(stat.icon, { size: 20 })}
                </div>
                <div className={`flex items-center gap-1 text-[10px] font-mono font-bold px-2 py-0.5 rounded ${stat.isUp ? 'bg-emerald-500/10 text-emerald-400' : 'bg-red-500/10 text-red-500'}`}>
                   {stat.isUp ? <RiArrowRightUpLine /> : <RiArrowRightDownLine />} {stat.trend}
                </div>
             </div>
             <div className="space-y-1">
                <div className="metric-label">{stat.label}</div>
                <div className="metric-value">{stat.value}</div>
             </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-12 gap-6">
        <div className="col-span-8 expert-container bg-zinc-950/20">
           <div className="p-4 border-b border-zinc-800/10 flex items-center justify-between">
              <h3 className="text-[14px] font-bold text-zinc-300">Transaction Stream</h3>
              <div className="relative">
                 <RiSearchLine className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-600" size={14} />
                 <input 
                   type="text" 
                   placeholder="Filter TXID..." 
                   className="bg-zinc-900/50 border border-zinc-800/40 rounded py-1 pl-9 pr-4 text-[11px] w-48 focus:border-emerald-500/30 outline-none transition-all"
                 />
              </div>
           </div>
           
           <div className="overflow-x-auto">
              <table className="w-full text-left">
                 <thead>
                    <tr className="bg-zinc-900/30">
                       <th className="px-6 py-3 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">Transaction ID</th>
                       <th className="px-6 py-3 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">Entity</th>
                       <th className="px-6 py-3 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">Volume</th>
                       <th className="px-6 py-3 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">Protocol</th>
                       <th className="px-6 py-3 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">State</th>
                       <th className="px-6 py-3 text-right"></th>
                    </tr>
                 </thead>
                 <tbody className="divide-y divide-zinc-800/10">
                    {transactions.map((tx) => (
                      <tr key={tx.id} className="hover:bg-zinc-900/40 transition-colors group">
                         <td className="px-6 py-4 font-mono text-[11px] text-zinc-500">{tx.id}</td>
                         <td className="px-6 py-4">
                            <div className="text-[12px] font-bold text-zinc-300">{tx.user}</div>
                            <div className="text-[10px] text-zinc-600 uppercase font-bold tracking-tight">{tx.date}</div>
                         </td>
                         <td className="px-6 py-4">
                            <div className={`text-[12px] font-mono font-bold ${tx.amount.startsWith('+') ? 'text-emerald-500' : 'text-zinc-300'}`}>
                               {tx.amount}
                            </div>
                         </td>
                         <td className="px-6 py-4">
                            <div className="flex items-center gap-2 text-[11px] font-medium text-zinc-500">
                               <RiBankCardLine size={14} /> {tx.method}
                            </div>
                         </td>
                         <td className="px-6 py-4">
                            <div className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${
                              tx.status === 'Settled' ? 'text-emerald-500' : 
                              tx.status === 'Failed' ? 'text-red-500' : 'text-orange-400'
                            }`}>
                               <div className={`w-1 h-1 rounded-full ${
                                 tx.status === 'Settled' ? 'bg-emerald-500' : 
                                 tx.status === 'Failed' ? 'bg-red-500' : 'bg-orange-400'
                               }`} />
                               {tx.status}
                            </div>
                         </td>
                         <td className="px-6 py-4 text-right">
                            <button className="text-zinc-800 group-hover:text-zinc-400 transition-colors">
                               <RiFileList3Line size={16} />
                            </button>
                         </td>
                      </tr>
                    ))}
                 </tbody>
              </table>
           </div>
        </div>

        <div className="col-span-4 space-y-6">
           <div className="expert-card">
              <h3 className="text-[14px] font-bold text-zinc-300 mb-6">Revenue Mix</h3>
              <div className="space-y-4">
                 {[
                   { label: 'Booking Fees', val: 65, color: 'bg-emerald-500' },
                   { label: 'Insurance Cut', val: 20, color: 'bg-blue-500' },
                   { label: 'Misc Ledger', val: 15, color: 'bg-zinc-700' },
                 ].map((item, i) => (
                   <div key={i} className="space-y-1.5">
                      <div className="flex justify-between text-[11px] font-bold">
                         <span className="text-zinc-500 uppercase">{item.label}</span>
                         <span className="text-zinc-200">{item.val}%</span>
                      </div>
                      <div className="w-full h-1 bg-zinc-900 rounded-full overflow-hidden">
                         <div className={`h-full ${item.color} opacity-60`} style={{ width: `${item.val}%` }} />
                      </div>
                   </div>
                 ))}
              </div>
           </div>

           <div className="expert-card bg-zinc-950/40 border-dashed border-zinc-800">
              <div className="flex items-center gap-4 mb-4">
                 <RiExchangeLine size={24} className="text-zinc-700" />
                 <h4 className="text-[12px] font-bold text-zinc-400 uppercase tracking-widest">Payout Node</h4>
              </div>
              <p className="text-[11px] text-zinc-600 font-medium leading-relaxed">System automated payouts are currently set to 24h batch intervals. Next settlement in <span className="text-zinc-400 font-mono italic">04:22:18</span></p>
              <button className="w-full mt-4 expert-button-secondary py-2">Manual Sweep</button>
           </div>
        </div>
      </div>
    </div>
  );
};

export default FinanceDashboard;
