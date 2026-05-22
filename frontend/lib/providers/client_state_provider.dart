import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c05/providers/security_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import 'client_state.dart';

final clientStateProvider = AsyncNotifierProvider<ClientStateNotifier, ClientState>(
    () => ClientStateNotifier(),
);

class ClientStateNotifier extends AbstractAsyncNotifier<ClientState> {

  @override
  Future<ClientState> build() async {
    ref.watch(securityProvider);

    final security = ref.read(securityProvider.notifier);

    if (!security.isLoggedIn) {
      throw "Utilisateur non connecté";
    }

    return await ClientState.getClientState();
  }

  @override
  Future<void> refresh() {
    // TODO: implement refresh
    throw UnimplementedError();
  }

}