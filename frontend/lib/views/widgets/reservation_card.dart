import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c05/providers/client_state_provider.dart';

import '../../models/reservation.dart';

class ReservationCard extends ConsumerWidget {
  final Reservation reservation;


  const ReservationCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate =
    DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr')
        .format(reservation.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          ref.read(clientStateProvider.notifier).setCurrentReservation(reservation);
          Navigator.pushNamed(context, '/clientViewReservation');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Tooltip(
                message: reservation.status.name,
                child: _statusIcon(reservation.status),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.restaurantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          reservation.cityName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${reservation.numberOfGuests} convives',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Icon _statusIcon(Status status) {
    switch (status) {
      case Status.pending:
        return const Icon(
          Icons.pending,
          size: 32,
          color: Colors.orange,
        );

      case Status.confirmed:
        return const Icon(
          Icons.check_circle,
          size: 32,
          color: Colors.green,
        );

      case Status.completed:
        return const Icon(
          Icons.event_available,
          size: 32,
          color: Colors.blue,
        );

      case Status.cancelled:
        return const Icon(
          Icons.cancel,
          size: 32,
          color: Colors.red,
        );
    }
  }
}
/*
Expanded(
child: ListView(
padding: const EdgeInsets.all(16.0),
children: [

Card(
margin: const EdgeInsets.only(bottom: 16),
child: InkWell(
onTap: () {},
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Row(
children: [
Tooltip(
message: 'En attente',
child: const Icon(Icons.pending, size: 32, color: Colors.orange),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'La Trattoria',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.location_on, size: 14),
const SizedBox(width: 4),
Text(
'Bruxelles',
style: TextStyle(fontSize: 12, color: Colors.grey[600]),
),
],
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.access_time, size: 16),
const SizedBox(width: 4),
Text(
'ven. 05/12/2024 à 20:00',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
const SizedBox(width: 12),
const Icon(Icons.people, size: 16),
const SizedBox(width: 4),
Text(
'4 convives',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
],
),
],
),
),
const Icon(Icons.chevron_right),
],
),
),
),
),
Card(
margin: const EdgeInsets.only(bottom: 16),
child: InkWell(
onTap: () {},
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Row(
children: [
Tooltip(
message: 'Confirmée',
child: const Icon(Icons.check_circle, size: 32, color: Colors.green),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'La Table du Chef',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.location_on, size: 14),
const SizedBox(width: 4),
Text(
'Liège',
style: TextStyle(fontSize: 12, color: Colors.grey[600]),
),
],
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.access_time, size: 16),
const SizedBox(width: 4),
Text(
'dim. 01/12/2024 à 13:00',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
const SizedBox(width: 12),
const Icon(Icons.people, size: 16),
const SizedBox(width: 4),
Text(
'4 convives',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
],
),
],
),
),
const Icon(Icons.chevron_right),
],
),
),
),
),
Card(
margin: const EdgeInsets.only(bottom: 16),
child: InkWell(
onTap: () {},
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Row(
children: [
Tooltip(
message: 'Terminée',
child: const Icon(Icons.event_available, size: 32, color: Colors.blue),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Sushi House',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.location_on, size: 14),
const SizedBox(width: 4),
Text(
'Bruxelles',
style: TextStyle(fontSize: 12, color: Colors.grey[600]),
),
],
),
const SizedBox(height: 4),
Row(
children: [
const Icon(Icons.access_time, size: 16),
const SizedBox(width: 4),
Text(
'mar. 26/11/2024 à 19:30',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
const SizedBox(width: 12),
const Icon(Icons.people, size: 16),
const SizedBox(width: 4),
Text(
'2 convives',
style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
],
),
],
),
),
const Icon(Icons.chevron_right),
],
),
),
),
),
],
),
),*/