import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import { Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes, randomUUID } from 'crypto';
import { PrismaService } from '../../database/prisma.service';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdateMeDto } from './dto/update-me.dto';
import { MailService } from './mail.service';

type AuthUser = {
  id: string;
  email: string;
  displayName: string | null;
  createdAt: Date;
  updatedAt: Date;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly mailService: MailService,
  ) {}

  async register(dto: RegisterDto) {
    const email = this.normalizeEmail(dto.email);
    const passwordHash = await this.hashSecret(dto.password);

    try {
      const user = await this.prisma.user.create({
        data: {
          email,
          displayName: dto.displayName?.trim() || null,
          passwordHash,
        },
      });

      return this.buildAuthResponse(user);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('Email is already registered');
      }

      throw error;
    }
  }

  async login(dto: LoginDto) {
    const email = this.normalizeEmail(dto.email);
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user?.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.buildAuthResponse(user);
  }

  async refresh(refreshToken: string) {
    const parsedToken = this.parseOpaqueToken(refreshToken);
    if (!parsedToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const session = await this.prisma.refreshSession.findUnique({
      where: { tokenId: parsedToken.tokenId },
      include: { user: true },
    });

    if (
      !session ||
      session.revokedAt ||
      session.expiresAt.getTime() <= Date.now()
    ) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const isTokenValid = await bcrypt.compare(
      parsedToken.secret,
      session.tokenHash,
    );
    if (!isTokenValid) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const nextToken = await this.createRefreshTokenParts();
    const expiresAt = this.getRefreshExpiresAt();
    const tokenHash = await this.hashSecret(nextToken.secret);
    const now = new Date();

    await this.prisma.$transaction([
      this.prisma.refreshSession.update({
        where: { id: session.id },
        data: { revokedAt: now },
      }),
      this.prisma.refreshSession.create({
        data: {
          tokenId: nextToken.tokenId,
          tokenHash,
          userId: session.userId,
          expiresAt,
        },
      }),
    ]);

    return {
      accessToken: await this.signAccessToken(session.user),
      refreshToken: this.serializeOpaqueToken(nextToken),
      user: this.toPublicUser(session.user),
    };
  }

  async logout(refreshToken: string) {
    const parsedToken = this.parseOpaqueToken(refreshToken);
    if (parsedToken) {
      await this.prisma.refreshSession.updateMany({
        where: {
          tokenId: parsedToken.tokenId,
          revokedAt: null,
        },
        data: { revokedAt: new Date() },
      });
    }

    return { success: true };
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const email = this.normalizeEmail(dto.email);
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (user) {
      const resetToken = await this.createRefreshTokenParts();
      const tokenHash = await this.hashSecret(resetToken.secret);
      const expiresAt = this.getPasswordResetExpiresAt();

      await this.prisma.passwordResetToken.create({
        data: {
          tokenId: resetToken.tokenId,
          tokenHash,
          userId: user.id,
          expiresAt,
        },
      });

      await this.mailService.sendPasswordResetEmail({
        email: user.email,
        resetToken: this.serializeOpaqueToken(resetToken),
      });
    }

    return { accepted: true };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const parsedToken = this.parseOpaqueToken(dto.token);
    if (!parsedToken) {
      throw new UnauthorizedException('Invalid reset token');
    }

    const resetToken = await this.prisma.passwordResetToken.findUnique({
      where: { tokenId: parsedToken.tokenId },
    });

    if (
      !resetToken ||
      resetToken.usedAt ||
      resetToken.expiresAt.getTime() <= Date.now()
    ) {
      throw new UnauthorizedException('Invalid reset token');
    }

    const isTokenValid = await bcrypt.compare(
      parsedToken.secret,
      resetToken.tokenHash,
    );
    if (!isTokenValid) {
      throw new UnauthorizedException('Invalid reset token');
    }

    const passwordHash = await this.hashSecret(dto.password);
    const now = new Date();

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: resetToken.userId },
        data: { passwordHash },
      }),
      this.prisma.passwordResetToken.update({
        where: { id: resetToken.id },
        data: { usedAt: now },
      }),
      this.prisma.refreshSession.updateMany({
        where: {
          userId: resetToken.userId,
          revokedAt: null,
        },
        data: { revokedAt: now },
      }),
    ]);

    return { success: true };
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.toPublicUser(user);
  }

  async updateMe(userId: string, dto: UpdateMeDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { displayName: dto.displayName },
    });

    return this.toPublicUser(user);
  }

  private async buildAuthResponse(user: AuthUser) {
    const refreshToken = await this.createRefreshSession(user.id);

    return {
      accessToken: await this.signAccessToken(user),
      refreshToken,
      user: this.toPublicUser(user),
    };
  }

  private async createRefreshSession(userId: string) {
    const token = await this.createRefreshTokenParts();
    const tokenHash = await this.hashSecret(token.secret);

    await this.prisma.refreshSession.create({
      data: {
        tokenId: token.tokenId,
        tokenHash,
        userId,
        expiresAt: this.getRefreshExpiresAt(),
      },
    });

    return this.serializeOpaqueToken(token);
  }

  private async signAccessToken(user: AuthUser) {
    const expiresIn = this.configService.get<string>(
      'auth.accessTokenTtl',
      '15m',
    ) as JwtSignOptions['expiresIn'];

    return this.jwtService.signAsync(
      {
        sub: user.id,
        email: user.email,
      },
      {
        secret: this.configService.getOrThrow<string>('auth.accessTokenSecret'),
        expiresIn,
      },
    );
  }

  private async createRefreshTokenParts() {
    return {
      tokenId: randomUUID(),
      secret: randomBytes(48).toString('base64url'),
    };
  }

  private serializeOpaqueToken(token: { tokenId: string; secret: string }) {
    return `${token.tokenId}.${token.secret}`;
  }

  private parseOpaqueToken(token: string) {
    const [tokenId, secret, extra] = token.split('.');
    if (!tokenId || !secret || extra) {
      return null;
    }

    return { tokenId, secret };
  }

  private hashSecret(secret: string) {
    return bcrypt.hash(
      secret,
      this.configService.get<number>('auth.passwordSaltRounds', 12),
    );
  }

  private getRefreshExpiresAt() {
    const ttlDays = this.configService.get<number>(
      'auth.refreshTokenTtlDays',
      30,
    );
    return new Date(Date.now() + ttlDays * 24 * 60 * 60 * 1000);
  }

  private getPasswordResetExpiresAt() {
    const ttlMinutes = this.configService.get<number>(
      'auth.passwordResetTokenTtlMinutes',
      30,
    );
    return new Date(Date.now() + ttlMinutes * 60 * 1000);
  }

  private normalizeEmail(email: string) {
    return email.trim().toLowerCase();
  }

  private toPublicUser(user: AuthUser) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}
