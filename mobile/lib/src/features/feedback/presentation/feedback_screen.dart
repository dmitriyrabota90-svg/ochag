import 'package:flutter/material.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  static const routePath = '/feedback';
  static const routeName = 'feedback';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.feedbackTitle,
      body: ListView(
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
        ],
      ),
    );
  }
}
