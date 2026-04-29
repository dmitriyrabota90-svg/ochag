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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    required this.token,
    super.key,
  });

  static const routePath = '/auth/reset-password';
  static const routeName = 'resetPassword';
  static const routeWithTokenName = 'resetPasswordWithToken';

  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    final isSubmitting = authState?.isSubmitting ?? false;
    final token = widget.token;

    return AppScaffold(
      title: l10n.resetPasswordTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (token == null || token.isEmpty)
              Text(l10n.resetTokenMissingMessage)
            else ...[
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                validator: (value) {
                  if (!AuthFormValidators.isValidPassword(value ?? '')) {
                    return l10n.passwordValidationError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration:
                    InputDecoration(labelText: l10n.confirmPasswordLabel),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return l10n.passwordsDoNotMatchError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.resetPasswordAction,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
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
    final token = widget.token;
    if (token == null || token.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final success =
        await ref.read(authControllerProvider.notifier).resetPassword(
              token: token,
              password: _passwordController.text,
            );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.passwordResetDoneMessage
              : authErrorMessage(
                  l10n,
                  ref.read(authControllerProvider).valueOrNull?.failure,
                ),
        ),
      ),
    );
    if (success) {
      context.go(AuthScreen.routePath);
    }
  }
}
