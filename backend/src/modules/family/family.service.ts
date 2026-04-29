import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FamilyMember, FamilyRole, Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes, randomUUID } from 'crypto';
import { PrismaService } from '../../database/prisma.service';
import { CreateFamilyDto } from './dto/create-family.dto';
import { DeleteConfirmDto } from './dto/delete-confirm.dto';
import { JoinFamilyDto } from './dto/join-family.dto';
import { TransferCreatorDto } from './dto/transfer-creator.dto';
import { UpdateFamilyDto } from './dto/update-family.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { FamilyMailService } from './family-mail.service';

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    inviteCode: string | null;
    createdAt: Date;
    updatedAt: Date;
  };
};

type OpaqueTokenParts = {
  tokenId: string;
  secret: string;
};

@Injectable()
export class FamilyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly familyMailService: FamilyMailService,
  ) {}

  async createFamily(userId: string, dto: CreateFamilyDto) {
    await this.assertUserHasNoFamily(userId);
    const name = this.normalizeFamilyName(dto.name);

    const result = await this.prisma.$transaction(async (tx) => {
      const family = await tx.family.create({
        data: { name },
      });
      const member = await tx.familyMember.create({
        data: {
          familyId: family.id,
          userId,
          role: FamilyRole.OWNER,
        },
      });
      await this.createActivity(tx, family.id, userId, 'family.created', {
        familyName: family.name,
      });

      return { family, member };
    });

    return {
      ...this.toFamilyResponse(result.family),
      currentMember: this.toMemberResponse(result.member),
    };
  }

  async getCurrentFamily(userId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return {
      ...this.toFamilyResponse(membership.family),
      currentMember: this.toMemberResponse(membership),
    };
  }

  async joinFamily(userId: string, dto: JoinFamilyDto) {
    await this.assertUserHasNoFamily(userId);

    const family = await this.prisma.family.findUnique({
      where: { inviteCode: dto.inviteCode.trim() },
    });
    if (!family) {
      throw new NotFoundException('Family invite not found');
    }

    const member = await this.prisma.$transaction(async (tx) => {
      const createdMember = await tx.familyMember.create({
        data: {
          familyId: family.id,
          userId,
          role: FamilyRole.CHILD,
        },
      });
      await this.createActivity(tx, family.id, userId, 'family.member.joined', {
        memberId: createdMember.id,
      });

      return createdMember;
    });

    return {
      ...this.toFamilyResponse(family),
      currentMember: this.toMemberResponse(member),
    };
  }

  async getCurrentFamilyMembers(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const members = await this.prisma.familyMember.findMany({
      where: { familyId: membership.familyId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            displayName: true,
            createdAt: true,
            updatedAt: true,
          },
        },
      },
      orderBy: [{ role: 'desc' }, { createdAt: 'asc' }],
    });

    return members.map((member) => ({
      ...this.toMemberResponse(member),
      user: member.user,
    }));
  }

  async updateCurrentFamily(userId: string, dto: UpdateFamilyDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    const name = this.normalizeFamilyName(dto.name);
    const family = await this.prisma.$transaction(async (tx) => {
      const updatedFamily = await tx.family.update({
        where: { id: membership.familyId },
        data: { name },
      });
      await this.createActivity(tx, membership.familyId, userId, 'family.updated', {
        familyName: updatedFamily.name,
      });

      return updatedFamily;
    });

    return this.toFamilyResponse(family);
  }

  async leaveCurrentFamily(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const members = await this.getFamilyMembers(membership.familyId);

    this.assertCanLeave(membership, members);

    if (members.length === 1) {
      await this.prisma.family.delete({ where: { id: membership.familyId } });
      return { success: true, familyDeleted: true };
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.familyMember.delete({ where: { id: membership.id } });
      await this.createActivity(tx, membership.familyId, userId, 'family.member.left', {
        memberId: membership.id,
      });
    });

    return { success: true, familyDeleted: false };
  }

  async updateMemberRole(
    userId: string,
    memberId: string,
    dto: UpdateMemberRoleDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    const targetMember = await this.requireFamilyMember(
      membership.familyId,
      memberId,
    );
    if (targetMember.role === FamilyRole.OWNER) {
      throw new BadRequestException('Use transfer-creator for creator role');
    }

    const updatedMember = await this.prisma.$transaction(async (tx) => {
      const member = await tx.familyMember.update({
        where: { id: targetMember.id },
        data: { role: dto.role },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.member.role_updated',
        {
          memberId: targetMember.id,
          role: dto.role,
        },
      );

      return member;
    });

    return this.toMemberResponse(updatedMember);
  }

  async removeMember(userId: string, memberId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    if (membership.id === memberId) {
      throw new BadRequestException('Use leave endpoint to leave a family');
    }

    const targetMember = await this.requireFamilyMember(
      membership.familyId,
      memberId,
    );
    if (targetMember.role === FamilyRole.OWNER) {
      throw new BadRequestException('Creator cannot be removed');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.familyMember.delete({ where: { id: targetMember.id } });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.member.removed',
        {
          memberId: targetMember.id,
          removedUserId: targetMember.userId,
        },
      );
    });

    return { success: true };
  }

  async transferCreator(userId: string, dto: TransferCreatorDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    if (membership.id === dto.memberId) {
      throw new BadRequestException('Creator is already assigned to this member');
    }

    const targetMember = await this.requireFamilyMember(
      membership.familyId,
      dto.memberId,
    );
    if (targetMember.role !== FamilyRole.ADULT) {
      throw new BadRequestException('Creator can only be transferred to an adult');
    }

    const updatedTarget = await this.prisma.$transaction(async (tx) => {
      await tx.familyMember.update({
        where: { id: membership.id },
        data: { role: FamilyRole.ADULT },
      });
      const newCreator = await tx.familyMember.update({
        where: { id: targetMember.id },
        data: { role: FamilyRole.OWNER },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.creator.transferred',
        {
          fromMemberId: membership.id,
          toMemberId: targetMember.id,
        },
      );

      return newCreator;
    });

    return this.toMemberResponse(updatedTarget);
  }

  async createInviteLink(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    if (membership.family.inviteCode) {
      return this.toInviteResponse(membership.family.inviteCode);
    }

    const inviteCode = await this.generateUniqueInviteCode();
    const family = await this.prisma.$transaction(async (tx) => {
      const updatedFamily = await tx.family.update({
        where: { id: membership.familyId },
        data: { inviteCode },
      });
      await this.createActivity(tx, membership.familyId, userId, 'family.invite.created', {
        inviteCode,
      });

      return updatedFamily;
    });

    return this.toInviteResponse(family.inviteCode as string);
  }

  async regenerateInviteCode(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    const inviteCode = await this.generateUniqueInviteCode();
    const family = await this.prisma.$transaction(async (tx) => {
      const updatedFamily = await tx.family.update({
        where: { id: membership.familyId },
        data: { inviteCode },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.invite.regenerated',
        { inviteCode },
      );

      return updatedFamily;
    });

    return this.toInviteResponse(family.inviteCode as string);
  }

  async requestDeleteCurrentFamily(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const token = this.createOpaqueTokenParts();
    const tokenHash = await this.hashSecret(token.secret);

    await this.prisma.$transaction(async (tx) => {
      await tx.familyDeleteRequest.create({
        data: {
          tokenId: token.tokenId,
          tokenHash,
          familyId: membership.familyId,
          userId,
          expiresAt: this.getDeleteConfirmExpiresAt(),
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.delete.requested',
      );
    });

    await this.familyMailService.sendDeleteConfirmation({
      email: user.email,
      familyId: membership.familyId,
      token: this.serializeOpaqueToken(token),
    });

    return { accepted: true };
  }

  async confirmDeleteCurrentFamily(userId: string, dto: DeleteConfirmDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertCreator(membership);

    const parsedToken = this.parseOpaqueToken(dto.token);
    if (!parsedToken) {
      throw new UnauthorizedException('Invalid delete confirmation token');
    }

    const deleteRequest = await this.prisma.familyDeleteRequest.findUnique({
      where: { tokenId: parsedToken.tokenId },
    });
    if (
      !deleteRequest ||
      deleteRequest.familyId !== membership.familyId ||
      deleteRequest.userId !== userId ||
      deleteRequest.usedAt ||
      deleteRequest.expiresAt.getTime() <= Date.now()
    ) {
      throw new UnauthorizedException('Invalid delete confirmation token');
    }

    const isTokenValid = await bcrypt.compare(
      parsedToken.secret,
      deleteRequest.tokenHash,
    );
    if (!isTokenValid) {
      throw new UnauthorizedException('Invalid delete confirmation token');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.familyDeleteRequest.update({
        where: { id: deleteRequest.id },
        data: { usedAt: new Date() },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family.delete.confirmed',
      );
      await tx.family.delete({ where: { id: membership.familyId } });
    });

    return { success: true };
  }

  private async requireCurrentMembership(
    userId: string,
  ): Promise<CurrentMembership> {
    const membership = await this.prisma.familyMember.findFirst({
      where: { userId },
      include: {
        family: {
          select: {
            id: true,
            name: true,
            inviteCode: true,
            createdAt: true,
            updatedAt: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });
    if (!membership) {
      throw new NotFoundException('Current family not found');
    }

    return membership;
  }

  private async assertUserHasNoFamily(userId: string) {
    const membership = await this.prisma.familyMember.findFirst({
      where: { userId },
      select: { id: true },
    });
    if (membership) {
      throw new ConflictException('User already has an active family');
    }
  }

  private async requireFamilyMember(familyId: string, memberId: string) {
    const member = await this.prisma.familyMember.findFirst({
      where: { id: memberId, familyId },
    });
    if (!member) {
      throw new NotFoundException('Family member not found');
    }

    return member;
  }

  private getFamilyMembers(familyId: string) {
    return this.prisma.familyMember.findMany({ where: { familyId } });
  }

  private assertCreator(member: Pick<FamilyMember, 'role'>) {
    if (member.role !== FamilyRole.OWNER) {
      throw new ForbiddenException('Creator permissions required');
    }
  }

  private assertAdult(member: Pick<FamilyMember, 'role'>) {
    if (member.role !== FamilyRole.OWNER && member.role !== FamilyRole.ADULT) {
      throw new ForbiddenException('Adult permissions required');
    }
  }

  private assertCanLeave(currentMember: FamilyMember, members: FamilyMember[]) {
    if (members.length === 1) {
      return;
    }

    if (currentMember.role === FamilyRole.OWNER) {
      throw new BadRequestException(
        'Creator must transfer creator role before leaving',
      );
    }

    const adultCount = members.filter((member) => this.isAdultRole(member.role))
      .length;
    const childCount = members.filter((member) => member.role === FamilyRole.CHILD)
      .length;

    if (
      this.isAdultRole(currentMember.role) &&
      adultCount === 1 &&
      childCount > 0
    ) {
      throw new BadRequestException(
        'The only adult cannot leave while children remain in the family',
      );
    }
  }

  private isAdultRole(role: FamilyRole) {
    return role === FamilyRole.OWNER || role === FamilyRole.ADULT;
  }

  private async generateUniqueInviteCode() {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const inviteCode = randomBytes(6).toString('base64url');
      const existingFamily = await this.prisma.family.findUnique({
        where: { inviteCode },
        select: { id: true },
      });
      if (!existingFamily) {
        return inviteCode;
      }
    }

    throw new ConflictException('Could not generate a unique invite code');
  }

  private toInviteResponse(inviteCode: string) {
    const publicBaseUrl = this.configService.get<string | null>(
      'app.invitePublicBaseUrl',
      null,
    );

    return {
      inviteCode,
      inviteLink: publicBaseUrl
        ? `${publicBaseUrl.replace(/\/+$/, '')}/join-family?code=${encodeURIComponent(inviteCode)}`
        : null,
    };
  }

  private normalizeFamilyName(name: string) {
    const normalizedName = name.trim();
    if (!normalizedName) {
      throw new BadRequestException('Family name cannot be empty');
    }

    return normalizedName;
  }

  private createOpaqueTokenParts(): OpaqueTokenParts {
    return {
      tokenId: randomUUID(),
      secret: randomBytes(48).toString('base64url'),
    };
  }

  private serializeOpaqueToken(token: OpaqueTokenParts) {
    return `${token.tokenId}.${token.secret}`;
  }

  private parseOpaqueToken(token: string) {
    const [tokenId, secret, extra] = token.split('.');
    if (!tokenId || !secret || extra) {
      return null;
    }

    return { tokenId, secret };
  }

  private hashSecret(secret: string) {
    return bcrypt.hash(
      secret,
      this.configService.get<number>('auth.passwordSaltRounds', 12),
    );
  }

  private getDeleteConfirmExpiresAt() {
    return new Date(Date.now() + 30 * 60 * 1000);
  }

  private createActivity(
    tx: Prisma.TransactionClient,
    familyId: string,
    actorId: string | null,
    type: string,
    payload?: Prisma.InputJsonValue,
  ) {
    return tx.historyEvent.create({
      data: {
        familyId,
        actorId,
        type,
        payload: payload ?? Prisma.JsonNull,
      },
    });
  }

  private toFamilyResponse(family: {
    id: string;
    name: string;
    inviteCode?: string | null;
    createdAt: Date;
    updatedAt: Date;
  }) {
    return {
      id: family.id,
      name: family.name,
      inviteCode: family.inviteCode ?? null,
      createdAt: family.createdAt,
      updatedAt: family.updatedAt,
    };
  }

  private toMemberResponse(member: {
    id: string;
    familyId: string;
    userId: string;
    role: FamilyRole;
    createdAt: Date;
  }) {
    return {
      id: member.id,
      familyId: member.familyId,
      userId: member.userId,
      role: member.role,
      createdAt: member.createdAt,
    };
  }
}
