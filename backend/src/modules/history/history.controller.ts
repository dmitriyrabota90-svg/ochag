import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { ListHistoryQueryDto } from './dto/list-history-query.dto';
import { HistoryService } from './history.service';

@Controller('history')
@UseGuards(AccessTokenGuard)
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Get()
  listHistory(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListHistoryQueryDto,
  ) {
    return this.historyService.listHistory(user.id, query);
  }
}
