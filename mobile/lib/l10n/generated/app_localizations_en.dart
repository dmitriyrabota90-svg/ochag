// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ochag';

  @override
  String get authTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get forgotPasswordTitle => 'Reset access';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get continueAction => 'Continue';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get retryAction => 'Retry';

  @override
  String get signInAction => 'Sign in';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get sendResetLinkAction => 'Send reset link';

  @override
  String get resetPasswordAction => 'Reset password';

  @override
  String get backToLoginAction => 'Back to sign in';

  @override
  String get logoutAction => 'Log out';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get displayNameLabel => 'Name';

  @override
  String get emailValidationError => 'Enter a valid email.';

  @override
  String get passwordValidationError => 'Use at least 8 characters.';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match.';

  @override
  String get displayNameValidationError => 'Name is too long.';

  @override
  String get authError => 'Something went wrong. Try again.';

  @override
  String get authInvalidRequestError =>
      'Check the entered details and try again.';

  @override
  String get authInvalidCredentialsError => 'Email or password is incorrect.';

  @override
  String get authEmailAlreadyExistsError =>
      'An account with this email already exists. Try signing in.';

  @override
  String get authNotFoundError => 'We could not find this request. Try again.';

  @override
  String get authResetLinkInvalidError =>
      'This reset link is invalid or expired. Request a new one.';

  @override
  String get authConflictError =>
      'This action cannot be completed right now. Try again.';

  @override
  String get authServerError =>
      'Server is temporarily unavailable. Try again later.';

  @override
  String get authNetworkError =>
      'No connection to the server. Check your internet and try again.';

  @override
  String get genericErrorMessage => 'Something went wrong. Try again.';

  @override
  String get betaBadgeLabel => 'Beta';

  @override
  String get resetLinkSentMessage =>
      'If the email exists, reset instructions were sent.';

  @override
  String get passwordResetDoneMessage => 'Password updated. You can sign in.';

  @override
  String get resetTokenMissingMessage => 'Reset token is missing.';

  @override
  String get forgotPasswordDescription =>
      'Enter your email and we will send reset instructions if the account exists.';

  @override
  String get restoringSession => 'Restoring session...';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get onboardingTitle => 'Onboarding';

  @override
  String get familySetupTitle => 'Family setup';

  @override
  String get familySetupDescription =>
      'Create a new family or join an existing one with an invite. If this is not the right account, you can safely sign out.';

  @override
  String get familySetupSwitchAccountTitle => 'Need another account?';

  @override
  String get familySetupSwitchAccountDescription =>
      'Sign out to return to the sign-in screen and use a different account.';

  @override
  String get familySetupSwitchAccountAction => 'Sign in with another account';

  @override
  String get createFamilyTitle => 'Create your family';

  @override
  String get joinFamilyTitle => 'Join a family';

  @override
  String get familySettingsTitle => 'Family settings';

  @override
  String get familyNameLabel => 'Family name';

  @override
  String get inviteCodeLabel => 'Invite code or link';

  @override
  String get familyNameValidationError => 'Use 1-80 characters.';

  @override
  String get inviteCodeValidationError => 'Enter an invite code or link.';

  @override
  String get createFamilyAction => 'Create family';

  @override
  String get joinFamilyAction => 'Join family';

  @override
  String get updateFamilyNameTitle => 'Family name';

  @override
  String get familyInviteTitle => 'Invite';

  @override
  String get createInviteLinkAction => 'Create invite link';

  @override
  String get regenerateInviteCodeAction => 'Regenerate code';

  @override
  String get copyInviteLinkAction => 'Copy invite link';

  @override
  String get familyMembersTitle => 'Members';

  @override
  String get familyDangerZoneTitle => 'Danger zone';

  @override
  String get leaveFamilyAction => 'Leave family';

  @override
  String get requestFamilyDeleteAction => 'Request family delete';

  @override
  String get removeMemberAction => 'Remove member';

  @override
  String get transferCreatorAction => 'Transfer creator';

  @override
  String get makeAdultAction => 'Make adult';

  @override
  String get makeChildAction => 'Make child';

  @override
  String get familyRoleOwner => 'Creator';

  @override
  String get familyRoleAdult => 'Adult';

  @override
  String get familyRoleChild => 'Child';

  @override
  String get noFamilyMessage => 'No active family yet.';

  @override
  String get inviteCodeNotCreatedMessage => 'Invite code is not created yet.';

  @override
  String get leaveFamilyConfirmMessage =>
      'You will lose access to this family\'s shared data.';

  @override
  String get removeMemberConfirmMessage =>
      'This member will lose access to the family.';

  @override
  String get transferCreatorConfirmMessage =>
      'Creator permissions will move to this member.';

  @override
  String get regenerateInviteConfirmMessage =>
      'The previous invite code will stop working.';

  @override
  String get requestFamilyDeleteConfirmMessage =>
      'A confirmation email will be sent to finish deletion.';

  @override
  String get familyCreatedMessage => 'Family created.';

  @override
  String get familyJoinedMessage => 'Family joined.';

  @override
  String get familyUpdatedMessage => 'Family updated.';

  @override
  String get familyLeftMessage => 'You left the family.';

  @override
  String get memberRoleUpdatedMessage => 'Member role updated.';

  @override
  String get memberRemovedMessage => 'Member removed.';

  @override
  String get creatorTransferredMessage => 'Creator transferred.';

  @override
  String get inviteCreatedMessage => 'Invite created.';

  @override
  String get inviteRegeneratedMessage => 'Invite code regenerated.';

  @override
  String get familyDeleteRequestedMessage =>
      'Check your email to confirm family deletion.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeTotalExperienceLabel => 'Total XP';

  @override
  String get homeAvailableFreeRewardsLabel => 'Free rewards';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String get homeMyActiveTasksTitle => 'My active tasks';

  @override
  String get homeWaitingForYouTitle => 'Waiting for you';

  @override
  String get homeFamilyGoalTitle => 'Family goal';

  @override
  String get homeLatestEventsTitle => 'Latest events';

  @override
  String get homeViewAllAction => 'View all';

  @override
  String get homeOpenGoalAction => 'Open goal';

  @override
  String get homeOpenRewardsAction => 'Open rewards';

  @override
  String get homeSendFeedbackAction => 'Send feedback';

  @override
  String get homeNoActiveTasksMessage => 'No active tasks assigned to you.';

  @override
  String get homeNoWaitingActionsMessage =>
      'Nothing needs your action right now.';

  @override
  String get homeNoRecentEventsMessage => 'No recent events yet.';

  @override
  String get homeTaskReviewAction => 'Review task';

  @override
  String get homeInitiativeDecisionAction => 'Decide initiative';

  @override
  String get homeRewardFulfillmentAction => 'Mark reward fulfilled';

  @override
  String get homeRewardReceivingAction => 'Confirm reward received';

  @override
  String get homeRewardCancelResponseAction => 'Respond to cancellation';

  @override
  String get homeGoalCompletionAction => 'Confirm goal completion';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get createTaskTitle => 'Create task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get taskDetailsTitle => 'Task details';

  @override
  String get taskTitleLabel => 'Title';

  @override
  String get taskDescriptionLabel => 'Description';

  @override
  String get taskAssigneeLabel => 'Assignee';

  @override
  String get taskCreatorLabel => 'Creator';

  @override
  String get taskDueDateLabel => 'Due date';

  @override
  String get taskRewardLabel => 'Reward';

  @override
  String get taskRecurrenceLabel => 'Recurrence';

  @override
  String get taskTemplateLabel => 'Template';

  @override
  String get noTemplateLabel => 'No template';

  @override
  String get noDueDateLabel => 'No due date';

  @override
  String get unassignedLabel => 'Unassigned';

  @override
  String get unknownUserLabel => 'Unknown user';

  @override
  String get rewardSparksLabel => 'Sparks';

  @override
  String get rewardExperienceLabel => 'Experience';

  @override
  String get sparksShortLabel => 'sparks';

  @override
  String get experienceShortLabel => 'xp';

  @override
  String get taskTitleValidationError => 'Use 1-120 characters.';

  @override
  String get taskAssigneeValidationError => 'Choose an assignee.';

  @override
  String get rewardValidationError => 'Use a number from 0 to 100000.';

  @override
  String get createTaskAction => 'Create task';

  @override
  String get deleteTaskAction => 'Delete task';

  @override
  String get submitTaskAction => 'Submit for review';

  @override
  String get approveTaskAction => 'Approve';

  @override
  String get rejectTaskAction => 'Reject';

  @override
  String get includeHistoryAction => 'Show history';

  @override
  String get noTasksMessage => 'No tasks yet.';

  @override
  String get deleteTaskConfirmMessage =>
      'This task will be removed from the active list.';

  @override
  String get rejectTaskConfirmMessage =>
      'The task will return to active status for more work.';

  @override
  String get taskReturnedToActiveMessage =>
      'This task was returned and is active again.';

  @override
  String get taskStatusActive => 'Active';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusConfirmed => 'Confirmed';

  @override
  String get taskStatusSkipped => 'Skipped';

  @override
  String get taskRecurrenceNone => 'No repeat';

  @override
  String get taskRecurrenceDaily => 'Daily';

  @override
  String get taskRecurrenceWeekly => 'Weekly';

  @override
  String get taskCommentsTitle => 'Comments';

  @override
  String get taskCommentLabel => 'Comment';

  @override
  String get addCommentAction => 'Add comment';

  @override
  String get noTaskCommentsMessage => 'No comments yet.';

  @override
  String get taskTemplatesTitle => 'Task templates';

  @override
  String get createTaskTemplateTitle => 'Create template';

  @override
  String get editTaskTemplateTitle => 'Edit template';

  @override
  String get taskCreatedMessage => 'Task created.';

  @override
  String get taskUpdatedMessage => 'Task updated.';

  @override
  String get taskDeletedMessage => 'Task deleted.';

  @override
  String get taskSubmittedMessage => 'Task submitted for review.';

  @override
  String get taskApprovedMessage => 'Task approved.';

  @override
  String get taskRejectedMessage => 'Task returned.';

  @override
  String get taskCommentAddedMessage => 'Comment added.';

  @override
  String get taskTemplateCreatedMessage => 'Template created.';

  @override
  String get taskTemplateUpdatedMessage => 'Template updated.';

  @override
  String get initiativesTitle => 'Initiatives';

  @override
  String get initiativesInTasksDescription =>
      'Ideas from family members that need discussion and a decision.';

  @override
  String get createInitiativeTitle => 'Create initiative';

  @override
  String get initiativeDetailsTitle => 'Initiative details';

  @override
  String get initiativeTitleLabel => 'Title';

  @override
  String get initiativeDescriptionLabel => 'Description';

  @override
  String get initiativeTitleValidationError => 'Use 1-120 characters.';

  @override
  String get createInitiativeAction => 'Create initiative';

  @override
  String get initiativeAuthorLabel => 'Author';

  @override
  String get initiativeDecidedByLabel => 'Decided by';

  @override
  String get discussionLockedUntilLabel => 'Discussion locked until';

  @override
  String get finalSparksLabel => 'Final sparks';

  @override
  String get finalSparksError => 'Use a number from 1 to 100000.';

  @override
  String get initiativeReviewTitle => 'Decision';

  @override
  String get rejectInitiativeConfirmMessage =>
      'This initiative will be closed as rejected.';

  @override
  String get approveInitiativeAction => 'Approve with sparks';

  @override
  String get approveWithoutRewardAction => 'Approve without reward';

  @override
  String get rejectInitiativeAction => 'Reject';

  @override
  String get noInitiativesMessage => 'No initiatives yet.';

  @override
  String get initiativeDiscussionLockMessage =>
      'Discussion is still open. A final decision will be available after the lock expires.';

  @override
  String get initiativeNextDiscussion => 'Next: family discussion.';

  @override
  String get initiativeNextReviewer => 'Next: reviewer decision.';

  @override
  String get initiativeNextFinished => 'Decision is final.';

  @override
  String get initiativeStatusDiscussion => 'Discussion';

  @override
  String get initiativeStatusWaitingDecision => 'Waiting decision';

  @override
  String get initiativeStatusApproved => 'Approved';

  @override
  String get initiativeStatusApprovedWithoutReward => 'Approved without reward';

  @override
  String get initiativeStatusRejected => 'Rejected';

  @override
  String get initiativeCreatedMessage => 'Initiative created.';

  @override
  String get initiativeApprovedMessage => 'Initiative approved.';

  @override
  String get initiativeApprovedWithoutRewardMessage =>
      'Initiative approved without reward.';

  @override
  String get initiativeRejectedMessage => 'Initiative rejected.';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardDetailsTitle => 'Reward details';

  @override
  String get createRewardTitle => 'Propose reward';

  @override
  String get rewardTitleLabel => 'Title';

  @override
  String get rewardDescriptionLabel => 'Description';

  @override
  String get rewardPriceLabel => 'Price';

  @override
  String get rewardPaymentModeLabel => 'Payment';

  @override
  String get rewardTemplateLabel => 'Template';

  @override
  String get rewardTitleValidationError => 'Use 1-120 characters.';

  @override
  String get rewardPriceValidationError => 'Use a number from 0 to 100000.';

  @override
  String get createRewardAction => 'Propose reward';

  @override
  String get requestRewardAction => 'Request reward';

  @override
  String get approveRewardAction => 'Approve';

  @override
  String get repriceRewardAction => 'Approve with new price';

  @override
  String get rejectRewardAction => 'Reject';

  @override
  String get rewardReviewTitle => 'Review proposal';

  @override
  String get rejectRewardConfirmMessage =>
      'This reward proposal will be closed as rejected.';

  @override
  String get rewardStatusProposed => 'Proposed';

  @override
  String get rewardStatusAvailable => 'Available';

  @override
  String get rewardStatusRejected => 'Rejected';

  @override
  String get rewardPaymentSparks => 'Pay with sparks';

  @override
  String get rewardPaymentLevelFree => 'Free level reward';

  @override
  String get rewardPaymentHint =>
      'Spark rewards charge immediately when requested. Free level rewards use the current level allowance if backend confirms it is available.';

  @override
  String get rewardSparksChargeHint =>
      'Sparks are charged immediately after the request is created.';

  @override
  String get rewardLevelFreeAvailabilityHint =>
      'Uses the current level free reward allowance if it is still available.';

  @override
  String get rewardLevelFreeUsedLabel => 'Free level reward used';

  @override
  String get rewardProviderLabel => 'Provider';

  @override
  String get rewardProposerLabel => 'Proposer';

  @override
  String get rewardRequesterLabel => 'Requester';

  @override
  String get noRewardsMessage => 'No rewards yet.';

  @override
  String get rewardTemplatesTitle => 'Reward templates';

  @override
  String get createRewardTemplateTitle => 'Create reward template';

  @override
  String get editRewardTemplateTitle => 'Edit reward template';

  @override
  String get rewardRequestsTitle => 'Recent requests';

  @override
  String get rewardRequestDetailsTitle => 'Reward request';

  @override
  String get rewardRequestStatusInProgress => 'In progress';

  @override
  String get rewardRequestStatusFulfilled => 'Fulfilled';

  @override
  String get rewardRequestStatusReceived => 'Completed';

  @override
  String get rewardRequestStatusCancelRequested => 'Cancellation requested';

  @override
  String get rewardRequestStatusCancelled => 'Cancelled';

  @override
  String get markRewardFulfilledAction => 'Mark fulfilled';

  @override
  String get confirmRewardReceivedAction => 'Confirm received';

  @override
  String get requestRewardCancelAction => 'Request cancellation';

  @override
  String get approveRewardCancelAction => 'Approve cancellation';

  @override
  String get rejectRewardCancelAction => 'Keep active';

  @override
  String get levelSnapshotLabel => 'Level';

  @override
  String get rewardFulfilledAtLabel => 'Fulfilled at';

  @override
  String get rewardReceivedAtLabel => 'Received at';

  @override
  String get rewardCancelRequestedAtLabel => 'Cancel requested at';

  @override
  String get rewardRequestInProgressHint =>
      'The reward is in progress. The provider should fulfill it next.';

  @override
  String get rewardRequestFulfilledHint =>
      'The provider marked it fulfilled. The requester should confirm receiving it.';

  @override
  String get rewardRequestReceivedHint => 'The reward is completed.';

  @override
  String get rewardRequestCancelHint =>
      'Cancellation was requested. The other participant should respond.';

  @override
  String get rewardRequestCancelledHint => 'The reward request was cancelled.';

  @override
  String get requestRewardCancelConfirmMessage =>
      'The other participant will need to respond to this cancellation request.';

  @override
  String get approveRewardCancelConfirmMessage =>
      'This reward request will be cancelled.';

  @override
  String get rejectRewardCancelConfirmMessage =>
      'The reward request will stay active.';

  @override
  String get rewardCreatedMessage => 'Reward proposed.';

  @override
  String get rewardApprovedMessage => 'Reward approved.';

  @override
  String get rewardRepricedMessage => 'Reward approved with new price.';

  @override
  String get rewardRejectedMessage => 'Reward rejected.';

  @override
  String get rewardTemplateCreatedMessage => 'Reward template created.';

  @override
  String get rewardTemplateUpdatedMessage => 'Reward template updated.';

  @override
  String get rewardRequestedMessage => 'Reward requested.';

  @override
  String get rewardFulfilledMessage => 'Reward marked fulfilled.';

  @override
  String get rewardReceivedMessage => 'Reward completed.';

  @override
  String get rewardCancelRequestedMessage => 'Cancellation requested.';

  @override
  String get rewardCancelledMessage => 'Reward cancelled.';

  @override
  String get rewardCancelRejectedMessage => 'Cancellation rejected.';

  @override
  String get goalTitle => 'Goal';

  @override
  String get createFamilyGoalTitle => 'Create family goal';

  @override
  String get updateFamilyGoalTitle => 'Update family goal';

  @override
  String get familyGoalTitleLabel => 'Title';

  @override
  String get familyGoalDescriptionLabel => 'Description';

  @override
  String get familyGoalTargetLabel => 'Target sparks';

  @override
  String get familyGoalTargetAtLabel => 'Target date';

  @override
  String get familyGoalSparksLabel => 'Sparks';

  @override
  String get familyGoalTitleValidationError => 'Use 1-120 characters.';

  @override
  String get familyGoalTargetValidationError =>
      'Use a number from 1 to 1000000.';

  @override
  String get familyGoalSparksError => 'Use a number from 1 to 1000000.';

  @override
  String get noFamilyGoalMessage => 'No family goal yet.';

  @override
  String get createFamilyGoalAction => 'Create goal';

  @override
  String get updateFamilyGoalAction => 'Update goal';

  @override
  String get contributeFamilyGoalAction => 'Contribute';

  @override
  String get confirmFamilyGoalCompletionAction => 'Confirm completion';

  @override
  String get familyGoalStatusActive => 'Active';

  @override
  String get familyGoalStatusAwaitingExecution => 'Awaiting execution';

  @override
  String get familyGoalStatusCompleted => 'Completed';

  @override
  String get familyGoalStatusCancelled => 'Cancelled';

  @override
  String get familyGoalContributionTitle => 'Contribution';

  @override
  String get spentSparksLabel => 'Spent sparks';

  @override
  String get gainedExperienceLabel => 'Gained experience';

  @override
  String get familyGoalContributionWarning =>
      'Contribution is irreversible. Sparks are spent immediately.';

  @override
  String get familyGoalConfirmationsTitle => 'Completion confirmations';

  @override
  String get familyGoalConfirmedMembersLabel => 'Already confirmed';

  @override
  String get familyGoalPendingMembersLabel => 'Still waiting';

  @override
  String get noneLabel => 'None';

  @override
  String get familyGoalAchievedMessage =>
      'Target achieved. The family can complete the goal after execution.';

  @override
  String get familyGoalCompletedSummaryMessage =>
      'This is the latest completed family goal.';

  @override
  String get familyGoalCreatedMessage => 'Family goal created.';

  @override
  String get familyGoalUpdatedMessage => 'Family goal updated.';

  @override
  String get familyGoalContributedMessage => 'Contribution added.';

  @override
  String get familyGoalConfirmedMessage => 'Completion confirmed.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get unreadNotificationLabel => 'Unread';

  @override
  String get readNotificationLabel => 'Read';

  @override
  String get notificationReadAtLabel => 'Read at';

  @override
  String get markAsReadAction => 'Mark as read';

  @override
  String get noNotificationsMessage => 'No notifications yet.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEntityFilterLabel => 'Entity';

  @override
  String get historyEventTypeFilterLabel => 'Event type';

  @override
  String get historyActorLabel => 'Actor';

  @override
  String get allHistoryEntitiesLabel => 'All entities';

  @override
  String get historyEntityFamily => 'Family';

  @override
  String get historyEntityTask => 'Task';

  @override
  String get historyEntityTaskTemplate => 'Task template';

  @override
  String get historyEntityInitiative => 'Initiative';

  @override
  String get historyEntityReward => 'Reward';

  @override
  String get historyEntityRewardTemplate => 'Reward template';

  @override
  String get historyEntityRewardRequest => 'Reward request';

  @override
  String get historyEntityFamilyGoal => 'Family goal';

  @override
  String get historyEntityUnknown => 'Unknown';

  @override
  String get noHistoryMessage => 'No history events yet.';

  @override
  String get loadMoreAction => 'Load more';

  @override
  String get loadingAction => 'Loading...';

  @override
  String get ratingTitle => 'Rating';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodAllTime => 'All time';

  @override
  String get analyticsSummaryTitle => 'Summary';

  @override
  String get completedTasksLabel => 'Tasks';

  @override
  String get sparksEarnedLabel => 'Sparks';

  @override
  String get experienceEarnedLabel => 'Experience';

  @override
  String get familyGoalContributedLabel => 'Goal';

  @override
  String get levelLabel => 'Level';

  @override
  String get periodExperienceLabel => 'XP';

  @override
  String get periodSparksLabel => 'Sparks';

  @override
  String get periodTasksLabel => 'Tasks';

  @override
  String get noRatingMessage => 'No rating data yet.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBetaMessage =>
      'Use this entry point during beta to collect notes from family testers. Connect the final feedback channel before public release.';

  @override
  String get homeFoundationReady =>
      'Mobile foundation is ready. Product flows will be connected next.';

  @override
  String featurePlaceholder(String featureName) {
    return '$featureName is prepared for the next implementation step.';
  }
}
