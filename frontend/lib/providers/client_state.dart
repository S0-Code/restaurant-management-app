import '../models/reservation.dart';

class ClientState {
  final List<Reservation> reservations;
  final ReservationsFilter reservationsFilter;
  final Reservation? currentReservation;

  ClientState({
    required this.reservations,
    this.reservationsFilter = ReservationsFilter.pending,
    this.currentReservation,
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
    Reservation? currentReservation
  }) {
    return ClientState(
      reservations: reservations ?? this.reservations,
      reservationsFilter: reservationsFilter ?? this.reservationsFilter,
      currentReservation: currentReservation ?? this.currentReservation
    );
  }

  static Future<ClientState> getClientState({
    required ReservationsFilter reservationsFilter,
    Reservation? currentReservation,
}) async {
    final reservations = await Reservation.getReservations();

    return ClientState(
      reservations: reservations,
      reservationsFilter: reservationsFilter,
      currentReservation: currentReservation
    );
  }



}

enum ReservationsFilter{
  all,
  pending,
  confirmed,
  cancelled,
  completed,
}