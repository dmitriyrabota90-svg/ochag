import { IsInt, Max, Min } from 'class-validator';

export class RepriceRewardDto {
  @IsInt()
  @Min(0)
  @Max(100000)
  pointsCost!: number;
}
