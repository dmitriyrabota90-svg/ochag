import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateFeedbackDto } from './dto/create-feedback.dto';

@Injectable()
export class FeedbackService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateFeedbackDto) {
    const feedback = await this.prisma.feedback.create({
      data: {
        userId,
        type: dto.type,
        text: dto.text,
      },
    });

    return {
      success: true,
      id: feedback.id,
      status: 'received',
      createdAt: feedback.createdAt,
    };
  }
}
