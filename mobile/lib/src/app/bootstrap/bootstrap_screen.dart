import 'package:flutter/material.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../shared/widgets/app_state_widgets.dart';

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  static const routePath = '/bootstrap';
  static const routeName = 'bootstrap';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: AppLoadingState(message: l10n.restoringSession),
      ),
    );
  }
}
