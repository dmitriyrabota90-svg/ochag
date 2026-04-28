import { NotFoundException } from '@nestjs/common';
import { FamilyRole } from '@prisma/client';
import { HistoryEntityType } from './dto/list-history-query.dto';
import { HistoryService } from './history.service';

describe('HistoryService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const membership = {
    id: 'member-1',
    familyId: 'family-1',
    userId: 'user-1',
    role: FamilyRole.OWNER,
    createdAt: now,
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
      },
      historyEvent: {
        findMany: jest.fn(),
      },
    };

    return {
      service: new HistoryService(prisma as never),
      prisma,
    };
  };

  it('returns current family history with mobile-friendly shape', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.historyEvent.findMany.mockResolvedValue([
      {
        id: 'event-2',
        familyId: membership.familyId,
        actorId: 'user-1',
        type: 'task.approved',
        payload: { taskId: 'task-1', rewardSparks: 5 },
        createdAt: now,
        actor: {
          id: 'user-1',
          email: 'adult@example.com',
          displayName: 'Adult',
        },
      },
    ]);

    const result = await service.listHistory('user-1', {});

    expect(prisma.historyEvent.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { familyId: membership.familyId },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: 31,
      }),
    );
    expect(result.items).toEqual([
      expect.objectContaining({
        id: 'event-2',
        eventType: 'task.approved',
        entityType: HistoryEntityType.TASK,
        entityId: 'task-1',
        summary: 'Task approved: 5 sparks',
        actor: expect.objectContaining({ email: 'adult@example.com' }),
      }),
    ]);
    expect(result.pageInfo).toEqual({
      limit: 30,
      page: 1,
      nextCursor: null,
      hasMore: false,
    });
  });

  it('supports cursor pagination and event/entity filters', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.historyEvent.findMany.mockResolvedValue([
      {
        id: 'event-1',
        familyId: membership.familyId,
        actorId: null,
        type: 'family_goal_completed',
        payload: { goalId: 'goal-1' },
        createdAt: now,
        actor: null,
      },
      {
        id: 'extra-event',
        familyId: membership.familyId,
        actorId: null,
        type: 'family_goal_updated',
        payload: { goalId: 'goal-1' },
        createdAt: now,
        actor: null,
      },
    ]);

    const result = await service.listHistory('user-1', {
      cursor: 'cursor-event',
      limit: 1,
      eventType: 'family_goal_completed',
      entityType: HistoryEntityType.FAMILY_GOAL,
    });

    expect(prisma.historyEvent.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          familyId: membership.familyId,
          type: 'family_goal_completed',
          OR: [{ type: { startsWith: 'family_goal_' } }],
        }),
        cursor: { id: 'cursor-event' },
        skip: 1,
        take: 2,
      }),
    );
    expect(result.items).toHaveLength(1);
    expect(result.items[0]).toEqual(
      expect.objectContaining({
        entityType: HistoryEntityType.FAMILY_GOAL,
        entityId: 'goal-1',
      }),
    );
    expect(result.pageInfo.nextCursor).toBe('event-1');
    expect(result.pageInfo.hasMore).toBe(true);
  });

  it('blocks users without a current family', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(null);

    await expect(service.listHistory('user-1', {})).rejects.toThrow(
      NotFoundException,
    );
    expect(prisma.historyEvent.findMany).not.toHaveBeenCalled();
  });
});
