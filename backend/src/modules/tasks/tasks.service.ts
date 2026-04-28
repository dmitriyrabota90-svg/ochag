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
  TaskRecurrence,
  TaskStatus,
} from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { CreateTaskCommentDto } from './dto/create-task-comment.dto';
import { CreateTaskTemplateDto } from './dto/create-task-template.dto';
import { CreateTaskDto } from './dto/create-task.dto';
import { ListTasksQueryDto } from './dto/list-tasks-query.dto';
import { UpdateTaskTemplateDto } from './dto/update-task-template.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

type CurrentMembership = FamilyMember & {
  family: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  };
};

type TaskWithRelations = Prisma.TaskGetPayload<{
  include: {
    assignee: {
      select: {
        id: true;
        email: true;
        displayName: true;
      };
    };
    createdBy: {
      select: {
        id: true;
        email: true;
        displayName: true;
      };
    };
    comments: {
      include: {
        user: {
          select: {
            id: true;
            email: true;
            displayName: true;
          };
        };
      };
    };
  };
}>;

@Injectable()
export class TasksService {
  constructor(private readonly prisma: PrismaService) {}

  async listTasks(userId: string, query: ListTasksQueryDto) {
    const membership = await this.requireCurrentMembership(userId);
    await this.skipOverdueRecurringTasks(membership.familyId);

    return this.prisma.task.findMany({
      where: {
        familyId: membership.familyId,
        deletedAt: null,
        ...(query.includeHistory
          ? {}
          : {
              status: {
                in: [TaskStatus.ACTIVE, TaskStatus.PENDING_CONFIRMATION],
              },
            }),
      },
      include: this.taskInclude(),
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async getTask(userId: string, taskId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const task = await this.requireTask(membership.familyId, taskId);

    return task;
  }

  async createTask(userId: string, dto: CreateTaskDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    const assignee = await this.requireFamilyMember(
      membership.familyId,
      dto.assigneeId,
    );
    this.assertCreatorIsNotAssignee(userId, assignee.userId);

    if (dto.templateId) {
      await this.requireTemplate(membership.familyId, dto.templateId);
    }

    const task = await this.prisma.$transaction(async (tx) => {
      const createdTask = await tx.task.create({
        data: {
          familyId: membership.familyId,
          title: this.normalizeText(dto.title, 'Task title'),
          description: this.normalizeOptionalText(dto.description),
          assigneeId: assignee.userId,
          createdById: userId,
          dueAt: dto.dueAt ? new Date(dto.dueAt) : null,
          rewardSparks: dto.rewardSparks ?? 0,
          rewardExperience: dto.rewardExperience ?? 0,
          recurrence: dto.recurrence ?? TaskRecurrence.NONE,
          templateId: dto.templateId ?? null,
        },
        include: this.taskInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.created',
        {
          taskId: createdTask.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: assignee.userId,
        type: 'task.created',
        title: 'New task',
        body: createdTask.title,
        payload: { taskId: createdTask.id },
      });

      return createdTask;
    });

    return task;
  }

  async updateTask(userId: string, taskId: string, dto: UpdateTaskDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const task = await this.requireTask(membership.familyId, taskId);
    this.assertTaskCreator(task, userId);
    this.assertTaskMutable(task);

    let assigneeUserId: string | null | undefined;
    if (dto.assigneeId) {
      const assignee = await this.requireFamilyMember(
        membership.familyId,
        dto.assigneeId,
      );
      this.assertCreatorIsNotAssignee(userId, assignee.userId);
      assigneeUserId = assignee.userId;
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedTask = await tx.task.update({
        where: { id: task.id },
        data: {
          ...(dto.title !== undefined
            ? { title: this.normalizeText(dto.title, 'Task title') }
            : {}),
          ...(dto.description !== undefined
            ? { description: this.normalizeOptionalText(dto.description) }
            : {}),
          ...(assigneeUserId !== undefined
            ? { assigneeId: assigneeUserId }
            : {}),
          ...(dto.dueAt !== undefined
            ? { dueAt: dto.dueAt ? new Date(dto.dueAt) : null }
            : {}),
          ...(dto.rewardSparks !== undefined
            ? { rewardSparks: dto.rewardSparks }
            : {}),
          ...(dto.rewardExperience !== undefined
            ? { rewardExperience: dto.rewardExperience }
            : {}),
          ...(dto.recurrence !== undefined
            ? { recurrence: dto.recurrence }
            : {}),
        },
        include: this.taskInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.updated',
        {
          taskId: task.id,
        },
      );

      return updatedTask;
    });
  }

  async deleteTask(userId: string, taskId: string) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    const task = await this.requireTask(membership.familyId, taskId);
    this.assertTaskCreator(task, userId);

    if (task.status === TaskStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException(
        'Pending confirmation task cannot be deleted',
      );
    }
    if (task.status === TaskStatus.CONFIRMED) {
      throw new BadRequestException('Confirmed task cannot be deleted');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.task.update({
        where: { id: task.id },
        data: {
          status: TaskStatus.CANCELLED,
          deletedAt: new Date(),
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.deleted',
        {
          taskId: task.id,
        },
      );
    });

    return { success: true };
  }

  async submitTask(userId: string, taskId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const task = await this.requireTask(membership.familyId, taskId);

    if (task.assigneeId !== userId) {
      throw new ForbiddenException('Only assignee can submit a task');
    }
    if (task.status !== TaskStatus.ACTIVE) {
      throw new BadRequestException('Only active task can be submitted');
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedTask = await tx.task.update({
        where: { id: task.id },
        data: {
          status: TaskStatus.PENDING_CONFIRMATION,
          submittedAt: new Date(),
        },
        include: this.taskInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.submitted',
        {
          taskId: task.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: task.createdById,
        type: 'task.submitted',
        title: 'Task submitted',
        body: task.title,
        payload: { taskId: task.id },
      });

      return updatedTask;
    });
  }

  async approveTask(userId: string, taskId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const task = await this.requireTask(membership.familyId, taskId);
    const members = await this.getFamilyMembers(membership.familyId);
    this.assertTaskPending(task);
    this.assertReviewerAllowed(task, membership, members);

    const assignee = members.find(
      (member) => member.userId === task.assigneeId,
    );
    if (!assignee) {
      throw new NotFoundException('Task assignee is not a family member');
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedTask = await tx.task.update({
        where: { id: task.id },
        data: {
          status: TaskStatus.CONFIRMED,
          confirmedAt: new Date(),
        },
        include: this.taskInclude(),
      });

      await tx.memberProgress.upsert({
        where: { memberId: assignee.id },
        create: {
          familyId: membership.familyId,
          memberId: assignee.id,
          sparks: task.rewardSparks,
          experience: task.rewardExperience,
        },
        update: {
          sparks: { increment: task.rewardSparks },
          experience: { increment: task.rewardExperience },
        },
      });
      await tx.sparkLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: assignee.id,
          taskId: task.id,
          amount: task.rewardSparks,
          reason: 'task.approved',
        },
      });
      await tx.experienceLedger.create({
        data: {
          familyId: membership.familyId,
          memberId: assignee.id,
          taskId: task.id,
          amount: task.rewardExperience,
          reason: 'task.approved',
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.approved',
        {
          taskId: task.id,
          assigneeMemberId: assignee.id,
          rewardSparks: task.rewardSparks,
          rewardExperience: task.rewardExperience,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: assignee.userId,
        type: 'task.approved',
        title: 'Task approved',
        body: task.title,
        payload: {
          taskId: task.id,
          rewardSparks: task.rewardSparks,
          rewardExperience: task.rewardExperience,
        },
      });

      await this.createNextRecurringTask(tx, task);

      return updatedTask;
    });
  }

  async rejectTask(userId: string, taskId: string) {
    const membership = await this.requireCurrentMembership(userId);
    const task = await this.requireTask(membership.familyId, taskId);
    const members = await this.getFamilyMembers(membership.familyId);
    this.assertTaskPending(task);
    this.assertReviewerAllowed(task, membership, members);

    return this.prisma.$transaction(async (tx) => {
      const updatedTask = await tx.task.update({
        where: { id: task.id },
        data: {
          status: TaskStatus.ACTIVE,
          rejectedAt: new Date(),
          submittedAt: null,
        },
        include: this.taskInclude(),
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.rejected',
        {
          taskId: task.id,
        },
      );
      await this.createNotification(tx, {
        familyId: membership.familyId,
        userId: task.assigneeId,
        type: 'task.rejected',
        title: 'Task returned',
        body: task.title,
        payload: { taskId: task.id },
      });

      return updatedTask;
    });
  }

  async createComment(
    userId: string,
    taskId: string,
    dto: CreateTaskCommentDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    const task = await this.requireTask(membership.familyId, taskId);

    return this.prisma.$transaction(async (tx) => {
      const comment = await tx.taskComment.create({
        data: {
          taskId: task.id,
          userId,
          body: this.normalizeText(dto.body, 'Comment'),
        },
        include: {
          user: {
            select: {
              id: true,
              email: true,
              displayName: true,
            },
          },
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task.commented',
        {
          taskId: task.id,
          commentId: comment.id,
        },
      );

      return comment;
    });
  }

  async listTemplates(userId: string) {
    const membership = await this.requireCurrentMembership(userId);

    return this.prisma.taskTemplate.findMany({
      where: { familyId: membership.familyId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createTemplate(userId: string, dto: CreateTaskTemplateDto) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);

    return this.prisma.$transaction(async (tx) => {
      const template = await tx.taskTemplate.create({
        data: {
          familyId: membership.familyId,
          createdById: userId,
          title: this.normalizeText(dto.title, 'Template title'),
          description: this.normalizeOptionalText(dto.description),
          rewardSparks: dto.rewardSparks ?? 0,
          rewardExperience: dto.rewardExperience ?? 0,
          recurrence: dto.recurrence ?? TaskRecurrence.NONE,
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task_template.created',
        { templateId: template.id },
      );

      return template;
    });
  }

  async updateTemplate(
    userId: string,
    templateId: string,
    dto: UpdateTaskTemplateDto,
  ) {
    const membership = await this.requireCurrentMembership(userId);
    this.assertAdult(membership);
    await this.requireTemplate(membership.familyId, templateId);

    return this.prisma.$transaction(async (tx) => {
      const template = await tx.taskTemplate.update({
        where: { id: templateId },
        data: {
          ...(dto.title !== undefined
            ? { title: this.normalizeText(dto.title, 'Template title') }
            : {}),
          ...(dto.description !== undefined
            ? { description: this.normalizeOptionalText(dto.description) }
            : {}),
          ...(dto.rewardSparks !== undefined
            ? { rewardSparks: dto.rewardSparks }
            : {}),
          ...(dto.rewardExperience !== undefined
            ? { rewardExperience: dto.rewardExperience }
            : {}),
          ...(dto.recurrence !== undefined
            ? { recurrence: dto.recurrence }
            : {}),
        },
      });
      await this.createActivity(
        tx,
        membership.familyId,
        userId,
        'task_template.updated',
        { templateId: template.id },
      );

      return template;
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

  private async requireTask(familyId: string, taskId: string) {
    const task = await this.prisma.task.findFirst({
      where: {
        id: taskId,
        familyId,
        deletedAt: null,
      },
      include: this.taskInclude(),
    });
    if (!task) {
      throw new NotFoundException('Task not found');
    }

    return task;
  }

  private async requireFamilyMember(familyId: string, memberId: string) {
    const member = await this.prisma.familyMember.findFirst({
      where: { id: memberId, familyId },
    });
    if (!member) {
      throw new NotFoundException('Family member not found');
    }

    return member;
  }

  private async requireTemplate(familyId: string, templateId: string) {
    const template = await this.prisma.taskTemplate.findFirst({
      where: { id: templateId, familyId },
    });
    if (!template) {
      throw new NotFoundException('Task template not found');
    }

    return template;
  }

  private getFamilyMembers(familyId: string) {
    return this.prisma.familyMember.findMany({ where: { familyId } });
  }

  private assertAdult(member: Pick<FamilyMember, 'role'>) {
    if (member.role !== FamilyRole.OWNER && member.role !== FamilyRole.ADULT) {
      throw new ForbiddenException('Adult permissions required');
    }
  }

  private assertCreatorIsNotAssignee(
    creatorUserId: string,
    assigneeUserId: string,
  ) {
    if (creatorUserId === assigneeUserId) {
      throw new BadRequestException('Task creator cannot be assignee');
    }
  }

  private assertTaskCreator(
    task: { createdById: string | null },
    userId: string,
  ) {
    if (task.createdById !== userId) {
      throw new ForbiddenException('Only task creator can change this task');
    }
  }

  private assertTaskMutable(task: { status: TaskStatus }) {
    if (task.status === TaskStatus.CONFIRMED) {
      throw new BadRequestException('Confirmed task cannot be changed');
    }
    if (task.status === TaskStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException(
        'Pending confirmation task cannot be changed',
      );
    }
  }

  private assertTaskPending(task: { status: TaskStatus }) {
    if (task.status !== TaskStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException('Task is not pending confirmation');
    }
  }

  private assertReviewerAllowed(
    task: { assigneeId: string | null; createdById: string | null },
    reviewer: FamilyMember,
    members: FamilyMember[],
  ) {
    if (task.assigneeId === reviewer.userId) {
      throw new ForbiddenException('Assignee cannot review own task');
    }

    if (
      this.isAdultRole(reviewer.role) &&
      task.createdById === reviewer.userId
    ) {
      return;
    }

    const adultMembers = members.filter((member) =>
      this.isAdultRole(member.role),
    );
    const assigneeMember = members.find(
      (member) => member.userId === task.assigneeId,
    );
    if (
      adultMembers.length === 1 &&
      reviewer.role === FamilyRole.CHILD &&
      assigneeMember &&
      this.isAdultRole(assigneeMember.role)
    ) {
      return;
    }

    throw new ForbiddenException('Reviewer is not allowed for this task');
  }

  private isAdultRole(role: FamilyRole) {
    return role === FamilyRole.OWNER || role === FamilyRole.ADULT;
  }

  private async skipOverdueRecurringTasks(familyId: string) {
    const overdueTasks = await this.prisma.task.findMany({
      where: {
        familyId,
        deletedAt: null,
        status: TaskStatus.ACTIVE,
        recurrence: { not: TaskRecurrence.NONE },
        dueAt: { lt: new Date() },
      },
    });

    for (const task of overdueTasks) {
      await this.prisma.$transaction(async (tx) => {
        await tx.task.update({
          where: { id: task.id },
          data: { status: TaskStatus.SKIPPED },
        });
        await this.createActivity(
          tx,
          familyId,
          null,
          'task.recurring.skipped',
          {
            taskId: task.id,
          },
        );
      });
    }
  }

  private async createNextRecurringTask(
    tx: Prisma.TransactionClient,
    task: {
      id: string;
      familyId: string;
      title: string;
      description: string | null;
      assigneeId: string | null;
      createdById: string | null;
      rewardSparks: number;
      rewardExperience: number;
      recurrence: TaskRecurrence;
      dueAt: Date | null;
      recurringParentId: string | null;
      templateId: string | null;
    },
  ) {
    const nextDueAt = this.getNextDueAt(task.recurrence, task.dueAt);
    if (!nextDueAt) {
      return;
    }

    const nextTask = await tx.task.create({
      data: {
        familyId: task.familyId,
        title: task.title,
        description: task.description,
        assigneeId: task.assigneeId,
        createdById: task.createdById,
        rewardSparks: task.rewardSparks,
        rewardExperience: task.rewardExperience,
        recurrence: task.recurrence,
        dueAt: nextDueAt,
        recurringParentId: task.recurringParentId ?? task.id,
        templateId: task.templateId,
      },
    });
    await this.createActivity(
      tx,
      task.familyId,
      task.createdById,
      'task.recurring.created',
      {
        taskId: nextTask.id,
        parentTaskId: task.id,
      },
    );
  }

  private getNextDueAt(recurrence: TaskRecurrence, dueAt: Date | null) {
    if (recurrence === TaskRecurrence.NONE) {
      return null;
    }

    const base = dueAt ? new Date(dueAt) : new Date();
    const days = recurrence === TaskRecurrence.WEEKLY ? 7 : 1;
    base.setDate(base.getDate() + days);
    return base;
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

  private taskInclude() {
    return {
      assignee: {
        select: {
          id: true,
          email: true,
          displayName: true,
        },
      },
      createdBy: {
        select: {
          id: true,
          email: true,
          displayName: true,
        },
      },
      comments: {
        include: {
          user: {
            select: {
              id: true,
              email: true,
              displayName: true,
            },
          },
        },
        orderBy: { createdAt: 'asc' as const },
      },
    } satisfies Prisma.TaskInclude;
  }
}
