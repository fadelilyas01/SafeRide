import { Controller, Get, Param, Patch, Body, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {
    console.log('UsersController initialized');
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id/verify')
  verifyUser(@Param('id') id: string) {
    return this.usersService.verifyUser(id);
  }

  @Patch(':id/women-safe')
  setWomenSafe(
    @Param('id') id: string,
    @Body() body: { value: boolean },
  ) {
    return this.usersService.setWomenSafe(id, body.value);
  }
}
