import '../models/reservation.dart';

class ClientState {
  final List<Reservation> reservations;
  final ReservationsFilter reservationsFilter;

  ClientState({
    required this.reservations,
    this.reservationsFilter = ReservationsFilter.pending
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
  }) {
    return ClientState(
      reservations: reservations ?? this.reservations,
      reservationsFilter: reservationsFilter ?? this.reservationsFilter,
    );
  }

  static Future<ClientState> getClientState({
    required ReservationsFilter reservationsFilter,
}) async {
    final reservations = await Reservation.getReservations();

    return ClientState(
      reservations: reservations,
      reservationsFilter: reservationsFilter
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