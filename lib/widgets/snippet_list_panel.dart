import 'dart:typed_data';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/utils/snippet_search.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:flutter/material.dart';

class SnippetListPanel extends StatelessWidget {
  const SnippetListPanel({
    super.key,
    required this.entries,
    required this.imageStorage,
    required this.scrollController,
    required this.showCategoryNames,
    required this.onSnippetCopied,
    required this.onSnippetEdited,
    required this.onSnippetDeleted,
  });

  final List<SnippetSearchResult> entries;
  final ImageStorageService imageStorage;
  final ScrollController scrollController;
  final bool showCategoryNames;
  final ValueChanged<SnippetSearchResult> onSnippetCopied;
  final ValueChanged<SnippetSearchResult> onSnippetEdited;
  final void Function(String categoryId, String snippetId) onSnippetDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Center(
        child: Text(
          showCategoryNames ? 'No snippets match your search.' : 'No snippets in this category.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final snippet = entry.snippet;

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 10),
                child: TextButton(
                  style: _listItemStyle(theme),
                  onPressed: () => onSnippetCopied(entry),
                  child: _SnippetListItemContent(
                    snippet: snippet,
                    categoryName: showCategoryNames ? entry.categoryName : null,
                    imageStorage: imageStorage,
                    textStyle: theme.textTheme.bodyMedium,
                    iconColor: theme.colorScheme.onSurface,
                    categoryStyle: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit snippet',
              onPressed: () => onSnippetEdited(entry),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Delete snippet',
              onPressed: () => onSnippetDeleted(entry.categoryId, snippet.id),
              icon: const Icon(Icons.delete),
            ),
            const SizedBox(width: 40),
          ],
        );
      },
    );
  }

  ButtonStyle _listItemStyle(ThemeData theme) {
    final scheme = theme.colorScheme;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return scheme.surfaceContainerHighest;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.all(scheme.onSurface),
    );
  }
}

class _SnippetListItemContent extends StatelessWidget {
  const _SnippetListItemContent({
    required this.snippet,
    required this.categoryName,
    required this.imageStorage,
    required this.textStyle,
    required this.iconColor,
    required this.categoryStyle,
  });

  final Snippet snippet;
  final String? categoryName;
  final ImageStorageService imageStorage;
  final TextStyle? textStyle;
  final Color iconColor;
  final TextStyle? categoryStyle;

  @override
  Widget build(BuildContext context) {
    final content = snippet.type == SnippetType.image
        ? Row(
            children: [
              Icon(Icons.image, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(child: Text(snippet.snippetTitle, style: textStyle)),
              const SizedBox(width: 8),
              _SnippetThumbnail(imageStorage: imageStorage, imagePath: snippet.imagePath!),
            ],
          )
        : Text('${snippet.snippetTitle}: ${snippet.snippetText}', style: textStyle);

    if (categoryName == null) {
      return content;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(categoryName!, style: categoryStyle),
        const SizedBox(height: 4),
        content,
      ],
    );
  }
}

class _SnippetThumbnail extends StatefulWidget {
  const _SnippetThumbnail({
    required this.imageStorage,
    required this.imagePath,
  });

  final ImageStorageService imageStorage;
  final String imagePath;

  @override
  State<_SnippetThumbnail> createState() => _SnippetThumbnailState();
}

class _SnippetThumbnailState extends State<_SnippetThumbnail> {
  late final Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.imageStorage.loadImage(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
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
