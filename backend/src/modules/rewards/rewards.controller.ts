import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { CreateRewardDto } from './dto/create-reward.dto';
import { RepriceRewardDto } from './dto/reprice-reward.dto';
import { RewardsService } from './rewards.service';

@Controller('rewards')
@UseGuards(AccessTokenGuard)
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get()
  listRewards(@CurrentUser() user: AuthenticatedUser) {
    return this.rewardsService.listRewards(user.id);
  }

  @Get(':rewardId')
  getReward(@CurrentUser() user: AuthenticatedUser, @Param('rewardId') rewardId: string) {
    return this.rewardsService.getReward(user.id, rewardId);
  }

  @Post()
  createReward(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateRewardDto) {
    return this.rewardsService.createReward(user.id, dto);
  }

  @Post(':rewardId/approve')
  approveReward(@CurrentUser() user: AuthenticatedUser, @Param('rewardId') rewardId: string) {
    return this.rewardsService.approveReward(user.id, rewardId);
  }

  @Post(':rewardId/reprice')
  repriceReward(
    @CurrentUser() user: AuthenticatedUser,
    @Param('rewardId') rewardId: string,
    @Body() dto: RepriceRewardDto,
  ) {
    return this.rewardsService.repriceReward(user.id, rewardId, dto);
  }

  @Post(':rewardId/reject')
  rejectReward(@CurrentUser() user: AuthenticatedUser, @Param('rewardId') rewardId: string) {
    return this.rewardsService.rejectReward(user.id, rewardId);
  }
}
