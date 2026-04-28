import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { CancelRespondDto } from './dto/cancel-respond.dto';
import { CreateRewardRequestDto } from './dto/create-reward-request.dto';
import { RewardsService } from './rewards.service';

@Controller('reward-requests')
@UseGuards(AccessTokenGuard)
export class RewardRequestsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Post()
  createRequest(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateRewardRequestDto) {
    return this.rewardsService.createRequest(user.id, dto);
  }

  @Get(':requestId')
  getRequest(@CurrentUser() user: AuthenticatedUser, @Param('requestId') requestId: string) {
    return this.rewardsService.getRequest(user.id, requestId);
  }

  @Post(':requestId/mark-fulfilled')
  markFulfilled(@CurrentUser() user: AuthenticatedUser, @Param('requestId') requestId: string) {
    return this.rewardsService.markFulfilled(user.id, requestId);
  }

  @Post(':requestId/confirm-received')
  confirmReceived(@CurrentUser() user: AuthenticatedUser, @Param('requestId') requestId: string) {
    return this.rewardsService.confirmReceived(user.id, requestId);
  }

  @Post(':requestId/cancel')
  requestCancel(@CurrentUser() user: AuthenticatedUser, @Param('requestId') requestId: string) {
    return this.rewardsService.requestCancel(user.id, requestId);
  }

  @Post(':requestId/cancel/respond')
  respondCancel(
    @CurrentUser() user: AuthenticatedUser,
    @Param('requestId') requestId: string,
    @Body() dto: CancelRespondDto,
  ) {
    return this.rewardsService.respondCancel(user.id, requestId, dto);
  }
}
