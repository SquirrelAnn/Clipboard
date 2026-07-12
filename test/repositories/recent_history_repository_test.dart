import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/repositories/recent_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late RecentHistoryRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_recent_test');
    repository = RecentHistoryRepository(basePath: tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('starts empty when history file is missing', () async {
    final items = await repository.load();
    expect(items, isEmpty);
  });

  test('pushText persists and reloads after restart', () async {
    await repository.load();
    await repository.pushText('Hello world', contentHash: 't:1');

    final reloaded = RecentHistoryRepository(basePath: tempDir.path);
    final items = await reloaded.load();

    expect(items, hasLength(1));
    expect(items.first.type, RecentItemType.text);
    expect(items.first.text, 'Hello world');

    final file = File('${tempDir.path}/recent_history.json');
    expect(file.existsSync(), isTrue);
  });

  test('ring buffer evicts oldest item after 20 entries', () async {
    await repository.load();

    for (var i = 0; i < 21; i++) {
      await repository.pushText('entry $i', contentHash: 't:$i');
    }

    expect(repository.items, hasLength(20));
    expect(repository.items.first.text, 'entry 20');
    expect(repository.items.last.text, 'entry 1');
    expect(repository.items.any((item) => item.text == 'entry 0'), isFalse);
  });

  test('duplicate content moves item to front', () async {
    await repository.load();
    await repository.pushText('first', contentHash: 't:1');
    await repository.pushText('second', contentHash: 't:2');
    await repository.pushText('first', contentHash: 't:1');

    expect(repository.items, hasLength(2));
    expect(repository.items.first.text, 'first');
    expect(repository.items.last.text, 'second');
  });

  test('pushImage stores png and removes file on eviction', () async {
    await repository.load();
    final pngBytes = Uint8List.fromList([137, 80, 78, 71, 1, 2, 3]);

    await repository.pushImage(pngBytes, contentHash: 'i:1');
    expect(repository.items.single.imagePath, isNotNull);

    final imageFile = File('${tempDir.path}/${repository.items.single.imagePath!}');
    expect(imageFile.existsSync(), isTrue);

    await repository.remove(repository.items.single.id);
    expect(imageFile.existsSync(), isFalse);
  });

  test('clear removes all items and history file content', () async {
    await repository.load();
    await repository.pushText('one', contentHash: 't:1');
    await repository.pushText('two', contentHash: 't:2');

    await repository.clear();

    expect(repository.items, isEmpty);

    final file = File('${tempDir.path}/recent_history.json');
    final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
    expect(jsonList, isEmpty);
  });
}
