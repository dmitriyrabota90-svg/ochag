import { FeedbackType } from './dto/create-feedback.dto';
import { FeedbackService } from './feedback.service';

describe('FeedbackService', () => {
  const now = new Date('2026-04-29T09:30:00.000Z');

  const createService = () => {
    const prisma = {
      feedback: {
        create: jest.fn(),
      },
    };

    return {
      service: new FeedbackService(prisma as never),
      prisma,
    };
  };

  it('stores feedback for the authenticated user', async () => {
    const { service, prisma } = createService();
    prisma.feedback.create.mockResolvedValue({
      id: 'feedback-1',
      userId: 'user-1',
      type: 'bug',
      text: 'Something broke',
      createdAt: now,
    });

    const result = await service.create('user-1', {
      type: FeedbackType.Bug,
      text: 'Something broke',
    });

    expect(prisma.feedback.create).toHaveBeenCalledWith({
      data: {
        userId: 'user-1',
        type: 'bug',
        text: 'Something broke',
      },
    });
    expect(result).toEqual({
      success: true,
      id: 'feedback-1',
      status: 'received',
      createdAt: now,
    });
  });
});
