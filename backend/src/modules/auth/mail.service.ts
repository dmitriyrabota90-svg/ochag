import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

type PasswordResetEmailInput = {
  email: string;
  resetToken: string;
};

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);

  constructor(private readonly configService: ConfigService) {}

  async sendPasswordResetEmail(input: PasswordResetEmailInput) {
    const appBaseUrl = this.configService.get<string>(
      'auth.appBaseUrl',
      'http://localhost:3000',
    );
    const resetUrl = `${appBaseUrl}/reset-password?token=${input.resetToken}`;

    this.logger.log(
      `Password reset requested for ${input.email}. MVP reset URL: ${resetUrl}`,
    );

    return { accepted: true };
  }
}
