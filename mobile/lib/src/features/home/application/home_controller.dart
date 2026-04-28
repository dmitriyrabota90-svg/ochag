import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../../goal/application/family_goal_controller.dart';
import '../../history/application/history_controller.dart';
import '../../initiatives/application/initiatives_controller.dart';
import '../../rating/application/rating_controller.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../data/home_repository.dart';
import '../domain/home_dashboard.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const HomeRepository();
});

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeDashboard>(
  HomeController.new,
);

class HomeController extends AsyncNotifier<HomeDashboard> {
  @override
  Future<HomeDashboard> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      throw StateError('Home requires an active family');
    }

    final tasksState = await ref.watch(tasksControllerProvider.future);
    final initiativesState =
        await ref.watch(initiativesControllerProvider.future);
    final rewardsState = await ref.watch(rewardsControllerProvider.future);
    final goalState = await ref.watch(familyGoalControllerProvider.future);
    final historyState = await ref.watch(historyControllerProvider.future);
    final ratingState = await ref.watch(ratingControllerProvider.future);

    return _compose(
      familyState: familyState,
      tasksState: tasksState,
      initiativesState: initiativesState,
      rewardsState: rewardsState,
      goalState: goalState,
      historyState: historyState,
      ratingState: ratingState,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    await Future.wait([
      ref.read(familyControllerProvider.notifier).reload(),
      ref.read(tasksControllerProvider.notifier).reload(),
      ref.read(initiativesControllerProvider.notifier).reload(),
      ref.read(rewardsControllerProvider.notifier).reload(),
      ref.read(familyGoalControllerProvider.notifier).reload(),
      ref.read(historyControllerProvider.notifier).reload(),
      ref.read(ratingControllerProvider.notifier).reload(),
    ]);
    state = await AsyncValue.guard(_readLoaded);
  }

  Future<HomeDashboard> _readLoaded() async {
    final familyState = await ref.read(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      throw StateError('Home requires an active family');
    }

    final tasksState = await ref.read(tasksControllerProvider.future);
    final initiativesState =
        await ref.read(initiativesControllerProvider.future);
    final rewardsState = await ref.read(rewardsControllerProvider.future);
    final goalState = await ref.read(familyGoalControllerProvider.future);
    final historyState = await ref.read(historyControllerProvider.future);
    final ratingState = await ref.read(ratingControllerProvider.future);

    return _compose(
      familyState: familyState,
      tasksState: tasksState,
      initiativesState: initiativesState,
      rewardsState: rewardsState,
      goalState: goalState,
      historyState: historyState,
      ratingState: ratingState,
    );
  }

  HomeDashboard _compose({
    required FamilyState familyState,
    required TasksState tasksState,
    required InitiativesState initiativesState,
    required RewardsState rewardsState,
    required FamilyGoalState goalState,
    required HistoryState historyState,
    required RatingState ratingState,
  }) {
    return ref.read(homeRepositoryProvider).buildDashboard(
          familyState: familyState,
          tasksState: tasksState,
          initiativesState: initiativesState,
          rewardsState: rewardsState,
          goalState: goalState,
          historyState: historyState,
          ratingState: ratingState,
          tasksController: ref.read(tasksControllerProvider.notifier),
          initiativesController:
              ref.read(initiativesControllerProvider.notifier),
          rewardsController: ref.read(rewardsControllerProvider.notifier),
          goalController: ref.read(familyGoalControllerProvider.notifier),
        );
  }
}
