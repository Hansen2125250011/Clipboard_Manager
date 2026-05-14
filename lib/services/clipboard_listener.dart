import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:clipboard_history_manager/main.dart';

class MyClipboardWatcher with ClipboardListener {
  final ClipboardProvider provider;

  MyClipboardWatcher(this.provider);

  @override
  void onClipboardChanged() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      provider.addClip(data.text!);
    }
  }

  void start() {
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

  void stop() {
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
  }
}
