import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/app_time.dart';

final simulatedTimeProvider =
AsyncNotifierProvider<SimulatedTimeNotifier, DateTime?>(
      () => SimulatedTimeNotifier(),
);

class SimulatedTimeNotifier extends AbstractAsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    return await AppTime.getSimulatedTime();
  }

  Future<void> setSimulatedTime(DateTime? time) async {
    final previousState = state;

    try {
      await AppTime.setSimulatedTime(time);
      state = AsyncData(time);
    } catch (e, stack) {
      state = previousState;
      state = AsyncError(e, stack);
    }
  }
  @override
  Future<void> refresh() async {
    final previousState = state;

    try {
      final simulatedTime = await AppTime.getSimulatedTime();
      state = AsyncData(simulatedTime);
    } catch (e, stack) {
      state = previousState;
      state = AsyncError(e, stack);
    }
  }
}