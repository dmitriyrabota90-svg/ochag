import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  const now = new Date('2026-04-27T00:00:00.000Z');
  const user = {
    id: 'user-1',
    email: 'user@example.com',
    displayName: 'User',
    passwordHash: '$2b$10$placeholder',
    createdAt: now,
    updatedAt: now,
  };

  const createService = () => {
    const prisma = {
      user: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      refreshSession: {
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
        findUnique: jest.fn(),
      },
      passwordResetToken: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      $transaction: jest.fn(async (operations: Promise<unknown>[]) =>
        Promise.all(operations),
      ),
    };
    const jwtService = {
      signAsync: jest.fn().mockResolvedValue('access-token'),
    };
    const configService = {
      get: jest.fn((key: string, fallback?: unknown) => {
        const values: Record<string, unknown> = {
          'auth.accessTokenTtl': '15m',
          'auth.passwordSaltRounds': 10,
          'auth.refreshTokenTtlDays': 30,
          'auth.passwordResetTokenTtlMinutes': 30,
        };
        return values[key] ?? fallback;
      }),
      getOrThrow: jest.fn((key: string) => {
        const values: Record<string, unknown> = {
          'auth.accessTokenSecret': 'test-secret',
        };
        return values[key];
      }),
    };
    const mailService = {
      sendPasswordResetEmail: jest.fn().mockResolvedValue({ accepted: true }),
    };

    return {
      service: new AuthService(
        prisma as never,
        jwtService as never,
        configService as never,
        mailService as never,
      ),
      prisma,
      jwtService,
      mailService,
    };
  };

  it('registers a user with a hashed password and creates a refresh session', async () => {
    const { service, prisma, jwtService } = createService();
    prisma.user.create.mockResolvedValue(user);
    prisma.refreshSession.create.mockResolvedValue({ id: 'session-1' });

    const result = await service.register({
      email: ' USER@example.com ',
      password: 'password-123',
      displayName: 'User',
    });

    expect(prisma.user.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        email: 'user@example.com',
        displayName: 'User',
      }),
    });
    const passwordHash = prisma.user.create.mock.calls[0][0].data.passwordHash;
    await expect(bcrypt.compare('password-123', passwordHash)).resolves.toBe(
      true,
    );
    expect(prisma.refreshSession.create).toHaveBeenCalled();
    expect(jwtService.signAsync).toHaveBeenCalled();
    expect(result).toEqual(
      expect.objectContaining({
        accessToken: 'access-token',
        refreshToken: expect.any(String),
        user: expect.objectContaining({ email: 'user@example.com' }),
      }),
    );
  });

  it('accepts forgot-password even when email does not exist', async () => {
    const { service, prisma, mailService } = createService();
    prisma.user.findUnique.mockResolvedValue(null);

    await expect(
      service.forgotPassword({ email: 'missing@example.com' }),
    ).resolves.toEqual({ accepted: true });
    expect(prisma.passwordResetToken.create).not.toHaveBeenCalled();
    expect(mailService.sendPasswordResetEmail).not.toHaveBeenCalled();
  });

  it('updates the current user display name', async () => {
    const { service, prisma } = createService();
    const updated = {
      ...user,
      displayName: 'New Name',
      updatedAt: new Date('2026-04-27T00:01:00.000Z'),
    };
    prisma.user.update.mockResolvedValue(updated);

    await expect(
      service.updateMe(user.id, { displayName: 'New Name' }),
    ).resolves.toEqual({
      id: user.id,
      email: user.email,
      displayName: 'New Name',
      createdAt: user.createdAt,
      updatedAt: updated.updatedAt,
    });

    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: user.id },
      data: { displayName: 'New Name' },
    });
  });

  it('resets password and revokes active refresh sessions', async () => {
    const { service, prisma } = createService();
    const tokenId = 'reset-token-id';
    const secret = 'reset-token-secret';
    const tokenHash = await bcrypt.hash(secret, 10);
    prisma.passwordResetToken.findUnique.mockResolvedValue({
      id: 'reset-1',
      tokenId,
      tokenHash,
      userId: user.id,
      expiresAt: new Date(Date.now() + 60_000),
      usedAt: null,
      createdAt: now,
    });
    prisma.user.update.mockResolvedValue(user);
    prisma.passwordResetToken.update.mockResolvedValue({ id: 'reset-1' });
    prisma.refreshSession.updateMany.mockResolvedValue({ count: 2 });

    await expect(
      service.resetPassword({
        token: `${tokenId}.${secret}`,
        password: 'new-password-123',
      }),
    ).resolves.toEqual({ success: true });

    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: user.id },
      data: { passwordHash: expect.any(String) },
    });
    expect(prisma.passwordResetToken.update).toHaveBeenCalledWith({
      where: { id: 'reset-1' },
      data: { usedAt: expect.any(Date) },
    });
    expect(prisma.refreshSession.updateMany).toHaveBeenCalledWith({
      where: {
        userId: user.id,
        revokedAt: null,
      },
      data: { revokedAt: expect.any(Date) },
    });
  });
});
