import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/restaurant_service.dart';

final publicServicesProvider = FutureProvider.family.autoDispose<List<RestaurantService>, int>((ref, restaurantId) async {
  // POur CLient
  return await RestaurantService.getPublicServices(restaurantId);
});