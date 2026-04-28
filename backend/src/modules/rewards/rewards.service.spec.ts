import { BadRequestException, ForbiddenException } from '@nestjs/common';
import {
  FamilyRole,
  RewardPaymentMode,
  RewardRequestStatus,
  RewardStatus,
} from '@prisma/client';
import { RewardsService } from './rewards.service';

describe('RewardsService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const family = {
    id: 'family-1',
    name: 'Ochag',
    createdAt: now,
    updatedAt: now,
  };
  const proposer = {
    id: 'member-proposer',
    familyId: family.id,
    userId: 'user-proposer',
    role: FamilyRole.ADULT,
    createdAt: now,
    family,
  };
  const provider = {
    id: 'member-provider',
    familyId: family.id,
    userId: 'user-provider',
    role: FamilyRole.OWNER,
    createdAt: now,
    family,
  };
  const reward = {
    id: 'reward-1',
    familyId: family.id,
    title: 'Movie',
    description: null,
    pointsCost: 10,
    paymentMode: RewardPaymentMode.SPARKS,
    status: RewardStatus.PROPOSED,
    levelRequired: null,
    createdById: proposer.userId,
    approvedById: null,
    approvedAt: null,
    rejectedAt: null,
    createdAt: now,
    updatedAt: now,
    createdBy: null,
    approvedBy: null,
  };
  const activeReward = {
    ...reward,
    status: RewardStatus.ACTIVE,
    approvedById: provider.userId,
  };
  const request = {
    id: 'request-1',
    familyId: family.id,
    rewardId: reward.id,
    requesterMemberId: proposer.id,
    providerMemberId: provider.id,
    status: RewardRequestStatus.CANCEL_REQUESTED,
    statusBeforeCancel: RewardRequestStatus.IN_PROGRESS,
    paymentMode: RewardPaymentMode.SPARKS,
    sparksCost: 10,
    levelSnapshot: null,
    fulfilledAt: null,
    receivedAt: null,
    cancelRequestedById: proposer.id,
    cancelRequestedAt: now,
    cancelledAt: null,
    createdAt: now,
    updatedAt: now,
    reward: activeReward,
    requester: proposer,
    provider,
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
      },
      reward: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      rewardTemplate: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      rewardRequest: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      memberProgress: {
        findUnique: jest.fn(),
        update: jest.fn(),
        upsert: jest.fn(),
      },
      sparkLedger: {
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
      service: new RewardsService(prisma as never),
      prisma,
    };
  };

  it('prevents proposer from approving own reward', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(proposer);
    prisma.reward.findFirst.mockResolvedValue(reward);

    await expect(
      service.approveReward(proposer.userId, reward.id),
    ).rejects.toThrow(ForbiddenException);
    expect(prisma.reward.update).not.toHaveBeenCalled();
  });

  it('charges sparks immediately when requesting a sparks reward', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst
      .mockResolvedValueOnce(proposer)
      .mockResolvedValueOnce(provider);
    prisma.reward.findFirst.mockResolvedValue(activeReward);
    prisma.memberProgress.findUnique.mockResolvedValue({
      memberId: proposer.id,
      sparks: 20,
      experience: 0,
    });
    prisma.rewardRequest.create.mockResolvedValue(request);

    await service.createRequest(proposer.userId, { rewardId: reward.id });

    expect(prisma.memberProgress.update).toHaveBeenCalledWith({
      where: { memberId: proposer.id },
      data: { sparks: { decrement: 10 } },
    });
    expect(prisma.sparkLedger.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        amount: -10,
        reason: 'reward.purchase',
      }),
    });
  });

  it('does not allow cancelling a confirmed reward request', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(proposer);
    prisma.rewardRequest.findFirst.mockResolvedValue({
      ...request,
      status: RewardRequestStatus.RECEIVED,
    });

    await expect(
      service.requestCancel(proposer.userId, request.id),
    ).rejects.toThrow(BadRequestException);
  });

  it('refunds sparks when cancel is approved', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(provider);
    prisma.rewardRequest.findFirst.mockResolvedValue(request);
    prisma.rewardRequest.update.mockResolvedValue({
      ...request,
      status: RewardRequestStatus.CANCELLED,
    });

    await service.respondCancel(provider.userId, request.id, { approve: true });

    expect(prisma.memberProgress.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: proposer.id },
        update: { sparks: { increment: 10 } },
      }),
    );
    expect(prisma.sparkLedger.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        amount: 10,
        reason: 'reward.refund',
      }),
    });
  });

  it('restores previous status when cancel is rejected', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(provider);
    prisma.rewardRequest.findFirst.mockResolvedValue({
      ...request,
      statusBeforeCancel: RewardRequestStatus.FULFILLED,
    });
    prisma.rewardRequest.update.mockResolvedValue({
      ...request,
      status: RewardRequestStatus.FULFILLED,
    });

    await service.respondCancel(provider.userId, request.id, {
      approve: false,
    });

    expect(prisma.rewardRequest.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          status: RewardRequestStatus.FULFILLED,
        }),
      }),
    );
  });
});
