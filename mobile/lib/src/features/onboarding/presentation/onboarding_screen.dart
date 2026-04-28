import 'package:flutter/material.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/feature_placeholder_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';
  static const routeName = 'onboarding';

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: AppLocalizations.of(context).onboardingTitle,
    );
  }
}
