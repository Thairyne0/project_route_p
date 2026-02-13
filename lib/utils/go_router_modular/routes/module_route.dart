import 'package:flutter/material.dart';
import 'i_modular_route.dart';

class ModuleRoute extends ModularRoute {
  ModuleRoute({
    required this.module,
    String? path,
    String? name,
    bool isVisible = true,
    IconData? icon,
    IconData? hugeIcon,
  }) : super(
          name: name ?? module.moduleRoute.name,
          path: path ?? module.moduleRoute.path,
          isVisible: isVisible,
          icon: icon,
          hugeIcon: hugeIcon,
        );

  final Module module;
}
