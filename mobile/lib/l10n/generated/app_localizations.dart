import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ochag'**
  String get appName;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset access'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetPasswordTitle;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkAction;

  /// No description provided for @resetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordAction;

  /// No description provided for @backToLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLoginAction;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutAction;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayNameLabel;

  /// No description provided for @emailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get emailValidationError;

  /// No description provided for @passwordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordValidationError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatchError;

  /// No description provided for @displayNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Name is too long.'**
  String get displayNameValidationError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authError;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get genericErrorMessage;

  /// No description provided for @betaBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get betaBadgeLabel;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If the email exists, reset instructions were sent.'**
  String get resetLinkSentMessage;

  /// No description provided for @passwordResetDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in.'**
  String get passwordResetDoneMessage;

  /// No description provided for @resetTokenMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset token is missing.'**
  String get resetTokenMissingMessage;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send reset instructions if the account exists.'**
  String get forgotPasswordDescription;

  /// No description provided for @restoringSession.
  ///
  /// In en, this message translates to:
  /// **'Restoring session...'**
  String get restoringSession;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboardingTitle;

  /// No description provided for @familySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Family setup'**
  String get familySetupTitle;

  /// No description provided for @createFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your family'**
  String get createFamilyTitle;

  /// No description provided for @joinFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a family'**
  String get joinFamilyTitle;

  /// No description provided for @familySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Family settings'**
  String get familySettingsTitle;

  /// No description provided for @familyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyNameLabel;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code or link'**
  String get inviteCodeLabel;

  /// No description provided for @familyNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use 1-80 characters.'**
  String get familyNameValidationError;

  /// No description provided for @inviteCodeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter an invite code or link.'**
  String get inviteCodeValidationError;

  /// No description provided for @createFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Create family'**
  String get createFamilyAction;

  /// No description provided for @joinFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Join family'**
  String get joinFamilyAction;

  /// No description provided for @updateFamilyNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get updateFamilyNameTitle;

  /// No description provided for @familyInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get familyInviteTitle;

  /// No description provided for @createInviteLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Create invite link'**
  String get createInviteLinkAction;

  /// No description provided for @regenerateInviteCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Regenerate code'**
  String get regenerateInviteCodeAction;

  /// No description provided for @copyInviteLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Copy invite link'**
  String get copyInviteLinkAction;

  /// No description provided for @familyMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get familyMembersTitle;

  /// No description provided for @familyDangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get familyDangerZoneTitle;

  /// No description provided for @leaveFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get leaveFamilyAction;

  /// No description provided for @requestFamilyDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Request family delete'**
  String get requestFamilyDeleteAction;

  /// No description provided for @removeMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMemberAction;

  /// No description provided for @transferCreatorAction.
  ///
  /// In en, this message translates to:
  /// **'Transfer creator'**
  String get transferCreatorAction;

  /// No description provided for @makeAdultAction.
  ///
  /// In en, this message translates to:
  /// **'Make adult'**
  String get makeAdultAction;

  /// No description provided for @makeChildAction.
  ///
  /// In en, this message translates to:
  /// **'Make child'**
  String get makeChildAction;

  /// No description provided for @familyRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get familyRoleOwner;

  /// No description provided for @familyRoleAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get familyRoleAdult;

  /// No description provided for @familyRoleChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get familyRoleChild;

  /// No description provided for @noFamilyMessage.
  ///
  /// In en, this message translates to:
  /// **'No active family yet.'**
  String get noFamilyMessage;

  /// No description provided for @inviteCodeNotCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite code is not created yet.'**
  String get inviteCodeNotCreatedMessage;

  /// No description provided for @leaveFamilyConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will lose access to this family\'s shared data.'**
  String get leaveFamilyConfirmMessage;

  /// No description provided for @removeMemberConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This member will lose access to the family.'**
  String get removeMemberConfirmMessage;

  /// No description provided for @transferCreatorConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Creator permissions will move to this member.'**
  String get transferCreatorConfirmMessage;

  /// No description provided for @regenerateInviteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The previous invite code will stop working.'**
  String get regenerateInviteConfirmMessage;

  /// No description provided for @requestFamilyDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'A confirmation email will be sent to finish deletion.'**
  String get requestFamilyDeleteConfirmMessage;

  /// No description provided for @familyCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Family created.'**
  String get familyCreatedMessage;

  /// No description provided for @familyJoinedMessage.
  ///
  /// In en, this message translates to:
  /// **'Family joined.'**
  String get familyJoinedMessage;

  /// No description provided for @familyUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Family updated.'**
  String get familyUpdatedMessage;

  /// No description provided for @familyLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'You left the family.'**
  String get familyLeftMessage;

  /// No description provided for @memberRoleUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Member role updated.'**
  String get memberRoleUpdatedMessage;

  /// No description provided for @memberRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Member removed.'**
  String get memberRemovedMessage;

  /// No description provided for @creatorTransferredMessage.
  ///
  /// In en, this message translates to:
  /// **'Creator transferred.'**
  String get creatorTransferredMessage;

  /// No description provided for @inviteCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite created.'**
  String get inviteCreatedMessage;

  /// No description provided for @inviteRegeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite code regenerated.'**
  String get inviteRegeneratedMessage;

  /// No description provided for @familyDeleteRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm family deletion.'**
  String get familyDeleteRequestedMessage;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeTotalExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get homeTotalExperienceLabel;

  /// No description provided for @homeAvailableFreeRewardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Free rewards'**
  String get homeAvailableFreeRewardsLabel;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeMyActiveTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My active tasks'**
  String get homeMyActiveTasksTitle;

  /// No description provided for @homeWaitingForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get homeWaitingForYouTitle;

  /// No description provided for @homeFamilyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Family goal'**
  String get homeFamilyGoalTitle;

  /// No description provided for @homeLatestEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest events'**
  String get homeLatestEventsTitle;

  /// No description provided for @homeViewAllAction.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAllAction;

  /// No description provided for @homeOpenGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Open goal'**
  String get homeOpenGoalAction;

  /// No description provided for @homeOpenRewardsAction.
  ///
  /// In en, this message translates to:
  /// **'Open rewards'**
  String get homeOpenRewardsAction;

  /// No description provided for @homeSendFeedbackAction.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get homeSendFeedbackAction;

  /// No description provided for @homeNoActiveTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'No active tasks assigned to you.'**
  String get homeNoActiveTasksMessage;

  /// No description provided for @homeNoWaitingActionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your action right now.'**
  String get homeNoWaitingActionsMessage;

  /// No description provided for @homeNoRecentEventsMessage.
  ///
  /// In en, this message translates to:
  /// **'No recent events yet.'**
  String get homeNoRecentEventsMessage;

  /// No description provided for @homeTaskReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review task'**
  String get homeTaskReviewAction;

  /// No description provided for @homeInitiativeDecisionAction.
  ///
  /// In en, this message translates to:
  /// **'Decide initiative'**
  String get homeInitiativeDecisionAction;

  /// No description provided for @homeRewardFulfillmentAction.
  ///
  /// In en, this message translates to:
  /// **'Mark reward fulfilled'**
  String get homeRewardFulfillmentAction;

  /// No description provided for @homeRewardReceivingAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm reward received'**
  String get homeRewardReceivingAction;

  /// No description provided for @homeRewardCancelResponseAction.
  ///
  /// In en, this message translates to:
  /// **'Respond to cancellation'**
  String get homeRewardCancelResponseAction;

  /// No description provided for @homeGoalCompletionAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm goal completion'**
  String get homeGoalCompletionAction;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @createTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetailsTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitleLabel;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescriptionLabel;

  /// No description provided for @taskAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get taskAssigneeLabel;

  /// No description provided for @taskCreatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get taskCreatorLabel;

  /// No description provided for @taskDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDateLabel;

  /// No description provided for @taskRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get taskRewardLabel;

  /// No description provided for @taskRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get taskRecurrenceLabel;

  /// No description provided for @taskTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get taskTemplateLabel;

  /// No description provided for @noTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'No template'**
  String get noTemplateLabel;

  /// No description provided for @noDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDateLabel;

  /// No description provided for @unassignedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedLabel;

  /// No description provided for @unknownUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUserLabel;

  /// No description provided for @rewardSparksLabel.
  ///
  /// In en, this message translates to:
  /// **'Sparks'**
  String get rewardSparksLabel;

  /// No description provided for @rewardExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get rewardExperienceLabel;

  /// No description provided for @sparksShortLabel.
  ///
  /// In en, this message translates to:
  /// **'sparks'**
  String get sparksShortLabel;

  /// No description provided for @experienceShortLabel.
  ///
  /// In en, this message translates to:
  /// **'xp'**
  String get experienceShortLabel;

  /// No description provided for @taskTitleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use 1-120 characters.'**
  String get taskTitleValidationError;

  /// No description provided for @taskAssigneeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Choose an assignee.'**
  String get taskAssigneeValidationError;

  /// No description provided for @rewardValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 0 to 100000.'**
  String get rewardValidationError;

  /// No description provided for @createTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskAction;

  /// No description provided for @deleteTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskAction;

  /// No description provided for @submitTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitTaskAction;

  /// No description provided for @approveTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveTaskAction;

  /// No description provided for @rejectTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectTaskAction;

  /// No description provided for @includeHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get includeHistoryAction;

  /// No description provided for @noTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get noTasksMessage;

  /// No description provided for @deleteTaskConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This task will be removed from the active list.'**
  String get deleteTaskConfirmMessage;

  /// No description provided for @rejectTaskConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The task will return to active status for more work.'**
  String get rejectTaskConfirmMessage;

  /// No description provided for @taskReturnedToActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This task was returned and is active again.'**
  String get taskReturnedToActiveMessage;

  /// No description provided for @taskStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get taskStatusActive;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @taskStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get taskStatusConfirmed;

  /// No description provided for @taskStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get taskStatusSkipped;

  /// No description provided for @taskRecurrenceNone.
  ///
  /// In en, this message translates to:
  /// **'No repeat'**
  String get taskRecurrenceNone;

  /// No description provided for @taskRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get taskRecurrenceDaily;

  /// No description provided for @taskRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get taskRecurrenceWeekly;

  /// No description provided for @taskCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get taskCommentsTitle;

  /// No description provided for @taskCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get taskCommentLabel;

  /// No description provided for @addCommentAction.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get addCommentAction;

  /// No description provided for @noTaskCommentsMessage.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noTaskCommentsMessage;

  /// No description provided for @taskTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Task templates'**
  String get taskTemplatesTitle;

  /// No description provided for @createTaskTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create template'**
  String get createTaskTemplateTitle;

  /// No description provided for @editTaskTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get editTaskTemplateTitle;

  /// No description provided for @taskCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task created.'**
  String get taskCreatedMessage;

  /// No description provided for @taskUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task updated.'**
  String get taskUpdatedMessage;

  /// No description provided for @taskDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task deleted.'**
  String get taskDeletedMessage;

  /// No description provided for @taskSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task submitted for review.'**
  String get taskSubmittedMessage;

  /// No description provided for @taskApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task approved.'**
  String get taskApprovedMessage;

  /// No description provided for @taskRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task returned.'**
  String get taskRejectedMessage;

  /// No description provided for @taskCommentAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Comment added.'**
  String get taskCommentAddedMessage;

  /// No description provided for @taskTemplateCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Template created.'**
  String get taskTemplateCreatedMessage;

  /// No description provided for @taskTemplateUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Template updated.'**
  String get taskTemplateUpdatedMessage;

  /// No description provided for @initiativesTitle.
  ///
  /// In en, this message translates to:
  /// **'Initiatives'**
  String get initiativesTitle;

  /// No description provided for @initiativesInTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Ideas from family members that need discussion and a decision.'**
  String get initiativesInTasksDescription;

  /// No description provided for @createInitiativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create initiative'**
  String get createInitiativeTitle;

  /// No description provided for @initiativeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Initiative details'**
  String get initiativeDetailsTitle;

  /// No description provided for @initiativeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get initiativeTitleLabel;

  /// No description provided for @initiativeDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get initiativeDescriptionLabel;

  /// No description provided for @initiativeTitleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use 1-120 characters.'**
  String get initiativeTitleValidationError;

  /// No description provided for @createInitiativeAction.
  ///
  /// In en, this message translates to:
  /// **'Create initiative'**
  String get createInitiativeAction;

  /// No description provided for @initiativeAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get initiativeAuthorLabel;

  /// No description provided for @initiativeDecidedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Decided by'**
  String get initiativeDecidedByLabel;

  /// No description provided for @discussionLockedUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Discussion locked until'**
  String get discussionLockedUntilLabel;

  /// No description provided for @finalSparksLabel.
  ///
  /// In en, this message translates to:
  /// **'Final sparks'**
  String get finalSparksLabel;

  /// No description provided for @finalSparksError.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 1 to 100000.'**
  String get finalSparksError;

  /// No description provided for @initiativeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get initiativeReviewTitle;

  /// No description provided for @rejectInitiativeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This initiative will be closed as rejected.'**
  String get rejectInitiativeConfirmMessage;

  /// No description provided for @approveInitiativeAction.
  ///
  /// In en, this message translates to:
  /// **'Approve with sparks'**
  String get approveInitiativeAction;

  /// No description provided for @approveWithoutRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Approve without reward'**
  String get approveWithoutRewardAction;

  /// No description provided for @rejectInitiativeAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectInitiativeAction;

  /// No description provided for @noInitiativesMessage.
  ///
  /// In en, this message translates to:
  /// **'No initiatives yet.'**
  String get noInitiativesMessage;

  /// No description provided for @initiativeDiscussionLockMessage.
  ///
  /// In en, this message translates to:
  /// **'Discussion is still open. A final decision will be available after the lock expires.'**
  String get initiativeDiscussionLockMessage;

  /// No description provided for @initiativeNextDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Next: family discussion.'**
  String get initiativeNextDiscussion;

  /// No description provided for @initiativeNextReviewer.
  ///
  /// In en, this message translates to:
  /// **'Next: reviewer decision.'**
  String get initiativeNextReviewer;

  /// No description provided for @initiativeNextFinished.
  ///
  /// In en, this message translates to:
  /// **'Decision is final.'**
  String get initiativeNextFinished;

  /// No description provided for @initiativeStatusDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get initiativeStatusDiscussion;

  /// No description provided for @initiativeStatusWaitingDecision.
  ///
  /// In en, this message translates to:
  /// **'Waiting decision'**
  String get initiativeStatusWaitingDecision;

  /// No description provided for @initiativeStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get initiativeStatusApproved;

  /// No description provided for @initiativeStatusApprovedWithoutReward.
  ///
  /// In en, this message translates to:
  /// **'Approved without reward'**
  String get initiativeStatusApprovedWithoutReward;

  /// No description provided for @initiativeStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get initiativeStatusRejected;

  /// No description provided for @initiativeCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Initiative created.'**
  String get initiativeCreatedMessage;

  /// No description provided for @initiativeApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Initiative approved.'**
  String get initiativeApprovedMessage;

  /// No description provided for @initiativeApprovedWithoutRewardMessage.
  ///
  /// In en, this message translates to:
  /// **'Initiative approved without reward.'**
  String get initiativeApprovedWithoutRewardMessage;

  /// No description provided for @initiativeRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Initiative rejected.'**
  String get initiativeRejectedMessage;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward details'**
  String get rewardDetailsTitle;

  /// No description provided for @createRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Propose reward'**
  String get createRewardTitle;

  /// No description provided for @rewardTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get rewardTitleLabel;

  /// No description provided for @rewardDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get rewardDescriptionLabel;

  /// No description provided for @rewardPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get rewardPriceLabel;

  /// No description provided for @rewardPaymentModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get rewardPaymentModeLabel;

  /// No description provided for @rewardTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get rewardTemplateLabel;

  /// No description provided for @rewardTitleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use 1-120 characters.'**
  String get rewardTitleValidationError;

  /// No description provided for @rewardPriceValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 0 to 100000.'**
  String get rewardPriceValidationError;

  /// No description provided for @createRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Propose reward'**
  String get createRewardAction;

  /// No description provided for @requestRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Request reward'**
  String get requestRewardAction;

  /// No description provided for @approveRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveRewardAction;

  /// No description provided for @repriceRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Approve with new price'**
  String get repriceRewardAction;

  /// No description provided for @rejectRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRewardAction;

  /// No description provided for @rewardReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review proposal'**
  String get rewardReviewTitle;

  /// No description provided for @rejectRewardConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This reward proposal will be closed as rejected.'**
  String get rejectRewardConfirmMessage;

  /// No description provided for @rewardStatusProposed.
  ///
  /// In en, this message translates to:
  /// **'Proposed'**
  String get rewardStatusProposed;

  /// No description provided for @rewardStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get rewardStatusAvailable;

  /// No description provided for @rewardStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rewardStatusRejected;

  /// No description provided for @rewardPaymentSparks.
  ///
  /// In en, this message translates to:
  /// **'Pay with sparks'**
  String get rewardPaymentSparks;

  /// No description provided for @rewardPaymentLevelFree.
  ///
  /// In en, this message translates to:
  /// **'Free level reward'**
  String get rewardPaymentLevelFree;

  /// No description provided for @rewardPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Spark rewards charge immediately when requested. Free level rewards use the current level allowance if backend confirms it is available.'**
  String get rewardPaymentHint;

  /// No description provided for @rewardSparksChargeHint.
  ///
  /// In en, this message translates to:
  /// **'Sparks are charged immediately after the request is created.'**
  String get rewardSparksChargeHint;

  /// No description provided for @rewardLevelFreeAvailabilityHint.
  ///
  /// In en, this message translates to:
  /// **'Uses the current level free reward allowance if it is still available.'**
  String get rewardLevelFreeAvailabilityHint;

  /// No description provided for @rewardLevelFreeUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Free level reward used'**
  String get rewardLevelFreeUsedLabel;

  /// No description provided for @rewardProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get rewardProviderLabel;

  /// No description provided for @rewardProposerLabel.
  ///
  /// In en, this message translates to:
  /// **'Proposer'**
  String get rewardProposerLabel;

  /// No description provided for @rewardRequesterLabel.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get rewardRequesterLabel;

  /// No description provided for @noRewardsMessage.
  ///
  /// In en, this message translates to:
  /// **'No rewards yet.'**
  String get noRewardsMessage;

  /// No description provided for @rewardTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward templates'**
  String get rewardTemplatesTitle;

  /// No description provided for @createRewardTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create reward template'**
  String get createRewardTemplateTitle;

  /// No description provided for @editRewardTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reward template'**
  String get editRewardTemplateTitle;

  /// No description provided for @rewardRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent requests'**
  String get rewardRequestsTitle;

  /// No description provided for @rewardRequestDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward request'**
  String get rewardRequestDetailsTitle;

  /// No description provided for @rewardRequestStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get rewardRequestStatusInProgress;

  /// No description provided for @rewardRequestStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get rewardRequestStatusFulfilled;

  /// No description provided for @rewardRequestStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rewardRequestStatusReceived;

  /// No description provided for @rewardRequestStatusCancelRequested.
  ///
  /// In en, this message translates to:
  /// **'Cancellation requested'**
  String get rewardRequestStatusCancelRequested;

  /// No description provided for @rewardRequestStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rewardRequestStatusCancelled;

  /// No description provided for @markRewardFulfilledAction.
  ///
  /// In en, this message translates to:
  /// **'Mark fulfilled'**
  String get markRewardFulfilledAction;

  /// No description provided for @confirmRewardReceivedAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm received'**
  String get confirmRewardReceivedAction;

  /// No description provided for @requestRewardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Request cancellation'**
  String get requestRewardCancelAction;

  /// No description provided for @approveRewardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Approve cancellation'**
  String get approveRewardCancelAction;

  /// No description provided for @rejectRewardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep active'**
  String get rejectRewardCancelAction;

  /// No description provided for @levelSnapshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelSnapshotLabel;

  /// No description provided for @rewardFulfilledAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled at'**
  String get rewardFulfilledAtLabel;

  /// No description provided for @rewardReceivedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Received at'**
  String get rewardReceivedAtLabel;

  /// No description provided for @rewardCancelRequestedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel requested at'**
  String get rewardCancelRequestedAtLabel;

  /// No description provided for @rewardRequestInProgressHint.
  ///
  /// In en, this message translates to:
  /// **'The reward is in progress. The provider should fulfill it next.'**
  String get rewardRequestInProgressHint;

  /// No description provided for @rewardRequestFulfilledHint.
  ///
  /// In en, this message translates to:
  /// **'The provider marked it fulfilled. The requester should confirm receiving it.'**
  String get rewardRequestFulfilledHint;

  /// No description provided for @rewardRequestReceivedHint.
  ///
  /// In en, this message translates to:
  /// **'The reward is completed.'**
  String get rewardRequestReceivedHint;

  /// No description provided for @rewardRequestCancelHint.
  ///
  /// In en, this message translates to:
  /// **'Cancellation was requested. The other participant should respond.'**
  String get rewardRequestCancelHint;

  /// No description provided for @rewardRequestCancelledHint.
  ///
  /// In en, this message translates to:
  /// **'The reward request was cancelled.'**
  String get rewardRequestCancelledHint;

  /// No description provided for @requestRewardCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The other participant will need to respond to this cancellation request.'**
  String get requestRewardCancelConfirmMessage;

  /// No description provided for @approveRewardCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This reward request will be cancelled.'**
  String get approveRewardCancelConfirmMessage;

  /// No description provided for @rejectRewardCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The reward request will stay active.'**
  String get rejectRewardCancelConfirmMessage;

  /// No description provided for @rewardCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward proposed.'**
  String get rewardCreatedMessage;

  /// No description provided for @rewardApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward approved.'**
  String get rewardApprovedMessage;

  /// No description provided for @rewardRepricedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward approved with new price.'**
  String get rewardRepricedMessage;

  /// No description provided for @rewardRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward rejected.'**
  String get rewardRejectedMessage;

  /// No description provided for @rewardTemplateCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward template created.'**
  String get rewardTemplateCreatedMessage;

  /// No description provided for @rewardTemplateUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward template updated.'**
  String get rewardTemplateUpdatedMessage;

  /// No description provided for @rewardRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward requested.'**
  String get rewardRequestedMessage;

  /// No description provided for @rewardFulfilledMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward marked fulfilled.'**
  String get rewardFulfilledMessage;

  /// No description provided for @rewardReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward completed.'**
  String get rewardReceivedMessage;

  /// No description provided for @rewardCancelRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancellation requested.'**
  String get rewardCancelRequestedMessage;

  /// No description provided for @rewardCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward cancelled.'**
  String get rewardCancelledMessage;

  /// No description provided for @rewardCancelRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancellation rejected.'**
  String get rewardCancelRejectedMessage;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalTitle;

  /// No description provided for @createFamilyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Create family goal'**
  String get createFamilyGoalTitle;

  /// No description provided for @updateFamilyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Update family goal'**
  String get updateFamilyGoalTitle;

  /// No description provided for @familyGoalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get familyGoalTitleLabel;

  /// No description provided for @familyGoalDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get familyGoalDescriptionLabel;

  /// No description provided for @familyGoalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target sparks'**
  String get familyGoalTargetLabel;

  /// No description provided for @familyGoalTargetAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get familyGoalTargetAtLabel;

  /// No description provided for @familyGoalSparksLabel.
  ///
  /// In en, this message translates to:
  /// **'Sparks'**
  String get familyGoalSparksLabel;

  /// No description provided for @familyGoalTitleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use 1-120 characters.'**
  String get familyGoalTitleValidationError;

  /// No description provided for @familyGoalTargetValidationError.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 1 to 1000000.'**
  String get familyGoalTargetValidationError;

  /// No description provided for @familyGoalSparksError.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 1 to 1000000.'**
  String get familyGoalSparksError;

  /// No description provided for @noFamilyGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'No family goal yet.'**
  String get noFamilyGoalMessage;

  /// No description provided for @createFamilyGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createFamilyGoalAction;

  /// No description provided for @updateFamilyGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Update goal'**
  String get updateFamilyGoalAction;

  /// No description provided for @contributeFamilyGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contributeFamilyGoalAction;

  /// No description provided for @confirmFamilyGoalCompletionAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm completion'**
  String get confirmFamilyGoalCompletionAction;

  /// No description provided for @familyGoalStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get familyGoalStatusActive;

  /// No description provided for @familyGoalStatusAwaitingExecution.
  ///
  /// In en, this message translates to:
  /// **'Awaiting execution'**
  String get familyGoalStatusAwaitingExecution;

  /// No description provided for @familyGoalStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get familyGoalStatusCompleted;

  /// No description provided for @familyGoalStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get familyGoalStatusCancelled;

  /// No description provided for @familyGoalContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get familyGoalContributionTitle;

  /// No description provided for @spentSparksLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent sparks'**
  String get spentSparksLabel;

  /// No description provided for @gainedExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Gained experience'**
  String get gainedExperienceLabel;

  /// No description provided for @familyGoalContributionWarning.
  ///
  /// In en, this message translates to:
  /// **'Contribution is irreversible. Sparks are spent immediately.'**
  String get familyGoalContributionWarning;

  /// No description provided for @familyGoalConfirmationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion confirmations'**
  String get familyGoalConfirmationsTitle;

  /// No description provided for @familyGoalConfirmedMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Already confirmed'**
  String get familyGoalConfirmedMembersLabel;

  /// No description provided for @familyGoalPendingMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Still waiting'**
  String get familyGoalPendingMembersLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @familyGoalAchievedMessage.
  ///
  /// In en, this message translates to:
  /// **'Target achieved. The family can complete the goal after execution.'**
  String get familyGoalAchievedMessage;

  /// No description provided for @familyGoalCompletedSummaryMessage.
  ///
  /// In en, this message translates to:
  /// **'This is the latest completed family goal.'**
  String get familyGoalCompletedSummaryMessage;

  /// No description provided for @familyGoalCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Family goal created.'**
  String get familyGoalCreatedMessage;

  /// No description provided for @familyGoalUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Family goal updated.'**
  String get familyGoalUpdatedMessage;

  /// No description provided for @familyGoalContributedMessage.
  ///
  /// In en, this message translates to:
  /// **'Contribution added.'**
  String get familyGoalContributedMessage;

  /// No description provided for @familyGoalConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Completion confirmed.'**
  String get familyGoalConfirmedMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @unreadNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadNotificationLabel;

  /// No description provided for @readNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readNotificationLabel;

  /// No description provided for @notificationReadAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Read at'**
  String get notificationReadAtLabel;

  /// No description provided for @markAsReadAction.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsReadAction;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsMessage;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEntityFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get historyEntityFilterLabel;

  /// No description provided for @historyEventTypeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get historyEventTypeFilterLabel;

  /// No description provided for @historyActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get historyActorLabel;

  /// No description provided for @allHistoryEntitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'All entities'**
  String get allHistoryEntitiesLabel;

  /// No description provided for @historyEntityFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get historyEntityFamily;

  /// No description provided for @historyEntityTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get historyEntityTask;

  /// No description provided for @historyEntityTaskTemplate.
  ///
  /// In en, this message translates to:
  /// **'Task template'**
  String get historyEntityTaskTemplate;

  /// No description provided for @historyEntityInitiative.
  ///
  /// In en, this message translates to:
  /// **'Initiative'**
  String get historyEntityInitiative;

  /// No description provided for @historyEntityReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get historyEntityReward;

  /// No description provided for @historyEntityRewardTemplate.
  ///
  /// In en, this message translates to:
  /// **'Reward template'**
  String get historyEntityRewardTemplate;

  /// No description provided for @historyEntityRewardRequest.
  ///
  /// In en, this message translates to:
  /// **'Reward request'**
  String get historyEntityRewardRequest;

  /// No description provided for @historyEntityFamilyGoal.
  ///
  /// In en, this message translates to:
  /// **'Family goal'**
  String get historyEntityFamilyGoal;

  /// No description provided for @historyEntityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get historyEntityUnknown;

  /// No description provided for @noHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'No history events yet.'**
  String get noHistoryMessage;

  /// No description provided for @loadMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreAction;

  /// No description provided for @loadingAction.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingAction;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingTitle;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @analyticsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get analyticsSummaryTitle;

  /// No description provided for @completedTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get completedTasksLabel;

  /// No description provided for @sparksEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Sparks'**
  String get sparksEarnedLabel;

  /// No description provided for @experienceEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceEarnedLabel;

  /// No description provided for @familyGoalContributedLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get familyGoalContributedLabel;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @periodExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get periodExperienceLabel;

  /// No description provided for @periodSparksLabel.
  ///
  /// In en, this message translates to:
  /// **'Sparks'**
  String get periodSparksLabel;

  /// No description provided for @periodTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get periodTasksLabel;

  /// No description provided for @noRatingMessage.
  ///
  /// In en, this message translates to:
  /// **'No rating data yet.'**
  String get noRatingMessage;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackBetaMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this entry point during beta to collect notes from family testers. Connect the final feedback channel before public release.'**
  String get feedbackBetaMessage;

  /// No description provided for @homeFoundationReady.
  ///
  /// In en, this message translates to:
  /// **'Mobile foundation is ready. Product flows will be connected next.'**
  String get homeFoundationReady;

  /// No description provided for @featurePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{featureName} is prepared for the next implementation step.'**
  String featurePlaceholder(String featureName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
