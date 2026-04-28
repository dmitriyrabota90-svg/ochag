import { NotFoundException } from '@nestjs/common';
import { FamilyRole } from '@prisma/client';
import { AnalyticsService } from './analytics.service';
import { AnalyticsPeriod } from './dto/analytics-period-query.dto';

describe('AnalyticsService', () => {
  const now = new Date('2026-04-27T10:00:00.000Z');
  const family = {
    id: 'family-1',
    name: 'Ochag',
    createdAt: now,
    updatedAt: now,
  };
  const membership = {
    id: 'member-adult',
    familyId: family.id,
    userId: 'user-adult',
    role: FamilyRole.OWNER,
    createdAt: now,
    family,
  };
  const members = [
    {
      id: 'member-adult',
      familyId: family.id,
      userId: 'user-adult',
      role: FamilyRole.OWNER,
      createdAt: now,
      user: {
        id: 'user-adult',
        email: 'adult@example.com',
        displayName: 'Adult',
      },
      progress: {
        id: 'progress-adult',
        familyId: family.id,
        memberId: 'member-adult',
        sparks: 15,
        experience: 210,
        createdAt: now,
        updatedAt: now,
      },
    },
    {
      id: 'member-child',
      familyId: family.id,
      userId: 'user-child',
      role: FamilyRole.CHILD,
      createdAt: now,
      user: {
        id: 'user-child',
        email: 'child@example.com',
        displayName: 'Child',
      },
      progress: {
        id: 'progress-child',
        familyId: family.id,
        memberId: 'member-child',
        sparks: 20,
        experience: 150,
        createdAt: now,
        updatedAt: now,
      },
    },
  ];

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
      },
      sparkLedger: {
        groupBy: jest.fn(),
      },
      experienceLedger: {
        groupBy: jest.fn(),
      },
      task: {
        groupBy: jest.fn(),
      },
    };

    return {
      service: new AnalyticsService(prisma as never),
      prisma,
    };
  };

  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(now);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('returns current family rating sorted by period experience, sparks, and completed tasks', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.familyMember.findMany.mockResolvedValue(members);
    prisma.sparkLedger.groupBy
      .mockResolvedValueOnce([
        { memberId: 'member-adult', _sum: { amount: 10 } },
        { memberId: 'member-child', _sum: { amount: 12 } },
      ])
      .mockResolvedValueOnce([]);
    prisma.experienceLedger.groupBy.mockResolvedValue([
      { memberId: 'member-adult', _sum: { amount: 20 } },
      { memberId: 'member-child', _sum: { amount: 20 } },
    ]);
    prisma.task.groupBy.mockResolvedValue([
      { assigneeId: 'user-adult', _count: { _all: 3 } },
      { assigneeId: 'user-child', _count: { _all: 1 } },
    ]);

    const result = await service.getRating('user-adult', {
      period: AnalyticsPeriod.WEEK,
    });

    expect(prisma.familyMember.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({ where: { userId: 'user-adult' } }),
    );
    expect(prisma.sparkLedger.groupBy).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          familyId: family.id,
          amount: { gt: 0 },
          reason: { in: ['task.approved', 'initiative.approved'] },
          createdAt: {
            gte: new Date('2026-04-27T00:00:00.000Z'),
            lt: new Date('2026-05-04T00:00:00.000Z'),
          },
        }),
      }),
    );
    expect(result.items).toEqual([
      expect.objectContaining({
        rank: 1,
        memberId: 'member-child',
        level: 2,
        experienceForPeriod: 20,
        sparksEarnedForPeriod: 12,
        completedTasksForPeriod: 1,
      }),
      expect.objectContaining({
        rank: 2,
        memberId: 'member-adult',
        level: 3,
        experienceForPeriod: 20,
        sparksEarnedForPeriod: 10,
        completedTasksForPeriod: 3,
      }),
    ]);
  });

  it('returns mobile-friendly family analytics summary with totals', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.familyMember.findMany.mockResolvedValue(members);
    prisma.sparkLedger.groupBy
      .mockResolvedValueOnce([
        { memberId: 'member-adult', _sum: { amount: 10 } },
        { memberId: 'member-child', _sum: { amount: 5 } },
      ])
      .mockResolvedValueOnce([
        { memberId: 'member-adult', _sum: { amount: -7 } },
        { memberId: 'member-child', _sum: { amount: -3 } },
      ]);
    prisma.experienceLedger.groupBy.mockResolvedValue([
      { memberId: 'member-adult', _sum: { amount: 15 } },
      { memberId: 'member-child', _sum: { amount: 8 } },
    ]);
    prisma.task.groupBy.mockResolvedValue([
      { assigneeId: 'user-adult', _count: { _all: 2 } },
      { assigneeId: 'user-child', _count: { _all: 1 } },
    ]);

    const result = await service.getSummary('user-adult', {
      period: AnalyticsPeriod.MONTH,
    });

    expect(result.period).toEqual({
      value: AnalyticsPeriod.MONTH,
      from: new Date('2026-04-01T00:00:00.000Z'),
      to: new Date('2026-05-01T00:00:00.000Z'),
    });
    expect(result.totals).toEqual({
      completedTasks: 3,
      sparksEarned: 15,
      experienceEarned: 23,
      familyGoalContributedSparks: 10,
    });
    expect(result.members).toEqual([
      expect.objectContaining({
        memberId: 'member-adult',
        completedTasks: 2,
        sparksEarned: 10,
        experienceEarned: 15,
        familyGoalContributedSparks: 7,
      }),
      expect.objectContaining({
        memberId: 'member-child',
        completedTasks: 1,
        sparksEarned: 5,
        experienceEarned: 8,
        familyGoalContributedSparks: 3,
      }),
    ]);
  });

  it('blocks users without a current family', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(null);

    await expect(service.getRating('user-1', {})).rejects.toThrow(
      NotFoundException,
    );
    expect(prisma.familyMember.findMany).not.toHaveBeenCalled();
  });
});
