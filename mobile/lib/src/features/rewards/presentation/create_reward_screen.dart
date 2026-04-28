import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import 'reward_labels.dart';

class CreateRewardScreen extends ConsumerWidget {
  const CreateRewardScreen({super.key});

  static const routePath = '/rewards/new';
  static const routeName = 'createReward';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RewardFormScreen();
  }
}

class RewardFormScreen extends ConsumerStatefulWidget {
  const RewardFormScreen({
    this.template,
    super.key,
  });

  final RewardTemplate? template;

  @override
  ConsumerState<RewardFormScreen> createState() => _RewardFormScreenState();
}

class _RewardFormScreenState extends ConsumerState<RewardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');
  RewardPaymentMode _paymentMode = RewardPaymentMode.sparks;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    if (template != null) {
      _applyTemplate(template);
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
    final state = ref.watch(rewardsControllerProvider).valueOrNull;
    final templates = state?.templates ?? const <RewardTemplate>[];
    final isSubmitting = state?.isSubmitting ?? false;

    return AppScaffold(
      title: l10n.createRewardTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (templates.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _templateId,
                decoration:
                    InputDecoration(labelText: l10n.rewardTemplateLabel),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.noTemplateLabel),
                  ),
                  for (final template in templates)
                    DropdownMenuItem(
                      value: template.id,
                      child: Text(template.title),
                    ),
                ],
                onChanged: (value) {
                  final template = templates
                      .where((template) => template.id == value)
                      .firstOrNull;
                  setState(() {
                    _templateId = value;
                    if (template != null) {
                      _applyTemplate(template);
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
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
              minLines: 3,
              maxLines: 6,
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
                  () => _paymentMode = value ?? RewardPaymentMode.sparks),
            ),
            const SizedBox(height: 12),
            Text(
              _paymentMode == RewardPaymentMode.sparks
                  ? l10n.rewardSparksChargeHint
                  : l10n.rewardLevelFreeAvailabilityHint,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.createRewardAction,
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
        await ref.read(rewardsControllerProvider.notifier).createReward(
              RewardDraft(
                title: _titleController.text,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text,
                pointsCost: int.tryParse(_pointsController.text) ?? 0,
                paymentMode: _paymentMode,
              ),
            );
    if (success && mounted) {
      context.pop();
    }
  }

  void _applyTemplate(RewardTemplate template) {
    _templateId = template.id;
    _titleController.text = template.title;
    _descriptionController.text = template.description ?? '';
    _pointsController.text = template.pointsCost.toString();
    _paymentMode = template.paymentMode;
  }

  String? _validatePoints(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0 || parsed > 100000) {
      return AppLocalizations.of(context).rewardPriceValidationError;
    }
    return null;
  }
}
