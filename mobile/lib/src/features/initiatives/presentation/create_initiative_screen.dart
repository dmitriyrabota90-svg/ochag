import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/initiatives_controller.dart';
import '../domain/initiative.dart';

class CreateInitiativeScreen extends ConsumerStatefulWidget {
  const CreateInitiativeScreen({super.key});

  static const routePath = '/tasks/initiatives/new';
  static const routeName = 'createInitiative';

  @override
  ConsumerState<CreateInitiativeScreen> createState() =>
      _CreateInitiativeScreenState();
}

class _CreateInitiativeScreenState
    extends ConsumerState<CreateInitiativeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting =
        ref.watch(initiativesControllerProvider).valueOrNull?.isSubmitting ??
            false;

    return AppScaffold(
      title: l10n.createInitiativeTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.initiativeTitleLabel),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty || trimmed.length > 120) {
                  return l10n.initiativeTitleValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 6,
              decoration:
                  InputDecoration(labelText: l10n.initiativeDescriptionLabel),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.createInitiativeAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success =
        await ref.read(initiativesControllerProvider.notifier).createInitiative(
              InitiativeDraft(
                title: _titleController.text,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text,
              ),
            );
    if (success && mounted) {
      context.pop();
    }
  }
}
