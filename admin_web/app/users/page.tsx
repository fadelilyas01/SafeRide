"use client";

import React, { useEffect, useState } from "react";
import { Search, Shield, ShieldAlert, CheckCircle, XCircle, FileText, X } from "lucide-react";
import { createClient } from "../../lib/supabase/client";

interface UserProfile {
  id: string;
  role: string;
  first_name: string | null;
  last_name: string | null;
  phone: string | null;
  trust_score: number;
  is_kyc_verified: boolean;
  is_women_safe: boolean;
  created_at: string;
}

export default function UsersPage() {
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
  const supabase = createClient();

  useEffect(() => {
    async function fetchUsers() {
      setLoading(true);
      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .order("created_at", { ascending: false });

      if (!error && data) {
        setUsers(data as UserProfile[]);
      }
      setLoading(false);
    }
    fetchUsers();
  }, [supabase]);

  async function toggleKYC(userId: string, currentStatus: boolean) {
    const { error } = await supabase
      .from("profiles")
      .update({ is_kyc_verified: !currentStatus })
      .eq("id", userId);

    if (!error) {
      setUsers(users.map(u => u.id === userId ? { ...u, is_kyc_verified: !currentStatus } : u));
    }
  }

  async function toggleWomenSafe(userId: string, currentStatus: boolean) {
    const { error } = await supabase
      .from("profiles")
      .update({ is_women_safe: !currentStatus })
      .eq("id", userId);

    if (!error) {
      setUsers(users.map(u => u.id === userId ? { ...u, is_women_safe: !currentStatus } : u));
    }
  }

  const filteredUsers = users.filter(u =>
    (u.first_name?.toLowerCase() || "").includes(search.toLowerCase()) ||
    (u.last_name?.toLowerCase() || "").includes(search.toLowerCase()) ||
    (u.phone || "").includes(search)
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">User Management</h1>
          <p className="text-zinc-500 mt-1">Manage passengers and drivers, verify identities.</p>
        </div>

        <div className="flex items-center relative max-w-sm w-full">
          <Search className="w-4 h-4 text-zinc-400 absolute left-3" />
          <input
            type="text"
            placeholder="Search by name or phone..."
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
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">User</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Role</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Phone</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Trust Score</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">KYC Status</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Women Safe</th>
                <th className="p-4 text-xs font-semibold text-zinc-500 uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-color">
              {loading ? (
                <tr>
                  <td colSpan={7} className="p-8 text-center text-zinc-500">
                    Loading users...
                  </td>
                </tr>
              ) : filteredUsers.length > 0 ? (
                filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-hover-bg transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center font-bold text-blue-600 dark:text-blue-400">
                          {user.first_name ? user.first_name[0] : "?"}
                        </div>
                        <div>
                          <div className="font-semibold text-foreground">{user.first_name} {user.last_name}</div>
                          <div className="text-xs text-zinc-500">Joined {new Date(user.created_at).toLocaleDateString()}</div>
                        </div>
                      </div>
                    </td>
                    <td className="p-4">
                      <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full inline-block ${
                        user.role === 'DRIVER' ? 'bg-orange-100 text-orange-700 dark:bg-orange-500/20 dark:text-orange-400' :
                        user.role === 'ADMIN' ? 'bg-purple-100 text-purple-700 dark:bg-purple-500/20 dark:text-purple-400' :
                        'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-400'
                      }`}>
                        {user.role}
                      </span>
                    </td>
                    <td className="p-4 text-sm text-zinc-600 dark:text-zinc-400">{user.phone}</td>
                    <td className="p-4">
                      <div className="flex items-center gap-1 text-sm font-medium">
                        {user.trust_score} / 5.0
                      </div>
                    </td>
                    <td className="p-4">
                      <button
                        onClick={() => toggleKYC(user.id, user.is_kyc_verified)}
                        className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold transition-colors ${
                          user.is_kyc_verified
                            ? "bg-green-100 text-green-700 hover:bg-green-200 dark:bg-green-500/20 dark:text-green-400 dark:hover:bg-green-500/30"
                            : "bg-red-100 text-red-700 hover:bg-red-200 dark:bg-red-500/20 dark:text-red-400 dark:hover:bg-red-500/30"
                        }`}
                      >
                        {user.is_kyc_verified ? <CheckCircle className="w-3.5 h-3.5" /> : <XCircle className="w-3.5 h-3.5" />}
                        {user.is_kyc_verified ? "Verified" : "Unverified"}
                      </button>
                    </td>
                    <td className="p-4">
                      {user.role === 'DRIVER' && (
                        <button
                          onClick={() => toggleWomenSafe(user.id, user.is_women_safe)}
                          className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold transition-colors border ${
                            user.is_women_safe
                              ? "bg-pink-100 text-pink-700 border-pink-200 hover:bg-pink-200 dark:bg-pink-500/20 dark:text-pink-400 dark:border-pink-500/30 dark:hover:bg-pink-500/30"
                              : "bg-zinc-100 text-zinc-500 border-border-color hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700"
                          }`}
                        >
                          {user.is_women_safe ? <Shield className="w-3.5 h-3.5" /> : <ShieldAlert className="w-3.5 h-3.5" />}
                          Women Safe
                        </button>
                      )}
                    </td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => setSelectedUser(user)}
                        className="flex items-center gap-1.5 ml-auto px-3 py-1.5 bg-blue-50 hover:bg-blue-100 dark:bg-blue-500/10 dark:hover:bg-blue-500/20 text-blue-600 dark:text-blue-400 rounded-lg text-xs font-bold transition-all"
                      >
                        <FileText className="w-3.5 h-3.5" />
                        Verify Docs
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} className="p-8 text-center text-zinc-500">
                    No users found matching your search.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* KYC Review Modal */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md">
          <div className="bg-card-bg border border-border-color rounded-3xl w-full max-w-2xl shadow-2xl overflow-hidden flex flex-col page-fade-in">
            <div className="p-6 border-b border-border-color flex items-center justify-between bg-muted/30">
              <div>
                <h3 className="font-bold text-xl flex items-center gap-2">
                  <Shield className="w-5 h-5 text-blue-500" />
                  KYC Document Verification
                </h3>
                <p className="text-xs text-zinc-500 mt-1">Reviewing documents for {selectedUser.first_name} {selectedUser.last_name}</p>
              </div>
              <button 
                onClick={() => setSelectedUser(null)} 
                className="p-2 hover:bg-hover-bg rounded-xl transition-colors"
                aria-label="Fermer la vérification KYC"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-8 grid grid-cols-1 md:grid-cols-2 gap-8 overflow-y-auto">
              {/* Document Simulator */}
              <div className="space-y-4">
                <p className="text-xs font-bold text-zinc-500 uppercase tracking-widest">Driver&apos;s License (Front)</p>
                <div className="aspect-[1.6/1] bg-gradient-to-br from-zinc-200 to-zinc-300 dark:from-zinc-800 dark:to-zinc-700 rounded-2xl relative overflow-hidden border border-border-color group">
                   {/* Blurred ID Simulation */}
                   <div className="absolute inset-4 blur-md opacity-40 bg-white/20 rounded-md"></div>
                   <div className="absolute top-6 left-6 w-12 h-16 bg-zinc-400/50 rounded-sm"></div>
                   <div className="absolute top-6 left-20 right-6 space-y-2">
                     <div className="h-4 w-3/4 bg-zinc-400/50 rounded-sm"></div>
                     <div className="h-3 w-1/2 bg-zinc-400/50 rounded-sm"></div>
                     <div className="h-3 w-2/3 bg-zinc-400/50 rounded-sm"></div>
                   </div>
                   <div className="absolute bottom-4 left-6 right-6 h-8 bg-zinc-400/30 rounded-full border border-zinc-400/20"></div>
                   
                   <div className="absolute inset-0 bg-blue-600/10 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity backdrop-blur-[2px]">
                      <p className="text-[10px] font-bold uppercase tracking-widest bg-blue-600 text-white px-3 py-1 rounded-full">Secure Document View</p>
                   </div>
                </div>
              </div>

              {/* User Details */}
              <div className="space-y-6">
                <div className="space-y-1">
                  <p className="text-xs font-bold text-zinc-500 uppercase tracking-widest">System Record</p>
                  <p className="text-sm font-medium">Name: {selectedUser.first_name} {selectedUser.last_name}</p>
                  <p className="text-sm font-medium">Role: {selectedUser.role}</p>
                  <p className="text-sm font-medium">Phone: {selectedUser.phone}</p>
                </div>
                
                <div className="p-4 bg-blue-500/10 rounded-2xl border border-blue-500/20">
                  <p className="text-xs text-blue-600 dark:text-blue-400 font-bold mb-2 flex items-center gap-1">
                    <CheckCircle className="w-3.5 h-3.5" />
                    Review Checklist
                  </p>
                  <ul className="text-[11px] space-y-1 text-zinc-600 dark:text-zinc-400 list-disc list-inside">
                    <li>Photo matches profile picture</li>
                    <li>License has not expired</li>
                    <li>Numbers match record ID</li>
                  </ul>
                </div>

                <div className="flex gap-3">
                  <button 
                    onClick={() => { toggleKYC(selectedUser.id, false); setSelectedUser(null); }}
                    className="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-sm shadow-lg shadow-blue-500/20 transition-all hover:-translate-y-1"
                  >
                    Approve ID
                  </button>
                  <button 
                    className="flex-1 py-3 bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-500/10 dark:hover:bg-red-500/20 dark:text-red-400 rounded-xl font-bold text-sm transition-all"
                    onClick={() => setSelectedUser(null)}
                  >
                    Reject
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
