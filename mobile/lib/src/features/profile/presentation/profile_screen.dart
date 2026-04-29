import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/auth_error_messages.dart';
import '../../family_setup/presentation/family_settings_screen.dart';
import '../../feedback/presentation/feedback_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../rating/presentation/rating_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';
  static const routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    final notificationsState =
        ref.watch(notificationsControllerProvider).valueOrNull;
    final user = authState?.user;
    final unreadCount = notificationsState?.unreadCount ?? 0;

    return AppScaffold(
      title: l10n.profileTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppBaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? l10n.profileTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (user != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text(user.email)),
                      IconButton(
                        tooltip: l10n.editDisplayNameAction,
                        onPressed: authState?.isSubmitting == true
                            ? null
                            : () => _showEditNameDialog(
                                  context,
                                  ref,
                                  user.displayName ?? '',
                                ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.familySettingsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(FamilySettingsScreen.routePath),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.notificationsTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (unreadCount > 0)
                  Badge(
                    label: Text(unreadCount.toString()),
                    child: const Icon(Icons.notifications_outlined),
                  )
                else
                  const Icon(Icons.notifications_outlined),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => context.push(NotificationsScreen.routePath),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ratingTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RatingScreen.routePath),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.historyTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(HistoryScreen.routePath),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.feedbackTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(FeedbackScreen.routePath),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.logoutAction,
            isLoading: authState?.isSubmitting ?? false,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentDisplayName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: currentDisplayName.trim());

    Future<void> submit(BuildContext dialogContext) async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final success = await ref
          .read(authControllerProvider.notifier)
          .updateDisplayName(controller.text);
      if (!dialogContext.mounted) {
        return;
      }

      if (success) {
        Navigator.of(dialogContext).pop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.displayNameUpdatedMessage)),
          );
        }
        return;
      }

      final failure = ref.read(authControllerProvider).valueOrNull?.failure;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, failure))),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final isSubmitting =
                ref.watch(authControllerProvider).valueOrNull?.isSubmitting ??
                    false;

            return AlertDialog(
              title: Text(l10n.updateDisplayNameTitle),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(labelText: l10n.displayNameLabel),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted:
                      isSubmitting ? null : (_) => submit(dialogContext),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty || trimmed.length > 80) {
                      return l10n.displayNameRequiredValidationError;
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelAction),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : () => submit(dialogContext),
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveAction),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }
}
