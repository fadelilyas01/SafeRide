# SafeRide — Plateforme de Covoiturage Verifie et Surveillance Temps Reel

> **Projet Universitaire d'Ingenierie Logicielle & Cybersecurite** — Application mobile multi-plateforme (React Native / Expo) couplee a une API backend Next.js 14, concue selon une architecture **Zero-Vulnerability** et **Fail-Secure**.

---

## 1. Vision Produit & Piliers de Securite

Le covoiturage quotidien repose sur la confiance entre particuliers. **SafeRide** securise chaque etape du trajet grace a quatre mecanismes techniques :

1. **Authentification Durcie (`scrypt` + Session Signee) :** Les comptes utilisateurs sont proteges par un hachage cryptographique `crypto.scryptSync` avec sel CSPRNG de 16 octets, verifie en temps constant (`crypto.timingSafeEqual`), et une session signee `HMAC-SHA256` transmise via cookie `HttpOnly; SameSite=Strict`.
2. **Validation de Prise en Charge par Code PIN CSPRNG :** Lorsqu'un passager reserve un trajet, le backend genere un code PIN unique a 4 chiffres via un generateur cryptographique (`crypto.randomInt`). Ce code, communique oralement au conducteur, est verifie en **temps constant** (`crypto.timingSafeEqual`) avec une protection anti-force brute (**3 tentatives maximum** avant verrouillage temporise).
3. **Geofencing & Detection de Deviation (Formule de Haversine) :** A chaque releve GPS, le serveur projette orthogonalement la position courante sur les segments de l'itineraire theorique OSRM. Tout ecart superieur a **150 metres** bascule automatiquement le trajet en statut `ALERT`. Un simulateur de telemetrie integre permet de tester en 1 clic l'avancement nominal ou un ecart de trajectoire (> 150 m).
4. **Minuteur d'Inactivite (Dead Man's Switch) :** Le passager peut activer une verification periodique. En l'absence de confirmation a l'expiration du compte a rebours, une alerte SOS est automatiquement declenchee.
5. **Signal SOS, Rapport d'Incident Certifie & Centre de Supervision Web :** En cas d'urgence, l'API `/api/alerts` enregistre l'alerte en base, analyse la telemetrie cinematique via Google Gemini (avec synthese deterministe de secours) et scelle le rapport avec une empreinte cryptographique **SHA-256** canonique, consultable en temps reel depuis le **Centre de Supervision** (`http://localhost:3001`).

---

## 2. Demarrage Rapide

### Prerequis
- **Node.js** (v18 ou superieur)

#### 1. Demarrer le Backend API (Port 3001)
```bash
cd backend
cp .env.example .env
npm install
npx prisma generate
npx prisma db push
npm run dev
```

#### 2. Demarrer l'Application Mobile / Web (Port 8081)
```bash
cd mobile
cp .env.example .env
npm install
npx expo start --web --port 8081
```

---

## 3. Scenario de Demonstration (Soutenance Jury)

```text
┌──────────────────────────┐    1. Demande de reservation    ┌──────────────────────────┐
│   Passager (Onglet 1)    ├────────────────────────────────>│   Conducteur (Onglet 2)  │
│   Recoit son PIN CSPRNG  │                                 │   Accepte la demande     │
└────────────┬─────────────┘                                 └────────────┬─────────────┘
             │                                                            │
             │         2. Communication orale du PIN a 4 chiffres         │
             └────────────────────── "Code : XXXX" ──────────────────────>│
                                                                          │ 3. Verification
                                                                          ▼    (Temps constant)
                                                             ┌──────────────────────────┐
                                                             │   Trajet Actif & Scelle  │
                                                             │  Suivi GPS + Geofencing  │
                                                             └──────────────────────────┘
```

1. **Connexion Passager :**
   - Ouvrez `http://localhost:8081`, saisissez `passager@saferide.fr` et un mot de passe (minimum 8 caracteres), puis choisissez le profil **Passager**.
   - Les offres de covoiturage initiales (*Paris - Gare de Lyon → Campus de Versailles* et *Paris - Chatelet → Plateau de Saclay*) s'affichent avec leur trace sur la carte interactive. Cliquez sur **Reserver**.
2. **Acceptation Conducteur :**
   - Cliquez sur le bouton **Changer** en haut a droite (ou ouvrez un second onglet) et connectez-vous avec `sophie.conductrice@saferide.fr` (ou publiez votre propre trajet parmi les itineraires preconfigures avec un compte **Conducteur**).
   - Cliquez sur **Accepter la Demande**.
3. **Validation du Code PIN :**
   - Cote **Passager**, le code PIN unique a 4 chiffres s'affiche a l'ecran.
   - Cote **Conducteur**, cliquez sur **Valider le Code PIN** et saisissez les 4 chiffres.
   - Tester un code errone permet de constater le decompte des tentatives restantes (verrouillage anti-brute force apres 3 echecs).
