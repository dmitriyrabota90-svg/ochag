import { Injectable, NotFoundException } from '@nestjs/common';
import { FamilyMember, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import {
  HistoryEntityType,
  ListHistoryQueryDto,
} from './dto/list-history-query.dto';

@Injectable()
export class HistoryService {
  private readonly defaultLimit = 30;

  constructor(private readonly prisma: PrismaService) {}

  async listHistory(userId: string, query: ListHistoryQueryDto) {
    const membership = await this.requireCurrentMembership(userId);
    const limit = query.limit ?? this.defaultLimit;
    const where: Prisma.HistoryEventWhereInput = {
      familyId: membership.familyId,
      ...(query.eventType ? { type: query.eventType } : {}),
      ...this.buildEntityFilter(query.entityType),
    };

    const events = await this.prisma.historyEvent.findMany({
      where,
      include: {
        actor: {
          select: {
            id: true,
            email: true,
            displayName: true,
          },
        },
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      ...(!query.cursor && query.page
        ? { skip: (query.page - 1) * limit }
        : {}),
    });

    const hasMore = events.length > limit;
    const items = events
      .slice(0, limit)
      .map((event) => this.toHistoryItem(event));

    return {
      items,
      pageInfo: {
        limit,
        page: query.cursor ? null : (query.page ?? 1),
        nextCursor: hasMore ? (items[items.length - 1]?.id ?? null) : null,
        hasMore,
      },
      filters: {
        eventType: query.eventType ?? null,
        entityType: query.entityType ?? null,
      },
    };
  }

  private async requireCurrentMembership(
    userId: string,
  ): Promise<FamilyMember> {
    const membership = await this.prisma.familyMember.findFirst({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });
    if (!membership) {
      throw new NotFoundException('Current family not found');
    }
    return membership;
  }

  private buildEntityFilter(entityType?: HistoryEntityType) {
    if (!entityType) {
      return {};
    }

    const prefixesByEntity: Record<HistoryEntityType, string[]> = {
      [HistoryEntityType.FAMILY]: ['family.'],
      [HistoryEntityType.TASK]: ['task.'],
      [HistoryEntityType.TASK_TEMPLATE]: ['task_template.'],
      [HistoryEntityType.INITIATIVE]: ['initiative_'],
      [HistoryEntityType.REWARD]: ['reward.'],
      [HistoryEntityType.REWARD_TEMPLATE]: ['reward_template.'],
      [HistoryEntityType.REWARD_REQUEST]: ['reward_request.'],
      [HistoryEntityType.FAMILY_GOAL]: ['family_goal_'],
    };

    return {
      OR: prefixesByEntity[entityType].map((prefix) => ({
        type: { startsWith: prefix },
      })),
    } satisfies Prisma.HistoryEventWhereInput;
  }

  private toHistoryItem(
    event: Prisma.HistoryEventGetPayload<{
      include: {
        actor: {
          select: {
            id: true;
            email: true;
            displayName: true;
          };
        };
      };
    }>,
  ) {
    const payload = this.sanitizePayload(
      event.type,
      this.toPayloadObject(event.payload),
    );
    const entity = this.resolveEntity(event.type, payload);

    return {
      id: event.id,
      eventType: event.type,
      entityType: entity.entityType,
      entityId: entity.entityId,
      occurredAt: event.createdAt,
      actor: event.actor
        ? {
            id: event.actor.id,
            email: event.actor.email,
            displayName: event.actor.displayName,
          }
        : null,
      summary: this.buildSummary(event.type, payload),
      payload,
    };
  }

  private toPayloadObject(payload: Prisma.JsonValue | null) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      return {};
    }
    return payload as Record<string, Prisma.JsonValue>;
  }

  private sanitizePayload(
    type: string,
    payload: Record<string, Prisma.JsonValue>,
  ) {
    if (!type.startsWith('family.invite.')) {
      return payload;
    }

    const { inviteCode: _inviteCode, ...safePayload } = payload;
    return safePayload;
  }

  private resolveEntity(
    type: string,
    payload: Record<string, Prisma.JsonValue>,
  ) {
    const entityType = this.resolveEntityType(type);
    const entityIdKeys: Record<string, string[]> = {
      family: ['familyId'],
      task: ['taskId'],
      task_template: ['templateId'],
      initiative: ['initiativeId'],
      reward: ['rewardId'],
      reward_template: ['templateId'],
      reward_request: ['requestId'],
      family_goal: ['goalId'],
    };
    const entityId = entityIdKeys[entityType]
      ?.map((key) => payload[key])
      .find((value): value is string => typeof value === 'string');

    return { entityType, entityId: entityId ?? null };
  }

  private resolveEntityType(type: string) {
    if (type.startsWith('family_goal_')) {
      return HistoryEntityType.FAMILY_GOAL;
    }
    if (type.startsWith('reward_request.')) {
      return HistoryEntityType.REWARD_REQUEST;
    }
    if (type.startsWith('reward_template.')) {
      return HistoryEntityType.REWARD_TEMPLATE;
    }
    if (type.startsWith('task_template.')) {
      return HistoryEntityType.TASK_TEMPLATE;
    }
    if (type.startsWith('initiative_')) {
      return HistoryEntityType.INITIATIVE;
    }
    if (type.startsWith('reward.')) {
      return HistoryEntityType.REWARD;
    }
    if (type.startsWith('task.')) {
      return HistoryEntityType.TASK;
    }
    if (type.startsWith('family.')) {
      return HistoryEntityType.FAMILY;
    }
    return 'unknown';
  }

  private buildSummary(
    type: string,
    payload: Record<string, Prisma.JsonValue>,
  ) {
    const labels: Record<string, string> = {
      'family.created': 'Family created',
      'family.updated': 'Family updated',
      'family.member.joined': 'Family member joined',
      'family.member.left': 'Family member left',
      'family.member.role_updated': 'Family member role updated',
      'family.member.removed': 'Family member removed',
      'family.creator.transferred': 'Family creator transferred',
      'family.invite.created': 'Family invite created',
      'family.invite.regenerated': 'Family invite regenerated',
      'family.delete.requested': 'Family delete requested',
      'family.delete.confirmed': 'Family delete confirmed',
      'task.created': 'Task created',
      'task.updated': 'Task updated',
      'task.deleted': 'Task deleted',
      'task.submitted': 'Task submitted',
      'task.approved': 'Task approved',
      'task.rejected': 'Task rejected',
      'task.commented': 'Task commented',
      'task.recurring.skipped': 'Recurring task skipped',
      'task.recurring.created': 'Recurring task created',
      'task_template.created': 'Task template created',
      'task_template.updated': 'Task template updated',
      initiative_submitted: 'Initiative submitted',
      initiative_approved: 'Initiative approved',
      initiative_approved_without_reward: 'Initiative approved without reward',
      initiative_rejected: 'Initiative rejected',
      'reward.proposed': 'Reward proposed',
      'reward.approved': 'Reward approved',
      'reward.repriced': 'Reward repriced',
      'reward.rejected': 'Reward rejected',
      'reward_template.created': 'Reward template created',
      'reward_template.updated': 'Reward template updated',
      'reward_request.created': 'Reward requested',
      'reward_request.fulfilled': 'Reward fulfilled',
      'reward_request.received': 'Reward received',
      'reward_request.cancel_requested': 'Reward cancel requested',
      'reward_request.cancel_rejected': 'Reward cancel rejected',
      'reward_request.cancel_approved': 'Reward cancel approved',
      family_goal_created: 'Family goal created',
      family_goal_updated: 'Family goal updated',
      family_goal_contributed: 'Family goal contribution added',
      family_goal_achieved: 'Family goal achieved',
      family_goal_completion_confirmed: 'Family goal completion confirmed',
      family_goal_completed: 'Family goal completed',
    };

    const base = labels[type] ?? this.humanizeType(type);
    const sparks = payload.sparks;
    const finalSparks = payload.finalSparks;
    const rewardSparks = payload.rewardSparks;
    if (typeof sparks === 'number') {
      return `${base}: ${sparks} sparks`;
    }
    if (typeof finalSparks === 'number') {
      return `${base}: ${finalSparks} sparks`;
    }
    if (typeof rewardSparks === 'number') {
      return `${base}: ${rewardSparks} sparks`;
    }
    return base;
  }

  private humanizeType(type: string) {
    return type
      .replace(/[._]/g, ' ')
      .replace(/\b\w/g, (letter) => letter.toUpperCase());
  }
}
