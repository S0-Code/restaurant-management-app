class ReservationSlot {
  final DateTime slotDateTime;
  final String slotTime;
  final bool hasEnoughCapacity;

  ReservationSlot({
    required this.slotDateTime,
    required this.slotTime,
    required this.hasEnoughCapacity,
  });

  factory ReservationSlot.fromJson(Map<String, dynamic> json) {
    return ReservationSlot(
      slotDateTime: DateTime.parse(json['slot_datetime']),
      slotTime: json['slot_time'],
      hasEnoughCapacity: json['has_enough_capacity'] as bool,
    );
  }
}