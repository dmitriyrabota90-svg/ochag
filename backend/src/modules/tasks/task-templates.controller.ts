import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { CreateTaskTemplateDto } from './dto/create-task-template.dto';
import { UpdateTaskTemplateDto } from './dto/update-task-template.dto';
import { TasksService } from './tasks.service';

@Controller('task-templates')
@UseGuards(AccessTokenGuard)
export class TaskTemplatesController {
  constructor(private readonly tasksService: TasksService) {}

  @Get()
  listTemplates(@CurrentUser() user: AuthenticatedUser) {
    return this.tasksService.listTemplates(user.id);
  }

  @Post()
  createTemplate(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateTaskTemplateDto,
  ) {
    return this.tasksService.createTemplate(user.id, dto);
  }

  @Patch(':templateId')
  updateTemplate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('templateId') templateId: string,
    @Body() dto: UpdateTaskTemplateDto,
  ) {
    return this.tasksService.updateTemplate(user.id, templateId, dto);
  }
}
