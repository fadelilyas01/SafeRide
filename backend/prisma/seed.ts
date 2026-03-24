import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding...');

  const hash = await bcrypt.hash('password', 10);
  const adminHash = await bcrypt.hash('admin', 10);

  // Create Admin
  await prisma.user.upsert({
    where: { email: 'admin@saferide.com' },
    update: {},
    create: {
      email: 'admin@saferide.com',
      password: adminHash,
      name: 'Super Admin',
      role: 'ADMIN',
      isVerified: true,
    },
  });

  // Create Drivers
  const driver1 = await prisma.user.upsert({
    where: { email: 'luc.roy@email.com' },
    update: {},
    create: {
      email: 'luc.roy@email.com',
      password: hash,
      name: 'Luc Roy',
      role: 'DRIVER',
      isVerified: true,
      rating: 4.9,
    },
  });

  await prisma.user.upsert({
    where: { email: 'marc.t@email.com' },
    update: {},
    create: {
      email: 'marc.t@email.com',
      password: hash,
      name: 'Marc Tremblay',
      role: 'DRIVER',
      isVerified: true,
      rating: 4.8,
    },
  });

  // Create Riders
  const rider1 = await prisma.user.upsert({
    where: { email: 'marie.c@email.com' },
    update: {},
    create: {
      email: 'marie.c@email.com',
      password: hash,
      name: 'Marie Côté',
      role: 'RIDER',
      isVerified: true,
      walletBalance: 150.0,
    },
  });

  // Create Active Ride
  await prisma.ride.create({
    data: {
      passengerId: rider1.id,
      driverId: driver1.id,
      status: 'STARTED',
      pickupLat: 45.5017,
      pickupLng: -73.5673,
      pickupAddress: 'Gare Centrale',
      destinationLat: 45.5231,
      destinationLng: -73.5875,
      destinationAddress: 'Plateau',
      estimatedPrice: 25.5,
      otp: '1234',
    },
  });

  // Create initial audit log
  await prisma.auditLog.create({
    data: {
      action: 'SYSTEM_INIT',
      target: 'Database',
      actor: 'System:SEED',
      status: 'Success',
    },
  });

  console.log('Seed completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
