import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../../feedback/presentation/feedback_screen.dart';
import '../../goal/application/family_goal_controller.dart';
import '../../goal/domain/family_goal.dart';
import '../../goal/presentation/goal_screen.dart';
import '../../history/application/history_controller.dart';
import '../../initiatives/application/initiatives_controller.dart';
import '../../initiatives/presentation/create_initiative_screen.dart';
import '../../initiatives/presentation/initiative_details_screen.dart';
import '../../rating/application/rating_controller.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/domain/reward.dart';
import '../../rewards/presentation/reward_request_details_screen.dart';
import '../../rewards/presentation/rewards_screen.dart';
import '../../tasks/application/tasks_controller.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/create_task_screen.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../domain/home_dashboard.dart';

class HomeRepository {
  const HomeRepository();

  HomeDashboard buildDashboard({
    required FamilyState familyState,
    required TasksState tasksState,
    required InitiativesState initiativesState,
    required RewardsState rewardsState,
    required FamilyGoalState goalState,
    required HistoryState historyState,
    required RatingState ratingState,
    required TasksController tasksController,
    required InitiativesController initiativesController,
    required RewardsController rewardsController,
    required FamilyGoalController goalController,
  }) {
    final family = familyState.family;
    final currentMember = familyState.currentMember;
    if (family == null || currentMember == null) {
      throw StateError('Home dashboard requires active family context');
    }

    final members = familyState.members;
    final myActiveTasks = tasksState.tasks
        .where((task) =>
            task.assigneeId == currentMember.userId &&
            !task.isHistory &&
            task.status != TaskStatus.pendingConfirmation)
        .take(3)
        .toList();

    final taskReviews = tasksState.tasks
        .where((task) => tasksController.canReviewTask(
              task,
              currentMember,
              members,
            ))
        .map(
          (task) => HomeActionItem(
            type: HomeActionType.taskReview,
            title: task.title,
            routePath: TaskDetailsScreen.path(task.id),
          ),
        );

    final initiativeDecisions = initiativesState.initiatives
        .where((initiative) => initiativesController.canReviewInitiative(
              initiative,
              currentMember,
              members,
            ))
        .map(
          (initiative) => HomeActionItem(
            type: HomeActionType.initiativeDecision,
            title: initiative.title,
            routePath: InitiativeDetailsScreen.path(initiative.id),
          ),
        );

    final rewardActions = rewardsState.requests
        .where((request) => _mustActOnRewardRequest(
              rewardsController,
              request,
              currentMember,
            ))
        .map(
          (request) => HomeActionItem(
            type: _rewardActionType(rewardsController, request, currentMember),
            title: request.reward.title,
            routePath: RewardRequestDetailsScreen.path(request.id),
          ),
        );

    final goal = goalState.goal;
    final goalActions = goalController.canConfirmCompletion(goal, currentMember)
        ? [
            HomeActionItem(
              type: HomeActionType.goalCompletion,
              title: goal!.title,
              routePath: GoalScreen.routePath,
            ),
          ]
        : const <HomeActionItem>[];

    final currentRatingItem = _firstOrNull(
      ratingState.rating?.items.where(
        (item) => item.memberId == currentMember.id,
      ),
    );
    final currentSummary = _firstOrNull(
      ratingState.summary?.members.where(
        (member) => member.memberId == currentMember.id,
      ),
    );
    final currentLevel = currentRatingItem?.level ?? currentSummary?.level ?? 1;

    return HomeDashboard(
      family: family,
      currentMember: currentMember,
      myActiveTasks: myActiveTasks,
      waitingActions: [
        ...taskReviews,
        ...initiativeDecisions,
        ...rewardActions,
        ...goalActions,
      ].take(5).toList(),
      currentGoal: goalState.hasGoal ? goal : null,
      historyPreview: historyState.items.take(3).toList(),
      quickActions: _quickActions(
        tasksController: tasksController,
        initiativesController: initiativesController,
        goalController: goalController,
        currentMember: currentMember,
        goal: goal,
      ),
      currentRatingItem: currentRatingItem,
      currentMemberSummary: currentSummary,
      availableLevelFreeRewards: _availableLevelFreeRewards(
          rewardsState.requests, rewardsState.rewards, currentLevel),
    );
  }

  List<HomeQuickAction> _quickActions({
    required TasksController tasksController,
    required InitiativesController initiativesController,
    required FamilyGoalController goalController,
    required FamilyMember currentMember,
    required FamilyGoal? goal,
  }) {
    return [
      if (tasksController.canCreateTask(currentMember))
        const HomeQuickAction(
          type: HomeQuickActionType.createTask,
          routePath: CreateTaskScreen.routePath,
        ),
      if (initiativesController.canCreateInitiative(currentMember))
        const HomeQuickAction(
          type: HomeQuickActionType.createInitiative,
          routePath: CreateInitiativeScreen.routePath,
        ),
      const HomeQuickAction(
        type: HomeQuickActionType.openRewards,
        routePath: RewardsScreen.routePath,
      ),
      if (goalController.canContribute(goal, currentMember))
        const HomeQuickAction(
          type: HomeQuickActionType.contributeGoal,
          routePath: GoalScreen.routePath,
        ),
      const HomeQuickAction(
        type: HomeQuickActionType.sendFeedback,
        routePath: FeedbackScreen.routePath,
      ),
    ];
  }

  bool _mustActOnRewardRequest(
    RewardsController controller,
    RewardRequest request,
    FamilyMember currentMember,
  ) {
    return controller.canMarkFulfilled(request, currentMember) ||
        controller.canConfirmReceived(request, currentMember) ||
        controller.canRespondCancel(request, currentMember);
  }

  HomeActionType _rewardActionType(
    RewardsController controller,
    RewardRequest request,
    FamilyMember currentMember,
  ) {
    if (controller.canMarkFulfilled(request, currentMember)) {
      return HomeActionType.rewardFulfillment;
    }
    if (controller.canConfirmReceived(request, currentMember)) {
      return HomeActionType.rewardReceiving;
    }
    return HomeActionType.rewardCancelResponse;
  }

  int _availableLevelFreeRewards(
    List<RewardRequest> requests,
    List<Reward> rewards,
    int currentLevel,
  ) {
    final usedLevelRewards = requests
        .where((request) =>
            request.usesLevelFree &&
            !request.isCancelled &&
            !request.isCancelRequested)
        .map((request) => request.rewardId)
        .toSet();
    return rewards
        .where((reward) =>
            reward.isAvailable &&
            reward.usesLevelFree &&
            !usedLevelRewards.contains(reward.id) &&
            (reward.levelRequired == null ||
                reward.levelRequired! <= currentLevel))
        .length;
  }
}

extension on RewardRequest {
  bool get usesLevelFree => paymentMode == RewardPaymentMode.levelFree;
}

T? _firstOrNull<T>(Iterable<T>? items) {
  final iterator = items?.iterator;
  if (iterator == null || !iterator.moveNext()) {
    return null;
  }
  return iterator.current;
}
