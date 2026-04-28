import { Injectable, NotFoundException } from '@nestjs/common';
import {
  FamilyMember,
  Notification,
  NotificationStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';

@Injectable()
export class NotificationsService {
  private readonly defaultLimit = 30;

  constructor(private readonly prisma: PrismaService) {}

  async listNotifications(userId: string, query: ListNotificationsQueryDto) {
    const membership = await this.requireCurrentMembership(userId);
    const limit = query.limit ?? this.defaultLimit;

    const notifications = await this.prisma.notification.findMany({
      where: {
        userId,
        familyId: membership.familyId,
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      ...(!query.cursor && query.page
        ? { skip: (query.page - 1) * limit }
        : {}),
    });

    const hasMore = notifications.length > limit;
    const items = notifications
      .slice(0, limit)
      .map((notification) => this.toNotificationResponse(notification));

    return {
      items,
      pageInfo: {
        limit,
        page: query.cursor ? null : (query.page ?? 1),
        nextCursor: hasMore ? (items[items.length - 1]?.id ?? null) : null,
        hasMore,
      },
    };
  }

  async markRead(userId: string, notificationId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const notification = await this.prisma.notification.findFirst({
      where: {
        id: notificationId,
        userId,
        familyId: membership.familyId,
      },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    if (notification.readAt) {
      return this.toNotificationResponse(notification);
    }

    const updated = await this.prisma.notification.update({
      where: { id: notification.id },
      data: {
        status: NotificationStatus.READ,
        readAt: new Date(),
      },
    });

    return this.toNotificationResponse(updated);
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

  private toNotificationResponse(notification: Notification) {
    return {
      id: notification.id,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      payload: this.toPayloadObject(notification.payload),
      status: notification.readAt ? 'read' : 'unread',
      readAt: notification.readAt,
      createdAt: notification.createdAt,
    };
  }

  private toPayloadObject(payload: Prisma.JsonValue | null) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      return {};
    }
    return payload as Record<string, Prisma.JsonValue>;
  }
}
