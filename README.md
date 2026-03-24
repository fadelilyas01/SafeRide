# SafeRide

SafeRide is a complete, full-stack urban mobility platform. It includes a mobile application for drivers and passengers, an administrative web dashboard, and a real-time Node.js backend. The project focuses on security, live tracking, and seamless communication.

## Project Structure

The repository is divided into three main components:

1. **`lib/` & `android/` & `ios/` (Mobile Application)**
   - Built with **Flutter**.
   - Handles real-time Google Maps integration, route estimation, and push notifications (Firebase).
   - Manages state using the BLoC pattern.
   - Includes secure Stripe integration for payment processing.

2. **`backend/` (Server)**
   - Built with **NestJS**.
   - Database managed by **Prisma** (configured for SQLite in development, easily switchable to PostgreSQL).
   - Secure authentication using JWT and Bcrypt connection.
   - Real-time features (chat, ride updates, driver location) powered by WebSockets (`Socket.io`).
   - Rate limiting and CORS policies configured.

3. **`admin_web/` (Admin Dashboard)**
   - Built with **React** and **Vite**.
   - Styling driven by **Tailwind CSS**.
   - Allows administrators to oversee active rides, manage users, and observe live platform metrics.

## Installation & Setup

### 1. Backend Server
Ensure you have Node.js (v18+) and npm installed.

```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run start:dev
```
*Note: Make sure to copy `backend/.env.example` to `backend/.env` and update the environment variables (like your Stripe and Firebase keys).*

### 2. Admin Web Dashboard
Requires the backend server to be running.

```bash
cd admin_web
npm install
npm run dev
```

### 3. Mobile Application
Ensure you have the Flutter SDK installed and an emulator running (or a physical device connected).

```bash
flutter pub get
flutter run
```
*Note: The mobile app requires your Google Maps API keys to be configured in `android/local.properties` (`MAPS_API_KEY`) and on iOS in `ios/Flutter/Secrets.xcconfig`.*

## Key Features
- **Real-Time Location Tracking:** using WebSockets and Google Maps.
- **Secure Authentication:** Passwords hashed with Bcrypt, access protected by JWT.
- **In-App Messaging:** Private socket-driven chat between riders and drivers.
- **Payments:** End-to-end payment flow integrated with Stripe's PaymentSheet API.
- **Push Notifications:** Firebase Cloud Messaging (FCM) linked to actions.
- **Security Protocols:** Features OTP verification for ride start, SOS alert buttons, and a Women Safety toggle mode.

## Architecture

This project strictly adheres to modular and scalable architectures:
- **NestJS** enforces strict Dependency Injection on the backend.
- **Prisma** handles object-relational mapping safely.
- **React** components in the web app are separated logically with strict responsive capabilities.
- **Flutter** uses Clean Architecture principles splitting domains, models, and presentation layers.
