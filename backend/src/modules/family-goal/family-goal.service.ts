import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { FamilyMember, FamilyRole, GoalStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { ContributeFamilyGoalDto } from './dto/contribute-family-goal.dto';
import { CreateFamilyGoalDto } from './dto/create-family-goal.dto';
import { UpdateFamilyGoalDto } from './dto/update-family-goal.dto';

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  };
};

@Injectable()
export class FamilyGoalService {
  constructor(private readonly prisma: PrismaService) {}

  async getCurrentGoal(userId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const currentGoal = await this.prisma.familyGoal.findFirst({
      where: {
        familyId: membership.familyId,
        status: { in: [GoalStatus.ACTIVE, GoalStatus.AWAITING_EXECUTION] },
      },
      include: this.goalInclude(),
      orderBy: { createdAt: 'desc' },
    });

    if (currentGoal) {
      return currentGoal;
    }

    const latestCompletedGoal = await this.prisma.familyGoal.findFirst({
      where: {
        familyId: membership.familyId,
        status: GoalStatus.COMPLETED,
      },
      include: this.goalInclude(),
      orderBy: { completedAt: 'desc' },
    });
    if (!latestCompletedGoal) {
      throw new NotFoundException('Family goal not found');
    }

    return latestCompletedGoal;
  }

