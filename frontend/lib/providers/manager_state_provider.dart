import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/security_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import 'manager_state.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(
      () => ManagerStateNotifier(),
);

class ManagerStateNotifier extends AbstractAsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    ref.watch(securityProvider);
    final security = ref.read(securityProvider.notifier);

    if (!security.isLoggedIn) {
      throw "Utilisateur non connecté";
    }

    return await ManagerState.getManagerState();
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    try {
      final managerState = await ManagerState.getManagerState();
      state = AsyncData(managerState);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}