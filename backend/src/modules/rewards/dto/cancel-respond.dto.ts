import { IsBoolean } from 'class-validator';

export class CancelRespondDto {
  @IsBoolean()
  approve!: boolean;
}
