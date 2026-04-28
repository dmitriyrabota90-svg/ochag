import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AccessTokenGuard } from './guards/access-token.guard';
import { MailService } from './mail.service';
import { MeController } from './me.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthController, MeController],
  providers: [AuthService, AccessTokenGuard, MailService],
  exports: [JwtModule, AuthService, AccessTokenGuard],
})
export class AuthModule {}