  async createGoal(userId: string, dto: CreateFamilyGoalDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    const activeGoal = await this.getActiveGoal(membership.familyId);
    if (activeGoal) {
      throw new BadRequestException('Family already has an active goal');
    }

    return this.prisma.$transaction(async (tx) => {
      const goal = await tx.familyGoal.create({
        data: {
          familyId: membership.familyId,
          title: this.normalizeText(dto.title, 'Family goal title'),
          description: this.normalizeOptionalText(dto.description),
          targetSparks: dto.targetSparks,
          currentSparks: 0,
          targetAt: dto.targetAt ? new Date(dto.targetAt) : null,
        },
        include: this.goalInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family_goal_created',
        { goalId: goal.id, targetSparks: goal.targetSparks },
      );

      return goal;
    });
  }

  async updateGoal(userId: string, goalId: string, dto: UpdateFamilyGoalDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const goal = await this.requireGoal(membership.familyId, goalId);
    const members = await this.getFamilyMembers(membership.familyId);

    if (goal.status === GoalStatus.COMPLETED) {
      throw new BadRequestException('Completed family goal cannot be changed');
    }
    if (goal.status !== GoalStatus.ACTIVE) {
      throw new BadRequestException('Only active family goal can be changed');
    }

    return this.prisma.$transaction(async (tx) => {
      const shouldAchieve =
        dto.targetSparks !== undefined &&
        goal.currentSparks >= dto.targetSparks;
      const updated = await tx.familyGoal.update({
        where: { id: goal.id },
        data: {
          ...(dto.title !== undefined
            ? { title: this.normalizeText(dto.title, 'Family goal title') }
            : {}),
          ...(dto.description !== undefined
            ? { description: this.normalizeOptionalText(dto.description) }
            : {}),
          ...(dto.targetSparks !== undefined
            ? { targetSparks: dto.targetSparks }
            : {}),
          ...(dto.targetAt !== undefined
            ? { targetAt: dto.targetAt ? new Date(dto.targetAt) : null }
            : {}),
          ...(shouldAchieve
            ? { status: GoalStatus.AWAITING_EXECUTION, achievedAt: new Date() }
            : {}),
        },
        include: this.goalInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family_goal_updated',
        { goalId: goal.id },
      );
      if (shouldAchieve) {
        await this.createActivity(
          tx,
          membership.familyId,
          userId,
          'family_goal_achieved',
          { goalId: goal.id },
        );
        await this.createNotifications(
          tx,
          members.map((member) => ({
            familyId: membership.familyId,
            userId: member.userId,
            type: 'family_goal_achieved',
            title: 'Family goal achieved',
            body: updated.title,
            payload: { goalId: goal.id },
          })),
        );
      }

      return updated;
    });
  }

  async contribute(
    userId: string,
    goalId: string,
    dto: ContributeFamilyGoalDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    const goal = await this.requireGoal(membership.familyId, goalId);
    const members = await this.getFamilyMembers(membership.familyId);
    if (goal.status !== GoalStatus.ACTIVE) {
      throw new BadRequestException(
        'Only active family goal accepts contributions',
      );
    }

    const experience = Math.floor(dto.sparks * 1.5);

    return this.prisma.$transaction(async (tx) => {
      const charged = await tx.memberProgress.updateMany({
        where: {
          memberId: membership.id,
          sparks: { gte: dto.sparks },
        },
        data: {
          sparks: { decrement: dto.sparks },
          experience: { increment: experience },
        },
      });
      if (charged.count === 0) {
        throw new BadRequestException('Not enough sparks');
      }

      const newCurrentSparks = goal.currentSparks + dto.sparks;
      const achieved = newCurrentSparks >= goal.targetSparks;
      const updated = await tx.familyGoal.update({
        where: { id: goal.id },
        data: {
          currentSparks: { increment: dto.sparks },
          ...(achieved
            ? { status: GoalStatus.AWAITING_EXECUTION, achievedAt: new Date() }
            : {}),
        },
        include: this.goalInclude(),
      });

      await tx.sparkLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: membership.id,
          familyGoalId: goal.id,
          amount: -dto.sparks,
          reason: 'family_goal.contribution',
        },
      });
      await tx.experienceLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: membership.id,
          familyGoalId: goal.id,
          amount: experience,
          reason: 'family_goal.contribution',
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family_goal_contributed',
        { goalId: goal.id, sparks: dto.sparks, experience },
      );
      await this.createNotifications(
        tx,
        members
          .filter((member) => member.userId !== userId)
          .map((member) => ({
            familyId: membership.familyId,
            userId: member.userId,
            type: 'family_goal_contributed',
            title: 'Family goal contribution',
            body: goal.title,
            payload: {
              goalId: goal.id,
              memberId: membership.id,
              sparks: dto.sparks,
              experience,
            },
          })),
      );
      if (achieved) {
        await this.createActivity(
          tx,
          membership.familyId,
          userId,
          'family_goal_achieved',
          { goalId: goal.id },
        );
        await this.createNotifications(
          tx,
          members.map((member) => ({
            familyId: membership.familyId,
            userId: member.userId,
            type: 'family_goal_achieved',
            title: 'Family goal achieved',
            body: goal.title,
            payload: { goalId: goal.id },
          })),
        );
      }

      return updated;
    });
  }

  async confirmCompletion(userId: string, goalId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const goal = await this.requireGoal(membership.familyId, goalId);

    if (goal.status === GoalStatus.COMPLETED) {
      throw new BadRequestException(
        'Completed family goal cannot be confirmed again',
      );
    }
    if (goal.status !== GoalStatus.AWAITING_EXECUTION) {
      throw new BadRequestException('Family goal is not awaiting execution');
    }

    const existingConfirmation =
      await this.prisma.familyGoalCompletionConfirmation.findUnique({
        where: {
          goalId_memberId: { goalId: goal.id, memberId: membership.id },
        },
      });
    if (existingConfirmation) {
      throw new BadRequestException(
        'Family goal completion is already confirmed',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.familyGoalCompletionConfirmation.create({
        data: {
          familyId: membership.familyId,
          goalId: goal.id,
          memberId: membership.id,
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'family_goal_completion_confirmed',
        { goalId: goal.id, memberId: membership.id },
      );

      const [membersCount, confirmationsCount] = await Promise.all([
        tx.familyMember.count({ where: { familyId: membership.familyId } }),
        tx.familyGoalCompletionConfirmation.count({
          where: { goalId: goal.id },
        }),
      ]);

      if (confirmationsCount >= membersCount) {
        const completed = await tx.familyGoal.update({
          where: { id: goal.id },
          data: { status: GoalStatus.COMPLETED, completedAt: new Date() },
          include: this.goalInclude(),
        });
        await this.createActivity(
          tx,
          membership.familyId,
          userId,
          'family_goal_completed',
          { goalId: goal.id },
        );
        return completed;
      }

      return tx.familyGoal.findUniqueOrThrow({
        where: { id: goal.id },
        include: this.goalInclude(),
      });
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

  private async requireGoal(familyId: string, goalId: string) {
    const goal = await this.prisma.familyGoal.findFirst({
      where: { id: goalId, familyId },
      include: this.goalInclude(),
    });
    if (!goal) {
      throw new NotFoundException('Family goal not found');
    }
    return goal;
  }

  private getActiveGoal(familyId: string) {
    return this.prisma.familyGoal.findFirst({
      where: {
        familyId,
        status: { in: [GoalStatus.ACTIVE, GoalStatus.AWAITING_EXECUTION] },
      },
      select: { id: true },
    });
  }

  private getFamilyMembers(familyId: string) {
    return this.prisma.familyMember.findMany({ where: { familyId } });
  }

  private assertAdult(member: Pick<FamilyMember, 'role'>) {
    if (member.role !== FamilyRole.OWNER && member.role !== FamilyRole.ADULT) {
      throw new ForbiddenException('Adult permissions required');
    }
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

  private goalInclude() {
    return {
      confirmations: {
        include: {
          member: {
            include: {
              user: {
                select: { id: true, email: true, displayName: true },
              },
            },
          },
        },
        orderBy: { createdAt: 'asc' as const },
      },
    } satisfies Prisma.FamilyGoalInclude;
  }
}
