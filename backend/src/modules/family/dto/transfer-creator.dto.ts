import { IsString, MinLength } from 'class-validator';

export class TransferCreatorDto {
  @IsString()
  @MinLength(1)
  memberId!: string;
}
