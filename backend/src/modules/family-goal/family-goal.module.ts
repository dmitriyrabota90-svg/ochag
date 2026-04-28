import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { FamilyGoalController } from './family-goal.controller';
import { FamilyGoalService } from './family-goal.service';

@Module({
  imports: [AuthModule],
  controllers: [FamilyGoalController],
  providers: [FamilyGoalService],
  exports: [FamilyGoalService],
})
export class FamilyGoalModule {}
