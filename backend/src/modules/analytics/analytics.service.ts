import { Injectable, NotFoundException } from '@nestjs/common';
import { FamilyMember, Prisma, TaskStatus } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import {
  AnalyticsPeriod,
  AnalyticsPeriodQueryDto,
} from './dto/analytics-period-query.dto';

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  };
};

type FamilyMemberForAnalytics = Prisma.FamilyMemberGetPayload<{
  include: {
    user: {
      select: {
        id: true;
        email: true;
        displayName: true;
      };
    };
    progress: true;
  };
}>;

type PeriodRange = {
  value: AnalyticsPeriod;
  from: Date | null;
  to: Date | null;
};

type MemberMetrics = {
  sparksEarned: number;
  experienceEarned: number;
  completedTasks: number;
  familyGoalContributedSparks: number;
};

@Injectable()
export class AnalyticsService {
  private readonly defaultPeriod = AnalyticsPeriod.WEEK;
  private readonly sparkEarnedReasons = [
    'task.approved',
    'initiative.approved',
  ];

  constructor(private readonly prisma: PrismaService) {}

  async getRating(userId: string, query: AnalyticsPeriodQueryDto) {
    const membership = await this.requireCurrentMembership(userId);
    const range = this.resolvePeriod(query.period);
    const members = await this.getFamilyMembers(membership.familyId);
    const metrics = await this.getMetrics(membership.familyId, range);

    const items = members
      .map((member) => {
        const memberMetrics = this.getMemberMetrics(metrics, member);
        const totalExperience = member.progress?.experience ?? 0;

        return {
          memberId: member.id,
          user: this.toUserResponse(member),
          role: member.role,
          level: this.getLevel(totalExperience),
          totalExperience,
          experienceForPeriod: memberMetrics.experienceEarned,
          sparksEarnedForPeriod: memberMetrics.sparksEarned,
          completedTasksForPeriod: memberMetrics.completedTasks,
        };
      })
      .sort((left, right) => this.compareRatingItems(left, right))
      .map((item, index) => ({
        rank: index + 1,
        ...item,
      }));

    return {
      family: this.toFamilyResponse(membership.family),
      period: this.toPeriodResponse(range),
      items,
    };
  }

  async getSummary(userId: string, query: AnalyticsPeriodQueryDto) {
    const membership = await this.requireCurrentMembership(userId);
    const range = this.resolvePeriod(query.period);
    const members = await this.getFamilyMembers(membership.familyId);
    const metrics = await this.getMetrics(membership.familyId, range);

    const membersSummary = members.map((member) => {
      const memberMetrics = this.getMemberMetrics(metrics, member);
      const totalExperience = member.progress?.experience ?? 0;

      return {
        memberId: member.id,
        user: this.toUserResponse(member),
        role: member.role,
        level: this.getLevel(totalExperience),
        completedTasks: memberMetrics.completedTasks,
        sparksEarned: memberMetrics.sparksEarned,
        experienceEarned: memberMetrics.experienceEarned,
        familyGoalContributedSparks: memberMetrics.familyGoalContributedSparks,
      };
    });

    return {
      family: this.toFamilyResponse(membership.family),
      period: this.toPeriodResponse(range),
      totals: membersSummary.reduce(
        (totals, member) => ({
          completedTasks: totals.completedTasks + member.completedTasks,
          sparksEarned: totals.sparksEarned + member.sparksEarned,
          experienceEarned: totals.experienceEarned + member.experienceEarned,
          familyGoalContributedSparks:
            totals.familyGoalContributedSparks +
            member.familyGoalContributedSparks,
        }),
        {
          completedTasks: 0,
          sparksEarned: 0,
          experienceEarned: 0,
          familyGoalContributedSparks: 0,
        },
      ),
      members: membersSummary,
    };
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

  private getFamilyMembers(familyId: string) {
    return this.prisma.familyMember.findMany({
      where: { familyId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            displayName: true,
          },
        },
        progress: true,
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
    });
  }

  private async getMetrics(familyId: string, range: PeriodRange) {
    const [sparkGroups, experienceGroups, taskGroups, goalContributionGroups] =
      await Promise.all([
        this.prisma.sparkLedger.groupBy({
          by: ['memberId'],
          where: {
            familyId,
            amount: { gt: 0 },
            reason: { in: this.sparkEarnedReasons },
            ...this.createdAtFilter(range),
          },
          _sum: { amount: true },
        }),
        this.prisma.experienceLedger.groupBy({
          by: ['memberId'],
          where: {
            familyId,
            amount: { gt: 0 },
            ...this.createdAtFilter(range),
          },
          _sum: { amount: true },
        }),
        this.prisma.task.groupBy({
          by: ['assigneeId'],
          where: {
            familyId,
            status: TaskStatus.CONFIRMED,
            assigneeId: { not: null },
            ...this.confirmedAtFilter(range),
          },
          _count: { _all: true },
        }),
        this.prisma.sparkLedger.groupBy({
          by: ['memberId'],
          where: {
            familyId,
            familyGoalId: { not: null },
            reason: 'family_goal.contribution',
            amount: { lt: 0 },
            ...this.createdAtFilter(range),
          },
          _sum: { amount: true },
        }),
      ]);

    return {
      sparksEarned: this.toAmountMap(sparkGroups),
      experienceEarned: this.toAmountMap(experienceGroups),
      completedTasksByUserId: this.toTaskCountMap(taskGroups),
      familyGoalContributedSparks: this.toContributionMap(
        goalContributionGroups,
      ),
    };
  }

