import { Module } from '@nestjs/common';
import { RidesService } from './rides.service';
import { RidesController } from './rides.controller';
import { EventsGateway } from '../events.gateway';

@Module({
  providers: [RidesService, EventsGateway],
  controllers: [RidesController],
  exports: [RidesService],
})
export class RidesModule {}
