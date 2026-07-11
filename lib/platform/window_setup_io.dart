import 'dart:io';

import 'window_setup.dart' as stub;
import 'window_setup_windows.dart' as windows;

void configureDesktopWindow() {
  if (Platform.isWindows) {
    windows.configureDesktopWindow();
  } else {
    stub.configureDesktopWindow();
  }
}
