// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Очаг';

  @override
  String get authTitle => 'Вход';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get forgotPasswordTitle => 'Восстановление доступа';

  @override
  String get resetPasswordTitle => 'Новый пароль';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get refreshAction => 'Обновить';

  @override
  String get retryAction => 'Повторить';

  @override
  String get signInAction => 'Войти';

  @override
  String get createAccountAction => 'Создать аккаунт';

  @override
  String get forgotPasswordAction => 'Забыли пароль?';

  @override
  String get sendResetLinkAction => 'Отправить ссылку';

  @override
  String get resetPasswordAction => 'Сменить пароль';

  @override
  String get backToLoginAction => 'Вернуться ко входу';

  @override
  String get logoutAction => 'Выйти';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get confirmPasswordLabel => 'Повторите пароль';

  @override
  String get displayNameLabel => 'Имя';

  @override
  String get emailValidationError => 'Введите корректный email.';

  @override
  String get passwordValidationError => 'Минимум 8 символов.';

  @override
  String get passwordsDoNotMatchError => 'Пароли не совпадают.';

  @override
  String get displayNameValidationError => 'Имя слишком длинное.';

  @override
  String get authError => 'Что-то пошло не так. Попробуйте еще раз.';

  @override
  String get genericErrorMessage => 'Что-то пошло не так. Попробуйте еще раз.';

  @override
  String get betaBadgeLabel => 'Бета';

  @override
  String get resetLinkSentMessage =>
      'Если email существует, инструкции отправлены.';

  @override
  String get passwordResetDoneMessage => 'Пароль обновлен. Можно войти.';

  @override
  String get resetTokenMissingMessage => 'Токен восстановления отсутствует.';

  @override
  String get forgotPasswordDescription =>
      'Введите email, и мы отправим инструкции, если аккаунт существует.';

  @override
  String get restoringSession => 'Восстанавливаем сессию...';

  @override
  String get saveAction => 'Сохранить';

  @override
  String get cancelAction => 'Отмена';

  @override
  String get confirmAction => 'Подтвердить';

  @override
  String get onboardingTitle => 'Онбординг';

  @override
  String get familySetupTitle => 'Настройка семьи';

  @override
  String get createFamilyTitle => 'Создать семью';

  @override
  String get joinFamilyTitle => 'Присоединиться к семье';

  @override
  String get familySettingsTitle => 'Настройки семьи';

  @override
  String get familyNameLabel => 'Название семьи';

  @override
  String get inviteCodeLabel => 'Код или ссылка приглашения';

  @override
  String get familyNameValidationError => 'Используйте 1-80 символов.';

  @override
  String get inviteCodeValidationError => 'Введите код или ссылку приглашения.';

  @override
  String get createFamilyAction => 'Создать семью';

  @override
  String get joinFamilyAction => 'Войти в семью';

  @override
  String get updateFamilyNameTitle => 'Название семьи';

  @override
  String get familyInviteTitle => 'Приглашение';

  @override
  String get createInviteLinkAction => 'Создать ссылку';

  @override
  String get regenerateInviteCodeAction => 'Обновить код';

  @override
  String get copyInviteLinkAction => 'Скопировать ссылку';

  @override
  String get familyMembersTitle => 'Участники';

  @override
  String get familyDangerZoneTitle => 'Опасная зона';

  @override
  String get leaveFamilyAction => 'Покинуть семью';

  @override
  String get requestFamilyDeleteAction => 'Запросить удаление семьи';

  @override
  String get removeMemberAction => 'Удалить участника';

  @override
  String get transferCreatorAction => 'Передать создателя';

  @override
  String get makeAdultAction => 'Сделать взрослым';

  @override
  String get makeChildAction => 'Сделать ребенком';

  @override
  String get familyRoleOwner => 'Создатель';

  @override
  String get familyRoleAdult => 'Взрослый';

  @override
  String get familyRoleChild => 'Ребенок';

  @override
  String get noFamilyMessage => 'Активной семьи пока нет.';

  @override
  String get inviteCodeNotCreatedMessage => 'Код приглашения еще не создан.';

  @override
  String get leaveFamilyConfirmMessage =>
      'Вы потеряете доступ к общим данным этой семьи.';

  @override
  String get removeMemberConfirmMessage =>
      'Этот участник потеряет доступ к семье.';

  @override
  String get transferCreatorConfirmMessage =>
      'Права создателя перейдут этому участнику.';

  @override
  String get regenerateInviteConfirmMessage =>
      'Предыдущий код приглашения перестанет работать.';

  @override
  String get requestFamilyDeleteConfirmMessage =>
      'Для завершения удаления на email придет подтверждение.';

  @override
  String get familyCreatedMessage => 'Семья создана.';

  @override
  String get familyJoinedMessage => 'Вы присоединились к семье.';

  @override
  String get familyUpdatedMessage => 'Семья обновлена.';

  @override
  String get familyLeftMessage => 'Вы покинули семью.';

  @override
  String get memberRoleUpdatedMessage => 'Роль участника обновлена.';

  @override
  String get memberRemovedMessage => 'Участник удален.';

  @override
  String get creatorTransferredMessage => 'Создатель передан.';

  @override
  String get inviteCreatedMessage => 'Приглашение создано.';

  @override
  String get inviteRegeneratedMessage => 'Код приглашения обновлен.';

  @override
  String get familyDeleteRequestedMessage =>
      'Проверьте email, чтобы подтвердить удаление семьи.';

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeTotalExperienceLabel => 'Всего XP';

  @override
  String get homeAvailableFreeRewardsLabel => 'Бесплатные награды';

  @override
  String get homeQuickActionsTitle => 'Быстрые действия';

  @override
  String get homeMyActiveTasksTitle => 'Мои активные задачи';

  @override
  String get homeWaitingForYouTitle => 'Ждет вашего действия';

  @override
  String get homeFamilyGoalTitle => 'Семейная цель';

  @override
  String get homeLatestEventsTitle => 'Последние события';

  @override
  String get homeViewAllAction => 'Все';

  @override
  String get homeOpenGoalAction => 'Открыть цель';

  @override
  String get homeOpenRewardsAction => 'Открыть награды';

  @override
  String get homeSendFeedbackAction => 'Отправить отзыв';

  @override
  String get homeNoActiveTasksMessage => 'У вас нет активных задач.';

  @override
  String get homeNoWaitingActionsMessage =>
      'Сейчас ничего не требует вашего действия.';

  @override
  String get homeNoRecentEventsMessage => 'Последних событий пока нет.';

  @override
  String get homeTaskReviewAction => 'Проверить задачу';

  @override
  String get homeInitiativeDecisionAction => 'Решить инициативу';

  @override
  String get homeRewardFulfillmentAction => 'Отметить награду выполненной';

  @override
  String get homeRewardReceivingAction => 'Подтвердить получение награды';

  @override
  String get homeRewardCancelResponseAction => 'Ответить на отмену';

  @override
  String get homeGoalCompletionAction => 'Подтвердить завершение цели';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get createTaskTitle => 'Создать задачу';

  @override
  String get editTaskTitle => 'Редактировать задачу';

  @override
  String get taskDetailsTitle => 'Детали задачи';

  @override
  String get taskTitleLabel => 'Название';

  @override
  String get taskDescriptionLabel => 'Описание';

  @override
  String get taskAssigneeLabel => 'Исполнитель';

  @override
  String get taskCreatorLabel => 'Создатель';

  @override
  String get taskDueDateLabel => 'Срок';

  @override
  String get taskRewardLabel => 'Награда';

  @override
  String get taskRecurrenceLabel => 'Повтор';

  @override
  String get taskTemplateLabel => 'Шаблон';

  @override
  String get noTemplateLabel => 'Без шаблона';

  @override
  String get noDueDateLabel => 'Без срока';

  @override
  String get unassignedLabel => 'Не назначено';

  @override
  String get unknownUserLabel => 'Неизвестный пользователь';

  @override
  String get rewardSparksLabel => 'Искры';

  @override
  String get rewardExperienceLabel => 'Опыт';

  @override
  String get sparksShortLabel => 'искр';

  @override
  String get experienceShortLabel => 'xp';

  @override
  String get taskTitleValidationError => 'Используйте 1-120 символов.';

  @override
  String get taskAssigneeValidationError => 'Выберите исполнителя.';

  @override
  String get rewardValidationError => 'Введите число от 0 до 100000.';

  @override
  String get createTaskAction => 'Создать задачу';

  @override
  String get deleteTaskAction => 'Удалить задачу';

  @override
  String get submitTaskAction => 'Отправить на проверку';

  @override
  String get approveTaskAction => 'Подтвердить';

  @override
  String get rejectTaskAction => 'Отклонить';

  @override
  String get includeHistoryAction => 'Показать историю';

  @override
  String get noTasksMessage => 'Задач пока нет.';

  @override
  String get deleteTaskConfirmMessage =>
      'Задача будет удалена из активного списка.';

  @override
  String get rejectTaskConfirmMessage =>
      'Задача вернется в активный статус для доработки.';

  @override
  String get taskReturnedToActiveMessage =>
      'Задачу вернули, она снова активна.';

  @override
  String get taskStatusActive => 'Активна';

  @override
  String get taskStatusPending => 'На проверке';

  @override
  String get taskStatusConfirmed => 'Подтверждена';

  @override
  String get taskStatusSkipped => 'Пропущена';

  @override
  String get taskRecurrenceNone => 'Без повтора';

  @override
  String get taskRecurrenceDaily => 'Ежедневно';

  @override
  String get taskRecurrenceWeekly => 'Еженедельно';

  @override
  String get taskCommentsTitle => 'Комментарии';

  @override
  String get taskCommentLabel => 'Комментарий';

  @override
  String get addCommentAction => 'Добавить комментарий';

  @override
  String get noTaskCommentsMessage => 'Комментариев пока нет.';

  @override
  String get taskTemplatesTitle => 'Шаблоны задач';

  @override
  String get createTaskTemplateTitle => 'Создать шаблон';

  @override
  String get editTaskTemplateTitle => 'Редактировать шаблон';

  @override
  String get taskCreatedMessage => 'Задача создана.';

  @override
  String get taskUpdatedMessage => 'Задача обновлена.';

  @override
  String get taskDeletedMessage => 'Задача удалена.';

  @override
  String get taskSubmittedMessage => 'Задача отправлена на проверку.';

  @override
  String get taskApprovedMessage => 'Задача подтверждена.';

  @override
  String get taskRejectedMessage => 'Задача возвращена.';

  @override
  String get taskCommentAddedMessage => 'Комментарий добавлен.';

  @override
  String get taskTemplateCreatedMessage => 'Шаблон создан.';

  @override
  String get taskTemplateUpdatedMessage => 'Шаблон обновлен.';

  @override
  String get initiativesTitle => 'Инициативы';

  @override
  String get initiativesInTasksDescription =>
      'Идеи участников семьи, которым нужны обсуждение и решение.';

  @override
  String get createInitiativeTitle => 'Создать инициативу';

  @override
  String get initiativeDetailsTitle => 'Детали инициативы';

  @override
  String get initiativeTitleLabel => 'Название';

  @override
  String get initiativeDescriptionLabel => 'Описание';

  @override
  String get initiativeTitleValidationError => 'Используйте 1-120 символов.';

  @override
  String get createInitiativeAction => 'Создать инициативу';

  @override
  String get initiativeAuthorLabel => 'Автор';

  @override
  String get initiativeDecidedByLabel => 'Решение принял';

  @override
  String get discussionLockedUntilLabel => 'Обсуждение до';

  @override
  String get finalSparksLabel => 'Итоговые искры';

  @override
  String get finalSparksError => 'Введите число от 1 до 100000.';

  @override
  String get initiativeReviewTitle => 'Решение';

  @override
  String get rejectInitiativeConfirmMessage =>
      'Инициатива будет закрыта как отклоненная.';

  @override
  String get approveInitiativeAction => 'Одобрить с искрами';

  @override
  String get approveWithoutRewardAction => 'Одобрить без награды';

  @override
  String get rejectInitiativeAction => 'Отклонить';

  @override
  String get noInitiativesMessage => 'Инициатив пока нет.';

  @override
  String get initiativeDiscussionLockMessage =>
      'Обсуждение еще открыто. Финальное решение будет доступно после окончания блокировки.';

  @override
  String get initiativeNextDiscussion => 'Следующий шаг: семейное обсуждение.';

  @override
  String get initiativeNextReviewer => 'Следующий шаг: решение проверяющего.';

  @override
  String get initiativeNextFinished => 'Решение финальное.';

  @override
  String get initiativeStatusDiscussion => 'Обсуждение';

  @override
  String get initiativeStatusWaitingDecision => 'Ожидает решения';

  @override
  String get initiativeStatusApproved => 'Одобрена';

  @override
  String get initiativeStatusApprovedWithoutReward => 'Одобрена без награды';

  @override
  String get initiativeStatusRejected => 'Отклонена';

  @override
  String get initiativeCreatedMessage => 'Инициатива создана.';

  @override
  String get initiativeApprovedMessage => 'Инициатива одобрена.';

  @override
  String get initiativeApprovedWithoutRewardMessage =>
      'Инициатива одобрена без награды.';

  @override
  String get initiativeRejectedMessage => 'Инициатива отклонена.';

  @override
  String get rewardsTitle => 'Награды';

  @override
  String get rewardDetailsTitle => 'Детали награды';

  @override
  String get createRewardTitle => 'Предложить награду';

  @override
  String get rewardTitleLabel => 'Название';

  @override
  String get rewardDescriptionLabel => 'Описание';

  @override
  String get rewardPriceLabel => 'Цена';

  @override
  String get rewardPaymentModeLabel => 'Оплата';

  @override
  String get rewardTemplateLabel => 'Шаблон';

  @override
  String get rewardTitleValidationError => 'Используйте 1-120 символов.';

  @override
  String get rewardPriceValidationError => 'Введите число от 0 до 100000.';

  @override
  String get createRewardAction => 'Предложить награду';

  @override
  String get requestRewardAction => 'Запросить награду';

  @override
  String get approveRewardAction => 'Одобрить';

  @override
  String get repriceRewardAction => 'Одобрить с новой ценой';

  @override
  String get rejectRewardAction => 'Отклонить';

  @override
  String get rewardReviewTitle => 'Проверка предложения';

  @override
  String get rejectRewardConfirmMessage =>
      'Предложение награды будет закрыто как отклоненное.';

  @override
  String get rewardStatusProposed => 'Предложена';

  @override
  String get rewardStatusAvailable => 'Доступна';

  @override
  String get rewardStatusRejected => 'Отклонена';

  @override
  String get rewardPaymentSparks => 'Оплата искрами';

  @override
  String get rewardPaymentLevelFree => 'Бесплатная награда уровня';

  @override
  String get rewardPaymentHint =>
      'Награды за искры списываются сразу при запросе. Бесплатная награда уровня используется, если backend подтвердит доступность права.';

  @override
  String get rewardSparksChargeHint =>
      'Искры списываются сразу после создания запроса.';

  @override
  String get rewardLevelFreeAvailabilityHint =>
      'Использует право бесплатной награды текущего уровня, если оно еще доступно.';

  @override
  String get rewardLevelFreeUsedLabel =>
      'Использована бесплатная награда уровня';

  @override
  String get rewardProviderLabel => 'Исполнитель';

  @override
  String get rewardProposerLabel => 'Предложил';

  @override
  String get rewardRequesterLabel => 'Запросил';

  @override
  String get noRewardsMessage => 'Наград пока нет.';

  @override
  String get rewardTemplatesTitle => 'Шаблоны наград';

  @override
  String get createRewardTemplateTitle => 'Создать шаблон награды';

  @override
  String get editRewardTemplateTitle => 'Редактировать шаблон награды';

  @override
  String get rewardRequestsTitle => 'Недавние запросы';

  @override
  String get rewardRequestDetailsTitle => 'Запрос награды';

  @override
  String get rewardRequestStatusInProgress => 'В исполнении';

  @override
  String get rewardRequestStatusFulfilled => 'Выполнена';

  @override
  String get rewardRequestStatusReceived => 'Завершена';

  @override
  String get rewardRequestStatusCancelRequested => 'Запрошена отмена';

  @override
  String get rewardRequestStatusCancelled => 'Отменена';

  @override
  String get markRewardFulfilledAction => 'Отметить выполненной';

  @override
  String get confirmRewardReceivedAction => 'Подтвердить получение';

  @override
  String get requestRewardCancelAction => 'Запросить отмену';

  @override
  String get approveRewardCancelAction => 'Подтвердить отмену';

  @override
  String get rejectRewardCancelAction => 'Оставить активной';

  @override
  String get levelSnapshotLabel => 'Уровень';

  @override
  String get rewardFulfilledAtLabel => 'Выполнена';

  @override
  String get rewardReceivedAtLabel => 'Получена';

  @override
  String get rewardCancelRequestedAtLabel => 'Отмена запрошена';

  @override
  String get rewardRequestInProgressHint =>
      'Награда в исполнении. Следующий шаг за исполнителем.';

  @override
  String get rewardRequestFulfilledHint =>
      'Исполнитель отметил награду выполненной. Получатель должен подтвердить получение.';

  @override
  String get rewardRequestReceivedHint => 'Награда завершена.';

  @override
  String get rewardRequestCancelHint =>
      'Запрошена отмена. Второй участник должен ответить.';

  @override
  String get rewardRequestCancelledHint => 'Запрос награды отменен.';

  @override
  String get requestRewardCancelConfirmMessage =>
      'Второй участник должен будет ответить на запрос отмены.';

  @override
  String get approveRewardCancelConfirmMessage =>
      'Запрос награды будет отменен.';

  @override
  String get rejectRewardCancelConfirmMessage =>
      'Запрос награды останется активным.';

  @override
  String get rewardCreatedMessage => 'Награда предложена.';

  @override
  String get rewardApprovedMessage => 'Награда одобрена.';

  @override
  String get rewardRepricedMessage => 'Награда одобрена с новой ценой.';

  @override
  String get rewardRejectedMessage => 'Награда отклонена.';

  @override
  String get rewardTemplateCreatedMessage => 'Шаблон награды создан.';

  @override
  String get rewardTemplateUpdatedMessage => 'Шаблон награды обновлен.';

  @override
  String get rewardRequestedMessage => 'Награда запрошена.';

  @override
  String get rewardFulfilledMessage => 'Награда отмечена выполненной.';

  @override
  String get rewardReceivedMessage => 'Награда завершена.';

  @override
  String get rewardCancelRequestedMessage => 'Отмена запрошена.';

  @override
  String get rewardCancelledMessage => 'Награда отменена.';

  @override
  String get rewardCancelRejectedMessage => 'Отмена отклонена.';

  @override
  String get goalTitle => 'Цель';

  @override
  String get createFamilyGoalTitle => 'Создать семейную цель';

  @override
  String get updateFamilyGoalTitle => 'Обновить семейную цель';

  @override
  String get familyGoalTitleLabel => 'Название';

  @override
  String get familyGoalDescriptionLabel => 'Описание';

  @override
  String get familyGoalTargetLabel => 'Цель в искрах';

  @override
  String get familyGoalTargetAtLabel => 'Дата цели';

  @override
  String get familyGoalSparksLabel => 'Искры';

  @override
  String get familyGoalTitleValidationError => 'Используйте 1-120 символов.';

  @override
  String get familyGoalTargetValidationError =>
      'Введите число от 1 до 1000000.';

  @override
  String get familyGoalSparksError => 'Введите число от 1 до 1000000.';

  @override
  String get noFamilyGoalMessage => 'Семейной цели пока нет.';

  @override
  String get createFamilyGoalAction => 'Создать цель';

  @override
  String get updateFamilyGoalAction => 'Обновить цель';

  @override
  String get contributeFamilyGoalAction => 'Вложить';

  @override
  String get confirmFamilyGoalCompletionAction => 'Подтвердить завершение';

  @override
  String get familyGoalStatusActive => 'Активна';

  @override
  String get familyGoalStatusAwaitingExecution => 'Ожидает исполнения';

  @override
  String get familyGoalStatusCompleted => 'Завершена';

  @override
  String get familyGoalStatusCancelled => 'Отменена';

  @override
  String get familyGoalContributionTitle => 'Вклад';

  @override
  String get spentSparksLabel => 'Потрачено искр';

  @override
  String get gainedExperienceLabel => 'Получено опыта';

  @override
  String get familyGoalContributionWarning =>
      'Вклад необратим. Искры списываются сразу.';

  @override
  String get familyGoalConfirmationsTitle => 'Подтверждения завершения';

  @override
  String get familyGoalConfirmedMembersLabel => 'Уже подтвердили';

  @override
  String get familyGoalPendingMembersLabel => 'Еще ожидаем';

  @override
  String get noneLabel => 'Нет';

  @override
  String get familyGoalAchievedMessage =>
      'Цель достигнута. Семья может завершить ее после исполнения.';

  @override
  String get familyGoalCompletedSummaryMessage =>
      'Это последняя завершенная семейная цель.';

  @override
  String get familyGoalCreatedMessage => 'Семейная цель создана.';

  @override
  String get familyGoalUpdatedMessage => 'Семейная цель обновлена.';

  @override
  String get familyGoalContributedMessage => 'Вклад добавлен.';

  @override
  String get familyGoalConfirmedMessage => 'Завершение подтверждено.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get unreadNotificationLabel => 'Новые';

  @override
  String get readNotificationLabel => 'Прочитано';

  @override
  String get notificationReadAtLabel => 'Прочитано';

  @override
  String get markAsReadAction => 'Отметить прочитанным';

  @override
  String get noNotificationsMessage => 'Уведомлений пока нет.';

  @override
  String get historyTitle => 'История';

  @override
  String get historyEntityFilterLabel => 'Сущность';

  @override
  String get historyEventTypeFilterLabel => 'Тип события';

  @override
  String get historyActorLabel => 'Автор';

  @override
  String get allHistoryEntitiesLabel => 'Все сущности';

  @override
  String get historyEntityFamily => 'Семья';

  @override
  String get historyEntityTask => 'Задача';

  @override
  String get historyEntityTaskTemplate => 'Шаблон задачи';

  @override
  String get historyEntityInitiative => 'Инициатива';

  @override
  String get historyEntityReward => 'Награда';

  @override
  String get historyEntityRewardTemplate => 'Шаблон награды';

  @override
  String get historyEntityRewardRequest => 'Запрос награды';

  @override
  String get historyEntityFamilyGoal => 'Семейная цель';

  @override
  String get historyEntityUnknown => 'Неизвестно';

  @override
  String get noHistoryMessage => 'Событий пока нет.';

  @override
  String get loadMoreAction => 'Загрузить еще';

  @override
  String get loadingAction => 'Загрузка...';

  @override
  String get ratingTitle => 'Рейтинг';

  @override
  String get periodDay => 'День';

  @override
  String get periodWeek => 'Неделя';

  @override
  String get periodMonth => 'Месяц';

  @override
  String get periodAllTime => 'Все время';

  @override
  String get analyticsSummaryTitle => 'Сводка';

  @override
  String get completedTasksLabel => 'Задачи';

  @override
  String get sparksEarnedLabel => 'Искры';

  @override
  String get experienceEarnedLabel => 'Опыт';

  @override
  String get familyGoalContributedLabel => 'Цель';

  @override
  String get levelLabel => 'Уровень';

  @override
  String get periodExperienceLabel => 'Опыт';

  @override
  String get periodSparksLabel => 'Искры';

  @override
  String get periodTasksLabel => 'Задачи';

  @override
  String get noRatingMessage => 'Данных рейтинга пока нет.';

  @override
  String get feedbackTitle => 'Обратная связь';

  @override
  String get feedbackBetaMessage =>
      'Используйте этот вход во время беты, чтобы собирать заметки от семейных тестировщиков. Перед публичным релизом подключите финальный канал обратной связи.';

  @override
  String get homeFoundationReady =>
      'Мобильная основа готова. Продуктовые сценарии будут подключены следующим шагом.';

  @override
  String featurePlaceholder(String featureName) {
    return '$featureName подготовлен для следующего шага реализации.';
  }
}
