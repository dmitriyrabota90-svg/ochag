import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user';
import { CreateFamilyDto } from './dto/create-family.dto';
import { DeleteConfirmDto } from './dto/delete-confirm.dto';
import { JoinFamilyDto } from './dto/join-family.dto';
import { TransferCreatorDto } from './dto/transfer-creator.dto';
import { UpdateFamilyDto } from './dto/update-family.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { FamilyService } from './family.service';

@Controller('families')
@UseGuards(AccessTokenGuard)
export class FamilyController {
  constructor(private readonly familyService: FamilyService) {}

  @Post()
  createFamily(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateFamilyDto,
  ) {
    return this.familyService.createFamily(user.id, dto);
  }

  @Get('current')
  getCurrentFamily(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.getCurrentFamily(user.id);
  }

  @Post('join')
  joinFamily(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: JoinFamilyDto,
  ) {
    return this.familyService.joinFamily(user.id, dto);
  }

  @Get('current/members')
  getCurrentFamilyMembers(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.getCurrentFamilyMembers(user.id);
  }

  @Patch('current')
  updateCurrentFamily(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateFamilyDto,
  ) {
    return this.familyService.updateCurrentFamily(user.id, dto);
  }

  @Post('current/leave')
  leaveCurrentFamily(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.leaveCurrentFamily(user.id);
  }

  @Patch('current/members/:memberId/role')
  updateMemberRole(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
    @Body() dto: UpdateMemberRoleDto,
  ) {
    return this.familyService.updateMemberRole(user.id, memberId, dto);
  }

  @Delete('current/members/:memberId')
  removeMember(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
  ) {
    return this.familyService.removeMember(user.id, memberId);
  }

  @Post('current/transfer-creator')
  transferCreator(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: TransferCreatorDto,
  ) {
    return this.familyService.transferCreator(user.id, dto);
  }

  @Post('current/invites/link')
  createInviteLink(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.createInviteLink(user.id);
  }

  @Post('current/invites/code/regenerate')
  regenerateInviteCode(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.regenerateInviteCode(user.id);
  }

  @Post('current/delete-request')
  requestDeleteCurrentFamily(@CurrentUser() user: AuthenticatedUser) {
    return this.familyService.requestDeleteCurrentFamily(user.id);
  }

  @Post('current/delete-confirm')
  confirmDeleteCurrentFamily(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: DeleteConfirmDto,
  ) {
    return this.familyService.confirmDeleteCurrentFamily(user.id, dto);
  }
}
