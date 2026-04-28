import { IsString, MaxLength, MinLength } from 'class-validator';

export class JoinFamilyDto {
  @IsString()
  @MinLength(6)
  @MaxLength(32)
  inviteCode!: string;
}
