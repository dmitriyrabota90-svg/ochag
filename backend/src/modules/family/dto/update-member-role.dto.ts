import { IsEnum } from 'class-validator';

export enum AssignableFamilyRole {
  ADULT = 'ADULT',
  CHILD = 'CHILD',
}

export class UpdateMemberRoleDto {
  @IsEnum(AssignableFamilyRole)
  role!: AssignableFamilyRole;
}
