import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../family_setup/application/family_controller.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import 'reward_labels.dart';

class RewardRequestDetailsScreen extends ConsumerStatefulWidget {
  const RewardRequestDetailsScreen({
    required this.requestId,
    super.key,
  });

  static const routeName = 'rewardRequestDetails';

  final String requestId;

  static String path(String requestId) => '/rewards/requests/$requestId';

  @override
  ConsumerState<RewardRequestDetailsScreen> createState() =>
      _RewardRequestDetailsScreenState();
}

class _RewardRequestDetailsScreenState
    extends ConsumerState<RewardRequestDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(rewardsControllerProvider.notifier)
          .loadRequest(widget.requestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(rewardsControllerProvider).valueOrNull;
    final request = state?.selectedRequest ??
        state?.requests
            .where((request) => request.id == widget.requestId)
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

    if (request == null) {
      final error = state?.errorMessage;
      return AppScaffold(
        title: l10n.rewardRequestDetailsTitle,
        body: error == null
            ? const AppLoadingState()
            : AppErrorState(
                message: error,
                onRetry: () => controller.loadRequest(widget.requestId),
              ),
      );
    }

    final canFulfill = controller.canMarkFulfilled(request, currentMember);
    final canReceive = controller.canConfirmReceived(request, currentMember);
    final canCancel = controller.canRequestCancel(request, currentMember);
    final canRespondCancel =
        controller.canRespondCancel(request, currentMember);

    return AppScaffold(
      title: l10n.rewardRequestDetailsTitle,
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
                      request.reward.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(
                        rewardRequestStatusLabel(l10n, request.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetaLine(
                  label: l10n.rewardRequesterLabel,
                  value: request.requester.displayName,
                ),
                _MetaLine(
                  label: l10n.rewardProviderLabel,
                  value: request.provider.displayName,
                ),
                _MetaLine(
                  label: l10n.rewardPaymentModeLabel,
                  value: rewardPaymentModeLabel(l10n, request.paymentMode),
                ),
                _MetaLine(
                  label: l10n.rewardPriceLabel,
                  value: request.paymentMode == RewardPaymentMode.levelFree
                      ? l10n.rewardLevelFreeUsedLabel
                      : '${request.sparksCost} ${l10n.sparksShortLabel}',
                ),
                if (request.levelSnapshot != null)
                  _MetaLine(
                    label: l10n.levelSnapshotLabel,
                    value: request.levelSnapshot.toString(),
                  ),
                if (request.fulfilledAt != null)
                  _MetaLine(
                    label: l10n.rewardFulfilledAtLabel,
                    value: _formatDate(context, request.fulfilledAt!),
                  ),
                if (request.receivedAt != null)
                  _MetaLine(
                    label: l10n.rewardReceivedAtLabel,
                    value: _formatDate(context, request.receivedAt!),
                  ),
                if (request.cancelRequestedAt != null)
                  _MetaLine(
                    label: l10n.rewardCancelRequestedAtLabel,
                    value: _formatDate(context, request.cancelRequestedAt!),
                  ),
                const SizedBox(height: 12),
                Text(_statusHint(l10n, request)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (canFulfill)
            PrimaryButton(
              label: l10n.markRewardFulfilledAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => controller.markFulfilled(request.id),
            ),
          if (canReceive)
            PrimaryButton(
              label: l10n.confirmRewardReceivedAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => controller.confirmReceived(request.id),
            ),
          if (canCancel)
            OutlinedButton(
              onPressed: state?.isSubmitting == true
                  ? null
                  : () => _confirmRequestCancel(request.id),
              child: Text(l10n.requestRewardCancelAction),
            ),
          if (canRespondCancel) ...[
            PrimaryButton(
              label: l10n.approveRewardCancelAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => _confirmRespondCancel(
                requestId: request.id,
                approve: true,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state?.isSubmitting == true
                  ? null
                  : () => _confirmRespondCancel(
                        requestId: request.id,
                        approve: false,
                      ),
              child: Text(l10n.rejectRewardCancelAction),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm()
        .format(value.toLocal());
  }

  Future<void> _confirmRequestCancel(String requestId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.requestRewardCancelAction,
      body: l10n.requestRewardCancelConfirmMessage,
    );
    if (confirmed) {
      await ref.read(rewardsControllerProvider.notifier).requestCancel(
            requestId,
          );
    }
  }

  Future<void> _confirmRespondCancel({
    required String requestId,
    required bool approve,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: approve
          ? l10n.approveRewardCancelAction
          : l10n.rejectRewardCancelAction,
      body: approve
          ? l10n.approveRewardCancelConfirmMessage
          : l10n.rejectRewardCancelConfirmMessage,
    );
    if (confirmed) {
      await ref.read(rewardsControllerProvider.notifier).respondCancel(
            requestId: requestId,
            approve: approve,
          );
    }
  }

  String _statusHint(AppLocalizations l10n, RewardRequest request) {
    return switch (request.status) {
      RewardRequestStatus.inProgress => l10n.rewardRequestInProgressHint,
      RewardRequestStatus.fulfilled => l10n.rewardRequestFulfilledHint,
      RewardRequestStatus.received => l10n.rewardRequestReceivedHint,
      RewardRequestStatus.cancelRequested => l10n.rewardRequestCancelHint,
      RewardRequestStatus.cancelled => l10n.rewardRequestCancelledHint,
    };
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
