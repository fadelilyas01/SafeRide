"use client";

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Building2, 
  LayoutDashboard, 
  Car, 
  Users, 
  Settings,
  MapPin,
  ShieldAlert,
  X
} from 'lucide-react';

const navItems = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Rides', href: '/rides', icon: Car },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Live Map', href: '/map', icon: MapPin },
  { name: 'Alerts', href: '/alerts', icon: ShieldAlert },
  { name: 'Finances', href: '/finances', icon: Building2 },
  { name: 'Settings', href: '/settings', icon: Settings },
];

interface SidebarProps {
  onClose?: () => void;
}

export default function Sidebar({ onClose }: SidebarProps) {
  const pathname = usePathname();

  const handleLinkClick = () => {
    if (onClose) {
      onClose();
    }
  };

  return (
    <aside className="h-full w-64 bg-sidebar-bg border-r border-border-color flex flex-col relative">
      <div className="h-16 flex items-center justify-between px-6 border-b border-border-color">
        <Link href="/" className="flex items-center gap-2 group" onClick={handleLinkClick}>
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center group-hover:bg-blue-700 transition-colors">
            <Building2 className="text-white w-5 h-5" />
          </div>
          <span className="text-xl font-bold tracking-tight text-foreground">
            SafeRide <span className="text-blue-600">Admin</span>
          </span>
        </Link>
        
        <button 
          onClick={onClose}
          className="md:hidden p-1 text-zinc-500 hover:text-foreground hover:bg-hover-bg rounded-lg transition-colors cursor-pointer"
          aria-label="Close Sidebar"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      <nav className="flex-1 overflow-y-auto py-6 px-4 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.name}
              href={item.href}
              onClick={handleLinkClick}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
                isActive 
                  ? 'bg-blue-50 text-blue-700 dark:bg-blue-500/10 dark:text-blue-400' 
                  : 'text-zinc-600 hover:bg-hover-bg hover:text-foreground dark:text-zinc-400'
              }`}
            >
              <item.icon className={`w-5 h-5 ${isActive ? 'text-blue-600 dark:text-blue-400' : 'text-zinc-400 group-hover:text-foreground'}`} />
              {item.name}
              {item.name === 'Alerts' && (
                <span className="ml-auto bg-red-100 text-red-600 py-0.5 px-2 rounded-full text-xs font-semibold dark:bg-red-500/20 dark:text-red-400">
                  2
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-border-color">
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl p-4 text-white shadow-lg premium-shadow">
          <h4 className="text-sm font-semibold mb-1">Premium Features</h4>
          <p className="text-xs text-blue-100 mb-3 opacity-90">Upgrade to unlock advanced analytics.</p>
          <button className="w-full bg-white/20 hover:bg-white/30 text-white text-xs font-medium py-1.5 rounded transition-colors">
            Learn More
          </button>
        </div>
      </div>
    </aside>
  );
}
