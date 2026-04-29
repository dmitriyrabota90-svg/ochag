import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ochag_mobile/src/features/auth/application/auth_failure.dart';
import 'package:ochag_mobile/src/features/auth/presentation/auth_form_validators.dart';
import 'package:ochag_mobile/src/features/family_setup/domain/family.dart';
import 'package:ochag_mobile/src/features/feedback/data/feedback_dto.dart';
import 'package:ochag_mobile/src/features/feedback/domain/feedback_entry.dart';
import 'package:ochag_mobile/src/features/goal/application/family_goal_controller.dart';
import 'package:ochag_mobile/src/features/history/domain/history.dart';
import 'package:ochag_mobile/src/features/initiatives/domain/initiative.dart';
import 'package:ochag_mobile/src/features/notifications/data/notification_dto.dart';
import 'package:ochag_mobile/src/features/rewards/domain/reward.dart';
import 'package:ochag_mobile/src/features/rating/domain/rating.dart';
import 'package:ochag_mobile/src/features/tasks/domain/task.dart';

void main() {
  testWidgets('placeholder test harness is ready', (tester) async {
    expect(true, isTrue);
  });

  test('auth validators accept basic valid credentials', () {
    expect(AuthFormValidators.isValidEmail('user@example.com'), isTrue);
    expect(AuthFormValidators.isValidPassword('Password123'), isTrue);
  });

  test('auth validators reject invalid credentials', () {
    expect(AuthFormValidators.isValidEmail('not-an-email'), isFalse);
    expect(AuthFormValidators.isValidPassword('short'), isFalse);
  });

  test('auth errors map to beta friendly failures', () {
    DioException dioError(int statusCode) {
      return DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: statusCode,
        ),
      );
    }

    expect(
      authFailureFromError(dioError(409), request: AuthRequest.register),
      AuthFailure.emailAlreadyExists,
    );
    expect(
      authFailureFromError(dioError(500), request: AuthRequest.login),
      AuthFailure.server,
    );
    expect(
      authFailureFromError(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionError,
        ),
        request: AuthRequest.login,
      ),
      AuthFailure.network,
    );
  });

  test('family roles map to backend values', () {
    expect(FamilyRole.owner.apiValue, 'OWNER');
    expect(FamilyRole.adult.apiValue, 'ADULT');
    expect(FamilyRole.child.apiValue, 'CHILD');
    expect(FamilyRole.owner.isAdult, isTrue);
    expect(FamilyRole.child.isAdult, isFalse);
  });

  test('feedback request maps to backend payload shape', () {
    final dto = FeedbackRequestDto.fromDomain(
      const FeedbackSubmission(
        type: FeedbackType.bug,
        text: 'Something broke',
      ),
    );

    expect(FeedbackType.idea.apiValue, 'idea');
    expect(dto.toJson(), {
      'type': 'bug',
      'text': 'Something broke',
    });
  });

  test('task recurrence maps to backend values', () {
    expect(TaskRecurrence.none.apiValue, 'NONE');
    expect(TaskRecurrence.daily.apiValue, 'DAILY');
    expect(TaskRecurrence.weekly.apiValue, 'WEEKLY');
  });

  test('initiative waiting decision is derived after discussion lock', () {
    final initiative = Initiative(
      id: 'initiative-id',
      familyId: 'family-id',
      title: 'Help',
      status: InitiativeStatus.discussion,
      discussionLockedUntil: DateTime.now().subtract(
        const Duration(minutes: 1),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(initiative.displayStatus, InitiativeDisplayStatus.waitingDecision);
  });

  test('reward payment modes map to backend values', () {
    expect(RewardPaymentMode.sparks.apiValue, 'SPARKS');
    expect(RewardPaymentMode.levelFree.apiValue, 'LEVEL_FREE');
  });

  test('family goal contribution experience is floor sparks times 1.5', () {
    final controller = FamilyGoalController();

    expect(controller.contributionExperience(1), 1);
    expect(controller.contributionExperience(2), 3);
    expect(controller.contributionExperience(10), 15);
  });

  test('history and rating filters map to backend values', () {
    expect(HistoryEntityType.familyGoal.apiValue, 'family_goal');
    expect(AnalyticsPeriod.allTime.apiValue, 'all_time');
  });

  test('notification dto maps read state and payload to domain', () {
    final page = NotificationsPageDto.fromJson({
      'items': [
        {
          'id': 'notification-id',
          'type': 'task_completed',
          'title': 'Task completed',
          'body': 'The task is ready for review.',
          'payload': {'taskId': 'task-id'},
          'readAt': null,
          'createdAt': '2026-04-28T08:00:00Z',
        },
      ],
      'pageInfo': {
        'limit': 30,
        'nextCursor': 'next-cursor',
        'hasMore': true,
      },
    }).toDomain();

    expect(page.items.single.isRead, isFalse);
    expect(page.items.single.payload['taskId'], 'task-id');
    expect(page.pageInfo.nextCursor, 'next-cursor');
    expect(page.pageInfo.hasMore, isTrue);
  });
}
