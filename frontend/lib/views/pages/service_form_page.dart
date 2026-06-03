import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/restaurant_service.dart';
import '../../providers/restaurant_services_provider.dart';
import '../../providers/manager_reservations_provider.dart';

class ServiceFormPage extends ConsumerStatefulWidget {
  final int restaurantId;
  final RestaurantService? existingService;

  const ServiceFormPage({super.key, required this.restaurantId, this.existingService});

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  static const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  int? _selectedDay;
  int? _startHour;
  int? _startMinute;
  int? _endHour;
  int? _endMinute;
  bool _isLoading = false;

  // Fonction pour réinitialiser le formulaire
  void _resetForm() {
    setState(() {
      if (widget.existingService != null) {
        // Mode Modification : on remet les anciennes valeurs
        final service = widget.existingService!;
        _selectedDay = service.dayOfWeek;

        final startParts = service.formattedStartTime.split(':');
        _startHour = int.parse(startParts[0]);
        _startMinute = int.parse(startParts[1]);

        final endParts = service.formattedEndTime.split(':');
        _endHour = int.parse(endParts[0]);
        _endMinute = int.parse(endParts[1]);
      } else {
        // Mode Création : on vide tout
        _selectedDay = null;
        _startHour = null;
        _startMinute = null;
        _endHour = null;
        _endMinute = null;
      }
    });
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _save() async {
    if (_selectedDay == null || _startHour == null || _startMinute == null || _endHour == null || _endMinute == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startTimeStr = _formatTime(_startHour!, _startMinute!);
      final endTimeStr = _formatTime(_endHour!, _endMinute!);

      if (widget.existingService == null) {
        await RestaurantService.create(widget.restaurantId, _selectedDay!, startTimeStr, endTimeStr);
      } else {
        await RestaurantService.update(widget.existingService!.id, _selectedDay!, startTimeStr, endTimeStr);
      }

      ref.invalidate(restaurantServicesProvider(widget.restaurantId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingService == null ? 'Service créé avec succès' : 'Service mis à jour avec succès'),
              backgroundColor: Colors.blueGrey[800],
            )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('Erreur lors de la création : ', '').replaceAll('Erreur lors de la mise à jour : ', '');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg, style: const TextStyle(color: Colors.red)), backgroundColor: Colors.white)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingService != null;
    final reservations = ref.watch(managerReservationsProvider(widget.restaurantId)).value ?? [];

    // On récupère les services existants pour vérifier les chevauchements
    final existingServices = ref.watch(restaurantServicesProvider(widget.restaurantId)).value ?? [];

    int conflictingCount = 0;
    String? timeError;
    String? overlapError;

    // 1. Calcul des conflits de réservation (seulement en modification)
    if (isEditing && _selectedDay != null && _startHour != null && _startMinute != null && _endHour != null && _endMinute != null) {
      final newStartMins = _startHour! * 60 + _startMinute!;
      final newEndMins = _endHour! * 60 + _endMinute!;

      final oldStartParts = widget.existingService!.formattedStartTime.split(':');
      final oldStartMins = int.parse(oldStartParts[0]) * 60 + int.parse(oldStartParts[1]);

      final oldEndParts = widget.existingService!.formattedEndTime.split(':');
      final oldEndMins = int.parse(oldEndParts[0]) * 60 + int.parse(oldEndParts[1]);

      for (final res in reservations) {
        final statusStr = res.status.toString().toLowerCase();
        if (statusStr.contains('cancelled') || statusStr.contains('completed')) continue;

        if (res.dateTime.weekday == widget.existingService!.dayOfWeek) {
          final resMins = res.dateTime.hour * 60 + res.dateTime.minute;
          if (resMins >= oldStartMins && resMins < oldEndMins) {
            if (_selectedDay != widget.existingService!.dayOfWeek || resMins < newStartMins || resMins >= newEndMins) {
              conflictingCount++;
            }
          }
        }
      }
    }

    // 2. Validation dynamique des horaires et des chevauchements
    if (_startHour != null && _startMinute != null && _endHour != null && _endMinute != null) {
      final startTotalMinutes = _startHour! * 60 + _startMinute!;
      final endTotalMinutes = _endHour! * 60 + _endMinute!;

      // Vérification de la logique du temps (Fin > Début, Durée >= 1h)
      if (endTotalMinutes <= startTotalMinutes) {
        timeError = "L'heure de fin doit être après l'heure de début";
      } else if ((endTotalMinutes - startTotalMinutes) < 60) {
        timeError = "La durée du service doit être d'au moins 1 heure";
      }
      // Vérification des chevauchements avec d'autres services
      else if (_selectedDay != null) {
        for (final srv in existingServices) {
          if (isEditing && srv.id == widget.existingService!.id) continue;

          if (srv.dayOfWeek == _selectedDay) {
            final srvStartParts = srv.formattedStartTime.split(':');
            final srvStartMins = int.parse(srvStartParts[0]) * 60 + int.parse(srvStartParts[1]);

            final srvEndParts = srv.formattedEndTime.split(':');
            final srvEndMins = int.parse(srvEndParts[0]) * 60 + int.parse(srvEndParts[1]);

            if (startTotalMinutes < srvEndMins && endTotalMinutes > srvStartMins) {
              overlapError = "Ce service chevauche avec un service existant le ${days[_selectedDay! - 1]}";
              break;
            }
          }
        }
      }
    }

    // On s'assure que le formulaire est valide pour afficher le bouton de sauvegarde
    final isFormValid = _selectedDay != null &&
        _startHour != null &&
        _startMinute != null &&
        _endHour != null &&
        _endMinute != null &&
        timeError == null &&
        overlapError == null &&
        conflictingCount == 0;

    final hours = List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('${i.toString().padLeft(2, '0')} h')));
    final minutes = [
      const DropdownMenuItem(value: 0, child: Text('00 min')),
      const DropdownMenuItem(value: 30, child: Text('30 min')),
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier le service' : 'Nouveau service'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: [
            if (_isLoading)
              const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
            else ...[
              // Le bouton de sauvegarde si valide
              if (isFormValid)
                IconButton(icon: const Icon(Icons.save), onPressed: _save),

              // Le bouton de rafraîchissement
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Réinitialiser',
                onPressed: _resetForm,
              ),
            ]
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown<int>(
              label: 'Jour',
              value: _selectedDay,
              items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(days[i]))),
              onChanged: (val) => setState(() => _selectedDay = val),
            ),

            // Affichage de l'erreur de chevauchement sous le jour
            if (overlapError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  overlapError,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            if (conflictingCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modification impossible : $conflictingCount réservation${conflictingCount > 1 ? 's' : ''} confirmée${conflictingCount > 1 ? 's' : ''} ou en attente serait en dehors des horaires du service.',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(child: _buildDropdown<int>(label: 'Heure de début (heure)', value: _startHour, items: hours, onChanged: (val) => setState(() => _startHour = val))),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown<int>(label: 'Minutes', value: _startMinute, items: minutes, onChanged: (val) => setState(() => _startMinute = val))),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildDropdown<int>(label: 'Heure de fin (heure)', value: _endHour, items: hours, onChanged: (val) => setState(() => _endHour = val))),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown<int>(label: 'Minutes', value: _endMinute, items: minutes, onChanged: (val) => setState(() => _endMinute = val))),
              ],
            ),

            if (timeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  timeError,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}