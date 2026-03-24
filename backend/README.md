# SafeRide Backend Infrastructure

The reliable core that powers the SafeRide ecosystem. Built with NestJS for enterprise-grade scalability and maintainability.

## 🏗 Architecture

- **Framework**: [NestJS](https://nestjs.com/) (Node.js)
- **Database**: [Prisma ORM](https://www.prisma.io/) with SQLite/PostgreSQL.
- **Real-time**: High-concurrency WebSockets for location streaming.
- **Security**: JWT-based authentication and RBAC (Role-Based Access Control).

## 📡 API Capabilities

- 🛣️ **Ride Engine**: Complex matching algorithms for drivers and passengers.
- 💳 **Payment Processing**: Secure wallet management and transaction tracking.
- 🛡️ **Identity (KYC)**: Secure storage and verification workflows for documents.
- 📍 **Geo-Streaming**: Low-latency GPS coordinate broadcasting via Socket.io.

## ⚙️ Development Setup

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Database Migration**:
   ```bash
   npx prisma migrate dev
   npx prisma generate
   ```

3. **Run Application**:
   ```bash
   npm run start:dev
   ```

## 🧪 Documentation & Testing

- **API Reference**: Swagger/OpenAPI (if enabled at `/api`).
- **Tests**: 
  - Unit: `npm run test`
  - E2E: `npm run test:e2e`

## 🗃 Database Schema Highlights
The schema includes robust entities for:
- `User` (Driver/Passenger roles)
- `Ride` (Status tracking, pricing, routing)
- `Document` (KYC attachments)
- `Transaction` (Financial records)
