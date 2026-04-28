import { IsString, MinLength } from 'class-validator';

export class DeleteConfirmDto {
  @IsString()
  @MinLength(16)
  token!: string;
}
