import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { FamilyRole, GoalStatus } from '@prisma/client';
import { FamilyGoalService } from './family-goal.service';

describe('FamilyGoalService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const family = {
    id: 'family-1',
    name: 'Ochag',
    createdAt: now,
    updatedAt: now,
  };
  const adultMember = {
    id: 'member-adult',
    familyId: family.id,
    userId: 'user-adult',
    role: FamilyRole.OWNER,
    createdAt: now,
    family,
  };
  const childMember = {
    id: 'member-child',
    familyId: family.id,
    userId: 'user-child',
    role: FamilyRole.CHILD,
    createdAt: now,
    family,
  };
  const activeGoal = {
    id: 'goal-1',
    familyId: family.id,
    title: 'New sofa',
    description: null,
    status: GoalStatus.ACTIVE,
    targetSparks: 20,
    currentSparks: 10,
    targetAt: null,
    achievedAt: null,
    completedAt: null,
    createdAt: now,
    updatedAt: now,
    confirmations: [],
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
      familyGoal: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        findUniqueOrThrow: jest.fn(),
      },
      familyGoalCompletionConfirmation: {
        findUnique: jest.fn(),
        create: jest.fn(),
        count: jest.fn(),
      },
      memberProgress: {
        updateMany: jest.fn(),
      },
      sparkLedger: {
        create: jest.fn(),
      },
      experienceLedger: {
        create: jest.fn(),
      },
      historyEvent: {
        create: jest.fn(),
      },
      notification: {
        create: jest.fn(),
      },
      $transaction: jest.fn(async (handler: (tx: unknown) => unknown) =>
        handler(prisma),
      ),
    };

    return {
      service: new FamilyGoalService(prisma as never),
      prisma,
    };
  };

  it('allows only adults to create goals', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);

    await expect(
      service.createGoal(childMember.userId, {
        title: 'New sofa',
        targetSparks: 20,
      }),
    ).rejects.toThrow(ForbiddenException);
    expect(prisma.familyGoal.create).not.toHaveBeenCalled();
  });

  it('blocks creating a second active goal', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(adultMember);
    prisma.familyGoal.findFirst.mockResolvedValue({ id: activeGoal.id });

    await expect(
      service.createGoal(adultMember.userId, {
        title: 'New sofa',
        targetSparks: 20,
      }),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.familyGoal.create).not.toHaveBeenCalled();
  });

  it('contributes sparks, awards experience, writes ledgers, and achieves goal', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.familyMember.findMany.mockResolvedValue([adultMember, childMember]);
    prisma.familyGoal.findFirst.mockResolvedValue(activeGoal);
    prisma.memberProgress.updateMany.mockResolvedValue({ count: 1 });
    prisma.familyGoal.update.mockResolvedValue({
      ...activeGoal,
      status: GoalStatus.AWAITING_EXECUTION,
      currentSparks: 20,
    });

    await service.contribute(childMember.userId, activeGoal.id, { sparks: 10 });

    expect(prisma.memberProgress.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: childMember.id, sparks: { gte: 10 } },
        data: {
          sparks: { decrement: 10 },
          experience: { increment: 15 },
        },
      }),
    );
    expect(prisma.familyGoal.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          currentSparks: { increment: 10 },
          status: GoalStatus.AWAITING_EXECUTION,
        }),
      }),
    );
    expect(prisma.sparkLedger.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          amount: -10,
          familyGoalId: activeGoal.id,
        }),
      }),
    );
    expect(prisma.experienceLedger.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          amount: 15,
          familyGoalId: activeGoal.id,
        }),
      }),
    );
  });

  it('blocks contribution without enough sparks', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.familyMember.findMany.mockResolvedValue([adultMember, childMember]);
    prisma.familyGoal.findFirst.mockResolvedValue(activeGoal);
    prisma.memberProgress.updateMany.mockResolvedValue({ count: 0 });

    await expect(
      service.contribute(childMember.userId, activeGoal.id, { sparks: 100 }),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.familyGoal.update).not.toHaveBeenCalled();
    expect(prisma.sparkLedger.create).not.toHaveBeenCalled();
  });

  it('completes goal only after all members confirm', async () => {
    const { service, prisma } = createService();
    const awaitingGoal = {
      ...activeGoal,
      status: GoalStatus.AWAITING_EXECUTION,
      currentSparks: 20,
    };
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.familyGoal.findFirst.mockResolvedValue(awaitingGoal);
    prisma.familyGoalCompletionConfirmation.findUnique.mockResolvedValue(null);
    prisma.familyMember.count.mockResolvedValue(2);
    prisma.familyGoalCompletionConfirmation.count.mockResolvedValue(1);
    prisma.familyGoal.findUniqueOrThrow.mockResolvedValue(awaitingGoal);

    const firstConfirmation = await service.confirmCompletion(
      childMember.userId,
      awaitingGoal.id,
    );
    expect(firstConfirmation.status).toBe(GoalStatus.AWAITING_EXECUTION);
    expect(prisma.familyGoal.update).not.toHaveBeenCalled();

    prisma.familyMember.findFirst.mockResolvedValue(adultMember);
    prisma.familyGoalCompletionConfirmation.count.mockResolvedValue(2);
    prisma.familyGoal.update.mockResolvedValue({
      ...awaitingGoal,
      status: GoalStatus.COMPLETED,
      completedAt: now,
    });

    const completed = await service.confirmCompletion(
      adultMember.userId,
      awaitingGoal.id,
    );

    expect(completed.status).toBe(GoalStatus.COMPLETED);
    expect(prisma.familyGoal.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ status: GoalStatus.COMPLETED }),
      }),
    );
  });
});
