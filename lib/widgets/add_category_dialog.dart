import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name.')),
      );
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Add new category', style: theme.dialogTheme.titleTextStyle),
      content: TextField(
        key: const Key('category_name_field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Category name'),
        style: theme.textTheme.bodyMedium,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
