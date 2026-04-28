import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/primary_button.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import 'reward_labels.dart';

Future<void> showRewardTemplateFormSheet({
  required BuildContext context,
  RewardTemplate? template,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _RewardTemplateFormSheet(template: template),
  );
}

class _RewardTemplateFormSheet extends ConsumerStatefulWidget {
  const _RewardTemplateFormSheet({this.template});

  final RewardTemplate? template;

  @override
  ConsumerState<_RewardTemplateFormSheet> createState() =>
      _RewardTemplateFormSheetState();
}

class _RewardTemplateFormSheetState
    extends ConsumerState<_RewardTemplateFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');
  RewardPaymentMode _paymentMode = RewardPaymentMode.sparks;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    if (template != null) {
      _titleController.text = template.title;
      _descriptionController.text = template.description ?? '';
      _pointsController.text = template.pointsCost.toString();
      _paymentMode = template.paymentMode;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting =
        ref.watch(rewardsControllerProvider).valueOrNull?.isSubmitting ?? false;
    final isEdit = widget.template != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? l10n.editRewardTemplateTitle
                    : l10n.createRewardTemplateTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.rewardTitleLabel),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty || trimmed.length > 120) {
                    return l10n.rewardTitleValidationError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration:
                    InputDecoration(labelText: l10n.rewardDescriptionLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.rewardPriceLabel),
                validator: _validatePoints,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RewardPaymentMode>(
                initialValue: _paymentMode,
                decoration:
                    InputDecoration(labelText: l10n.rewardPaymentModeLabel),
                items: [
                  for (final mode in RewardPaymentMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(rewardPaymentModeLabel(l10n, mode)),
                    ),
                ],
                onChanged: (value) => setState(
                  () => _paymentMode = value ?? RewardPaymentMode.sparks,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.saveAction,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final draft = RewardDraft(
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text,
      pointsCost: int.tryParse(_pointsController.text) ?? 0,
      paymentMode: _paymentMode,
    );
    final controller = ref.read(rewardsControllerProvider.notifier);
    final success = widget.template == null
        ? await controller.createTemplate(draft)
        : await controller.updateTemplate(
            templateId: widget.template!.id,
            draft: draft,
          );
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _validatePoints(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0 || parsed > 100000) {
      return AppLocalizations.of(context).rewardPriceValidationError;
    }
    return null;
  }
}
