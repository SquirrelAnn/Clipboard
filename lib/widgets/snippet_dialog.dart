import 'dart:typed_data';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SnippetDialog extends StatefulWidget {
  const SnippetDialog({
    super.key,
    required this.clipboardService,
    required this.imageStorageService,
    this.existingSnippet,
  });

  final ClipboardService clipboardService;
  final ImageStorageService imageStorageService;
  final Snippet? existingSnippet;

  bool get isEditing => existingSnippet != null;

  static Future<Snippet?> showAdd(
    BuildContext context, {
    required ClipboardService clipboardService,
    required ImageStorageService imageStorageService,
  }) {
    return showDialog<Snippet>(
      context: context,
      builder: (context) => SnippetDialog(
        clipboardService: clipboardService,
        imageStorageService: imageStorageService,
      ),
    );
  }

  static Future<Snippet?> showEdit(
    BuildContext context, {
    required ClipboardService clipboardService,
    required ImageStorageService imageStorageService,
    required Snippet existingSnippet,
  }) {
    return showDialog<Snippet>(
      context: context,
      builder: (context) => SnippetDialog(
        clipboardService: clipboardService,
        imageStorageService: imageStorageService,
        existingSnippet: existingSnippet,
      ),
    );
  }

  @override
  State<SnippetDialog> createState() => _SnippetDialogState();
}

class _SnippetDialogState extends State<SnippetDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late bool _isImageMode;
  Uint8List? _clipboardImage;
  Uint8List? _existingImage;
  bool _loadingClipboard = false;
  bool _loadingExistingImage = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSnippet;
    _titleController = TextEditingController(text: existing?.snippetTitle ?? '');
    _textController = TextEditingController(text: existing?.snippetText ?? '');
    _isImageMode = existing?.type == SnippetType.image;

    if (existing?.type == SnippetType.image && existing?.imagePath != null) {
      _loadExistingImage(existing!.imagePath!);
    }
  }

  Future<void> _loadExistingImage(String imagePath) async {
    setState(() => _loadingExistingImage = true);
    try {
      final bytes = await widget.imageStorageService.loadImage(imagePath);
      if (!mounted) return;
      setState(() => _existingImage = bytes);
    } finally {
      if (mounted) {
        setState(() => _loadingExistingImage = false);
      }
    }
  }

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

    final existing = widget.existingSnippet;
    final id = existing?.id ?? const Uuid().v1();

    if (_isImageMode) {
      final imageBytes = _clipboardImage ?? _existingImage;
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paste an image from the clipboard first.')),
        );
        return;
      }

      String imagePath;
      if (_clipboardImage != null || existing?.imagePath == null) {
        if (existing?.imagePath != null && _clipboardImage != null) {
          await widget.imageStorageService.deleteImage(existing!.imagePath!);
        }
        imagePath = await widget.imageStorageService.saveImage(imageBytes, id);
      } else {
        imagePath = existing!.imagePath!;
      }

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

    if (existing?.type == SnippetType.image && existing?.imagePath != null) {
      await widget.imageStorageService.deleteImage(existing!.imagePath!);
    }

    Navigator.pop(
      context,
      Snippet.text(id: id, snippetTitle: title, snippetText: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSwitchType = !widget.isEditing;

    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit snippet' : 'Add new snippet',
        style: theme.dialogTheme.titleTextStyle,
      ),
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
            if (canSwitchType) ...[
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
            ],
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
                label: Text(widget.isEditing ? 'Replace from clipboard' : 'Paste from clipboard'),
              ),
              if (_loadingExistingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              if (_clipboardImage != null || _existingImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _clipboardImage ?? _existingImage!,
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
