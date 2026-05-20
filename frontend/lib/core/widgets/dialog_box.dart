import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final String message;
  final List<String> actions;

  const DialogBox({
    required this.title,
    required this.message,
    required this.actions,
  });

  Future<String?> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions.map((action) {
        final isDanger = action == 'Réinitialiser';

        return TextButton(
          onPressed: () => Navigator.of(context).pop(action),
          style: TextButton.styleFrom(
            backgroundColor: isDanger ? Colors.red : null,
            foregroundColor: isDanger ? Colors.white : null,
          ),
          child: Text(action),
        );
      }).toList(),
    );
  }
}
