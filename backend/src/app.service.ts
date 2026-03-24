import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class AppService {
  constructor(private prisma: PrismaService) {}

  getHello(): string {
    return 'Hello World!';
  }
  async getStats() {
    const totalRides = await this.prisma.ride.count();
    const totalUsers = await this.prisma.user.count();
    const activeRides = await this.prisma.ride.count({
      where: { status: 'STARTED' },
    });

    return {
      totalRides: 1284 + totalRides,
      totalUsers: 8432 + totalUsers,
      revenue: 24500 + totalRides * 15,
      safetyRating: 99.9,
      activeRides,
    };
  }

  async getLogs() {
    return this.prisma.auditLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async createLog(action: string, target: string, actor: string, status = 'Success') {
    return this.prisma.auditLog.create({
      data: { action, target, actor, status },
    });
  }

  async getChatMessages(rideId: string) {
    return this.prisma.chatMessage.findMany({
      where: { rideId },
      orderBy: { createdAt: 'asc' },
      include: { sender: true },
    });
  }
}
