import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../family_setup/application/family_controller.dart';
import '../application/rewards_controller.dart';
import 'reward_labels.dart';
import 'reward_request_details_screen.dart';

class RewardDetailsScreen extends ConsumerStatefulWidget {
  const RewardDetailsScreen({
    required this.rewardId,
    super.key,
  });

  static const routeName = 'rewardDetails';

  final String rewardId;

  static String path(String rewardId) => '/rewards/$rewardId';

  @override
  ConsumerState<RewardDetailsScreen> createState() =>
      _RewardDetailsScreenState();
}

class _RewardDetailsScreenState extends ConsumerState<RewardDetailsScreen> {
  final _repriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(rewardsControllerProvider.notifier)
          .loadReward(widget.rewardId),
    );
  }

  @override
  void dispose() {
    _repriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(rewardsControllerProvider).valueOrNull;
    final reward = state?.selectedReward ??
        state?.rewards
            .where((reward) => reward.id == widget.rewardId)
            .firstOrNull;
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final controller = ref.read(rewardsControllerProvider.notifier);

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

    if (reward == null) {
      final error = state?.errorMessage;
      return AppScaffold(
        title: l10n.rewardDetailsTitle,
        body: error == null
            ? const AppLoadingState()
            : AppErrorState(
                message: error,
                onRetry: () => controller.loadReward(widget.rewardId),
              ),
      );
    }

    _repriceController.text = _repriceController.text.isEmpty
        ? reward.pointsCost.toString()
        : _repriceController.text;

    final canReview = controller.canReviewReward(reward, currentMember);
    final canRequest = controller.canRequestReward(reward, currentMember);

    return AppScaffold(
      title: l10n.rewardDetailsTitle,
      body: ListView(
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
                      reward.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(label: Text(rewardStatusLabel(l10n, reward.status))),
                  ],
                ),
                if (reward.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(reward.description!),
                ],
                const SizedBox(height: 12),
                _MetaLine(
                  label: l10n.rewardPaymentModeLabel,
                  value: rewardPaymentModeLabel(l10n, reward.paymentMode),
                ),
                _MetaLine(
                  label: l10n.rewardPriceLabel,
                  value: reward.usesLevelFree
                      ? l10n.rewardLevelFreeAvailabilityHint
                      : '${reward.pointsCost} ${l10n.sparksShortLabel}',
                ),
                _MetaLine(
                  label: l10n.rewardProposerLabel,
                  value: reward.createdBy?.name ?? l10n.unknownUserLabel,
                ),
                if (reward.approvedBy != null)
                  _MetaLine(
                    label: l10n.rewardProviderLabel,
                    value: reward.approvedBy!.name,
                  ),
                const SizedBox(height: 12),
                Text(
                  reward.usesSparks
                      ? l10n.rewardSparksChargeHint
                      : l10n.rewardLevelFreeAvailabilityHint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (canRequest)
            PrimaryButton(
              label: l10n.requestRewardAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => _requestReward(reward.id),
            ),
          if (canReview)
            _RewardReviewCard(
              repriceController: _repriceController,
              isSubmitting: state?.isSubmitting ?? false,
              onApprove: () => controller.approveReward(reward.id),
              onReprice: () => _reprice(reward.id),
              onReject: () => _confirmReject(reward.id),
            ),
        ],
      ),
    );
  }

  Future<void> _requestReward(String rewardId) async {
    final success = await ref
        .read(rewardsControllerProvider.notifier)
        .createRequest(rewardId);
    final request =
        ref.read(rewardsControllerProvider).valueOrNull?.selectedRequest;
    if (success && mounted && request != null) {
      context.push(RewardRequestDetailsScreen.path(request.id));
    }
  }

  Future<void> _reprice(String rewardId) async {
    final points = int.tryParse(_repriceController.text);
    if (points == null || points < 0 || points > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).rewardPriceValidationError)),
      );
      return;
    }
    await ref.read(rewardsControllerProvider.notifier).repriceReward(
          rewardId: rewardId,
          pointsCost: points,
        );
  }

  Future<void> _confirmReject(String rewardId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.rejectRewardAction,
      body: l10n.rejectRewardConfirmMessage,
    );
    if (confirmed) {
      await ref.read(rewardsControllerProvider.notifier).rejectReward(rewardId);
    }
  }
}

class _RewardReviewCard extends StatelessWidget {
  const _RewardReviewCard({
    required this.repriceController,
    required this.isSubmitting,
    required this.onApprove,
    required this.onReprice,
    required this.onReject,
  });

  final TextEditingController repriceController;
  final bool isSubmitting;
  final VoidCallback onApprove;
  final VoidCallback onReprice;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rewardReviewTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: l10n.approveRewardAction,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onApprove,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: repriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.rewardPriceLabel),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: isSubmitting ? null : onReprice,
            child: Text(l10n.repriceRewardAction),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: isSubmitting ? null : onReject,
            child: Text(l10n.rejectRewardAction),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label: $value'),
    );
  }
}
