import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  FamilyMember,
  FamilyRole,
  InitiativeStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { ApproveInitiativeDto } from './dto/approve-initiative.dto';
import { CreateInitiativeDto } from './dto/create-initiative.dto';

const DISCUSSION_LOCK_MINUTES = 15;

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  };
};

@Injectable()
export class InitiativesService {
  constructor(private readonly prisma: PrismaService) {}

  async listInitiatives(userId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return this.prisma.initiative.findMany({
      where: { familyId: membership.familyId },
      include: this.initiativeInclude(),
      orderBy: { createdAt: 'desc' },
    });
  }

  async getInitiative(userId: string, initiativeId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return this.requireInitiative(membership.familyId, initiativeId);
  }

  async createInitiative(userId: string, dto: CreateInitiativeDto) {
    const membership = await this.requireCurrentMembership(userId);
    const members = await this.getFamilyMembers(membership.familyId);
    const discussionLockedUntil = new Date(
      Date.now() + DISCUSSION_LOCK_MINUTES * 60 * 1000,
    );

    return this.prisma.$transaction(async (tx) => {
      const initiative = await tx.initiative.create({
        data: {
          familyId: membership.familyId,
          title: this.normalizeText(dto.title, 'Initiative title'),
          description: this.normalizeOptionalText(dto.description),
          status: InitiativeStatus.DISCUSSION,
          createdById: userId,
          discussionLockedUntil,
        },
        include: this.initiativeInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'initiative_submitted',
        {
          initiativeId: initiative.id,
          discussionLockedUntil: discussionLockedUntil.toISOString(),
        },
      );
      await this.createNotifications(
        tx,
        members
          .filter(
            (member) =>
              this.isAdultRole(member.role) && member.userId !== userId,
          )
          .map((member) => ({
            familyId: membership.familyId,
            userId: member.userId,
            type: 'initiative_submitted',
            title: 'New initiative',
            body: initiative.title,
            payload: { initiativeId: initiative.id },
          })),
      );

      return initiative;
    });
  }

  async approveInitiative(
    userId: string,
    initiativeId: string,
    dto: ApproveInitiativeDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    const initiative = await this.requireInitiative(
      membership.familyId,
      initiativeId,
    );
    const members = await this.getFamilyMembers(membership.familyId);
    const submitter = this.requireSubmitterMember(initiative, members);

    this.assertFinalizable(initiative);
    this.assertReviewerAllowed(initiative, membership, submitter, members);

    return this.prisma.$transaction(async (tx) => {
      const approved = await tx.initiative.update({
        where: { id: initiative.id },
        data: {
          status: InitiativeStatus.APPROVED,
          finalSparks: dto.finalSparks,
          decidedById: userId,
          decidedAt: new Date(),
        },
        include: this.initiativeInclude(),
      });

      await tx.memberProgress.upsert({
        where: { memberId: submitter.id },
        create: {
          familyId: membership.familyId,
          memberId: submitter.id,
          sparks: dto.finalSparks,
          experience: dto.finalSparks,
        },
        update: {
          sparks: { increment: dto.finalSparks },
          experience: { increment: dto.finalSparks },
        },
      });
      await tx.sparkLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: submitter.id,
          initiativeId: initiative.id,
          amount: dto.finalSparks,
          reason: 'initiative.approved',
        },
      });
      await tx.experienceLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: submitter.id,
          initiativeId: initiative.id,
          amount: dto.finalSparks,
          reason: 'initiative.approved',
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'initiative_approved',
        {
          initiativeId: initiative.id,
          submitterMemberId: submitter.id,
          finalSparks: dto.finalSparks,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: submitter.userId,
        type: 'initiative_approved',
        title: 'Initiative approved',
        body: initiative.title,
        payload: {
          initiativeId: initiative.id,
          finalSparks: dto.finalSparks,
        },
      });

