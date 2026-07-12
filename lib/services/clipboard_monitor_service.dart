import 'dart:async';

import 'package:clipboard/repositories/recent_history_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/utils/content_hash.dart';

class ClipboardMonitorService {
  ClipboardMonitorService({
    required ClipboardService clipboardService,
    required RecentHistoryRepository repository,
    required void Function() onHistoryChanged,
    this.pollInterval = const Duration(milliseconds: 500),
  })  : _clipboardService = clipboardService,
        _repository = repository,
        _onHistoryChanged = onHistoryChanged;

  final ClipboardService _clipboardService;
  final RecentHistoryRepository _repository;
  final void Function() _onHistoryChanged;
  final Duration pollInterval;

  Timer? _timer;
  String? _lastContentHash;
  bool _isChecking = false;

  void start() {
    _timer ??= Timer.periodic(pollInterval, (_) => unawaited(_checkClipboard()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
  }

  Future<void> _checkClipboard() async {
    if (_isChecking) {
      return;
    }

    _isChecking = true;
    try {
      final content = await _clipboardService.readCurrentClipboard();
      if (content == null || content.isEmpty) {
        return;
      }

      final contentHash = content.imageBytes != null
          ? contentHashForImage(content.imageBytes!)
          : contentHashForText(content.text!);

      if (_clipboardService.ignoreNextClipboardChange) {
        _clipboardService.ignoreNextClipboardChange = false;
        _lastContentHash = contentHash;
        return;
      }

      if (_lastContentHash == contentHash) {
        return;
      }

      _lastContentHash = contentHash;

      if (content.imageBytes != null) {
        await _repository.pushImage(content.imageBytes!, contentHash: contentHash);
      } else {
        await _repository.pushText(content.text!, contentHash: contentHash);
      }

      _onHistoryChanged();
    } catch (_) {
      // Ignore transient clipboard read failures while polling.
    } finally {
      _isChecking = false;
    }
  }
}
