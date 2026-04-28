import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { FamilyRole, TaskRecurrence, TaskStatus } from '@prisma/client';
import { TasksService } from './tasks.service';

describe('TasksService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const family = {
    id: 'family-1',
    name: 'Ochag',
    createdAt: now,
    updatedAt: now,
  };
  const ownerMember = {
    id: 'member-owner',
    familyId: family.id,
    userId: 'user-owner',
    role: FamilyRole.OWNER,
    createdAt: now,
    family,
  };
  const adultMember = {
    id: 'member-adult',
    familyId: family.id,
    userId: 'user-adult',
    role: FamilyRole.ADULT,
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
  const pendingTask = {
    id: 'task-1',
    familyId: family.id,
    title: 'Do it',
    description: null,
    status: TaskStatus.PENDING_CONFIRMATION,
    dueAt: null,
    assigneeId: childMember.userId,
    createdById: ownerMember.userId,
    rewardSparks: 5,
    rewardExperience: 7,
    submittedAt: now,
    confirmedAt: null,
    rejectedAt: null,
    deletedAt: null,
    recurrence: TaskRecurrence.NONE,
    recurringParentId: null,
    templateId: null,
    createdAt: now,
    updatedAt: now,
    assignee: null,
    createdBy: null,
    comments: [],
  };

  const createService = () => {
    const prisma = {
      familyMember: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
      },
      task: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      taskTemplate: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      taskComment: {
        create: jest.fn(),
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
      service: new TasksService(prisma as never),
      prisma,
    };
  };

  it('prevents children from creating tasks', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);

    await expect(
      service.createTask(childMember.userId, {
        title: 'Task',
        assigneeId: ownerMember.id,
      }),
    ).rejects.toThrow(ForbiddenException);
    expect(prisma.task.create).not.toHaveBeenCalled();
  });

  it('prevents task creator from being assignee', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(ownerMember);
    prisma.familyMember.findFirst.mockResolvedValueOnce(ownerMember);
    prisma.familyMember.findFirst.mockResolvedValueOnce({
      ...ownerMember,
      family: undefined,
    });

    await expect(
      service.createTask(ownerMember.userId, {
        title: 'Task',
        assigneeId: ownerMember.id,
      }),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.task.create).not.toHaveBeenCalled();
  });

  it('allows only assignee to submit a task', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.task.findFirst.mockResolvedValue({
      ...pendingTask,
      status: TaskStatus.ACTIVE,
      assigneeId: 'another-user',
    });

    await expect(
      service.submitTask(childMember.userId, pendingTask.id),
    ).rejects.toThrow(ForbiddenException);
    expect(prisma.task.update).not.toHaveBeenCalled();
  });

  it('approves task and writes progress plus ledgers', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(ownerMember);
    prisma.task.findFirst.mockResolvedValue(pendingTask);
    prisma.familyMember.findMany.mockResolvedValue([
      ownerMember,
      { ...childMember, family: undefined },
    ]);
    prisma.task.update.mockResolvedValue({
      ...pendingTask,
      status: TaskStatus.CONFIRMED,
    });

    await service.approveTask(ownerMember.userId, pendingTask.id);

    expect(prisma.memberProgress.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { memberId: childMember.id },
        update: {
          sparks: { increment: pendingTask.rewardSparks },
          experience: { increment: pendingTask.rewardExperience },
        },
      }),
    );
    expect(prisma.sparkLedger.create).toHaveBeenCalled();
    expect(prisma.experienceLedger.create).toHaveBeenCalled();
  });

  it('allows child reviewer for adult task when family has only one adult', async () => {
    const { service, prisma } = createService();
    const adultTask = {
      ...pendingTask,
      assigneeId: adultMember.userId,
      createdById: adultMember.userId,
    };
    prisma.familyMember.findFirst.mockResolvedValue(childMember);
    prisma.task.findFirst.mockResolvedValue(adultTask);
    prisma.familyMember.findMany.mockResolvedValue([
      { ...adultMember, family: undefined },
      { ...childMember, family: undefined },
    ]);
    prisma.task.update.mockResolvedValue({
      ...adultTask,
      status: TaskStatus.CONFIRMED,
    });

    await service.approveTask(childMember.userId, adultTask.id);

    expect(prisma.task.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: adultTask.id },
      }),
    );
  });
});
