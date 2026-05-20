import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prbd_2526_c05/app/my_app.dart';
import 'package:prbd_2526_c05/core/tools/my_provider_observer.dart';
import 'package:prbd_2526_c05/core/tools/params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Params.init();

  runApp(
    ProviderScope(
      observers: [MyProviderObserver()],
      retry: (int _, Object _) => null,
      child: MyApp(),
    ),
  );
}