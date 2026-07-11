import 'package:flutter/material.dart';

class AlertWidgets {
  static Future<void> showNumTxtDlg(
    String title,
    Future<void> Function(String) setValue,
    BuildContext context,
  ) async {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: theme.dialogTheme.titleTextStyle),
        content: TextField(
          key: const Key('category_name_field'),
          keyboardType: TextInputType.multiline,
          autofocus: true,
          controller: controller,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, [controller.text]),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await setValue(result.join('\n'));
    }
  }
}
