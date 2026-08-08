import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context,
  String title,
  String text, {
  String falselabel = 'NO',
  String truelabel = 'YES',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton.icon(
            onPressed:
                () => Navigator.of(context, rootNavigator: true).pop(false),
            icon: const Icon(Icons.clear),
            label: Text(falselabel),
          ),
          ElevatedButton.icon(
            onPressed:
                () => Navigator.of(context, rootNavigator: true).pop(true),
            icon: const Icon(Icons.check),
            label: Text(truelabel),
          ),
        ],
      );
    },
  ).then((b) => b ?? false);
}
