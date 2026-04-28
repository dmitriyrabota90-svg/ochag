import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { RewardRequestsController } from './reward-requests.controller';
import { RewardTemplatesController } from './reward-templates.controller';
import { RewardsController } from './rewards.controller';
import { RewardsService } from './rewards.service';

@Module({
  imports: [AuthModule],
  controllers: [RewardsController, RewardTemplatesController, RewardRequestsController],
  providers: [RewardsService],
  exports: [RewardsService],
})
export class RewardsModule {}
