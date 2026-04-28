import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../application/family_goal_controller.dart';
import '../domain/family_goal.dart';
import 'family_goal_form_screen.dart';
import 'family_goal_labels.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  static const routePath = '/goal';
  static const routeName = 'goal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalAsync = ref.watch(familyGoalControllerProvider);
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final controller = ref.read(familyGoalControllerProvider.notifier);
    final canManage = controller.canManageGoal(currentMember);

    ref.listen(familyGoalControllerProvider, (previous, next) {
      final state = next.valueOrNull;
      final success = familyGoalSuccessMessage(l10n, state?.successMessage);
      final message = state?.errorMessage ?? (success.isEmpty ? null : success);
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return AppScaffold(
      title: l10n.goalTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () => controller.reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: goalAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: error.toString(),
          onRetry: () => controller.reload(),
        ),
        data: (state) {
          if (!state.hasGoal || state.goal == null) {
            return _EmptyGoal(canManage: canManage);
          }
          return _GoalContent(state: state);
        },
      ),
    );
  }
}

class _EmptyGoal extends StatelessWidget {
  const _EmptyGoal({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppBaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.noFamilyGoalMessage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (canManage) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.createFamilyGoalAction,
                  onPressed: () => context.push(FamilyGoalFormScreen.routePath),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalContent extends ConsumerWidget {
  const _GoalContent({required this.state});

  final FamilyGoalState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goal = state.goal!;
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final members = ref.watch(currentFamilyMembersProvider);
    final controller = ref.read(familyGoalControllerProvider.notifier);
    final canManage = controller.canManageGoal(currentMember);
    final canContribute = controller.canContribute(goal, currentMember);
    final canConfirm = controller.canConfirmCompletion(goal, currentMember);

    return RefreshIndicator(
      onRefresh: () => controller.reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppBaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(familyGoalStatusLabel(l10n, goal.status)),
                    ),
                  ],
                ),
                if (goal.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(goal.description!),
                ],
                const SizedBox(height: 16),
                LinearProgressIndicator(value: goal.progress),
                const SizedBox(height: 8),
                Text(
                  '${goal.currentSparks} / ${goal.targetSparks} '
                  '${l10n.sparksShortLabel}',
                ),
                if (goal.targetAt != null)
                  Text(
                    '${l10n.familyGoalTargetAtLabel}: '
                    '${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(goal.targetAt!)}',
                  ),
                if (goal.achievedAt != null)
                  Text(l10n.familyGoalAchievedMessage),
                if (goal.completedAt != null)
                  Text(l10n.familyGoalCompletedSummaryMessage),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (canManage && goal.isActive)
            PrimaryButton(
              label: l10n.updateFamilyGoalAction,
              onPressed: () => context.push(FamilyGoalFormScreen.routePath),
            ),
          if (canContribute) ...[
            const SizedBox(height: 16),
            _ContributionCard(goal: goal, isSubmitting: state.isSubmitting),
          ],
          if (goal.isAwaitingExecution || goal.isCompleted) ...[
            const SizedBox(height: 16),
            _ConfirmationsCard(
              goal: goal,
              members: members,
              canConfirm: canConfirm,
              isSubmitting: state.isSubmitting,
            ),
          ],
        ],
      ),
    );
  }
}

class _ContributionCard extends ConsumerStatefulWidget {
  const _ContributionCard({
    required this.goal,
    required this.isSubmitting,
  });

  final FamilyGoal goal;
  final bool isSubmitting;

  @override
  ConsumerState<_ContributionCard> createState() => _ContributionCardState();
}

class _ContributionCardState extends ConsumerState<_ContributionCard> {
  final _sparksController = TextEditingController(text: '10');

  @override
  void dispose() {
    _sparksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sparks = int.tryParse(_sparksController.text) ?? 0;
    final experience = ref
        .read(familyGoalControllerProvider.notifier)
        .contributionExperience(sparks);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyGoalContributionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sparksController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.familyGoalSparksLabel),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('${l10n.spentSparksLabel}: $sparks'),
          Text('${l10n.gainedExperienceLabel}: $experience'),
          const SizedBox(height: 8),
          Text(l10n.familyGoalContributionWarning),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.contributeFamilyGoalAction,
            isLoading: widget.isSubmitting,
            onPressed: widget.isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final sparks = int.tryParse(_sparksController.text);
    if (sparks == null || sparks < 1 || sparks > 1000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).familyGoalSparksError)),
      );
      return;
    }
    await ref.read(familyGoalControllerProvider.notifier).contribute(
          goalId: widget.goal.id,
          sparks: sparks,
        );
  }
}

class _ConfirmationsCard extends ConsumerWidget {
  const _ConfirmationsCard({
    required this.goal,
    required this.members,
    required this.canConfirm,
    required this.isSubmitting,
  });

  final FamilyGoal goal;
  final List<FamilyMember> members;
  final bool canConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final confirmedMemberIds =
        goal.confirmations.map((confirmation) => confirmation.memberId).toSet();
    final confirmed = members
        .where((member) => confirmedMemberIds.contains(member.id))
        .toList();
    final pending = members
        .where((member) => !confirmedMemberIds.contains(member.id))
        .toList();

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyGoalConfirmationsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.familyGoalConfirmedMembersLabel),
          if (confirmed.isEmpty)
            Text(l10n.noneLabel)
          else
            for (final member in confirmed) Text(member.displayName),
          const SizedBox(height: 8),
          Text(l10n.familyGoalPendingMembersLabel),
          if (pending.isEmpty)
            Text(l10n.noneLabel)
          else
            for (final member in pending) Text(member.displayName),
          if (canConfirm) ...[
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.confirmFamilyGoalCompletionAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : () => ref
                      .read(familyGoalControllerProvider.notifier)
                      .confirmCompletion(goal.id),
            ),
          ],
        ],
      ),
    );
  }
}
