"use client";

import React from 'react';
import { 
  DollarSign, 
  TrendingUp, 
  ArrowUpRight, 
  ArrowDownRight, 
  CreditCard, 
  Building,
  Calendar,
  Download
} from 'lucide-react';
import { 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';

const data = [
  { name: 'Lun', revenue: 4500, rides: 120 },
  { name: 'Mar', revenue: 5200, rides: 145 },
  { name: 'Mer', revenue: 4800, rides: 130 },
  { name: 'Jeu', revenue: 6100, rides: 170 },
  { name: 'Ven', revenue: 7500, rides: 210 },
  { name: 'Sam', revenue: 9200, rides: 250 },
  { name: 'Dim', revenue: 8400, rides: 230 },
];

export default function FinancesPage() {
  return (
    <div className="space-y-8 page-fade-in">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Finances & Revenus</h1>
          <p className="text-zinc-500 mt-1">Gérez la santé financière de SafeRide Canada</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 bg-card-bg border border-border-color rounded-xl text-sm font-medium hover:bg-hover-bg transition-colors">
            <Calendar className="w-4 h-4" />
            Ce mois
          </button>
          <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-xl text-sm font-medium hover:bg-blue-700 transition-colors shadow-lg shadow-blue-500/20">
            <Download className="w-4 h-4" />
            Exporter
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass p-6 rounded-3xl relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-green-500/10 rounded-2xl text-green-600">
              <DollarSign className="w-6 h-6" />
            </div>
            <span className="flex items-center text-xs font-bold text-green-600 bg-green-500/10 px-2 py-1 rounded-full">
              <ArrowUpRight className="w-3 h-3 mr-1" />
              +12.5%
            </span>
          </div>
          <h3 className="text-zinc-500 text-sm font-medium">Revenu Brut (MTD)</h3>
          <p className="text-3xl font-bold mt-1">$45,650.00 <span className="text-sm font-normal text-zinc-400">CAD</span></p>
          <div className="absolute -bottom-2 -right-2 w-24 h-24 bg-green-500/5 rounded-full blur-2xl group-hover:bg-green-500/10 transition-all"></div>
        </div>

        <div className="glass p-6 rounded-3xl relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-blue-500/10 rounded-2xl text-blue-600">
              <Building className="w-6 h-6" />
            </div>
            <span className="flex items-center text-xs font-bold text-blue-600 bg-blue-500/10 px-2 py-1 rounded-full">
              <ArrowUpRight className="w-3 h-3 mr-1" />
              +8.2%
            </span>
          </div>
          <h3 className="text-zinc-500 text-sm font-medium">Net SafeRide (Commissions)</h3>
          <p className="text-3xl font-bold mt-1">$11,412.50 <span className="text-sm font-normal text-zinc-400">CAD</span></p>
          <div className="absolute -bottom-2 -right-2 w-24 h-24 bg-blue-500/5 rounded-full blur-2xl group-hover:bg-blue-500/10 transition-all"></div>
        </div>

        <div className="glass p-6 rounded-3xl relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-purple-500/10 rounded-2xl text-purple-600">
              <CreditCard className="w-6 h-6" />
            </div>
            <span className="flex items-center text-xs font-bold text-red-600 bg-red-500/10 px-2 py-1 rounded-full">
              <ArrowDownRight className="w-3 h-3 mr-1" />
              -2.1%
            </span>
          </div>
          <h3 className="text-zinc-500 text-sm font-medium">Paiements Chauffeurs Dus</h3>
          <p className="text-3xl font-bold mt-1">$34,237.50 <span className="text-sm font-normal text-zinc-400">CAD</span></p>
          <div className="absolute -bottom-2 -right-2 w-24 h-24 bg-purple-500/5 rounded-full blur-2xl group-hover:bg-purple-500/10 transition-all"></div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="glass p-8 rounded-3xl">
          <div className="flex items-center justify-between mb-8">
            <h3 className="font-bold flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-blue-500" />
              Revenu Hebdomadaire
            </h3>
          </div>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-color)" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#a1a1aa', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#a1a1aa', fontSize: 12}} dx={-10} tickFormatter={(val) => `$${val}`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: 'var(--card-bg)', borderColor: 'var(--border-color)', borderRadius: '12px', backdropFilter: 'blur(8px)' }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="glass p-8 rounded-3xl">
          <div className="flex items-center justify-between mb-8">
            <h3 className="font-bold">Prochains Payouts (Chauffeurs)</h3>
            <button className="text-xs text-blue-600 hover:underline">Voir tout</button>
          </div>
          <div className="space-y-4">
            {[
              { name: 'Jean-Sébastien Roy', amount: 1240.50, rides: 42, status: 'Prêt' },
              { name: 'Amélie Tremblay', amount: 980.25, rides: 35, status: 'Prêt' },
              { name: 'Marc-André Côté', amount: 2150.00, rides: 68, status: 'En attente' },
              { name: 'Sophie Lefebvre', amount: 450.75, rides: 12, status: 'Prêt' },
            ].map((driver, i) => (
              <div key={i} className="flex items-center justify-between p-4 rounded-2xl hover:bg-hover-bg transition-colors border border-transparent hover:border-border-color group">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center font-bold text-zinc-500">
                    {driver.name.charAt(0)}
                  </div>
                  <div>
                    <p className="text-sm font-bold text-foreground">{driver.name}</p>
                    <p className="text-xs text-zinc-500">{driver.rides} courses terminées</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold">${driver.amount.toFixed(2)} CAD</p>
                  <span className={`text-[10px] font-bold uppercase ${driver.status === 'Prêt' ? 'text-green-500' : 'text-orange-500'}`}>
                    {driver.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
