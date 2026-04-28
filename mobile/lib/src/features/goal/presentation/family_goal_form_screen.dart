import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/family_goal_controller.dart';
import '../domain/family_goal.dart';

class FamilyGoalFormScreen extends ConsumerStatefulWidget {
  const FamilyGoalFormScreen({super.key});

  static const routePath = '/goal/edit';
  static const routeName = 'familyGoalForm';

  @override
  ConsumerState<FamilyGoalFormScreen> createState() =>
      _FamilyGoalFormScreenState();
}

class _FamilyGoalFormScreenState extends ConsumerState<FamilyGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _targetAt;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(familyGoalControllerProvider).valueOrNull;
    final goal = state?.goal;
    final isEdit = goal?.isActive == true;

    if (!_initialized && isEdit) {
      _titleController.text = goal!.title;
      _descriptionController.text = goal.description ?? '';
      _targetController.text = goal.targetSparks.toString();
      _targetAt = goal.targetAt;
      _initialized = true;
    } else if (!_initialized) {
      _targetController.text = '100';
      _initialized = true;
    }

    return AppScaffold(
      title: isEdit ? l10n.updateFamilyGoalTitle : l10n.createFamilyGoalTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.familyGoalTitleLabel),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty || trimmed.length > 120) {
                  return l10n.familyGoalTitleValidationError;
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
                  InputDecoration(labelText: l10n.familyGoalDescriptionLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: l10n.familyGoalTargetLabel),
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed < 1 || parsed > 1000000) {
                  return l10n.familyGoalTargetValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.familyGoalTargetAtLabel),
              subtitle: Text(_targetAt == null
                  ? l10n.noDueDateLabel
                  : MaterialLocalizations.of(context)
                      .formatMediumDate(_targetAt!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickTargetAt,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: isEdit ? l10n.saveAction : l10n.createFamilyGoalAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: state?.isSubmitting == true ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTargetAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _targetAt = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final state = ref.read(familyGoalControllerProvider).valueOrNull;
    final goal = state?.goal;
    final draft = FamilyGoalDraft(
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text,
      targetSparks: int.tryParse(_targetController.text) ?? 1,
      targetAt: _targetAt,
    );
    final controller = ref.read(familyGoalControllerProvider.notifier);
    final success = goal?.isActive == true
        ? await controller.updateGoal(goalId: goal!.id, draft: draft)
        : await controller.createGoal(draft);
    if (success && mounted) {
      context.pop();
    }
  }
}
