import 'package:flutter/material.dart';
import 'i_modular_route.dart';

class ChildRoute extends ModularRoute {
  ChildRoute(
    String path, {
    required this.child,
    String? name,
    this.routeName,
    bool isVisible = true,
    IconData? icon,
    IconData? hugeIcon,
  }) : super(name: name ?? path, path: path, isVisible: isVisible, icon: icon, hugeIcon: hugeIcon);

  final WidgetBuilder child;
  String? routeName;

  factory ChildRoute.build({
    required CLRoute route,
    required WidgetBuilder childBuilder,
    bool isVisible = true,
  }) {
    return ChildRoute(
      route.path,
      name: route.name,
      child: childBuilder,
      isVisible: isVisible,
    );
  }
}
