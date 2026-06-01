import '../models/reservation.dart';
import '../models/restaurant_detail.dart';
import '../models/restaurant_service.dart';

class ClientState {
  final List<Reservation> reservations;
  final ReservationsFilter reservationsFilter;
  final Reservation? currentReservation;

  final List<RestaurantDetail> restaurants;
  final String restaurantSearchText;
  final RestaurantDetail? currentRestaurant;
  final bool hasTooManyRestaurantResults;
  final List<RestaurantService> currentRestaurantServices;

  ClientState({
    required this.reservations,
    this.reservationsFilter = ReservationsFilter.pending,
    this.currentReservation,
    this.restaurants = const [],
    this.restaurantSearchText = '',
    this.currentRestaurant,
    this.hasTooManyRestaurantResults = false,
    this.currentRestaurantServices = const [],
  });

  List<Reservation> get filteredReservations {
    if (reservationsFilter == ReservationsFilter.all) {
      return reservations;
    }

    return reservations
        .where((reservation) => reservation.status.name == reservationsFilter.name)
        .toList();
  }

  ClientState copyWith({
    List<Reservation>? reservations,
    ReservationsFilter? reservationsFilter,
    Reservation? currentReservation,
    List<RestaurantDetail>? restaurants,
    String? restaurantSearchText,
    RestaurantDetail? currentRestaurant,
    bool? hasTooManyRestaurantResults,
    List<RestaurantService>? currentRestaurantServices,
  }) {
    return ClientState(
      reservations: reservations ?? this.reservations,
      reservationsFilter: reservationsFilter ?? this.reservationsFilter,
      currentReservation: currentReservation ?? this.currentReservation,
      restaurants: restaurants ?? this.restaurants,
      restaurantSearchText: restaurantSearchText ?? this.restaurantSearchText,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
      hasTooManyRestaurantResults:
      hasTooManyRestaurantResults ?? this.hasTooManyRestaurantResults,
      currentRestaurantServices:
      currentRestaurantServices ?? this.currentRestaurantServices,
    );
  }

  static Future<ClientState> getClientState({
    required ReservationsFilter reservationsFilter,
    Reservation? currentReservation,
    List<RestaurantDetail> restaurants = const [],
    String restaurantSearchText = '',
    RestaurantDetail? currentRestaurant,
    bool hasTooManyRestaurantResults = false,
    List<RestaurantService> currentRestaurantServices = const [],
  }) async {
    final reservations = await Reservation.getReservations();

    return ClientState(
      reservations: reservations,
      reservationsFilter: reservationsFilter,
      currentReservation: currentReservation,
      restaurants: restaurants,
      restaurantSearchText: restaurantSearchText,
      currentRestaurant: currentRestaurant,
      hasTooManyRestaurantResults: hasTooManyRestaurantResults,
      currentRestaurantServices: currentRestaurantServices,
    );
  }
}

enum ReservationsFilter {
  all,
  pending,
  confirmed,
  cancelled,
  completed,
}