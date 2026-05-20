import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../core/config/app_config.dart';

Future<void> showPrivacyPolicyDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.privacyPolicyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.privacyPolicyDescription),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicyUrlLabel,
              style: Theme.of(dialogContext).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            const SelectableText(AppConfig.privacyPolicyUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppConfig.privacyPolicyUrl),
              );
              if (!dialogContext.mounted) {
                return;
              }
              Navigator.of(dialogContext).pop();
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.privacyPolicyCopiedMessage)),
              );
            },
            child: Text(l10n.privacyPolicyCopyAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.confirmAction),
          ),
        ],
      );
    },
  );
}
