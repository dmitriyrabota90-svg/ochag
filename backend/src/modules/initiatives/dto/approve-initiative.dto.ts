import { IsInt, Max, Min } from 'class-validator';

export class ApproveInitiativeDto {
  @IsInt()
  @Min(1)
  @Max(100000)
  finalSparks!: number;
}
