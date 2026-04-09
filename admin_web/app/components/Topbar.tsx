"use client";

import React from 'react';
import { Search, Bell, Menu, User } from 'lucide-react';

interface TopbarProps {
  onMenuClick?: () => void;
}

export default function Topbar({ onMenuClick }: TopbarProps) {
  return (
    <header className="h-16 flex items-center justify-between px-6 bg-card-bg/80 backdrop-blur-md border-b border-border-color sticky top-0 z-10">
      <div className="flex items-center gap-4 flex-1">
        <button 
          aria-label="Toggle Menu" 
          title="Toggle Menu" 
          onClick={onMenuClick}
          className="md:hidden p-2 -ml-2 text-zinc-500 hover:text-foreground hover:bg-hover-bg rounded-lg transition-colors cursor-pointer"
        >
          <Menu className="w-5 h-5" />
        </button>
        
        <div className="hidden md:flex items-center relative max-w-md w-full">
          <Search className="w-4 h-4 text-zinc-400 absolute left-3" />
          <input 
            type="text" 
            placeholder="Search drivers, riders, or trips..." 
            className="w-full bg-hover-bg border-transparent focus:border-blue-500 focus:bg-card-bg focus:ring-1 focus:ring-blue-500 rounded-lg pl-10 pr-4 py-2 text-sm transition-all outline-none text-foreground placeholder:text-zinc-500"
          />
        </div>
      </div>

      <div className="flex items-center gap-2 md:gap-4">
        <button aria-label="Notifications" title="Notifications" className="relative p-2 text-zinc-500 hover:text-foreground hover:bg-hover-bg rounded-lg transition-colors">
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-card-bg"></span>
        </button>

        <div className="h-8 w-px bg-border-color mx-1"></div>

        <button className="flex items-center gap-2 hover:bg-hover-bg p-1 pr-2 rounded-full transition-colors border border-transparent hover:border-border-color">
          <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
            <User className="w-4 h-4 text-blue-600 dark:text-blue-400" />
          </div>
          <div className="hidden md:flex flex-col items-start">
            <span className="text-sm font-semibold text-foreground leading-none">Admin</span>
            <span className="text-xs text-zinc-500 mt-0.5">Superuser</span>
          </div>
        </button>
      </div>
    </header>
  );
}