      return approved;
    });
  }

  async approveWithoutReward(userId: string, initiativeId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const initiative = await this.requireInitiative(
      membership.familyId,
      initiativeId,
    );
    const members = await this.getFamilyMembers(membership.familyId);
    const submitter = this.requireSubmitterMember(initiative, members);

    this.assertFinalizable(initiative);
    this.assertReviewerAllowed(initiative, membership, submitter, members);

    return this.prisma.$transaction(async (tx) => {
      const approved = await tx.initiative.update({
        where: { id: initiative.id },
        data: {
          status: InitiativeStatus.APPROVED_WITHOUT_REWARD,
          finalSparks: 0,
          decidedById: userId,
          decidedAt: new Date(),
        },
        include: this.initiativeInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'initiative_approved_without_reward',
        { initiativeId: initiative.id },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: submitter.userId,
        type: 'initiative_approved_without_reward',
        title: 'Initiative approved',
        body: initiative.title,
        payload: { initiativeId: initiative.id },
      });

      return approved;
    });
  }

  async rejectInitiative(userId: string, initiativeId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const initiative = await this.requireInitiative(
      membership.familyId,
      initiativeId,
    );
    const members = await this.getFamilyMembers(membership.familyId);
    const submitter = this.requireSubmitterMember(initiative, members);

    this.assertFinalizable(initiative);
    this.assertReviewerAllowed(initiative, membership, submitter, members);

    return this.prisma.$transaction(async (tx) => {
      const rejected = await tx.initiative.update({
        where: { id: initiative.id },
        data: {
          status: InitiativeStatus.REJECTED,
          decidedById: userId,
          decidedAt: new Date(),
        },
        include: this.initiativeInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'initiative_rejected',
        { initiativeId: initiative.id },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: submitter.userId,
        type: 'initiative_rejected',
        title: 'Initiative rejected',
        body: initiative.title,
        payload: { initiativeId: initiative.id },
      });

      return rejected;
    });
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

  private async requireInitiative(familyId: string, initiativeId: string) {
    const initiative = await this.prisma.initiative.findFirst({
      where: { id: initiativeId, familyId },
      include: this.initiativeInclude(),
    });
    if (!initiative) {
      throw new NotFoundException('Initiative not found');
    }

    return initiative;
  }

  private getFamilyMembers(familyId: string) {
    return this.prisma.familyMember.findMany({ where: { familyId } });
  }

  private requireSubmitterMember(
    initiative: { createdById: string | null },
    members: FamilyMember[],
  ) {
    const submitter = members.find(
      (member) => member.userId === initiative.createdById,
    );
    if (!submitter) {
      throw new NotFoundException(
        'Initiative submitter is not a family member',
      );
    }

    return submitter;
  }

  private assertFinalizable(initiative: {
    status: InitiativeStatus;
    discussionLockedUntil: Date | null;
  }) {
    if (initiative.status !== InitiativeStatus.DISCUSSION) {
      throw new BadRequestException('Initiative already has a final decision');
    }
    if (
      initiative.discussionLockedUntil &&
      initiative.discussionLockedUntil.getTime() > Date.now()
    ) {
      throw new BadRequestException(
        'Initiative discussion lock is still active',
      );
    }
  }

  private assertReviewerAllowed(
    initiative: { createdById: string | null },
    reviewer: FamilyMember,
    submitter: FamilyMember,
    members: FamilyMember[],
  ) {
    if (initiative.createdById === reviewer.userId) {
      throw new ForbiddenException('Submitter cannot review own initiative');
    }

    const adultMembers = members.filter((member) =>
      this.isAdultRole(member.role),
    );
    if (this.isAdultRole(reviewer.role)) {
      return;
    }

    if (
      adultMembers.length === 1 &&
      reviewer.role === FamilyRole.CHILD &&
      this.isAdultRole(submitter.role)
    ) {
      return;
    }

    throw new ForbiddenException('Reviewer is not allowed for this initiative');
  }

  private isAdultRole(role: FamilyRole) {
    return role === FamilyRole.OWNER || role === FamilyRole.ADULT;
  }

  private normalizeText(value: string, fieldName: string) {
    const normalized = value.trim();
    if (!normalized) {
      throw new BadRequestException(`${fieldName} cannot be empty`);
    }

    return normalized;
  }

  private normalizeOptionalText(value?: string) {
    if (value === undefined) {
      return undefined;
    }

    const normalized = value.trim();
    return normalized || null;
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

  private createNotification(
    tx: Prisma.TransactionClient,
    notification: {
      familyId: string;
      userId?: string | null;
      type: string;
      title: string;
      body?: string | null;
      payload?: Prisma.InputJsonValue;
    },
  ) {
    if (!notification.userId) {
      return null;
    }

    return tx.notification.create({
      data: {
        familyId: notification.familyId,
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        body: notification.body ?? null,
        payload: notification.payload ?? Prisma.JsonNull,
      },
    });
  }

  private async createNotifications(
    tx: Prisma.TransactionClient,
    notifications: Array<{
      familyId: string;
      userId?: string | null;
      type: string;
      title: string;
      body?: string | null;
      payload?: Prisma.InputJsonValue;
    }>,
  ) {
    await Promise.all(
      notifications.map((notification) =>
        this.createNotification(tx, notification),
      ),
    );
  }

  private initiativeInclude() {
    return {
      createdBy: {
        select: {
          id: true,
          email: true,
          displayName: true,
        },
      },
      decidedBy: {
        select: {
          id: true,
          email: true,
          displayName: true,
        },
      },
    } satisfies Prisma.InitiativeInclude;
  }
}
