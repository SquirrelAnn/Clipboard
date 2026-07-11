import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

void configureDesktopWindow() {
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 600);
    const maxSize = Size(1200, 1200);
    win.size = initialSize;
    win.maxSize = maxSize;
    win.minSize = const Size(1000, 500);
    win.alignment = Alignment.center;
    win.title = 'Clipboard app';
    win.show();
  });
}
