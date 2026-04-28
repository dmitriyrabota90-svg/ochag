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
import '../application/initiatives_controller.dart';
import '../domain/initiative.dart';
import 'initiative_labels.dart';

class InitiativeDetailsScreen extends ConsumerStatefulWidget {
  const InitiativeDetailsScreen({
    required this.initiativeId,
    super.key,
  });

  static const routeName = 'initiativeDetails';

  final String initiativeId;

  static String path(String initiativeId) => '/tasks/initiatives/$initiativeId';

  @override
  ConsumerState<InitiativeDetailsScreen> createState() =>
      _InitiativeDetailsScreenState();
}

class _InitiativeDetailsScreenState
    extends ConsumerState<InitiativeDetailsScreen> {
  final _sparksController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(initiativesControllerProvider.notifier)
          .loadInitiative(widget.initiativeId),
    );
  }

  @override
  void dispose() {
    _sparksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(initiativesControllerProvider).valueOrNull;
    final initiative = state?.selectedInitiative ??
        state?.initiatives
            .where((initiative) => initiative.id == widget.initiativeId)
            .firstOrNull;
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final members = ref.watch(currentFamilyMembersProvider);
    final controller = ref.read(initiativesControllerProvider.notifier);

    ref.listen(initiativesControllerProvider, (previous, next) {
      final state = next.valueOrNull;
      final success = initiativeSuccessMessage(l10n, state?.successMessage);
      final message = state?.errorMessage ?? (success.isEmpty ? null : success);
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    if (initiative == null) {
      final error = state?.errorMessage;
      return AppScaffold(
        title: l10n.initiativeDetailsTitle,
        body: error == null
            ? const AppLoadingState()
            : AppErrorState(
                message: error,
                onRetry: () => controller.loadInitiative(widget.initiativeId),
              ),
      );
    }

    final canReview =
        controller.canReviewInitiative(initiative, currentMember, members);

    return AppScaffold(
      title: l10n.initiativeDetailsTitle,
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
                      initiative.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(
                        initiativeStatusLabel(
                          l10n,
                          initiative.displayStatus,
                        ),
                      ),
                    ),
                  ],
                ),
                if (initiative.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(initiative.description!),
                ],
                const SizedBox(height: 12),
                _MetaLine(
                  label: l10n.initiativeAuthorLabel,
                  value: initiative.createdBy?.name ?? l10n.unknownUserLabel,
                ),
                if (initiative.discussionLockedUntil != null)
                  _MetaLine(
                    label: l10n.discussionLockedUntilLabel,
                    value: DateFormat.yMMMd(
                      Localizations.localeOf(context).toString(),
                    ).add_Hm().format(
                          initiative.discussionLockedUntil!.toLocal(),
                        ),
                  ),
                if (initiative.finalSparks != null)
                  _MetaLine(
                    label: l10n.finalSparksLabel,
                    value: initiative.finalSparks.toString(),
                  ),
                if (initiative.decidedBy != null)
                  _MetaLine(
                    label: l10n.initiativeDecidedByLabel,
                    value: initiative.decidedBy!.name,
                  ),
                const SizedBox(height: 12),
                Text(_nextStepText(l10n, initiative)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (initiative.isDiscussionLocked)
            AppBaseCard(
              child: Text(l10n.initiativeDiscussionLockMessage),
            ),
          if (canReview)
            _ReviewCard(
              controller: _sparksController,
              isSubmitting: state?.isSubmitting ?? false,
              onApprove: () => _approve(initiative.id),
              onApproveWithoutReward: () =>
                  controller.approveWithoutReward(initiative.id),
              onReject: () => _confirmReject(initiative.id),
            ),
        ],
      ),
    );
  }

  Future<void> _approve(String initiativeId) async {
    final sparks = int.tryParse(_sparksController.text);
    if (sparks == null || sparks < 1 || sparks > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).finalSparksError)),
      );
      return;
    }
    await ref.read(initiativesControllerProvider.notifier).approveInitiative(
          initiativeId: initiativeId,
          finalSparks: sparks,
        );
  }

  Future<void> _confirmReject(String initiativeId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.rejectInitiativeAction,
      body: l10n.rejectInitiativeConfirmMessage,
    );
    if (confirmed) {
      await ref
          .read(initiativesControllerProvider.notifier)
          .rejectInitiative(initiativeId);
    }
  }

  String _nextStepText(AppLocalizations l10n, Initiative initiative) {
    return switch (initiative.displayStatus) {
      InitiativeDisplayStatus.discussion => l10n.initiativeNextDiscussion,
      InitiativeDisplayStatus.waitingDecision => l10n.initiativeNextReviewer,
      InitiativeDisplayStatus.approved ||
      InitiativeDisplayStatus.approvedWithoutReward ||
      InitiativeDisplayStatus.rejected =>
        l10n.initiativeNextFinished,
    };
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.controller,
    required this.isSubmitting,
    required this.onApprove,
    required this.onApproveWithoutReward,
    required this.onReject,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onApprove;
  final VoidCallback onApproveWithoutReward;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.initiativeReviewTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.finalSparksLabel),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: l10n.approveInitiativeAction,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onApprove,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: isSubmitting ? null : onApproveWithoutReward,
            child: Text(l10n.approveWithoutRewardAction),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: isSubmitting ? null : onReject,
            child: Text(l10n.rejectInitiativeAction),
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
