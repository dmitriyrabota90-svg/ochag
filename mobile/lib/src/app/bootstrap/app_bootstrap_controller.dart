import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/family_setup/application/family_controller.dart';

final appBootstrapControllerProvider =
    AsyncNotifierProvider<AppBootstrapController, AppBootstrapState>(
  AppBootstrapController.new,
);

class AppBootstrapState {
  const AppBootstrapState({
    required this.hasAccessToken,
    required this.hasFamily,
  });

  final bool hasAccessToken;
  final bool hasFamily;
}

class AppBootstrapController extends AsyncNotifier<AppBootstrapState> {
  @override
  Future<AppBootstrapState> build() async {
    final authState = await ref.watch(authControllerProvider.future);
    if (!authState.isAuthenticated) {
      return const AppBootstrapState(
        hasAccessToken: false,
        hasFamily: false,
      );
    }

    final familyState = await ref.watch(familyControllerProvider.future);

    return AppBootstrapState(
      hasAccessToken: true,
      hasFamily: familyState.hasFamily,
    );
  }
}
