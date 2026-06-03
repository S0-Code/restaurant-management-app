import 'package:flutter/material.dart';
import 'package:prbd_2526_c05/core/tools/abstract_async_notifier.dart';

class DataErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final AbstractAsyncNotifier notifier;
  final VoidCallback? onGoToLogin;


  const DataErrorWidget({
    required this.error,
    this.stackTrace,
    required this.notifier,
    this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              notifier.refresh();
            },
            child: const Text('Retry'),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: onGoToLogin,
            child: const Text('Go to login'),
          ),
        ],
      ),
    );
  }
}