import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/table_availability.dart';
import 'security_provider.dart';

class TableAvailabilityArgs {
  final int restaurantId;
  final int reservationId;
  TableAvailabilityArgs(this.restaurantId, this.reservationId);

  @override
  bool operator ==(Object other) => identical(this, other) || other is TableAvailabilityArgs && other.restaurantId == restaurantId && other.reservationId == reservationId;
  @override
  int get hashCode => restaurantId.hashCode ^ reservationId.hashCode;
}

final tableAvailabilityProvider = FutureProvider.family.autoDispose<List<TableAvailability>, TableAvailabilityArgs>((ref, args) async {
  final token = await ref.watch(securityProvider.future);
  if (token == null) throw "Utilisateur non connecté";

  return await TableAvailability.getAvailability(args.restaurantId, args.reservationId);
});