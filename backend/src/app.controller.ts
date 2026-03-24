import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { AppService } from './app.service';
import { JwtAuthGuard } from './auth/jwt-auth.guard';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @UseGuards(JwtAuthGuard)
  @Get('stats')
  getStats() {
    return this.appService.getStats();
  }

  @UseGuards(JwtAuthGuard)
  @Get('logs')
  getLogs() {
    return this.appService.getLogs();
  }

  @UseGuards(JwtAuthGuard)
  @Get('rides/:id/messages')
  getMessages(@Param('id') id: string) {
    return this.appService.getChatMessages(id);
  }
}
