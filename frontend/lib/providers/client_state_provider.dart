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

    try {
      return await ClientState.getClientState(
        reservationsFilter: ReservationsFilter.pending,
      );
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }

  void setReservationsFilter(ReservationsFilter filter) {
    final currentState = state.value;

    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(reservationsFilter: filter),
    );
  }

  @override
  Future<void> refresh() async {
    final currentFilter =
        state.value?.reservationsFilter ??
            ReservationsFilter.pending;

    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    try {
      final clientState = await ClientState.getClientState(
        reservationsFilter: currentFilter,
      );

      state = AsyncData(clientState);

    } catch (e, stack) {

      state = AsyncError(e, stack);
    }
  }
}
