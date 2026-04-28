import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { TaskTemplatesController } from './task-templates.controller';
import { TasksController } from './tasks.controller';
import { TasksService } from './tasks.service';

@Module({
  imports: [AuthModule],
  controllers: [TasksController, TaskTemplatesController],
  providers: [TasksService],
  exports: [TasksService],
})
export class TasksModule {}
