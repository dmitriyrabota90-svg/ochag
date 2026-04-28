import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  FamilyMember,
  FamilyRole,
  Prisma,
  RewardPaymentMode,
  RewardRequestStatus,
  RewardStatus,
} from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { CancelRespondDto } from './dto/cancel-respond.dto';
import { CreateRewardRequestDto } from './dto/create-reward-request.dto';
import { CreateRewardTemplateDto } from './dto/create-reward-template.dto';
import { CreateRewardDto } from './dto/create-reward.dto';
import { RepriceRewardDto } from './dto/reprice-reward.dto';
import { UpdateRewardTemplateDto } from './dto/update-reward-template.dto';

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  };
};

@Injectable()
export class RewardsService {
  constructor(private readonly prisma: PrismaService) {}

  async listRewards(userId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return this.prisma.reward.findMany({
      where: { familyId: membership.familyId },
      include: this.rewardInclude(),
      orderBy: { createdAt: 'desc' },
    });
  }

  async getReward(userId: string, rewardId: string) {
    const membership = await this.requireCurrentMembership(userId);
    return this.requireReward(membership.familyId, rewardId);
  }

  async createReward(userId: string, dto: CreateRewardDto) {
    const membership = await this.requireCurrentMembership(userId);

    return this.prisma.$transaction(async (tx) => {
      const reward = await tx.reward.create({
        data: {
          familyId: membership.familyId,
          createdById: userId,
          title: this.normalizeText(dto.title, 'Reward title'),
          description: this.normalizeOptionalText(dto.description),
          pointsCost: dto.pointsCost ?? 0,
          paymentMode: dto.paymentMode ?? RewardPaymentMode.SPARKS,
          status: RewardStatus.PROPOSED,
        },
        include: this.rewardInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward.proposed',
        {
          rewardId: reward.id,
        },
      );

      return reward;
    });
  }

  async approveReward(userId: string, rewardId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const reward = await this.requireReward(membership.familyId, rewardId);
    this.assertCanReviewReward(reward, userId);

    return this.prisma.$transaction(async (tx) => {
      const approved = await tx.reward.update({
        where: { id: reward.id },
        data: {
          status: RewardStatus.ACTIVE,
          approvedById: userId,
          approvedAt: new Date(),
        },
        include: this.rewardInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward.approved',
        {
          rewardId: reward.id,
          pointsCost: reward.pointsCost,
        },
      );

      return approved;
    });
  }

  async repriceReward(userId: string, rewardId: string, dto: RepriceRewardDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const reward = await this.requireReward(membership.familyId, rewardId);
    this.assertCanReviewReward(reward, userId);

    return this.prisma.$transaction(async (tx) => {
      const repriced = await tx.reward.update({
        where: { id: reward.id },
        data: {
          pointsCost: dto.pointsCost,
          status: RewardStatus.ACTIVE,
          approvedById: userId,
          approvedAt: new Date(),
        },
        include: this.rewardInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward.repriced',
        {
          rewardId: reward.id,
          pointsCost: dto.pointsCost,
        },
      );

      return repriced;
    });
  }

  async rejectReward(userId: string, rewardId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const reward = await this.requireReward(membership.familyId, rewardId);
    this.assertCanReviewReward(reward, userId);

    return this.prisma.$transaction(async (tx) => {
      const rejected = await tx.reward.update({
        where: { id: reward.id },
        data: {
          status: RewardStatus.REJECTED,
          rejectedAt: new Date(),
        },
        include: this.rewardInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward.rejected',
        {
          rewardId: reward.id,
        },
      );

      return rejected;
    });
  }

  async listTemplates(userId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return this.prisma.rewardTemplate.findMany({
      where: { familyId: membership.familyId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createTemplate(userId: string, dto: CreateRewardTemplateDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    return this.prisma.$transaction(async (tx) => {
      const template = await tx.rewardTemplate.create({
        data: {
          familyId: membership.familyId,
          createdById: userId,
          title: this.normalizeText(dto.title, 'Reward template title'),
          description: this.normalizeOptionalText(dto.description),
          pointsCost: dto.pointsCost ?? 0,
          paymentMode: dto.paymentMode ?? RewardPaymentMode.SPARKS,
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_template.created',
        {
          templateId: template.id,
        },
      );

      return template;
    });
  }

  async updateTemplate(
    userId: string,
    templateId: string,
    dto: UpdateRewardTemplateDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const template = await this.prisma.rewardTemplate.findFirst({
      where: { id: templateId, familyId: membership.familyId },
    });
    if (!template) {
      throw new NotFoundException('Reward template not found');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.rewardTemplate.update({
        where: { id: templateId },
        data: {
          ...(dto.title !== undefined
            ? { title: this.normalizeText(dto.title, 'Reward template title') }
            : {}),
          ...(dto.description !== undefined
            ? { description: this.normalizeOptionalText(dto.description) }
            : {}),
          ...(dto.pointsCost !== undefined
            ? { pointsCost: dto.pointsCost }
            : {}),
          ...(dto.paymentMode !== undefined
            ? { paymentMode: dto.paymentMode }
            : {}),
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_template.updated',
        {
          templateId,
        },
      );

      return updated;
    });
  }

  async createRequest(userId: string, dto: CreateRewardRequestDto) {
    const membership = await this.requireCurrentMembership(userId);
    const reward = await this.requireReward(membership.familyId, dto.rewardId);
    if (reward.status !== RewardStatus.ACTIVE || !reward.approvedById) {
      throw new BadRequestException('Reward is not active');
    }

    const provider = await this.requireMemberByUserId(
      membership.familyId,
      reward.approvedById,
    );
    const levelSnapshot = await this.getCurrentLevel(membership.id);

    return this.prisma.$transaction(async (tx) => {
      if (reward.paymentMode === RewardPaymentMode.SPARKS) {
        await this.chargeSparks(tx, membership, reward.pointsCost);
      } else {
        await this.assertLevelFreeAvailable(
          membership.id,
          reward.id,
          levelSnapshot,
        );
      }

      const request = await tx.rewardRequest.create({
        data: {
          familyId: membership.familyId,
          rewardId: reward.id,
          requesterMemberId: membership.id,
          providerMemberId: provider.id,
          status: RewardRequestStatus.IN_PROGRESS,
          paymentMode: reward.paymentMode,
          sparksCost:
            reward.paymentMode === RewardPaymentMode.SPARKS
              ? reward.pointsCost
              : 0,
          levelSnapshot:
            reward.paymentMode === RewardPaymentMode.LEVEL_FREE
              ? levelSnapshot
              : null,
        },
        include: this.requestInclude(),
      });

      if (reward.paymentMode === RewardPaymentMode.SPARKS) {
        await tx.sparkLedger.create({
          data: {
            familyId: membership.familyId,
            memberId: membership.id,
            rewardRequestId: request.id,
            amount: -reward.pointsCost,
            reason: 'reward.purchase',
          },
        });
      }

      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_request.created',
        {
          requestId: request.id,
          rewardId: reward.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: provider.userId,
        type: 'reward_request.created',
        title: 'Reward requested',
        body: reward.title,
        payload: { requestId: request.id, rewardId: reward.id },
      });

      return request;
    });
  }

  async getRequest(userId: string, requestId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const request = await this.requireRequest(membership.familyId, requestId);
    this.assertRequestParticipant(request, membership.id);

    return request;
  }

  async markFulfilled(userId: string, requestId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const request = await this.requireRequest(membership.familyId, requestId);
    if (request.providerMemberId !== membership.id) {
      throw new ForbiddenException('Only provider can mark reward fulfilled');
    }
    if (request.status !== RewardRequestStatus.IN_PROGRESS) {
      throw new BadRequestException(
        'Reward request cannot be marked fulfilled',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.rewardRequest.update({
        where: { id: request.id },
        data: {
          status: RewardRequestStatus.FULFILLED,
          fulfilledAt: new Date(),
        },
        include: this.requestInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_request.fulfilled',
        {
          requestId: request.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: request.requester.userId,
        type: 'reward_request.fulfilled',
        title: 'Reward fulfilled',
        body: request.reward.title,
        payload: { requestId: request.id, rewardId: request.rewardId },
      });

      return updated;
    });
  }

  async confirmReceived(userId: string, requestId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const request = await this.requireRequest(membership.familyId, requestId);
    if (request.requesterMemberId !== membership.id) {
      throw new ForbiddenException(
        'Only requester can confirm reward received',
      );
    }
    if (request.status !== RewardRequestStatus.FULFILLED) {
      throw new BadRequestException('Reward request is not fulfilled');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.rewardRequest.update({
        where: { id: request.id },
        data: {
          status: RewardRequestStatus.RECEIVED,
          receivedAt: new Date(),
        },
        include: this.requestInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_request.received',
        {
          requestId: request.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: request.provider.userId,
        type: 'reward_request.received',
        title: 'Reward completed',
        body: request.reward.title,
        payload: { requestId: request.id, rewardId: request.rewardId },
      });

      return updated;
    });
  }

  async requestCancel(userId: string, requestId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const request = await this.requireRequest(membership.familyId, requestId);
    this.assertRequestParticipant(request, membership.id);
    if (request.status === RewardRequestStatus.RECEIVED) {
      throw new BadRequestException(
        'Confirmed reward request cannot be cancelled',
      );
    }
    if (request.status === RewardRequestStatus.CANCEL_REQUESTED) {
      throw new BadRequestException('Cancel is already requested');
    }
    if (request.status === RewardRequestStatus.CANCELLED) {
      throw new BadRequestException('Reward request is already cancelled');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.rewardRequest.update({
        where: { id: request.id },
        data: {
          statusBeforeCancel: request.status,
          status: RewardRequestStatus.CANCEL_REQUESTED,
          cancelRequestedById: membership.id,
          cancelRequestedAt: new Date(),
        },
        include: this.requestInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_request.cancel_requested',
        {
          requestId: request.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: this.getOtherParticipantUserId(request, membership.id),
        type: 'reward_request.cancel_requested',
        title: 'Reward cancellation requested',
        body: request.reward.title,
        payload: { requestId: request.id, rewardId: request.rewardId },
      });

      return updated;
    });
  }

  async respondCancel(
    userId: string,
    requestId: string,
    dto: CancelRespondDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    const request = await this.requireRequest(membership.familyId, requestId);
    this.assertRequestParticipant(request, membership.id);
    if (request.status !== RewardRequestStatus.CANCEL_REQUESTED) {
      throw new BadRequestException('Cancel is not requested');
    }
    if (request.cancelRequestedById === membership.id) {
      throw new ForbiddenException('Cancel requester cannot respond');
    }

    return this.prisma.$transaction(async (tx) => {
      if (!dto.approve) {
        const restoredStatus =
          request.statusBeforeCancel ?? RewardRequestStatus.IN_PROGRESS;
        const updated = await tx.rewardRequest.update({
          where: { id: request.id },
          data: {
            status: restoredStatus,
            statusBeforeCancel: null,
            cancelRequestedById: null,
            cancelRequestedAt: null,
          },
          include: this.requestInclude(),
        });
        await this.createActivity(
          tx,
          membership.familyId,
          userId,
          'reward_request.cancel_rejected',
          {
            requestId: request.id,
          },
        );
        await this.createNotification(tx, {
          familyId: membership.familyId,
          userId: this.getCancelRequesterUserId(request),
          type: 'reward_request.cancel_rejected',
          title: 'Reward cancellation rejected',
          body: request.reward.title,
          payload: { requestId: request.id, rewardId: request.rewardId },
        });
        return updated;
      }

      if (
        request.paymentMode === RewardPaymentMode.SPARKS &&
        request.sparksCost > 0
      ) {
        await tx.memberProgress.upsert({
          where: { memberId: request.requesterMemberId },
          create: {
            familyId: membership.familyId,
            memberId: request.requesterMemberId,
            sparks: request.sparksCost,
            experience: 0,
          },
          update: {
            sparks: { increment: request.sparksCost },
          },
        });
        await tx.sparkLedger.create({
          data: {
            familyId: membership.familyId,
            memberId: request.requesterMemberId,
            rewardRequestId: request.id,
            amount: request.sparksCost,
            reason: 'reward.refund',
          },
        });
      }

      const updated = await tx.rewardRequest.update({
        where: { id: request.id },
        data: {
          status: RewardRequestStatus.CANCELLED,
          statusBeforeCancel: null,
          cancelledAt: new Date(),
        },
        include: this.requestInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'reward_request.cancel_approved',
        {
          requestId: request.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: this.getCancelRequesterUserId(request),
        type: 'reward_request.cancel_approved',
        title: 'Reward cancelled',
        body: request.reward.title,
        payload: { requestId: request.id, rewardId: request.rewardId },
      });

      return updated;
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

  private async requireReward(familyId: string, rewardId: string) {
    const reward = await this.prisma.reward.findFirst({
      where: { id: rewardId, familyId },
      include: this.rewardInclude(),
    });
    if (!reward) {
      throw new NotFoundException('Reward not found');
    }
    return reward;
  }

  private async requireRequest(familyId: string, requestId: string) {
    const request = await this.prisma.rewardRequest.findFirst({
      where: { id: requestId, familyId },
      include: this.requestInclude(),
    });
    if (!request) {
      throw new NotFoundException('Reward request not found');
    }
    return request;
  }

  private async requireMemberByUserId(familyId: string, userId: string) {
    const member = await this.prisma.familyMember.findFirst({
      where: { familyId, userId },
    });
    if (!member) {
      throw new NotFoundException('Family member not found');
    }
    return member;
  }

  private assertAdult(member: Pick<FamilyMember, 'role'>) {
    if (member.role !== FamilyRole.OWNER && member.role !== FamilyRole.ADULT) {
      throw new ForbiddenException('Adult permissions required');
    }
  }

  private assertCanReviewReward(
    reward: { createdById: string | null; status: RewardStatus },
    reviewerUserId: string,
  ) {
    if (reward.status !== RewardStatus.PROPOSED) {
      throw new BadRequestException('Reward is already finalized');
    }
    if (reward.createdById === reviewerUserId) {
      throw new ForbiddenException('Reward proposer cannot review own reward');
    }
  }

  private assertRequestParticipant(
    request: { requesterMemberId: string; providerMemberId: string },
    memberId: string,
  ) {
    if (
      request.requesterMemberId !== memberId &&
      request.providerMemberId !== memberId
    ) {
      throw new ForbiddenException(
        'Only request participants can access this request',
      );
    }
  }

  private async chargeSparks(
    tx: Prisma.TransactionClient,
    membership: FamilyMember,
    amount: number,
  ) {
    const progress = await tx.memberProgress.findUnique({
      where: { memberId: membership.id },
    });
    if (!progress || progress.sparks < amount) {
      throw new BadRequestException('Not enough sparks');
    }

    await tx.memberProgress.update({
      where: { memberId: membership.id },
      data: { sparks: { decrement: amount } },
    });
  }

  private async assertLevelFreeAvailable(
    memberId: string,
    rewardId: string,
    levelSnapshot: number,
  ) {
    const existing = await this.prisma.rewardRequest.findFirst({
      where: {
        rewardId,
        requesterMemberId: memberId,
        paymentMode: RewardPaymentMode.LEVEL_FREE,
        levelSnapshot,
        status: { not: RewardRequestStatus.CANCELLED },
      },
      select: { id: true },
    });
    if (existing) {
      throw new BadRequestException(
        'Level-free reward was already used for current level',
      );
    }
  }

  private async getCurrentLevel(memberId: string) {
    const progress = await this.prisma.memberProgress.findUnique({
      where: { memberId },
    });
    return Math.floor((progress?.experience ?? 0) / 100) + 1;
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

  private getOtherParticipantUserId(
    request: {
      requesterMemberId: string;
      providerMemberId: string;
      requester: { userId: string };
      provider: { userId: string };
    },
    currentMemberId: string,
  ) {
    return currentMemberId === request.requesterMemberId
      ? request.provider.userId
      : request.requester.userId;
  }

  private getCancelRequesterUserId(request: {
    cancelRequestedById: string | null;
    requesterMemberId: string;
    requester: { userId: string };
    provider: { userId: string };
  }) {
    return request.cancelRequestedById === request.requesterMemberId
      ? request.requester.userId
      : request.provider.userId;
  }

  private rewardInclude() {
    return {
      createdBy: {
        select: { id: true, email: true, displayName: true },
      },
      approvedBy: {
        select: { id: true, email: true, displayName: true },
      },
    } satisfies Prisma.RewardInclude;
  }

  private requestInclude() {
    return {
      reward: true,
      requester: {
        include: {
          user: {
            select: { id: true, email: true, displayName: true },
          },
        },
      },
      provider: {
        include: {
          user: {
            select: { id: true, email: true, displayName: true },
          },
        },
      },
    } satisfies Prisma.RewardRequestInclude;
  }
}
