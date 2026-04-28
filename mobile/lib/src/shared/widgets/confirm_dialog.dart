import 'package:flutter/material.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirmAction),
            ),
          ],
        ),
      ) ??
      false;
}
