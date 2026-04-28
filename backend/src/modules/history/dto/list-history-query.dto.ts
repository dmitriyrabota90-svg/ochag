import { Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export enum HistoryEntityType {
  FAMILY = 'family',
  TASK = 'task',
  TASK_TEMPLATE = 'task_template',
  INITIATIVE = 'initiative',
  REWARD = 'reward',
  REWARD_TEMPLATE = 'reward_template',
  REWARD_REQUEST = 'reward_request',
  FAMILY_GOAL = 'family_goal',
}

export class ListHistoryQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(128)
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  eventType?: string;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.toLowerCase() : value))
  @IsEnum(HistoryEntityType)
  entityType?: HistoryEntityType;
}
