import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/feedback_controller.dart';
import '../domain/feedback_entry.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  static const routePath = '/feedback';
  static const routeName = 'feedback';

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  FeedbackType? _selectedType;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feedbackState = ref.watch(feedbackControllerProvider);
    final isSubmitting = feedbackState.isSubmitting;

    ref.listen(feedbackControllerProvider, (previous, next) {
      if (next.submitted && previous?.submitted != true) {
        _textController.clear();
        _formKey.currentState?.reset();
        setState(() {
          _selectedType = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.feedbackSentMessage)),
        );
      }

      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_feedbackFailureMessage(l10n, failure))),
        );
      }
    });

    return AppScaffold(
      title: l10n.feedbackTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppBaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(l10n.betaBadgeLabel)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.feedbackBetaMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppBaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<FeedbackType>(
                    initialValue: _selectedType,
                    decoration:
                        InputDecoration(labelText: l10n.feedbackTypeLabel),
                    items: FeedbackType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(_feedbackTypeLabel(l10n, type)),
                          ),
                        )
                        .toList(),
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return l10n.feedbackTypeValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _textController,
                    enabled: !isSubmitting,
                    minLines: 5,
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: l10n.feedbackTextLabel,
                      hintText: l10n.feedbackTextHint,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return l10n.feedbackTextValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.sendFeedbackAction,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
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

    final type = _selectedType;
    if (type == null) {
      return;
    }

    FocusScope.of(context).unfocus();
    await ref.read(feedbackControllerProvider.notifier).submit(
          type: type,
          text: _textController.text,
        );
  }

  String _feedbackTypeLabel(AppLocalizations l10n, FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return l10n.feedbackTypeBug;
      case FeedbackType.idea:
        return l10n.feedbackTypeIdea;
      case FeedbackType.feedback:
        return l10n.feedbackTypeFeedback;
    }
  }

  String _feedbackFailureMessage(
    AppLocalizations l10n,
    FeedbackFailure failure,
  ) {
    switch (failure) {
      case FeedbackFailure.network:
        return l10n.feedbackNetworkErrorMessage;
      case FeedbackFailure.server:
        return l10n.feedbackServerErrorMessage;
      case FeedbackFailure.unknown:
        return l10n.feedbackSubmitErrorMessage;
    }
  }
}
