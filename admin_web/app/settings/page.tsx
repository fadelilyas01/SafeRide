"use client";

import React from "react";
import { Bell, Shield, Globe, Palette } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Settings</h1>
        <p className="text-zinc-500 mt-1">Manage your platform preferences and configuration.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <SettingsCard
          icon={<Bell className="w-5 h-5 text-blue-600" />}
          title="Notifications"
          description="Configure email and push notification preferences for admin events."
        />
        <SettingsCard
          icon={<Shield className="w-5 h-5 text-green-600" />}
          title="Security"
          description="Manage authentication settings, API keys, and access controls."
        />
        <SettingsCard
          icon={<Globe className="w-5 h-5 text-purple-600" />}
          title="Regional"
          description="Set the default language, currency, and timezone for the platform."
        />
        <SettingsCard
          icon={<Palette className="w-5 h-5 text-orange-600" />}
          title="Appearance"
          description="Toggle dark mode, customize branding colors, and upload a logo."
        />
      </div>
    </div>
  );
}

function SettingsCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div className="glass rounded-xl p-6 premium-shadow hover:-translate-y-1 transition-transform duration-300 cursor-pointer group">
      <div className="flex items-center gap-3 mb-3">
        <div className="w-10 h-10 rounded-full bg-zinc-50 dark:bg-zinc-800/80 flex items-center justify-center border border-border-color">
          {icon}
        </div>
        <h3 className="font-semibold text-foreground group-hover:text-blue-600 transition-colors">{title}</h3>
      </div>
      <p className="text-sm text-zinc-500">{description}</p>
    </div>
  );
}
