import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/restaurant_service.dart';
import 'security_provider.dart';

// 1. autoDispose : On vide la mémoire quand on quitte la page du restaurant
// 2. family : On crée un provider spécifique par ID de restaurant (int)
final restaurantServicesProvider = FutureProvider.family.autoDispose<List<RestaurantService>, int>((ref, restaurantId) async {

  // on s'assure que le manager est bien connecté
  final token = await ref.watch(securityProvider.future);
  if (token == null) throw "Utilisateur non connecté";

  return await RestaurantService.getRestaurantServices(restaurantId);
});