import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import 'auth_error_messages.dart';
import 'auth_form_validators.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  static const routePath = '/auth';
  static const routeName = 'auth';

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    final isSubmitting = authState?.isSubmitting ?? false;

    ref.listen(authControllerProvider, (previous, next) {
      final failure = next.valueOrNull?.failure;
      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(l10n, failure))),
        );
      }
    });

    return AppScaffold(
      title: l10n.authTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              validator: (value) {
                if (!AuthFormValidators.isValidEmail(value ?? '')) {
                  return l10n.emailValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.passwordLabel),
              validator: (value) {
                if (!AuthFormValidators.isValidPassword(value ?? '')) {
                  return l10n.passwordValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.signInAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),
            TextButton(
              onPressed: () => context.go(RegisterScreen.routePath),
              child: Text(l10n.createAccountAction),
            ),
            TextButton(
              onPressed: () => context.go(ForgotPasswordScreen.routePath),
              child: Text(l10n.forgotPasswordAction),
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
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
