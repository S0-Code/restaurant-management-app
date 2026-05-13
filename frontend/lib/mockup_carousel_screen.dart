import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockups/assign_tables_mockup.dart';
import 'package:mockups/edit_service_mockup.dart';
import 'package:mockups/edit_table_mockup.dart';
import 'package:mockups/home_client_mockup.dart';
import 'package:mockups/login_mockup.dart';
import 'package:mockups/my_restaurants_mockup.dart';
import 'package:mockups/reservation_details_manager_mockup.dart';
import 'package:mockups/reservation_details_mockup.dart';
import 'package:mockups/reservation_form_mockup.dart';
import 'package:mockups/restaurant_details_mockup.dart';
import 'package:mockups/restaurant_management_reservations_mockup.dart';
import 'package:mockups/restaurant_management_services_mockup.dart';
import 'package:mockups/restaurant_management_tables_mockup.dart';
import 'package:mockups/search_restaurants_mockup.dart';
import 'package:mockups/signup_mockup.dart';

/// Écran carousel qui affiche tous les mockups du projet.
class MockupCarouselScreen extends StatefulWidget {
  const MockupCarouselScreen({super.key});

  @override
  State<MockupCarouselScreen> createState() => _MockupCarouselScreenState();
}

class _MockupCarouselScreenState extends State<MockupCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final List<({String label, Widget screen})> _mockups = [
    (label: 'Connexion', screen: const LoginMockupScreen()),
    (label: 'Inscription', screen: const SignupMockupScreen()),
    (label: 'Accueil client', screen: const HomeClientMockupScreen()),
    (label: 'Recherche restaurants', screen: const SearchRestaurantsMockupScreen()),
    (label: 'Détails restaurant', screen: const RestaurantDetailsMockupScreen()),
    (label: 'Formulaire réservation', screen: const ReservationFormMockupScreen()),
    (label: 'Détails réservation', screen: const ReservationDetailsMockupScreen()),
    (label: 'Mes restaurants', screen: const MyRestaurantsMockupScreen()),
    (label: 'Gestion restaurant - Réservations', screen: const RestaurantManagementReservationsMockupScreen()),
    (label: 'Gestion restaurant - Services', screen: const RestaurantManagementServicesMockupScreen()),
    (label: 'Gestion restaurant - Tables', screen: const RestaurantManagementTablesMockupScreen()),
    (label: 'Détails réservation (manager)', screen: const ReservationDetailsManagerMockupScreen()),
    (label: 'Assigner des tables', screen: const AssignTablesMockupScreen()),
    (label: 'Modifier le service', screen: const EditServiceMockupScreen()),
    (label: 'Modifier la table', screen: const EditTableMockupScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _initDateFormatting();
  }

  Future<void> _initDateFormatting() async {
    await initializeDateFormatting('fr_FR', null);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _mockups.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _goToPage(_currentPage + 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _goToPage(_currentPage - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inverseSurface,
        foregroundColor: theme.colorScheme.onInverseSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
            color: theme.colorScheme.inverseSurface,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Text(
                  _mockups[_currentPage].label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _mockups.length,
                    (index) => _DotIndicator(
                      label: _mockups[index].label,
                      isActive: index == _currentPage,
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Focus(
        onKeyEvent: _onKeyEvent,
        autofocus: true,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _mockups.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: _mockups[index].screen,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.onInverseSurface.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
