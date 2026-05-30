import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'simulated_time_provider.dart';

final referenceTimeProvider = Provider<DateTime>((ref) {
  final simulatedTimeState = ref.watch(simulatedTimeProvider);

  return simulatedTimeState.value ?? DateTime.now();
});