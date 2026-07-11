import 'dart:typed_data';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:clipboard/widgets/add_snippet_dialog.dart';
import 'package:clipboard/widgets/alertwidgets.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoriesOverview extends StatefulWidget {
  const CategoriesOverview({
    super.key,
    required this.categories,
    required this.saveCategories,
    required this.repository,
    required this.clipboardService,
  });

  final List<Category> categories;
  final Future<void> Function() saveCategories;
  final CategoriesRepository repository;
  final ClipboardService clipboardService;

  @override
  State<CategoriesOverview> createState() => _CategoriesOverviewState();
}

class _CategoriesOverviewState extends State<CategoriesOverview> {
  int catIndex = 0;
  int hoveredIndex = -1;
  int hoveredSnippetIndex = -1;
  late final ScrollController _categoryScrollController;
  late final ScrollController _snippetScrollController;

  ImageStorageService get _imageStorage => widget.repository.imageStorageService;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController(initialScrollOffset: 10);
    _snippetScrollController = ScrollController(initialScrollOffset: 10);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _snippetScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              controller: _categoryScrollController,
              padding: const EdgeInsets.only(bottom: 4),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                if (widget.categories.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 4),
                        child: MouseRegion(
                          onHover: (_) => setState(() => hoveredIndex = index),
                          onExit: (_) => setState(() => hoveredIndex = -1),
                          child: TextButton(
                            style: _listItemStyle(theme, selected: index == catIndex),
                            onPressed: () => setState(() => catIndex = index),
                            child: Text(widget.categories[index].name),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteCategoryDialog(index),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                );
              },
            ),
          ),
          VerticalDivider(color: theme.colorScheme.primary),
          Expanded(
            flex: 3,
            child: _buildSnippetsList(),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 30),
          FloatingActionButton(
            onPressed: () async => _showAddCategoryDialog(),
            tooltip: 'Add new category',
            child: const Icon(Icons.add),
          ),
          const Spacer(),
          FloatingActionButton(
            onPressed: () async => _showAddSnippetDialog(),
            tooltip: 'Add snippet',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSnippetsList() {
    if (widget.categories.isEmpty || catIndex >= widget.categories.length) {
      return const SizedBox.shrink();
    }

    final snippets = widget.categories[catIndex].snippets;
    final theme = Theme.of(context);
    return ListView.builder(
      controller: _snippetScrollController,
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: snippets.length,
      itemBuilder: (context, index) {
        final snippet = snippets[index];
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 10),
                child: MouseRegion(
                  onHover: (_) => setState(() => hoveredSnippetIndex = index),
                  onExit: (_) => setState(() => hoveredSnippetIndex = -1),
                  child: TextButton(
                    style: _listItemStyle(theme, selected: false),
                    onPressed: () => _copySnippet(snippet),
                    child: _buildSnippetContent(snippet, theme),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _deleteSnippet(index),
              icon: const Icon(Icons.delete),
            ),
            const SizedBox(width: 70),
          ],
        );
      },
    );
  }

  Widget _buildSnippetContent(Snippet snippet, ThemeData theme) {
    final textStyle = theme.textTheme.bodyMedium;

    if (snippet.type == SnippetType.image) {
      return Row(
        children: [
          Icon(Icons.image, size: 18, color: theme.colorScheme.onSurface),
          const SizedBox(width: 8),
          Expanded(child: Text(snippet.snippetTitle, style: textStyle)),
          const SizedBox(width: 8),
          _SnippetThumbnail(imageStorage: _imageStorage, imagePath: snippet.imagePath!),
        ],
      );
    }

    return Text('${snippet.snippetTitle}: ${snippet.snippetText}', style: textStyle);
  }

  ButtonStyle _listItemStyle(ThemeData theme, {required bool selected}) {
    final scheme = theme.colorScheme;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return scheme.surfaceContainerHighest;
        }
        if (selected) {
          return scheme.primary;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (selected) {
          return scheme.onPrimary;
        }
        return scheme.onSurface;
      }),
    );
  }

  Future<void> _copySnippet(Snippet snippet) async {
    try {
      await widget.clipboardService.copySnippet(snippet);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snippet.type == SnippetType.image ? 'Image copied to clipboard.' : 'Text copied to clipboard.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to copy: $e')),
      );
    }
  }

  Future<void> _showAddSnippetDialog() async {
    if (widget.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a category first.')),
      );
      return;
    }

    final snippet = await AddSnippetDialog.show(
      context,
      clipboardService: widget.clipboardService,
      imageStorageService: _imageStorage,
    );
    if (snippet == null) return;

    widget.categories[catIndex].snippets.add(snippet);
    await widget.saveCategories();
    setState(() {});
  }

  Future<void> _deleteSnippet(int index) async {
    final snippet = widget.categories[catIndex].snippets[index];
    await widget.repository.deleteSnippetImage(snippet);
    widget.categories[catIndex].snippets.removeAt(index);
    await widget.saveCategories();
    setState(() {});
  }

  Future<void> _showAddCategoryDialog() async {
    await AlertWidgets.showNumTxtDlg('Add new category', _addCategory, context);
  }

  Future<void> _addCategory(String val) async {
    if (val.isEmpty) return;
    const uuid = Uuid();
    widget.categories.add(
      Category(id: uuid.v1(), name: val, snippets: []),
    );
    await widget.saveCategories();
    setState(() {});
  }

  Future<void> _deleteCategory(int index) async {
    for (final snippet in widget.categories[index].snippets) {
      await widget.repository.deleteSnippetImage(snippet);
    }
    widget.categories.removeAt(index);
    if (catIndex >= widget.categories.length) {
      catIndex = widget.categories.isEmpty ? 0 : widget.categories.length - 1;
    }
    await widget.saveCategories();
    setState(() {});
  }

  Future<void> _showDeleteCategoryDialog(int index) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Delete category?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _deleteCategory(index);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SnippetThumbnail extends StatelessWidget {
  const _SnippetThumbnail({
    required this.imageStorage,
    required this.imagePath,
  });

  final ImageStorageService imageStorage;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: imageStorage.loadImage(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 64, height: 64);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            snapshot.data!,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