  private getMemberMetrics(
    metrics: Awaited<ReturnType<AnalyticsService['getMetrics']>>,
    member: Pick<FamilyMemberForAnalytics, 'id' | 'userId'>,
  ): MemberMetrics {
    return {
      sparksEarned: metrics.sparksEarned.get(member.id) ?? 0,
      experienceEarned: metrics.experienceEarned.get(member.id) ?? 0,
      completedTasks: metrics.completedTasksByUserId.get(member.userId) ?? 0,
      familyGoalContributedSparks:
        metrics.familyGoalContributedSparks.get(member.id) ?? 0,
    };
  }

  private getLevel(totalExperience: number) {
    return Math.floor(totalExperience / 100) + 1;
  }

  private compareRatingItems(
    left: {
      memberId: string;
      user: { name: string };
      totalExperience: number;
      experienceForPeriod: number;
      sparksEarnedForPeriod: number;
      completedTasksForPeriod: number;
    },
    right: {
      memberId: string;
      user: { name: string };
      totalExperience: number;
      experienceForPeriod: number;
      sparksEarnedForPeriod: number;
      completedTasksForPeriod: number;
    },
  ) {
    return (
      right.experienceForPeriod - left.experienceForPeriod ||
      right.sparksEarnedForPeriod - left.sparksEarnedForPeriod ||
      right.completedTasksForPeriod - left.completedTasksForPeriod ||
      right.totalExperience - left.totalExperience ||
      left.user.name.localeCompare(right.user.name) ||
      left.memberId.localeCompare(right.memberId)
    );
  }

  private resolvePeriod(period?: AnalyticsPeriod): PeriodRange {
    const value = period ?? this.defaultPeriod;
    if (value === AnalyticsPeriod.ALL_TIME) {
      return { value, from: null, to: null };
    }

    const now = new Date();
    if (value === AnalyticsPeriod.DAY) {
      const from = new Date(
        Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
      );
      const to = new Date(from);
      to.setUTCDate(to.getUTCDate() + 1);
      return { value, from, to };
    }

    if (value === AnalyticsPeriod.MONTH) {
      const from = new Date(
        Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1),
      );
      const to = new Date(
        Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1),
      );
      return { value, from, to };
    }

    const from = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
    );
    const day = from.getUTCDay() || 7;
    from.setUTCDate(from.getUTCDate() - day + 1);
    const to = new Date(from);
    to.setUTCDate(to.getUTCDate() + 7);

    return { value, from, to };
  }

  private createdAtFilter(range: PeriodRange) {
    if (!range.from || !range.to) {
      return {};
    }

    return {
      createdAt: {
        gte: range.from,
        lt: range.to,
      },
    } satisfies Pick<Prisma.SparkLedgerWhereInput, 'createdAt'>;
  }

  private confirmedAtFilter(range: PeriodRange) {
    if (!range.from || !range.to) {
      return {};
    }

    return {
      confirmedAt: {
        gte: range.from,
        lt: range.to,
      },
    } satisfies Pick<Prisma.TaskWhereInput, 'confirmedAt'>;
  }

  private toAmountMap(
    groups: Array<{ memberId: string; _sum: { amount: number | null } }>,
  ) {
    return new Map(
      groups.map((group) => [group.memberId, group._sum.amount ?? 0] as const),
    );
  }

  private toContributionMap(
    groups: Array<{ memberId: string; _sum: { amount: number | null } }>,
  ) {
    return new Map(
      groups.map(
        (group) => [group.memberId, Math.abs(group._sum.amount ?? 0)] as const,
      ),
    );
  }

  private toTaskCountMap(
    groups: Array<{ assigneeId: string | null; _count: { _all: number } }>,
  ) {
    return new Map(
      groups
        .filter(
          (group): group is { assigneeId: string; _count: { _all: number } } =>
            Boolean(group.assigneeId),
        )
        .map((group) => [group.assigneeId, group._count._all] as const),
    );
  }

  private toUserResponse(member: FamilyMemberForAnalytics) {
    return {
      id: member.user.id,
      name: member.user.displayName ?? member.user.email,
      displayName: member.user.displayName,
      email: member.user.email,
    };
  }

  private toFamilyResponse(family: CurrentMembership['family']) {
    return {
      id: family.id,
      name: family.name,
    };
  }

  private toPeriodResponse(range: PeriodRange) {
    return {
      value: range.value,
      from: range.from,
      to: range.to,
    };
  }
}
