import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import 'auth_error_messages.dart';
import 'auth_form_validators.dart';
import 'auth_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routePath = '/auth/forgot-password';
  static const routeName = 'forgotPassword';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    final isSubmitting = authState?.isSubmitting ?? false;

    return AppScaffold(
      title: l10n.forgotPasswordTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.forgotPasswordDescription),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (value) {
                if (!AuthFormValidators.isValidEmail(value ?? '')) {
                  return l10n.emailValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.sendResetLinkAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),
            TextButton(
              onPressed: () => context.go(AuthScreen.routePath),
              child: Text(l10n.backToLoginAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final success = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.resetLinkSentMessage
              : authErrorMessage(
                  l10n,
                  ref.read(authControllerProvider).valueOrNull?.failure,
                ),
        ),
      ),
    );
  }
}
