import 'dart:typed_data';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddSnippetDialog extends StatefulWidget {
  const AddSnippetDialog({
    super.key,
    required this.clipboardService,
    required this.imageStorageService,
  });

  final ClipboardService clipboardService;
  final ImageStorageService imageStorageService;

  static Future<Snippet?> show(
    BuildContext context, {
    required ClipboardService clipboardService,
    required ImageStorageService imageStorageService,
  }) {
    return showDialog<Snippet>(
      context: context,
      builder: (context) => AddSnippetDialog(
        clipboardService: clipboardService,
        imageStorageService: imageStorageService,
      ),
    );
  }

  @override
  State<AddSnippetDialog> createState() => _AddSnippetDialogState();
}

class _AddSnippetDialogState extends State<AddSnippetDialog> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  bool _isImageMode = false;
  Uint8List? _clipboardImage;
  bool _loadingClipboard = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    setState(() => _loadingClipboard = true);
    try {
      final bytes = await widget.clipboardService.readImageFromClipboard();
      if (!mounted) return;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image found in clipboard.')),
        );
        return;
      }
      setState(() {
        _isImageMode = true;
        _clipboardImage = bytes;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingClipboard = false);
      }
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }

    const uuid = Uuid();
    final id = uuid.v1();

    if (_isImageMode) {
      if (_clipboardImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paste an image from the clipboard first.')),
        );
        return;
      }
      final imagePath = await widget.imageStorageService.saveImage(_clipboardImage!, id);
      if (!mounted) return;
      Navigator.pop(
        context,
        Snippet.image(id: id, snippetTitle: title, imagePath: imagePath),
      );
      return;
    }

    final text = _textController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter snippet text.')),
      );
      return;
    }

    Navigator.pop(
      context,
      Snippet.text(id: id, snippetTitle: title, snippetText: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Add new snippet', style: theme.dialogTheme.titleTextStyle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Title'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Text'), icon: Icon(Icons.text_fields)),
                ButtonSegment(value: true, label: Text('Screenshot'), icon: Icon(Icons.image)),
              ],
              selected: {_isImageMode},
              onSelectionChanged: (selection) {
                setState(() => _isImageMode = selection.first);
              },
            ),
            const SizedBox(height: 12),
            if (_isImageMode) ...[
              OutlinedButton.icon(
                onPressed: _loadingClipboard ? null : _pasteFromClipboard,
                icon: _loadingClipboard
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onSurface,
                        ),
                      )
                    : const Icon(Icons.content_paste),
                label: const Text('Paste from clipboard'),
              ),
              if (_clipboardImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _clipboardImage!,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ] else
              TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Value'),
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
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
