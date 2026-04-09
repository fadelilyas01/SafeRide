"use client";

import React, { useEffect, useState } from "react";
import { Search, MapPin, Navigation, MessageSquare, X } from "lucide-react";
import { createClient } from "../../lib/supabase/client";

interface RiderDriver {
  first_name: string;
  last_name: string;
  phone: string;
}

interface Ride {
  id: string;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  price: number;
  created_at: string;
  rider: RiderDriver | null;
  driver: RiderDriver | null;
}

interface ChatMessage {
  id: string;
  message: string;
  sender_id: string;
  ride_id: string;
  created_at: string;
}

export default function RidesPage() {
  const [rides, setRides] = useState<Ride[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedRideId, setSelectedRideId] = useState<string | null>(null);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const supabase = createClient();

  useEffect(() => {
    async function fetchRides() {
      setLoading(true);
      const { data, error } = await supabase
        .from("rides")
        .select(`
          *,
          rider:profiles!rider_id (first_name, last_name, phone),
          driver:profiles!driver_id (first_name, last_name, phone)
        `)
        .order("created_at", { ascending: false });

      if (!error && data) {
        const formattedData: Ride[] = data.map((r) => ({
          id: r.id as string,
          pickup_address: r.pickup_address as string,
          dropoff_address: r.dropoff_address as string,
          status: r.status as string,
          price: r.price as number,
          created_at: r.created_at as string,
          rider: (Array.isArray(r.rider) ? r.rider[0] : r.rider) as RiderDriver | null,
          driver: (Array.isArray(r.driver) ? r.driver[0] : r.driver) as RiderDriver | null
        }));
        setRides(formattedData);
      }
      setLoading(false);
    }

    fetchRides();
  }, [supabase]);

  const filteredRides = rides.filter(r =>
    r.id.toLowerCase().includes(search.toLowerCase()) ||
    r.pickup_address.toLowerCase().includes(search.toLowerCase()) ||
    r.dropoff_address.toLowerCase().includes(search.toLowerCase()) ||
    (r.rider?.first_name?.toLowerCase() || "").includes(search.toLowerCase()) ||
    (r.driver?.first_name?.toLowerCase() || "").includes(search.toLowerCase())
  );

  const openChat = async (rideId: string) => {
    setSelectedRideId(rideId);
    const { data } = await supabase
      .from("chat_messages")
      .select("*")
      .eq("ride_id", rideId)
      .order("created_at", { ascending: true });
    if (data) {
      setChatMessages(data as ChatMessage[]);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Rides History</h1>
          <p className="text-zinc-500 mt-1">Monitor all in-progress, completed, and canceled rides.</p>
        </div>

        <div className="flex items-center relative max-w-sm w-full">
          <Search className="w-4 h-4 text-zinc-400 absolute left-3" />
          <input
            type="text"
            placeholder="Search by ID, location, or name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-card-bg border border-border-color focus:border-blue-500 focus:ring-1 focus:ring-blue-500 rounded-lg pl-10 pr-4 py-2 text-sm transition-all outline-none text-foreground placeholder:text-zinc-500"
          />
        </div>
      </div>

      <div className="glass rounded-xl overflow-hidden premium-shadow">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-muted/50 border-b border-border-color">
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Ride Info</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Route</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Rider</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Driver</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Status</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Price</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-color">
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    <td className="p-4"><div className="skeleton h-8 w-24"></div></td>
                    <td className="p-4"><div className="skeleton h-12 w-48"></div></td>
                    <td className="p-4"><div className="skeleton h-8 w-32"></div></td>
                    <td className="p-4"><div className="skeleton h-8 w-32"></div></td>
                    <td className="p-4"><div className="skeleton h-6 w-16"></div></td>
                    <td className="p-4"><div className="skeleton h-8 w-16"></div></td>
                    <td className="p-4"><div className="skeleton h-8 w-8"></div></td>
                  </tr>
                ))
              ) : filteredRides.length > 0 ? (
                filteredRides.map((ride) => (
                  <tr key={ride.id} className="hover:bg-hover-bg transition-colors">
                    <td className="p-4">
                      <div className="font-mono text-xs bg-muted px-2 py-1 rounded inline-block mb-1">
                        {ride.id.substring(0, 8)}...
                      </div>
                      <div className="text-xs text-zinc-500">
                        {new Date(ride.created_at).toLocaleString()}
                      </div>
                    </td>
                    <td className="p-4 max-w-[250px]">
                      <div className="flex items-start gap-2 mb-2">
                        <MapPin className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                        <span className="text-sm truncate" title={ride.pickup_address}>{ride.pickup_address}</span>
                      </div>
                      <div className="flex items-start gap-2">
                        <Navigation className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                        <span className="text-sm truncate" title={ride.dropoff_address}>{ride.dropoff_address}</span>
                      </div>
                    </td>
                    <td className="p-4">
                      {ride.rider ? (
                        <>
                          <div className="text-sm font-semibold text-foreground">{ride.rider.first_name} {ride.rider.last_name}</div>
                          <div className="text-xs text-zinc-500">{ride.rider.phone}</div>
                        </>
                      ) : (
                        <span className="text-sm text-zinc-500 italic">Unknown</span>
                      )}
                    </td>
                    <td className="p-4">
                      {ride.driver ? (
                        <>
                          <div className="text-sm font-semibold text-foreground">{ride.driver.first_name} {ride.driver.last_name}</div>
                          <div className="text-xs text-zinc-500">{ride.driver.phone}</div>
                        </>
                      ) : (
                        <span className="text-sm text-zinc-500 italic">Unassigned</span>
                      )}
                    </td>
                    <td className="p-4">
                      <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full inline-block ${
                        ride.status === 'COMPLETED' ? 'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-400' :
                        ride.status === 'CANCELLED' ? 'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400' :
                        'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-400'
                      }`}>
                        {ride.status}
                      </span>
                    </td>
                    <td className="p-4">
                      <div className="text-sm font-bold">${Number(ride.price).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})} CAD</div>
                    </td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => openChat(ride.id)}
                        className="p-2 text-zinc-400 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-lg transition-colors"
                        title="View Chat"
                      >
                        <MessageSquare className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} className="p-8 text-center text-zinc-500">
                    No rides found matching your criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Chat Modal */}
      {selectedRideId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm px-6 py-6">
          <div className="bg-card-bg border border-border-color rounded-2xl w-full max-w-md shadow-2xl overflow-hidden flex flex-col max-h-[80vh]">
            <div className="p-4 border-b border-border-color flex items-center justify-between bg-muted/30">
              <h3 className="font-bold flex items-center gap-2">
                <MessageSquare className="w-4 h-4 text-blue-600" />
                Ride Chat History
              </h3>
              <button 
                onClick={() => setSelectedRideId(null)} 
                className="p-1 hover:bg-hover-bg rounded-lg transition-colors"
                aria-label="Fermer la fenêtre de chat"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              {chatMessages.length > 0 ? chatMessages.map((msg, i) => (
                <div key={i} className={`flex flex-col ${msg.ride_id === 'admin' ? 'items-center' : 'items-start'}`}>
                   <div className="bg-muted px-3 py-2 rounded-lg text-sm max-w-[85%] border border-border-color">
                    <p className="text-xs font-bold text-zinc-500 mb-1">{msg.sender_id.substring(0,8)}</p>
                    {msg.message}
                   </div>
                   <span className="text-[10px] text-zinc-500 mt-1">{new Date(msg.created_at).toLocaleTimeString()}</span>
                </div>
              )) : (
                <div className="h-40 flex items-center justify-center text-zinc-500 italic text-sm">
                  No messages for this ride.
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
