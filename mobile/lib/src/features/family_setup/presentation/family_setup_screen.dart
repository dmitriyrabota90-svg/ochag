import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';
import '../application/family_controller.dart';

class FamilySetupScreen extends ConsumerStatefulWidget {
  const FamilySetupScreen({super.key});

  static const routePath = '/family-setup';
  static const routeName = 'familySetup';

  @override
  ConsumerState<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends ConsumerState<FamilySetupScreen> {
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  final _inviteController = TextEditingController();

  @override
  void dispose() {
    _familyNameController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    final familyState = ref.watch(familyControllerProvider).valueOrNull;
    final isSubmitting = (familyState?.isSubmitting ?? false) ||
        (authState?.isSubmitting ?? false);

    ref.listen(familyControllerProvider, (previous, next) {
      final error = next.valueOrNull?.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return AppScaffold(
      title: l10n.familySetupTitle,
      actions: [
        IconButton(
          tooltip: l10n.logoutAction,
          onPressed: isSubmitting ? null : _logout,
          icon: const Icon(Icons.logout),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.familySetupDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppBaseCard(
            child: Form(
              key: _createFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createFamilyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _familyNameController,
                    textInputAction: TextInputAction.done,
                    decoration:
                        InputDecoration(labelText: l10n.familyNameLabel),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty || trimmed.length > 80) {
                        return l10n.familyNameValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.createFamilyAction,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _createFamily,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppBaseCard(
            child: Form(
              key: _joinFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.joinFamilyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _inviteController,
                    textInputAction: TextInputAction.done,
                    decoration:
                        InputDecoration(labelText: l10n.inviteCodeLabel),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.length < 6) {
                        return l10n.inviteCodeValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.joinFamilyAction,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _joinFamily,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppBaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.familySetupSwitchAccountTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.familySetupSwitchAccountDescription),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: isSubmitting ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.familySetupSwitchAccountAction),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createFamily() async {
    if (!_createFormKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(familyControllerProvider.notifier)
        .createFamily(_familyNameController.text);
  }

  Future<void> _joinFamily() async {
    if (!_joinFormKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(familyControllerProvider.notifier)
        .joinFamily(_inviteController.text);
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
  }
}
