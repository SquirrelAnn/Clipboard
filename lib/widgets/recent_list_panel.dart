import 'dart:typed_data';

import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:flutter/material.dart';

class RecentListPanel extends StatelessWidget {
  const RecentListPanel({
    super.key,
    required this.items,
    required this.imageStorage,
    required this.scrollController,
    required this.onItemCopied,
    required this.onItemDeleted,
    required this.onSaveAsSnippet,
  });

  final List<RecentItem> items;
  final ImageStorageService imageStorage;
  final ScrollController scrollController;
  final ValueChanged<RecentItem> onItemCopied;
  final ValueChanged<RecentItem> onItemDeleted;
  final ValueChanged<RecentItem> onSaveAsSnippet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Copied text and images appear here.\nThe last 20 entries are kept across restarts.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 10),
                child: TextButton(
                  style: _listItemStyle(theme),
                  onPressed: () => onItemCopied(item),
                  child: _RecentListItemContent(
                    item: item,
                    imageStorage: imageStorage,
                    textStyle: theme.textTheme.bodyMedium,
                    iconColor: theme.colorScheme.onSurface,
                    metaStyle: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Save as snippet',
              onPressed: () => onSaveAsSnippet(item),
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
            IconButton(
              tooltip: 'Remove from history',
              onPressed: () => onItemDeleted(item),
              icon: const Icon(Icons.delete_outline),
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

class _RecentListItemContent extends StatelessWidget {
  const _RecentListItemContent({
    required this.item,
    required this.imageStorage,
    required this.textStyle,
    required this.iconColor,
    required this.metaStyle,
  });

  final RecentItem item;
  final ImageStorageService imageStorage;
  final TextStyle? textStyle;
  final Color iconColor;
  final TextStyle? metaStyle;

  @override
  Widget build(BuildContext context) {
    final content = item.type == RecentItemType.image
        ? Row(
            children: [
              Icon(Icons.image, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(child: Text('Image', style: textStyle)),
              const SizedBox(width: 8),
              _RecentThumbnail(imageStorage: imageStorage, imagePath: item.imagePath!),
            ],
          )
        : Text(item.preview, style: textStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatCapturedAt(item.capturedAt), style: metaStyle),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  String _formatCapturedAt(DateTime capturedAt) {
    final local = capturedAt.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $time';
  }
}

class _RecentThumbnail extends StatefulWidget {
  const _RecentThumbnail({
    required this.imageStorage,
    required this.imagePath,
  });

  final ImageStorageService imageStorage;
  final String imagePath;

  @override
  State<_RecentThumbnail> createState() => _RecentThumbnailState();
}

class _RecentThumbnailState extends State<_RecentThumbnail> {
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
