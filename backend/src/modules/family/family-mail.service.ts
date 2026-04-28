import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

type FamilyDeleteConfirmationInput = {
  email: string;
  familyId: string;
  token: string;
};

@Injectable()
export class FamilyMailService {
  private readonly logger = new Logger(FamilyMailService.name);

  constructor(private readonly configService: ConfigService) {}

  async sendDeleteConfirmation(input: FamilyDeleteConfirmationInput) {
    const appBaseUrl = this.configService.get<string>(
      'auth.appBaseUrl',
      'http://localhost:3000',
    );
    const confirmUrl = `${appBaseUrl}/families/delete-confirm?token=${input.token}`;

    this.logger.log(
      `Family delete confirmation requested for ${input.email}, family ${input.familyId}. MVP confirm URL: ${confirmUrl}`,
    );

    return { accepted: true };
  }
}
