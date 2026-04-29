import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../application/auth_failure.dart';

String authErrorMessage(AppLocalizations l10n, AuthFailure? failure) {
  return switch (failure) {
    AuthFailure.invalidRequest => l10n.authInvalidRequestError,
    AuthFailure.invalidCredentials => l10n.authInvalidCredentialsError,
    AuthFailure.emailAlreadyExists => l10n.authEmailAlreadyExistsError,
    AuthFailure.notFound => l10n.authNotFoundError,
    AuthFailure.resetLinkInvalid => l10n.authResetLinkInvalidError,
    AuthFailure.conflict => l10n.authConflictError,
    AuthFailure.server => l10n.authServerError,
    AuthFailure.network => l10n.authNetworkError,
    AuthFailure.generic || null => l10n.authError,
  };
}
