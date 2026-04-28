import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { CreateRewardTemplateDto } from './dto/create-reward-template.dto';
import { UpdateRewardTemplateDto } from './dto/update-reward-template.dto';
import { RewardsService } from './rewards.service';

@Controller('reward-templates')
@UseGuards(AccessTokenGuard)
export class RewardTemplatesController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get()
  listTemplates(@CurrentUser() user: AuthenticatedUser) {
    return this.rewardsService.listTemplates(user.id);
  }

  @Post()
  createTemplate(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateRewardTemplateDto) {
    return this.rewardsService.createTemplate(user.id, dto);
  }

  @Patch(':templateId')
  updateTemplate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('templateId') templateId: string,
    @Body() dto: UpdateRewardTemplateDto,
  ) {
    return this.rewardsService.updateTemplate(user.id, templateId, dto);
  }
}
