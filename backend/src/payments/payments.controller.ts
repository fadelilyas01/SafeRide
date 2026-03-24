import {
  Controller,
  Post,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post(':rideId/intent')
  async createIntent(@Param('rideId') rideId: string, @Request() req: any) {
    // req.user is injected by JwtAuthGuard
    return this.paymentsService.createPaymentIntent(rideId, req.user.userId);
  }

  @Post(':rideId/confirm')
  async confirmPayment(@Param('rideId') rideId: string) {
    return this.paymentsService.confirmPayment(rideId);
  }
}
