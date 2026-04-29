import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { CurrentUser } from './decorators/current-user.decorator';
import { UpdateMeDto } from './dto/update-me.dto';
import { AccessTokenGuard } from './guards/access-token.guard';
import { AuthenticatedUser } from './types/authenticated-user';

@Controller('me')
export class MeController {
  constructor(private readonly authService: AuthService) {}

  @Get()
  @UseGuards(AccessTokenGuard)
  getMe(@CurrentUser() user: AuthenticatedUser) {
    return this.authService.getMe(user.id);
  }

  @Patch()
  @UseGuards(AccessTokenGuard)
  updateMe(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateMeDto) {
    return this.authService.updateMe(user.id, dto);
  }
}
