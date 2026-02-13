import 'dart:io';
import 'package:flutter/material.dart';

extension DownloadExtension on BuildContext {
  Future<void> downloadFile(dynamic source) async {
    if (source is String) {
      return;
    }
    if (source is File) {
      return;
    }
  }
}
