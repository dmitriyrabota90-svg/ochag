import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { ContributeFamilyGoalDto } from './dto/contribute-family-goal.dto';
import { CreateFamilyGoalDto } from './dto/create-family-goal.dto';
import { UpdateFamilyGoalDto } from './dto/update-family-goal.dto';
import { FamilyGoalService } from './family-goal.service';

@Controller('family-goal')
@UseGuards(AccessTokenGuard)
export class FamilyGoalController {
  constructor(private readonly familyGoalService: FamilyGoalService) {}

  @Get()
  getCurrentGoal(@CurrentUser() user: AuthenticatedUser) {
    return this.familyGoalService.getCurrentGoal(user.id);
  }

  @Post()
  createGoal(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateFamilyGoalDto) {
    return this.familyGoalService.createGoal(user.id, dto);
  }

  @Patch(':goalId')
  updateGoal(
    @CurrentUser() user: AuthenticatedUser,
    @Param('goalId') goalId: string,
    @Body() dto: UpdateFamilyGoalDto,
  ) {
    return this.familyGoalService.updateGoal(user.id, goalId, dto);
  }

  @Post(':goalId/contributions')
  contribute(
    @CurrentUser() user: AuthenticatedUser,
    @Param('goalId') goalId: string,
    @Body() dto: ContributeFamilyGoalDto,
  ) {
    return this.familyGoalService.contribute(user.id, goalId, dto);
  }

  @Post(':goalId/confirm-completion')
  confirmCompletion(
    @CurrentUser() user: AuthenticatedUser,
    @Param('goalId') goalId: string,
  ) {
    return this.familyGoalService.confirmCompletion(user.id, goalId);
  }
}
