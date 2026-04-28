import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/task.dart';

String taskStatusLabel(AppLocalizations l10n, TaskStatus status) {
  return switch (status) {
    TaskStatus.todo => l10n.taskStatusActive,
    TaskStatus.active => l10n.taskStatusActive,
    TaskStatus.inProgress => l10n.taskStatusActive,
    TaskStatus.pendingConfirmation => l10n.taskStatusPending,
    TaskStatus.done => l10n.taskStatusConfirmed,
    TaskStatus.confirmed => l10n.taskStatusConfirmed,
    TaskStatus.skipped => l10n.taskStatusSkipped,
    TaskStatus.cancelled => l10n.taskStatusSkipped,
  };
}

String taskRecurrenceLabel(AppLocalizations l10n, TaskRecurrence recurrence) {
  return switch (recurrence) {
    TaskRecurrence.none => l10n.taskRecurrenceNone,
    TaskRecurrence.daily => l10n.taskRecurrenceDaily,
    TaskRecurrence.weekly => l10n.taskRecurrenceWeekly,
  };
}

String taskSuccessMessage(AppLocalizations l10n, String? code) {
  return switch (code) {
    'task_created' => l10n.taskCreatedMessage,
    'task_updated' => l10n.taskUpdatedMessage,
    'task_deleted' => l10n.taskDeletedMessage,
    'task_submitted' => l10n.taskSubmittedMessage,
    'task_approved' => l10n.taskApprovedMessage,
    'task_rejected' => l10n.taskRejectedMessage,
    'task_comment_added' => l10n.taskCommentAddedMessage,
    'task_template_created' => l10n.taskTemplateCreatedMessage,
    'task_template_updated' => l10n.taskTemplateUpdatedMessage,
    _ => '',
  };
}
