import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { EventsGateway } from '../events.gateway';

@Injectable()
export class RidesService {
  constructor(
    private prisma: PrismaService,
    private eventsGateway: EventsGateway,
  ) {}

  async createRide(data: any) {
    const ride = await this.prisma.ride.create({
      data: {
        passengerId: data.passengerId,
        pickupLat: data.pickupLat,
        pickupLng: data.pickupLng,
        pickupAddress: data.pickupAddress,
        destinationLat: data.destinationLat,
        destinationLng: data.destinationLng,
        destinationAddress: data.destinationAddress,
        estimatedPrice: data.estimatedPrice,
        isWomenSafe: data.isWomenSafe || false,
        status: 'PENDING',
        otp: Math.floor(1000 + Math.random() * 9000).toString(),
      },
      include: { passenger: true },
    });
    
    // Broadcast the new ride to all connected drivers
    this.eventsGateway.server.emit('ride_requested', ride);
    
    return ride;
  }

  async updateStatus(id: string, status: string, driverId?: string) {
    const data: any = { status };
    if (driverId) data.driverId = driverId;

    const ride = await this.prisma.ride.update({
      where: { id },
      data,
      include: { passenger: true, driver: true },
    });

    if (status === 'ACCEPTED') {
      this.eventsGateway.server.emit(`ride_accepted_${ride.passengerId}`, ride);
    }
    
    this.eventsGateway.server.emit(`ride_status_${id}`, ride);
    
    return ride;
  }

  async getActiveRides() {
    return this.prisma.ride.findMany({
      where: {
        status: {
          notIn: ['COMPLETED', 'CANCELLED'],
        },
      },
      include: { passenger: true, driver: true },
    });
  }

  async getRideById(id: string) {
    const ride = await this.prisma.ride.findUnique({
      where: { id },
      include: { passenger: true, driver: true },
    });
    if (!ride) throw new NotFoundException('Ride not found');
    return ride;
  }

  async verifyOtpAndStart(id: string, otp: string) {
    const ride = await this.prisma.ride.findUnique({ where: { id } });
    if (!ride) throw new NotFoundException('Trajet introuvable');
    if (ride.status !== 'ACCEPTED') {
      throw new BadRequestException('Le trajet doit être accepté avant vérification OTP');
    }
    if (ride.otp !== otp) {
      throw new BadRequestException('Code OTP invalide');
    }

    const updated = await this.prisma.ride.update({
      where: { id },
      data: { status: 'STARTED' },
      include: { passenger: true, driver: true },
    });

    this.eventsGateway.server.emit(`ride_status_${id}`, updated);
    this.eventsGateway.server.emit('statusUpdate', { rideId: id, status: 'STARTED' });

    return updated;
  }
}
