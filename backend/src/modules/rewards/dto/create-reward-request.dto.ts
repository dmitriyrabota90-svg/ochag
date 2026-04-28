import { IsString, MinLength } from 'class-validator';

export class CreateRewardRequestDto {
  @IsString()
  @MinLength(1)
  rewardId!: string;
}
