import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "SafeRide - Suivi de Trajets",
  description: "Système de suivi de trajets en temps réel pour la sécurité",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}
