import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/models/category.dart';
import 'package:clipboard/utils/snippet_search.dart';
import 'package:clipboard/widgets/add_category_dialog.dart';
import 'package:clipboard/widgets/category_list_panel.dart';
import 'package:clipboard/widgets/snippet_dialog.dart';
import 'package:clipboard/widgets/snippet_list_panel.dart';
import 'package:clipboard/widgets/snippet_search_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required this.controller});

  final CategoriesController controller;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final ScrollController _categoryScrollController;
  late final ScrollController _snippetScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  CategoriesController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController(initialScrollOffset: 10);
    _snippetScrollController = ScrollController(initialScrollOffset: 10);
    _searchController = TextEditingController(text: _controller.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _snippetScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyF, control: true): _focusSearch,
            const SingleActivator(LogicalKeyboardKey.keyN, control: true): _showAddSnippetDialog,
            const SingleActivator(LogicalKeyboardKey.keyN, control: true, shift: true): _showAddCategoryDialog,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Clipboard app'),
                actions: [
                  IconButton(
                    tooltip: 'Export backup',
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.upload),
                  ),
                  IconButton(
                    tooltip: 'Import backup',
                    onPressed: _importBackup,
                    icon: const Icon(Icons.download),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected: _handleMenuSelection,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'shortcuts',
                        child: Text('Keyboard shortcuts'),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  SnippetSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _controller.setSearchQuery,
                    onClear: _clearSearch,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CategoryListPanel(
                            categories: _controller.filteredCategories,
                            selectedCategoryId: _controller.selectedCategoryId,
                            scrollController: _categoryScrollController,
                            onCategorySelected: _controller.selectCategory,
                            onCategoryDeleted: _confirmDeleteCategory,
                          ),
                        ),
                        VerticalDivider(color: theme.colorScheme.primary),
                        Expanded(
                          flex: 3,
                          child: SnippetListPanel(
                            entries: _controller.visibleSnippets,
                            imageStorage: _controller.repository.imageStorageService,
                            scrollController: _snippetScrollController,
                            showCategoryNames: _controller.isSearching,
                            onSnippetCopied: _copySnippetResult,
                            onSnippetEdited: _showEditSnippetDialog,
                            onSnippetDeleted: _confirmDeleteSnippet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 30),
                  FloatingActionButton(
                    key: const Key('add_category_fab'),
                    onPressed: _showAddCategoryDialog,
                    tooltip: 'Add new category (Ctrl+Shift+N)',
                    child: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    key: const Key('add_snippet_fab'),
                    onPressed: _showAddSnippetDialog,
                    tooltip: 'Add snippet (Ctrl+N)',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _clearSearch() {
    _controller.clearSearch();
  }

  void _handleMenuSelection(String value) {
    if (value == 'shortcuts') {
      _showShortcutsDialog();
    }
  }

  Future<void> _showShortcutsDialog() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keyboard shortcuts', style: theme.dialogTheme.titleTextStyle),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ctrl+F — Focus search'),
            Text('Ctrl+N — Add snippet'),
            Text('Ctrl+Shift+N — Add category'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose export folder',
    );
    if (directoryPath == null) return;

    try {
      await _controller.exportToDirectory(directoryPath);
      if (!mounted) return;
      _showSnackBar('Backup exported successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Export failed: $e');
    }
  }

  Future<void> _importBackup() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose backup folder',
    );
    if (directoryPath == null) return;

    final replaceExisting = await _confirmImportMode();
    if (replaceExisting == null) return;

    try {
      await _controller.importFromDirectory(
        directoryPath,
        replaceExisting: replaceExisting,
      );
      if (!mounted) return;
      _showSnackBar(replaceExisting ? 'Backup replaced current data.' : 'Backup merged successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Import failed: $e');
    }
  }

  Future<bool?> _confirmImportMode() {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Import backup', style: theme.dialogTheme.titleTextStyle),
        content: Text(
          'Replace all current snippets or merge with existing data?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final name = await AddCategoryDialog.show(context);
    if (name == null) return;
    await _controller.addCategory(name);
  }

  Future<void> _showAddSnippetDialog() async {
    if (_controller.categories.isEmpty) {
      _showSnackBar('Add a category first.');
      return;
    }

    final snippet = await SnippetDialog.showAdd(
      context,
      clipboardService: _controller.clipboardService,
      imageStorageService: _controller.repository.imageStorageService,
    );
    if (snippet == null) return;

    await _controller.addSnippet(snippet);
  }

  Future<void> _showEditSnippetDialog(SnippetSearchResult result) async {
    final updated = await SnippetDialog.showEdit(
      context,
      clipboardService: _controller.clipboardService,
      imageStorageService: _controller.repository.imageStorageService,
      existingSnippet: result.snippet,
    );
    if (updated == null) return;

    await _controller.updateSnippet(result.categoryId, result.snippet.id, updated);
  }

  Future<void> _confirmDeleteCategory(String categoryId) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Delete category?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteCategory(categoryId);
    }
  }

  Future<void> _confirmDeleteSnippet(String categoryId, String snippetId) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Delete snippet?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteSnippet(categoryId, snippetId);
    }
  }

  Future<void> _copySnippetResult(SnippetSearchResult result) async {
    await _copySnippet(result.snippet);
  }

  Future<void> _copySnippet(Snippet snippet) async {
    try {
      await _controller.copySnippet(snippet);
      if (!mounted) return;
      _showSnackBar(
        snippet.type == SnippetType.image ? 'Image copied to clipboard.' : 'Text copied to clipboard.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to copy: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
