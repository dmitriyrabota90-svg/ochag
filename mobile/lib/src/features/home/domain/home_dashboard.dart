import '../../family_setup/domain/family.dart';
import '../../goal/domain/family_goal.dart';
import '../../history/domain/history.dart';
import '../../rating/domain/rating.dart';
import '../../tasks/domain/task.dart';

enum HomeActionType {
  taskReview,
  initiativeDecision,
  rewardFulfillment,
  rewardReceiving,
  rewardCancelResponse,
  goalCompletion,
}

enum HomeQuickActionType {
  createTask,
  createInitiative,
  openRewards,
  contributeGoal,
  sendFeedback,
}

class HomeDashboard {
  const HomeDashboard({
    required this.family,
    required this.currentMember,
    required this.myActiveTasks,
    required this.waitingActions,
    required this.historyPreview,
    required this.quickActions,
    this.currentGoal,
    this.currentRatingItem,
    this.currentMemberSummary,
    this.availableLevelFreeRewards = 0,
  });

  final Family family;
  final FamilyMember currentMember;
  final List<Task> myActiveTasks;
  final List<HomeActionItem> waitingActions;
  final FamilyGoal? currentGoal;
  final List<HistoryEvent> historyPreview;
  final List<HomeQuickAction> quickActions;
  final RatingItem? currentRatingItem;
  final AnalyticsMemberSummary? currentMemberSummary;
  final int availableLevelFreeRewards;

  int get currentLevel =>
      currentRatingItem?.level ?? currentMemberSummary?.level ?? 1;

  int? get totalExperience => currentRatingItem?.totalExperience;

  int? get periodExperience => currentMemberSummary?.experienceEarned;

  int? get periodSparks => currentMemberSummary?.sparksEarned;

  int? get periodCompletedTasks => currentMemberSummary?.completedTasks;
}

class HomeActionItem {
  const HomeActionItem({
    required this.type,
    required this.title,
    required this.routePath,
  });

  final HomeActionType type;
  final String title;
  final String routePath;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.type,
    required this.routePath,
  });

  final HomeQuickActionType type;
  final String routePath;
}
