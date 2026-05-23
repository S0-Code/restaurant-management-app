import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final DateTime simulatedTime;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.simulatedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant, size: 40),
        title: Text(restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(restaurant.city),
                if (restaurant.rating != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating!.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                if (restaurant.priceRange != null && restaurant.priceRange! > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '€' * restaurant.priceRange!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (restaurant.lastReservationDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Dernière réservation: ${_formatRelativeDate(restaurant.lastReservationDate!, simulatedTime)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (restaurant.pendingRequestsCount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.pending, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant.pendingRequestsCount} demande${restaurant.pendingRequestsCount > 1 ? 's' : ''} en attente',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  String _formatRelativeDate(DateTime date, DateTime now) {
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (diff == 0) return "aujourd'hui";
    if (diff == -1) return "hier";
    if (diff == 1) return "demain";

    return DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(date);
  }
}