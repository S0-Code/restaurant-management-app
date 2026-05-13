import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mockups/mockup_carousel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carousel des mockups',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MockupCarouselScreen(),
    ),
  );
}
