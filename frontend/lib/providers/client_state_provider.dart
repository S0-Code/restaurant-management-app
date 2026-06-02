import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c05/models/reservation.dart';
import 'package:prbd_2526_c05/models/restaurant_detail.dart';
import 'package:prbd_2526_c05/providers/security_provider.dart';
import 'package:prbd_2526_c05/providers/simulated_time_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import 'client_state.dart';
import '../models/restaurant_service.dart';

final clientStateProvider =
AsyncNotifierProvider<ClientStateNotifier, ClientState>(
      () => ClientStateNotifier(),
);

class ClientStateNotifier extends AbstractAsyncNotifier<ClientState> {
  static const int maxRestaurantSearchResults = 6;

  @override
  Future<ClientState> build() async {
    ref.watch(simulatedTimeProvider);
    ref.watch(securityProvider);

    final reservations = await Reservation.getReservations();

    final currentState = state.value;

    if (currentState == null) {
      return ClientState(
        reservations: reservations,
        reservationsFilter: ReservationsFilter.pending,
        currentReservation: null,
        restaurants: const [],
        restaurantSearchText: '',
        currentRestaurant: null,
        hasTooManyRestaurantResults: false,
      );
    }

    return currentState.copyWith(
      reservations: reservations,
    );
  }


  void setReservationsFilter(ReservationsFilter filter) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(reservationsFilter: filter),
    );
  }

  void setCurrentReservation(Reservation reservation) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(currentReservation: reservation),
    );
  }

  void setCurrentRestaurant(RestaurantDetail restaurant) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(
        currentRestaurant: restaurant,
        currentRestaurantServices: const [],
      ),
    );
  }
  Future<void> loadCurrentRestaurantServices() async {
    final currentState = state.value;
    final restaurant = currentState?.currentRestaurant;

    if (currentState == null || restaurant == null) return;

    final services = await RestaurantService.getRestaurantServices(
      restaurant.id,
    );

    state = AsyncData(
      currentState.copyWith(
        currentRestaurantServices: services,
      ),
    );
  }

  Future<void> searchRestaurants(String searchText) async {
    final currentState = state.value;
    if (currentState == null) return;

    final restaurants = await RestaurantDetail.searchClientRestaurants(
      searchText: searchText,
      limit: maxRestaurantSearchResults + 1,
    );

    state = AsyncData(
      currentState.copyWith(
        restaurantSearchText: searchText,
        restaurants: restaurants.take(maxRestaurantSearchResults).toList(),
        hasTooManyRestaurantResults:
        restaurants.length > maxRestaurantSearchResults,
      ),
    );
  }

  @override
  Future<void> refresh() async {
    final currentFilter =
        state.value?.reservationsFilter ?? ReservationsFilter.pending;

    final currentReservation = state.value?.currentReservation;
    final restaurantSearchText = state.value?.restaurantSearchText ?? '';
    final currentRestaurant = state.value?.currentRestaurant;

    state = const AsyncLoading();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final clientState = await ClientState.getClientState(
        reservationsFilter: currentFilter,
        currentReservation: currentReservation,
        restaurantSearchText: restaurantSearchText,
        currentRestaurant: currentRestaurant,
      );

      state = AsyncData(clientState);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}