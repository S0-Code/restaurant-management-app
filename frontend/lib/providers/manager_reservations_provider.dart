import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/manager_reservation.dart';
import 'security_provider.dart';

final managerReservationsProvider = FutureProvider.family.autoDispose<List<ManagerReservation>, int>((ref, restaurantId) async {
  final token = await ref.watch(securityProvider.future);
  if (token == null) throw "Utilisateur non connecté";

  return await ManagerReservation.getForRestaurant(restaurantId);
});