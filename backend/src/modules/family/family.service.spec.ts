import { BadRequestException } from '@nestjs/common';
import { FamilyRole } from '@prisma/client';
import { FamilyService } from './family.service';

describe('FamilyService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const family = {
    id: 'family-1',
    name: 'Ochag',
    inviteCode: 'INVITE1',
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
  };
  const childMember = {
    id: 'member-child',
    familyId: family.id,
    userId: 'user-child',
    role: FamilyRole.CHILD,
    createdAt: now,
  };

  const createService = () => {
    const prisma = {
      family: {
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      familyMember: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      historyEvent: {
        create: jest.fn(),
      },
      user: {
        findUnique: jest.fn(),
      },
      familyDeleteRequest: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      $transaction: jest.fn(async (handler: (tx: unknown) => unknown) =>
        handler(prisma),
      ),
    };
    const configService = {
      get: jest.fn((key: string, fallback?: unknown) => fallback),
    };
    const familyMailService = {
      sendDeleteConfirmation: jest.fn().mockResolvedValue({ accepted: true }),
    };

    return {
      service: new FamilyService(
        prisma as never,
        configService as never,
        familyMailService as never,
      ),
      prisma,
    };
  };

  it('returns invite code without a backend localhost link by default', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(ownerMember);

    const result = await service.createInviteLink(ownerMember.userId);

    expect(result).toEqual({
      inviteCode: family.inviteCode,
      inviteLink: null,
    });
  });

  it('uses public invite base url when it is configured', async () => {
    const { service, prisma } = createService();
    const configService = (
      service as unknown as {
        configService: { get: jest.Mock };
      }
    ).configService;
    configService.get.mockImplementation((key: string, fallback?: unknown) =>
      key === 'app.invitePublicBaseUrl'
        ? 'https://ochag.example/app/'
        : fallback,
    );
    prisma.familyMember.findFirst.mockResolvedValue(ownerMember);

    const result = await service.createInviteLink(ownerMember.userId);

    expect(result).toEqual({
      inviteCode: family.inviteCode,
      inviteLink: `https://ochag.example/app/join-family?code=${family.inviteCode}`,
    });
  });

  it('prevents creator from leaving when other members remain', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(ownerMember);
    prisma.familyMember.findMany.mockResolvedValue([ownerMember, adultMember]);

    await expect(
      service.leaveCurrentFamily(ownerMember.userId),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.familyMember.delete).not.toHaveBeenCalled();
  });

  it('prevents the only adult from leaving while children remain', async () => {
    const { service, prisma } = createService();
    const currentAdult = { ...adultMember, family };
    prisma.familyMember.findFirst.mockResolvedValue(currentAdult);
    prisma.familyMember.findMany.mockResolvedValue([adultMember, childMember]);

    await expect(
      service.leaveCurrentFamily(adultMember.userId),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.familyMember.delete).not.toHaveBeenCalled();
  });

  it('only transfers creator role to an adult member', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst
      .mockResolvedValueOnce(ownerMember)
      .mockResolvedValueOnce(childMember);

    await expect(
      service.transferCreator(ownerMember.userId, { memberId: childMember.id }),
    ).rejects.toThrow(BadRequestException);
    expect(prisma.familyMember.update).not.toHaveBeenCalled();
  });

  it('joins a family as child by default', async () => {
    const { service, prisma } = createService();
    prisma.familyMember.findFirst.mockResolvedValue(null);
    prisma.family.findUnique.mockResolvedValue(family);
    prisma.familyMember.create.mockResolvedValue(childMember);
    prisma.historyEvent.create.mockResolvedValue({ id: 'event-1' });

    const result = await service.joinFamily('user-child', {
      inviteCode: family.inviteCode,
    });

    expect(prisma.familyMember.create).toHaveBeenCalledWith({
      data: {
        familyId: family.id,
        userId: 'user-child',
        role: FamilyRole.CHILD,
      },
    });
    expect(result.currentMember.role).toBe(FamilyRole.CHILD);
  });
});
