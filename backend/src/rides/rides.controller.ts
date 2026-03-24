import { Controller, Post, Patch, Get, Param, Body, UseGuards } from '@nestjs/common';
import { RidesService } from './rides.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('rides')
export class RidesController {
  constructor(private readonly ridesService: RidesService) {}

  @Post()
  create(@Body() data: any) {
    return this.ridesService.createRide(data);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Body() body: { status: string; driverId?: string },
  ) {
    return this.ridesService.updateStatus(id, body.status, body.driverId);
  }

  @Get('active')
  getActive() {
    return this.ridesService.getActiveRides();
  }

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.ridesService.getRideById(id);
  }

  @Post(':id/verify-otp')
  verifyOtp(
    @Param('id') id: string,
    @Body() body: { otp: string },
  ) {
    return this.ridesService.verifyOtpAndStart(id, body.otp);
  }
}
