import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import configuration from './config/configuration';
import { validateEnv } from './config/env.validation';
import { PrismaModule } from './database/prisma.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { FamilyModule } from './modules/family/family.module';
import { TasksModule } from './modules/tasks/tasks.module';
import { InitiativesModule } from './modules/initiatives/initiatives.module';
import { RewardsModule } from './modules/rewards/rewards.module';
import { FamilyGoalModule } from './modules/family-goal/family-goal.module';
import { HistoryModule } from './modules/history/history.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { FeedbackModule } from './modules/feedback/feedback.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
      load: [configuration],
      validate: validateEnv,
    }),
    PrismaModule,
    AuthModule,
    FamilyModule,
    TasksModule,
    InitiativesModule,
    RewardsModule,
    FamilyGoalModule,
    HistoryModule,
    NotificationsModule,
    AnalyticsModule,
    FeedbackModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
