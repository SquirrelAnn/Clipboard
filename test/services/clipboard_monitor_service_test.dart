import 'dart:io';
import 'dart:typed_data';

import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/repositories/recent_history_repository.dart';
import 'package:clipboard/services/clipboard_monitor_service.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClipboardService extends ClipboardService {
  _FakeClipboardService() : super();

  ClipboardContent? nextContent;
  int copyCount = 0;

  @override
  Future<ClipboardContent?> readCurrentClipboard() async => nextContent;

  @override
  Future<void> copyRecentItem(RecentItem item) async {
    copyCount++;
    ignoreNextClipboardChange = true;
  }
}

void main() {
  late RecentHistoryRepository repository;
  late _FakeClipboardService clipboardService;
  late int changeCount;
  late ClipboardMonitorService monitor;

  setUp(() async {
    repository = RecentHistoryRepository(basePath: (await Directory.systemTemp.createTemp('clipboard_monitor_test')).path);
    await repository.load();
    clipboardService = _FakeClipboardService();
    changeCount = 0;
    monitor = ClipboardMonitorService(
      clipboardService: clipboardService,
      repository: repository,
      onHistoryChanged: () => changeCount++,
      pollInterval: const Duration(milliseconds: 10),
    );
  });

  tearDown(() {
    monitor.dispose();
  });

  test('records new clipboard text content', () async {
    clipboardService.nextContent = ClipboardContent.text('hello');
    monitor.start();

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(repository.items, hasLength(1));
    expect(repository.items.first.text, 'hello');
    expect(changeCount, 1);
  });

  test('ignores duplicate clipboard content', () async {
    clipboardService.nextContent = ClipboardContent.text('hello');
    monitor.start();
    await Future<void>.delayed(const Duration(milliseconds: 40));

    changeCount = 0;
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(repository.items, hasLength(1));
    expect(changeCount, 0);
  });

  test('skips recording when app copied to clipboard', () async {
    clipboardService.nextContent = ClipboardContent.text('from app');
    clipboardService.ignoreNextClipboardChange = true;
    monitor.start();

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(repository.items, isEmpty);
  });

  test('records image clipboard content', () async {
    clipboardService.nextContent = ClipboardContent.image(Uint8List.fromList([1, 2, 3, 4]));
    monitor.start();

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(repository.items, hasLength(1));
    expect(repository.items.first.type, RecentItemType.image);
  });
}
