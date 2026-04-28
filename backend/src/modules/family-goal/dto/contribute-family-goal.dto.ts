import { IsInt, Max, Min } from 'class-validator';

export class ContributeFamilyGoalDto {
  @IsInt()
  @Min(1)
  @Max(1000000)
  sparks!: number;
}
