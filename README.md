# 🛡️ SafeRide Canada

**SafeRide** est une plateforme de mobilité urbaine full-stack ultra-sécurisée, conçue pour le marché canadien. Elle intègre une application mobile hybride (Passager/Chauffeur), un tableau de bord administratif temps réel et une infrastructure backend robuste basée sur Supabase.

---

## 🏗️ Architecture du Projet

L'écosystème SafeRide est divisé en deux composants principaux pilotés par un backend unifié :

### 1. 📱 SafeRide Mobile (Flutter)
Application mobile haute performance pour iOS et Android.
- **Stack**: Flutter, BLoC Pattern, Google Maps SDK, Supabase Flutter.
- **Localisation**: "Canada Edition" avec devises en **$ CAD** et intégration des services d'urgence locaux.
- **Fonctions Clés**: Suivi GPS temps réel, Chat intégré, intégration de paiements Stripe, et détection automatique d'anomalies.

### 2. 💻 Admin Web Dashboard (Next.js)
Tableau de bord de gestion centralisé pour les administrateurs.
- **Stack**: Next.js 16 (React 19), Tailwind CSS 4, Recharts, Lucide React.
- **Fonctions Clés**: Monitoring des courses en direct, gestion des utilisateurs (KYC), supervision des revenus (Commissions SafeRide) et journal d'audit de sécurité.

### 3. 🔥 Cloud Backend (Supabase)
Infrastructure "Serverless" temps réel.
- **Database**: PostgreSQL avec Row Level Security (RLS).
- **Auth**: Authentification sécurisée par téléphone (OTP).
- **Realtime**: Diffusion des positions des chauffeurs et chat via WebSockets.
- **Storage**: Gestion des documents d'identité (KYC).

---

## 🔒 Signature de Sécurité (SafeGate)

SafeRide se distingue par son protocole de sécurité multicouche unique :

- **SafeGate Monitoring**: Surveillance automatique des trajets. Si un véhicule s'immobilise de manière suspecte pendant 5 minutes, une alerte est instantanément générée dans le tableau de bord admin.
- **Family Shield**: Partage de lien de suivi en temps réel avec les proches.
- **Emergency Hub**: Accès direct en un clic au **911** (Urgence), **811** (Santé/Info-Santé) et à l'assistance routière.
- **Women Safe Mode**: Option permettant aux passagères de ne voyager qu'avec des chauffeuses vérifiées.
- **OTP Verification**: Code unique de sécurité pour valider le début de chaque course.

---

## 🛠️ Installation et Lancement

### Mobile (Flutter)
1. Assurez-vous d'avoir le SDK Flutter installé.
2. Clonez le dépôt et installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Configurez vos clés API dans `lib/core/utils/app_constants.dart`.
4. Lancez l'application :
   ```bash
   flutter run
   ```

### Admin Web (Next.js)
1. Naviguez dans le dossier `admin_web` :
   ```bash
   cd admin_web
   ```
2. Installez les dépendances :
   ```bash
   npm install
   ```
3. Configurez votre fichier `.env.local` avec vos identifiants Supabase.
4. Lancez le serveur de développement :
   ```bash
   npm run dev
   ```

---

## 📈 Suivi des Revenus
Le système calcule automatiquement la **Commission SafeRide (20%)** sur chaque trajet, permettant une gestion transparente des revenus et des reversements chauffeurs directement depuis l'interface administrative.

---

## 📄 Licence
Propriété de SafeRide Canada. Tous droits réservés.
