import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c05/models/reservation.dart';
import 'package:prbd_2526_c05/models/restaurant_detail.dart';
import 'package:prbd_2526_c05/providers/reference_time_provider.dart';
import 'package:prbd_2526_c05/providers/security_provider.dart';
import 'package:prbd_2526_c05/providers/simulated_time_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/reservation_slot.dart';
import 'client_state.dart';
import '../models/restaurant_service.dart';
import 'dart:async';

final clientStateProvider =
AsyncNotifierProvider<ClientStateNotifier, ClientState>(
      () => ClientStateNotifier(),
);

class ClientStateNotifier extends AbstractAsyncNotifier<ClientState> {
  static const int maxRestaurantSearchResults = 6;
  Timer? _guestsDebounce;

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

  Future<void> prepareNewReservation() async {
    final currentState = state.value;
    final restaurant = currentState?.currentRestaurant;

    if (currentState == null || restaurant == null) return;

    final now = ref.read(referenceTimeProvider);
    final initialDate = DateTime(now.year, now.month, now.day);

    state = AsyncData(
      currentState.copyWith(
        newReservationDate: initialDate,
        newReservationGuests: 2,
        newReservationSpecialRequests: '',
        reservationSlots: const [],
        isLoadingReservationSlots: true,
        isEditingReservation: false,
        editedReservationId: null,
      ),
    );

    await loadReservationSlots();
  }


  Future<void> prepareEditReservation() async {
    final currentState = state.value;
    final reservation = currentState?.currentReservation;

    if (currentState == null || reservation == null || reservation.id == null) return;

    final initialDate = DateTime(
      reservation.dateTime.year,
      reservation.dateTime.month,
      reservation.dateTime.day,
    );

    state = AsyncData(
      currentState.copyWith(
        newReservationDate: initialDate,
        selectedReservationSlot: null,
        newReservationGuests: reservation.numberOfGuests,
        newReservationSpecialRequests: reservation.specialRequests ?? '',
        reservationSlots: const [],
        isLoadingReservationSlots: true,
        isEditingReservation: true,
        editedReservationId: reservation.id,
      ),
    );

    await loadReservationSlots(preferredDateTime: reservation.dateTime);
  }

  Future<void> loadReservationSlots({DateTime? preferredDateTime}) async {
    final currentState = state.value;
    final date = currentState?.newReservationDate;

    if (currentState == null || date == null) return;

    final restaurantId = currentState.isEditingReservation
        ? currentState.currentReservation?.restaurantId
        : currentState.currentRestaurant?.id;

    if (restaurantId == null) return;

    state = AsyncData(
      currentState.copyWith(
        isLoadingReservationSlots: true,
        reservationSlots: const [],
        selectedReservationSlot: null,
      ),
    );

    final slots = await Reservation.getReservationSlots(
      restaurantId: restaurantId,
      date: date,
      numberOfGuests: currentState.newReservationGuests,
      ignoredReservationId: currentState.isEditingReservation
          ? currentState.editedReservationId
          : null,
    );

    ReservationSlot? selectedSlot;

    if (preferredDateTime != null) {
      for (final slot in slots) {
        if (slot.slotDateTime == preferredDateTime) {
          selectedSlot = slot;
          break;
        }
      }
    }

    selectedSlot ??= slots.isNotEmpty ? slots.first : null;

    state = AsyncData(
      state.value!.copyWith(
        reservationSlots: slots,
        selectedReservationSlot: selectedSlot,
        isLoadingReservationSlots: false,
      ),
    );
  }

  Future<void> setNewReservationDate(DateTime date) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(
        newReservationDate: DateTime(date.year, date.month, date.day),
      ),
    );

    await loadReservationSlots();
  }

  Future<void> nextReservationDate() async {
    final currentState = state.value;
    final date = currentState?.newReservationDate;
    if (currentState == null || date == null) return;

    await setNewReservationDate(date.add(const Duration(days: 1)));
  }

  Future<void> previousReservationDate() async {
    final currentState = state.value;
    final date = currentState?.newReservationDate;
    if (currentState == null || date == null) return;

    await setNewReservationDate(date.subtract(const Duration(days: 1)));
  }

  void setSelectedReservationSlot(ReservationSlot slot) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(selectedReservationSlot: slot),
    );
  }



  void setNewReservationGuests(int guests) {
    final currentState = state.value;
    if (currentState == null || guests < 1) return;

    state = AsyncData(
      currentState.copyWith(newReservationGuests: guests),
    );

    _guestsDebounce?.cancel();
    _guestsDebounce = Timer(const Duration(milliseconds: 500), () {
      loadReservationSlots();
    });
  }


  void setNewReservationSpecialRequests(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(newReservationSpecialRequests: value),
    );
  }

  Future<void> createReservation() async {
    final currentState = state.value;
    final restaurant = currentState?.currentRestaurant;
    final slot = currentState?.selectedReservationSlot;

    if (currentState == null || restaurant == null || slot == null) return;

    final newReservation = await Reservation.createReservation(
      restaurantId: restaurant.id,
      dateTime: slot.slotDateTime,
      numberOfGuests: currentState.newReservationGuests,
      specialRequests: currentState.newReservationSpecialRequests,
    );

    state = AsyncData(
      currentState.copyWith(
        reservations: [
          newReservation,
          ...currentState.reservations,
        ],
        reservationsFilter: ReservationsFilter.pending,
      ),
    );
  }


  Future<void> updateReservation() async {
    final currentState = state.value;
    final reservation = currentState?.currentReservation;
    final slot = currentState?.selectedReservationSlot;

    if (
    currentState == null ||
        reservation == null ||
        reservation.id == null ||
        slot == null
    ) {
      return;
    }

    final updatedReservation = await Reservation.updateReservation(
      reservationId: reservation.id!,
      dateTime: slot.slotDateTime,
      numberOfGuests: currentState.newReservationGuests,
      specialRequests: currentState.newReservationSpecialRequests,
    );

    final updatedReservations = currentState.reservations.map((reservation) {
      if (reservation.id == updatedReservation.id) {
        return updatedReservation;
      }

      return reservation;
    }).toList();

    state = AsyncData(
      currentState.copyWith(
        reservations: updatedReservations,
        currentReservation: updatedReservation,
        isEditingReservation: false,
        reservationsFilter: ReservationsFilter.pending,
      ),
    );
  }

  Future<void> cancelReservation() async {
    final currentState = state.value;
    final reservation = currentState?.currentReservation;

    if (
    currentState == null ||
        reservation == null ||
        reservation.id == null
    ) {
      return;
    }

    final cancelledReservation = await Reservation.cancelReservation(
      reservationId: reservation.id!,
    );

    final updatedReservations = currentState.reservations.map((reservation) {
      if (reservation.id == cancelledReservation.id) {
        return cancelledReservation;
      }

      return reservation;
    }).toList();

    state = AsyncData(
      currentState.copyWith(
        reservations: updatedReservations,
        currentReservation: cancelledReservation,
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