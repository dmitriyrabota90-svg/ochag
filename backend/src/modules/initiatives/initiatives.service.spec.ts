import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { FamilyRole, InitiativeStatus } from '@prisma/client';
import { InitiativesService } from './initiatives.service';

describe('InitiativesService', () => {
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
  const anotherAdultMember = {
    id: 'member-adult-2',
    familyId: family.id,
    userId: 'user-adult-2',
    role: FamilyRole.ADULT,
    createdAt: now,
  };
  const childMember = {
    id: 'member-child',
    familyId: family.id,
    userId: 'user-child',
    role: FamilyRole.CHILD,
    createdAt: now,
  };
  const initiative = {
    id: 'initiative-1',
    familyId: family.id,
    title: 'Clean hallway',
    description: null,
    status: InitiativeStatus.DISCUSSION,
    createdById: childMember.userId,
    discussionLockedUntil: new Date(Date.now() - 60_000),
    finalSparks: null,
    decidedById: null,
    decidedAt: null,
    createdAt: now,
    updatedAt: now,
    createdBy: null,
    decidedBy: null,
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
      },
      initiative: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      memberProgress: {
        upsert: jest.fn(),
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
      service: new InitiativesService(prisma as never),
      prisma,
    };
  };

  it('blocks final decision before discussion lock expires', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(adultMember);
    prisma.initiative.findFirst.mockResolvedValue({
      ...initiative,
      discussionLockedUntil: new Date(Date.now() + 60_000),
    });
    prisma.familyMember.findMany.mockResolvedValue([
      { ...adultMember, family: undefined },
      childMember,
    ]);

    await expect(
      service.approveInitiative(adultMember.userId, initiative.id, {
        finalSparks: 3,
      }),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.initiative.update).not.toHaveBeenCalled();
  });

  it('prevents submitter from reviewing own initiative', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.initiative.findFirst.mockResolvedValue(initiative);
    prisma.familyMember.findMany.mockResolvedValue([adultMember, childMember]);

    await expect(
      service.rejectInitiative(childMember.userId, initiative.id),
    ).rejects.toThrow(ForbiddenException);
  });

  it('approves with reward and writes progress plus ledgers', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(adultMember);
    prisma.initiative.findFirst.mockResolvedValue(initiative);
    prisma.familyMember.findMany.mockResolvedValue([
      { ...adultMember, family: undefined },
      childMember,
    ]);
    prisma.initiative.update.mockResolvedValue({
      ...initiative,
      status: InitiativeStatus.APPROVED,
      finalSparks: 5,
    });

    await service.approveInitiative(adultMember.userId, initiative.id, {
      finalSparks: 5,
    });

    expect(prisma.memberProgress.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: childMember.id },
        update: {
          sparks: { increment: 5 },
          experience: { increment: 5 },
        },
      }),
    );
    expect(prisma.sparkLedger.create).toHaveBeenCalled();
    expect(prisma.experienceLedger.create).toHaveBeenCalled();
  });

  it('allows child reviewer for adult initiative when family has one adult', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.initiative.findFirst.mockResolvedValue({
      ...initiative,
      createdById: adultMember.userId,
    });
    prisma.familyMember.findMany.mockResolvedValue([
      { ...adultMember, family: undefined },
      childMember,
    ]);
    prisma.initiative.update.mockResolvedValue({
      ...initiative,
      status: InitiativeStatus.APPROVED_WITHOUT_REWARD,
    });

    await service.approveWithoutReward(childMember.userId, initiative.id);

    expect(prisma.initiative.update).toHaveBeenCalled();
    expect(prisma.sparkLedger.create).not.toHaveBeenCalled();
  });

  it('does not allow final decisions to be changed', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(adultMember);
    prisma.initiative.findFirst.mockResolvedValue({
      ...initiative,
      status: InitiativeStatus.APPROVED,
    });
    prisma.familyMember.findMany.mockResolvedValue([
      { ...adultMember, family: undefined },
      childMember,
    ]);

    await expect(
      service.rejectInitiative(adultMember.userId, initiative.id),
    ).rejects.toThrow(BadRequestException);
  });
});
