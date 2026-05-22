import '../models/reservation.dart';

class ClientState {
  final List<Reservation> reservations;

  ClientState({
    required this.reservations,
  });

  static Future<ClientState> getClientState() async {
    final reservations = await Reservation.getReservations();

    return ClientState(
      reservations: reservations,
    );
  }
}