4. **Surveillance Active, Simulateur d'Ecart (> 150 m) & Declenchement SOS :**
   - Une fois le PIN valide, le suivi GPS demarre.
   - Utilisez le **Simulateur GPS & Geofencing** integre au tableau de bord pour tester **Avancer sur le trajet** (conforme au couloir de 150 m) ou **Simuler ecart (> 150 m)** (declenchement automatique de l'alerte de deviation Haversine cote serveur).
   - Activez le **Minuteur d'inactivite** ou appuyez sur le bouton **SOS** : l'application declenche l'alerte aupres du serveur et affiche le rapport d'incident certifie.
   - Consultez le **Centre de Supervision Web Temps Reel** sur `http://localhost:3001` ainsi que la carte de suivi public en direct sur `http://localhost:3001/track/<tripId>`.

---

## 4. Architecture du Projet

```text
SafeRide/
├── backend/                         # API Next.js 14 & Logique Souveraine
│   ├── app/
│   │   ├── api/
│   │   │   ├── auth/login/          # Authentification & creation de profil
│   │   │   ├── rides/               # Publication et liste des offres + routage OSRM
│   │   │   ├── reservations/        # Reservation & validation PIN (verify/)
│   │   │   ├── trips/               # Gestion des trajets et rapport IA ([tripId]/report)
│   │   │   ├── gps/                 # Telemetrie GPS & detection d'ecart Haversine
│   │   │   └── alerts/              # Declenchement SOS & scellement SHA-256
│   │   └── track/[tripId]/          # Page web publique de suivi en direct
│   ├── lib/
│   │   ├── ai.ts                    # Generation de rapports d'incidents (Gemini + secours)
│   │   ├── db.ts                    # Instance Prisma singleton
│   │   └── geofence.ts              # Calculs trigonometriques de Haversine
│   ├── prisma/
│   │   └── schema.prisma            # Modeles User, Ride, Reservation, Trip, LocationPing, EmergencyAlert
│   ├── src/
│   │   ├── config/env.ts            # Configuration centralisee des variables d'environnement
│   │   ├── constants/index.ts       # Seuils metier et constantes
│   │   ├── schemas/index.ts         # Validation runtime stricte via Zod
│   │   ├── services/                # Couche metier (User, Ride, Reservation, GPS, Alert)
│   │   ├── types/index.ts           # Interfaces et DTOs TypeScript
│   │   └── utils/                   # Erreurs typees, logger et cryptographie (security.ts)
│   └── workflows/                   # Workflows durables (cycle de reservation et surveillance)
│
└── mobile/                          # Application Mobile React Native (Expo Router)
    ├── app/
    │   ├── _layout.tsx              # Configuration de la navigation
    │   ├── login.tsx                # Ecran d'authentification (Fail-Secure)
    │   ├── index.tsx                # Orchestrateur principal Passager / Conducteur
    │   └── driver-verify.tsx        # Ecran de verification du code PIN a 4 chiffres
    ├── components/
    │   ├── PassengerDashboard.tsx   # Vue Passager (5 etats UI, PIN, Dead Man's Switch, SOS)
    │   ├── DriverDashboard.tsx      # Vue Conducteur (Publication et gestion des demandes)
    │   ├── StatusBanner.tsx         # Banniere non-bloquante de notification et rapport SHA-256
    │   ├── EmergencyButton.tsx      # Bouton SOS anime (Reanimated)
    │   ├── MapView.tsx              # Rendu cartographique et telemetrie GPS
    │   └── RadarLoader.tsx          # Indicateur d'acquisition satellite
    ├── hooks/
    │   └── useLocationTracker.ts    # Suivi GPS avec annulation propre (AbortController)
    ├── lib/
    │   └── api.ts                   # Client HTTP resilient (Timeout 8s + Idempotency-Key CSPRNG)
    └── src/
        └── theme/tokens.ts          # Design Tokens (Grille 8pt & Palette OLED True Dark)
```

---

## 5. Standards de Securite Appliques

| Domaine | Mesure Implementee | Fichier Reference |
| :--- | :--- | :--- |
| **Generation PIN** | CSPRNG `crypto.randomInt(1000, 10000)` (Zero `Math.random()`) | `backend/src/utils/security.ts` |
| **Verification PIN** | Comparaison en temps constant `crypto.timingSafeEqual` (CWE-208) | `backend/src/utils/security.ts` |
| **Anti-Brute Force** | Rate-limiting a 3 essais max + verrouillage temporise 5 min (`HTTP 429`) | `backend/src/services/reservation.service.ts` |
| **Integrite & Scellement** | Hash `SHA-256` calcule sur payload canonique trie (CWE-345) | `backend/lib/ai.ts` |
| **Validation des Entrees** | Schemas `Zod` sur 100 % des routes API et Zero type `any` | `backend/src/schemas/index.ts` |
| **Architecture Fail-Secure** | Refus d'acces par defaut en cas d'erreur reseau ou PIN invalide (CWE-636) | `mobile/app/driver-verify.tsx` |
| **Resilience Reseau** | Timeouts stricts (6s-8s) via `AbortController` et cles `Idempotency-Key` | `mobile/lib/api.ts` |
| **Politique CSP & Headers** | CSP sans `'unsafe-eval'`, `X-Frame-Options: DENY`, `nosniff` | `backend/next.config.js` |
