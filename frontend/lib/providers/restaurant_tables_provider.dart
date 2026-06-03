import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/restaurant_table.dart';
import 'security_provider.dart';

final restaurantTablesProvider = FutureProvider.family.autoDispose<List<RestaurantTable>, int>((ref, restaurantId) async {

  // Petite vérification de sécurité : l'utilisateur est-il connecté ?
  final token = await ref.watch(securityProvider.future);
  if (token == null) throw "Utilisateur non connecté";

  // On demande au modèle d'aller chercher les données
  return await RestaurantTable.getForRestaurant(restaurantId);
});