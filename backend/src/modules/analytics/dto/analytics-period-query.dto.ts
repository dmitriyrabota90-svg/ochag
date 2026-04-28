import { Transform } from 'class-transformer';
import { IsEnum, IsOptional } from 'class-validator';

export enum AnalyticsPeriod {
  DAY = 'day',
  WEEK = 'week',
  MONTH = 'month',
  ALL_TIME = 'all_time',
}

export class AnalyticsPeriodQueryDto {
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.toLowerCase() : value,
  )
  @IsEnum(AnalyticsPeriod)
  period?: AnalyticsPeriod;
}
