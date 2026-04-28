import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../family_setup/application/family_controller.dart';
import '../application/initiatives_controller.dart';
import '../domain/initiative.dart';
import 'create_initiative_screen.dart';
import 'initiative_details_screen.dart';
import 'initiative_labels.dart';

class InitiativesScreen extends ConsumerWidget {
  const InitiativesScreen({super.key});

  static const routePath = '/tasks/initiatives';
  static const routeName = 'initiatives';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final initiativesAsync = ref.watch(initiativesControllerProvider);
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final canCreate = ref
        .read(initiativesControllerProvider.notifier)
        .canCreateInitiative(currentMember);

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

    return AppScaffold(
      title: l10n.initiativesTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () =>
              ref.read(initiativesControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push(CreateInitiativeScreen.routePath),
              child: const Icon(Icons.add),
            )
          : null,
      body: initiativesAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.read(initiativesControllerProvider.notifier).reload(),
        ),
        data: (state) => _InitiativesList(initiatives: state.initiatives),
      ),
    );
  }
}

class _InitiativesList extends ConsumerWidget {
  const _InitiativesList({required this.initiatives});

  final List<Initiative> initiatives;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(initiativesControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (initiatives.isEmpty)
            AppBaseCard(child: Text(l10n.noInitiativesMessage))
          else
            for (final initiative in initiatives)
              _InitiativeTile(initiative: initiative),
        ],
      ),
    );
  }
}

class _InitiativeTile extends StatelessWidget {
  const _InitiativeTile({required this.initiative});

  final Initiative initiative;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lockedUntil = initiative.discussionLockedUntil;

    return AppBaseCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(initiative.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(initiative.createdBy?.name ?? l10n.unknownUserLabel),
            if (lockedUntil != null && initiative.isDiscussionLocked)
              Text(
                '${l10n.discussionLockedUntilLabel}: '
                '${DateFormat.Hm().format(lockedUntil.toLocal())}',
              ),
            Text(_nextStepText(l10n, initiative)),
          ],
        ),
        trailing: Chip(
          label: Text(
            initiativeStatusLabel(l10n, initiative.displayStatus),
          ),
        ),
        onTap: () => context.push(InitiativeDetailsScreen.path(initiative.id)),
      ),
    );
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
