import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../family_setup/application/family_controller.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import 'create_reward_screen.dart';
import 'reward_details_screen.dart';
import 'reward_labels.dart';
import 'reward_request_details_screen.dart';
import 'reward_template_form_sheet.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const routePath = '/rewards';
  static const routeName = 'rewards';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rewardsAsync = ref.watch(rewardsControllerProvider);
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final controller = ref.read(rewardsControllerProvider.notifier);
    final canPropose = controller.canProposeReward(currentMember);
    final canManageTemplates = controller.canManageTemplates(currentMember);

    ref.listen(rewardsControllerProvider, (previous, next) {
      final state = next.valueOrNull;
      final success = rewardSuccessMessage(l10n, state?.successMessage);
      final message = state?.errorMessage ?? (success.isEmpty ? null : success);
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return AppScaffold(
      title: l10n.rewardsTitle,
      actions: [
        IconButton(
          tooltip: l10n.rewardTemplatesTitle,
          onPressed: canManageTemplates
              ? () => showRewardTemplateFormSheet(context: context)
              : null,
          icon: const Icon(Icons.bookmark_add_outlined),
        ),
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () => controller.reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: canPropose
          ? FloatingActionButton(
              onPressed: () => context.push(CreateRewardScreen.routePath),
              child: const Icon(Icons.add),
            )
          : null,
      body: rewardsAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(rewardsControllerProvider.notifier).reload(),
        ),
        data: (state) => _RewardsContent(state: state),
      ),
    );
  }
}

class _RewardsContent extends ConsumerWidget {
  const _RewardsContent({required this.state});

  final RewardsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(rewardsControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppBaseCard(
            child: Text(l10n.rewardPaymentHint),
          ),
          const SizedBox(height: 16),
          if (state.rewards.isEmpty)
            AppBaseCard(child: Text(l10n.noRewardsMessage))
          else
            for (final reward in state.rewards) _RewardTile(reward: reward),
          if (state.requests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.rewardRequestsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final request in state.requests)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(request.reward.title),
                subtitle: Text(
                  rewardRequestStatusLabel(l10n, request.status),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  RewardRequestDetailsScreen.path(request.id),
                ),
              ),
          ],
          if (state.templates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.rewardTemplatesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final template in state.templates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(template.title),
                subtitle: Text(
                  '${template.pointsCost} ${l10n.sparksShortLabel} · '
                  '${rewardPaymentModeLabel(l10n, template.paymentMode)}',
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => showRewardTemplateFormSheet(
                  context: context,
                  template: template,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.reward});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(reward.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rewardPaymentModeLabel(l10n, reward.paymentMode)),
            Text(_priceText(l10n, reward)),
            if (reward.approvedBy != null)
              Text('${l10n.rewardProviderLabel}: ${reward.approvedBy!.name}'),
          ],
        ),
        trailing: Chip(label: Text(rewardStatusLabel(l10n, reward.status))),
        onTap: () => context.push(RewardDetailsScreen.path(reward.id)),
      ),
    );
  }

  String _priceText(AppLocalizations l10n, Reward reward) {
    if (reward.usesLevelFree) {
      return l10n.rewardLevelFreeAvailabilityHint;
    }
    return '${reward.pointsCost} ${l10n.sparksShortLabel}';
  }
}
