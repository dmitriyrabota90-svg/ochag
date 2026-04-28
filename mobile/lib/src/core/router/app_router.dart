import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/bootstrap_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/family_setup/application/family_controller.dart';
import '../../features/family_setup/presentation/family_settings_screen.dart';
import '../../features/family_setup/presentation/family_setup_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/goal/presentation/family_goal_form_screen.dart';
import '../../features/goal/presentation/goal_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/initiatives/presentation/create_initiative_screen.dart';
import '../../features/initiatives/presentation/initiative_details_screen.dart';
import '../../features/initiatives/presentation/initiatives_screen.dart';
import '../../features/main_tab_shell/presentation/main_tab_shell.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/rating/presentation/rating_screen.dart';
import '../../features/rewards/presentation/create_reward_screen.dart';
import '../../features/rewards/presentation/reward_details_screen.dart';
import '../../features/rewards/presentation/reward_request_details_screen.dart';
import '../../features/rewards/presentation/rewards_screen.dart';
import '../../features/tasks/presentation/create_task_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: BootstrapScreen.routePath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final familyState = ref.read(familyControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith(AuthScreen.routePath);
      final isFamilySetupRoute = location == FamilySetupScreen.routePath;

      if (authState.isLoading) {
        return location == BootstrapScreen.routePath
            ? null
            : BootstrapScreen.routePath;
      }

      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;

      if (!isAuthenticated) {
        return isAuthRoute ? null : AuthScreen.routePath;
      }

      if (familyState.isLoading) {
        return location == BootstrapScreen.routePath
            ? null
            : BootstrapScreen.routePath;
      }

      final hasFamily = familyState.valueOrNull?.hasFamily ?? false;
      if (!hasFamily) {
        return isFamilySetupRoute ? null : FamilySetupScreen.routePath;
      }

      if (location == BootstrapScreen.routePath ||
          isAuthRoute ||
          isFamilySetupRoute) {
        return HomeScreen.routePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: BootstrapScreen.routePath,
        name: BootstrapScreen.routeName,
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AuthScreen.routePath,
        name: AuthScreen.routeName,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routePath,
        name: ForgotPasswordScreen.routeName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: ResetPasswordScreen.routePath,
        name: ResetPasswordScreen.routeName,
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '${ResetPasswordScreen.routePath}/:token',
        name: ResetPasswordScreen.routeWithTokenName,
        builder: (context, state) => ResetPasswordScreen(
          token: state.pathParameters['token'] ??
              state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: FamilySetupScreen.routePath,
        name: FamilySetupScreen.routeName,
        builder: (context, state) => const FamilySetupScreen(),
      ),
      GoRoute(
        path: FamilySettingsScreen.routePath,
        name: FamilySettingsScreen.routeName,
        builder: (context, state) => const FamilySettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.routePath,
                name: HomeScreen.routeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TasksScreen.routePath,
                name: TasksScreen.routeName,
                builder: (context, state) => const TasksScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: CreateTaskScreen.routeName,
                    builder: (context, state) => const CreateTaskScreen(),
                  ),
                  GoRoute(
                    path: 'initiatives',
                    name: InitiativesScreen.routeName,
                    builder: (context, state) => const InitiativesScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: CreateInitiativeScreen.routeName,
                        builder: (context, state) =>
                            const CreateInitiativeScreen(),
                      ),
                      GoRoute(
                        path: ':initiativeId',
                        name: InitiativeDetailsScreen.routeName,
                        builder: (context, state) => InitiativeDetailsScreen(
                          initiativeId: state.pathParameters['initiativeId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':taskId',
                    name: TaskDetailsScreen.routeName,
                    builder: (context, state) => TaskDetailsScreen(
                      taskId: state.pathParameters['taskId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: EditTaskScreen.routeName,
                        builder: (context, state) => EditTaskScreen(
                          taskId: state.pathParameters['taskId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GoalScreen.routePath,
                name: GoalScreen.routeName,
                builder: (context, state) => const GoalScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: FamilyGoalFormScreen.routeName,
                    builder: (context, state) => const FamilyGoalFormScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RewardsScreen.routePath,
                name: RewardsScreen.routeName,
                builder: (context, state) => const RewardsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: CreateRewardScreen.routeName,
                    builder: (context, state) => const CreateRewardScreen(),
                  ),
                  GoRoute(
                    path: 'requests/:requestId',
                    name: RewardRequestDetailsScreen.routeName,
                    builder: (context, state) => RewardRequestDetailsScreen(
                      requestId: state.pathParameters['requestId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':rewardId',
                    name: RewardDetailsScreen.routeName,
                    builder: (context, state) => RewardDetailsScreen(
                      rewardId: state.pathParameters['rewardId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileScreen.routePath,
                name: ProfileScreen.routeName,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    name: NotificationsScreen.routeName,
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'rating',
                    name: RatingScreen.routeName,
                    builder: (context, state) => const RatingScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    name: HistoryScreen.routeName,
                    builder: (context, state) => const HistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: FeedbackScreen.routePath,
        name: FeedbackScreen.routeName,
        builder: (context, state) => const FeedbackScreen(),
      ),
    ],
  );
});

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    _authSubscription = ref.listen<AsyncValue<AuthState>>(
      authControllerProvider,
      (previous, next) => notifyListeners(),
    );
    _familySubscription = ref.listen<AsyncValue<FamilyState>>(
      familyControllerProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<AuthState>> _authSubscription;
  late final ProviderSubscription<AsyncValue<FamilyState>> _familySubscription;

  @override
  void dispose() {
    _authSubscription.close();
    _familySubscription.close();
    super.dispose();
  }
}
