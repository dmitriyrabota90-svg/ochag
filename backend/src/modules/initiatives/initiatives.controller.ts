import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { ApproveInitiativeDto } from './dto/approve-initiative.dto';
import { CreateInitiativeDto } from './dto/create-initiative.dto';
import { InitiativesService } from './initiatives.service';

@Controller('initiatives')
@UseGuards(AccessTokenGuard)
export class InitiativesController {
  constructor(private readonly initiativesService: InitiativesService) {}

  @Get()
  listInitiatives(@CurrentUser() user: AuthenticatedUser) {
    return this.initiativesService.listInitiatives(user.id);
  }

  @Get(':initiativeId')
  getInitiative(
    @CurrentUser() user: AuthenticatedUser,
    @Param('initiativeId') initiativeId: string,
  ) {
    return this.initiativesService.getInitiative(user.id, initiativeId);
  }

  @Post()
  createInitiative(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateInitiativeDto,
  ) {
    return this.initiativesService.createInitiative(user.id, dto);
  }

  @Post(':initiativeId/approve')
  approveInitiative(
    @CurrentUser() user: AuthenticatedUser,
    @Param('initiativeId') initiativeId: string,
    @Body() dto: ApproveInitiativeDto,
  ) {
    return this.initiativesService.approveInitiative(user.id, initiativeId, dto);
  }

  @Post(':initiativeId/approve-without-reward')
  approveWithoutReward(
    @CurrentUser() user: AuthenticatedUser,
    @Param('initiativeId') initiativeId: string,
  ) {
    return this.initiativesService.approveWithoutReward(user.id, initiativeId);
  }

  @Post(':initiativeId/reject')
  rejectInitiative(
    @CurrentUser() user: AuthenticatedUser,
    @Param('initiativeId') initiativeId: string,
  ) {
    return this.initiativesService.rejectInitiative(user.id, initiativeId);
  }
}
