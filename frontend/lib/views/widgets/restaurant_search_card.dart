import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/restaurant_detail.dart';

class RestaurantSearchCard extends StatelessWidget {
  final RestaurantDetail restaurant;
  final DateTime? simulatedTime;
  final VoidCallback? onTap;

  const RestaurantSearchCard({
    required this.restaurant,
    required this.simulatedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastReservationDate = restaurant.lastReservationDate;
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(Icons.restaurant, size: 40),
        title: Text(restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(restaurant.city),

                if (restaurant.rating != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                if (restaurant.priceRange != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    '€' * restaurant.priceRange!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),

            if (lastReservationDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dernière réservation: ${formatRelativeDate(lastReservationDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            if (restaurant.pendingRequestsCount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.pending,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.pendingRequestsCount == 1
                        ? '1 demande en attente'
                        : '${restaurant.pendingRequestsCount} demandes en attente',
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
        onTap: onTap,
      ),
    );
  }

  String formatRelativeDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final simulatedDateOnly = DateTime(
      simulatedTime!.year,
      simulatedTime!.month,
      simulatedTime!.day,
    );

    final diff = dateOnly.difference(simulatedDateOnly).inDays;

    if (diff == 0) {
      return "aujourd'hui";
    }

    if (diff == -1) {
      return 'hier';
    }

    if (diff == 1) {
      return 'demain';
    }

    return DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(date);
  }
}