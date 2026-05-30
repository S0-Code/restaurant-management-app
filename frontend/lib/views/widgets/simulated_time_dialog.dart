import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/simulated_time_provider.dart';

class SimulatedTimeDialog extends ConsumerStatefulWidget {
  final DateTime referenceTime;

  const SimulatedTimeDialog({
    super.key,
    required this.referenceTime,
  });

  @override
  ConsumerState<SimulatedTimeDialog> createState() =>
      _SimulatedTimeDialogState();
}

class _SimulatedTimeDialogState
    extends ConsumerState<SimulatedTimeDialog> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.referenceTime;
    selectedTime = TimeOfDay.fromDateTime(widget.referenceTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le temps simulé'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(selectedDate!),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );

              if (date == null) return;

              setState(() {
                selectedDate = date;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Heure'),
            subtitle: Text(
              selectedTime!.format(context),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime!,
              );

              if (time == null) return;

              setState(() {
                selectedTime = time;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            await ref
                .read(simulatedTimeProvider.notifier)
                .setSimulatedTime(null);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Effacer (null)'),
        ),
        TextButton(
          onPressed: () async {
            final newDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );

            await ref
                .read(simulatedTimeProvider.notifier)
                .setSimulatedTime(newDateTime);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}