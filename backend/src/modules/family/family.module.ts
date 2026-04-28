import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { FamilyController } from './family.controller';
import { FamilyMailService } from './family-mail.service';
import { FamilyService } from './family.service';

@Module({
  imports: [AuthModule],
  controllers: [FamilyController],
  providers: [FamilyService, FamilyMailService],
  exports: [FamilyService],
})
export class FamilyModule {}
