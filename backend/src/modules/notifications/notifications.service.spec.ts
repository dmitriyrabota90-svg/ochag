import { NotFoundException } from '@nestjs/common';
import { FamilyRole, NotificationStatus } from '@prisma/client';
import { NotificationsService } from './notifications.service';

describe('NotificationsService', () => {
  const now = new Date('2026-04-28T07:00:00.000Z');
  const membership = {
    id: 'member-1',
    familyId: 'family-1',
    userId: 'user-1',
    role: FamilyRole.OWNER,
    createdAt: now,
  };
  const unreadNotification = {
    id: 'notification-1',
    familyId: membership.familyId,
    userId: membership.userId,
    type: 'task.created',
    title: 'New task',
    body: 'Do it',
    payload: { taskId: 'task-1' },
    status: NotificationStatus.PENDING,
    createdAt: now,
    readAt: null,
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
      },
      notification: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
    };

    return {
      service: new NotificationsService(prisma as never),
      prisma,
    };
  };

  it('lists current user notifications with cursor pagination shape', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.notification.findMany.mockResolvedValue([
      unreadNotification,
      { ...unreadNotification, id: 'notification-extra' },
    ]);

    const result = await service.listNotifications('user-1', {
      cursor: 'notification-cursor',
      limit: 1,
    });

    expect(prisma.notification.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          userId: 'user-1',
          familyId: membership.familyId,
        },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: 2,
        cursor: { id: 'notification-cursor' },
        skip: 1,
      }),
    );
    expect(result.items).toEqual([
      {
        id: 'notification-1',
        type: 'task.created',
        title: 'New task',
        body: 'Do it',
        payload: { taskId: 'task-1' },
        status: 'unread',
        readAt: null,
        createdAt: now,
      },
    ]);
    expect(result.pageInfo).toEqual({
      limit: 1,
      page: null,
      nextCursor: 'notification-1',
      hasMore: true,
    });
  });

  it('marks notification as read for current user', async () => {
    const { service, prisma } = createService();
    const readAt = new Date('2026-04-28T07:01:00.000Z');
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.notification.findFirst.mockResolvedValue(unreadNotification);
    prisma.notification.update.mockResolvedValue({
      ...unreadNotification,
      status: NotificationStatus.READ,
      readAt,
    });

    const result = await service.markRead('user-1', unreadNotification.id);

    expect(prisma.notification.update).toHaveBeenCalledWith({
      where: { id: unreadNotification.id },
      data: {
        status: NotificationStatus.READ,
        readAt: expect.any(Date),
      },
    });
    expect(result.status).toBe('read');
    expect(result.readAt).toBe(readAt);
  });

  it('is idempotent when notification is already read', async () => {
    const { service, prisma } = createService();
    const readAt = new Date('2026-04-28T07:01:00.000Z');
    prisma.familyMember.findFirst.mockResolvedValue(membership);
    prisma.notification.findFirst.mockResolvedValue({
      ...unreadNotification,
      status: NotificationStatus.READ,
      readAt,
    });

    const result = await service.markRead('user-1', unreadNotification.id);

    expect(prisma.notification.update).not.toHaveBeenCalled();
    expect(result.status).toBe('read');
    expect(result.readAt).toBe(readAt);
  });

  it('blocks users without a current family', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(null);

    await expect(service.listNotifications('user-1', {})).rejects.toThrow(
      NotFoundException,
    );
    expect(prisma.notification.findMany).not.toHaveBeenCalled();
  });
});
