import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

abstract class ModularRoute {
  ModularRoute({
    required this.name,
    required this.path,
    this.isVisible = true,
    this.icon,
    this.hugeIcon,
  });

  String name;
  String path;
  bool isVisible;
  IconData? icon;
  List<List<dynamic>>? hugeIcon;

  bool get hasIcon => icon != null || hugeIcon != null;

  Widget? buildIcon({double? size, Color? color}) {
    if (hugeIcon != null) {
      return HugeIcon(icon: hugeIcon!, size: size, color: color);
    }
    if (icon != null) {
      return Icon(icon, size: size, color: color);
    }
    return null;
  }
}

class CLRoute {
  const CLRoute({required this.name, required this.path});

  final String name;
  final String path;
}

abstract class Module {
  CLRoute get moduleRoute;
  List<ModularRoute> get routes;
}
