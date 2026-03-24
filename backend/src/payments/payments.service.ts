import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma.service';
import Stripe from 'stripe';

@Injectable()
export class PaymentsService {
  private stripe: Stripe;
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private configService: ConfigService,
    private prisma: PrismaService,
  ) {
    const stripeKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    if (stripeKey) {
      this.stripe = new Stripe(stripeKey, { apiVersion: '2025-02-24' as any });
      this.logger.log('Stripe initialized successfully');
    } else {
      this.logger.warn('STRIPE_SECRET_KEY is missing. Payments are disabled.');
    }
  }

  async createPaymentIntent(rideId: string, userId: string) {
    if (!this.stripe) throw new Error('Stripe is not configured');

    const ride = await this.prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw new Error('Ride not found');

    let user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error('User not found');
    
    // Create Stripe Customer if missing
    if (!user.stripeCustId) {
      const customer = await this.stripe.customers.create({
        email: user.email,
        name: user.name,
      });
      user = await this.prisma.user.update({
        where: { id: userId },
        data: { stripeCustId: customer.id }
      });
    }

    // Create PaymentIntent
    // Amount must be in cents (e.g., $25.50 -> 2550)
    const amountInCents = Math.round(ride.estimatedPrice * 100);
    
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: amountInCents,
      currency: 'cad', // Change to your currency
      customer: user.stripeCustId!,
      metadata: { rideId: ride.id },
    });

    // Save intent ID to ride
    await this.prisma.ride.update({
      where: { id: rideId },
      data: { paymentIntentId: paymentIntent.id, paymentStatus: 'PENDING' }
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amount: ride.estimatedPrice
    };
  }

  async confirmPayment(rideId: string) {
    await this.prisma.ride.update({
      where: { id: rideId },
      data: { paymentStatus: 'PAID' }
    });
    return { success: true };
  }
}
