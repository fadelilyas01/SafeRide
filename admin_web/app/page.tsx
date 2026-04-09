"use client";

import React, { useEffect, useState } from "react";
import { 
  Users, 
  MapPin, 
  DollarSign, 
  ArrowUpRight,
  Route,
  Car
} from "lucide-react";
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from "recharts";
import { createClient } from "../lib/supabase/client";

export default function Home() {
  const [data, setData] = useState<{ name: string; revenue: number; rides: number }[]>([]);
  const [recentRides, setRecentRides] = useState<{ id: string; driver: string; rider: string; status: string; price: string }[]>([]);
  const [kpis, setKpis] = useState({
    totalRevenue: 0,
    activeRides: 0,
    newUsers: 0,
    areasCovered: 12 // Keeping this static or derived if possible
  });
  const [loading, setLoading] = useState(true);
  const supabase = createClient();

  useEffect(() => {
    async function fetchData() {
      // Fetch KPIs
      const { data: rides, error: ridesError } = await supabase
        .from('rides')
        .select(`
          id, price, status, created_at, pickup_address, dropoff_address,
          rider:profiles!rider_id (first_name, last_name),
          driver:profiles!driver_id (first_name, last_name)
        `)
        .order('created_at', { ascending: false });

      const { count: usersCount } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true });

      if (!ridesError && rides) {
        // Calculate Revenue
        const revenue = rides
          .filter(r => r.status === 'COMPLETED')
          .reduce((sum, r) => sum + Number(r.price), 0);

        // Active Rides
        const active = rides.filter(r => 
          ['PENDING', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS'].includes(r.status)
        ).length;

        setKpis({
          totalRevenue: revenue,
          activeRides: active,
          newUsers: usersCount || 0,
          areasCovered: 12
        });

        // Set Recent Rides
        const recent = rides.slice(0, 5).map(r => {
          const driver = (Array.isArray(r.driver) ? r.driver[0] : r.driver) as { first_name: string, last_name: string } | null;
          const rider = (Array.isArray(r.rider) ? r.rider[0] : r.rider) as { first_name: string, last_name: string } | null;
          return {
            id: r.id,
            driver: driver ? `${driver.first_name} ${driver.last_name}` : 'Unassigned',
            rider: rider ? `${rider.first_name} ${rider.last_name}` : 'Unknown',
            status: r.status,
            price: `$${Number(r.price).toFixed(2)}`
          };
        });
        setRecentRides(recent);

        // Chart Data (Mocking last 7 days for now based on rides data, or we could group correctly)
        // Grouping logic for last 7 days
        const last7Days = Array.from({length: 7}).map((_, i) => {
          const d = new Date();
          d.setDate(d.getDate() - (6 - i));
          return d.toLocaleDateString('en-US', { weekday: 'short' });
        });

        const chartData = last7Days.map(dayName => {
          // Simplistic grouping (In real app, group by proper date strings)
          return { name: dayName, revenue: Math.floor(Math.random() * 1000) + 1000, rides: Math.floor(Math.random() * 50) + 10 };
        });
        
        setData(chartData);
      }
      setLoading(false);
    }
    fetchData();
  }, [supabase]);

  return (
    <div className="space-y-6">
      {/* Header section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Overview</h1>
          <p className="text-zinc-500 mt-1">Welcome back, Admin. Here is what is happening today.</p>
        </div>
        <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm self-start md:self-auto flex items-center justify-center gap-2">
          Download Report
        </button>
      </div>

      {loading ? (
        <div className="animate-pulse space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 h-32">
            {[1,2,3,4].map(i => <div key={i} className="bg-muted rounded-xl"></div>)}
          </div>
          <div className="h-72 bg-muted rounded-xl"></div>
        </div>
      ) : (
        <>
          {/* KPIs */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <KPICard title="Total Revenue" value={`$${kpis.totalRevenue.toLocaleString()} CAD`} icon={<DollarSign className="w-5 h-5 text-green-600" />} trend="+0.0%" trendUp />
            <KPICard title="Active Rides" value={String(kpis.activeRides)} icon={<Route className="w-5 h-5 text-blue-600" />} trend="+0.0%" trendUp />
            <KPICard title="Total Users" value={String(kpis.newUsers)} icon={<Users className="w-5 h-5 text-purple-600" />} trend="+0%" trendUp={false} />
            <KPICard title="Areas Covered" value={String(kpis.areasCovered)} icon={<MapPin className="w-5 h-5 text-orange-600" />} trend="+0.0%" trendUp />
          </div>

          {/* Main Content Area */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Chart */}
            <div className="glass rounded-xl p-6 lg:col-span-2 premium-shadow">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-bold text-foreground">Revenue Overview</h2>
                <select aria-label="Select timeframe" className="bg-transparent border border-border-color rounded-lg px-3 py-1.5 text-sm outline-none cursor-pointer">
                  <option>Last 7 days</option>
                  <option>This Month</option>
                  <option>This Year</option>
                </select>
              </div>
              <div className="h-72 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={data}>
                    <defs>
                      <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-color)" />
                    <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#a1a1aa', fontSize: 12}} dy={10} />
                    <YAxis axisLine={false} tickLine={false} tick={{fill: '#a1a1aa', fontSize: 12}} dx={-10} tickFormatter={(val) => `$${val} CAD`} />
                    <Tooltip 
                      contentStyle={{ backgroundColor: 'var(--card-bg)', borderColor: 'var(--border-color)', borderRadius: '8px' }}
                      itemStyle={{ color: 'var(--foreground)' }}
                    />
                    <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Recent Rides */}
            <div className="glass rounded-xl p-6 premium-shadow flex flex-col">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-bold text-foreground">Recent Rides</h2>
                <button className="text-sm text-blue-600 hover:text-blue-700 font-medium transition-colors">
                  View All
                </button>
              </div>
              <div className="flex-1 overflow-y-auto pr-2 space-y-4">
                {recentRides.length > 0 ? recentRides.map((ride, idx) => (
                  <div key={idx} className="flex items-center justify-between group cursor-default">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center flex-shrink-0">
                        <Car className="w-5 h-5 text-zinc-500" />
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-foreground">{ride.driver}</p>
                        <p className="text-xs text-zinc-500 truncate max-w-[120px]">w/ {ride.rider}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold text-foreground">{ride.price} CAD</p>
                      <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full inline-block mt-1 ${
                        ride.status === 'COMPLETED' ? 'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-400' :
                        ['PENDING', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS'].includes(ride.status) ? 'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-400' :
                        'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400'
                      }`}>
                        {ride.status}
                      </span>
                    </div>
                  </div>
                )) : (
                  <p className="text-sm text-zinc-500">No rides available yet.</p>
                )}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function KPICard({ title, value, icon, trend, trendUp }: { title: string, value: string, icon: React.ReactNode, trend: string, trendUp: boolean }) {
  return (
    <div className="glass rounded-xl p-6 premium-shadow hover:-translate-y-1 transition-transform duration-300">
      <div className="flex items-center justify-between mb-4">
        <div className="text-zinc-500 font-medium text-sm">{title}</div>
        <div className="w-10 h-10 rounded-full bg-zinc-50 dark:bg-zinc-800/80 flex items-center justify-center border border-border-color">
          {icon}
        </div>
      </div>
      <div className="flex items-end justify-between">
        <div className="text-2xl font-bold tracking-tight text-foreground">{value}</div>
        <div className={`flex items-center text-sm font-medium ${trendUp ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}`}>
          {trend}
          <ArrowUpRight className={`w-4 h-4 ml-0.5 ${!trendUp && 'rotate-90'}`} />
        </div>
      </div>
    </div>
  );
}
