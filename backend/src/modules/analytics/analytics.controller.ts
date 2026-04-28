import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { AnalyticsService } from './analytics.service';
import { AnalyticsPeriodQueryDto } from './dto/analytics-period-query.dto';

@Controller()
@UseGuards(AccessTokenGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('rating')
  getRating(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AnalyticsPeriodQueryDto,
  ) {
    return this.analyticsService.getRating(user.id, query);
  }

  @Get('analytics/summary')
  getSummary(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: AnalyticsPeriodQueryDto,
  ) {
    return this.analyticsService.getSummary(user.id, query);
  }
}
