import 'package:clipboard/models/category.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter/platform', JSONMethodCodec());

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('copySnippet copies text snippets to clipboard', () async {
    String? copiedText;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          copiedText = call.arguments['text'] as String?;
          return null;
        case 'Clipboard.getData':
          return {'text': copiedText};
        default:
          return null;
      }
    });

    final service = ClipboardService();
    final snippet = Snippet.text(
      id: 'text-1',
      snippetTitle: 'Title',
      snippetText: 'Copied text',
    );

    await service.copySnippet(snippet);

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    expect(data?.text, 'Copied text');
  });
}
