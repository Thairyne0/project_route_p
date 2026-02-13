import 'package:flutter/material.dart';
import 'i_modular_route.dart';

class ShellModularRoute extends ModularRoute {
  ShellModularRoute({
    required this.builder,
    required this.routes,
    this.redirect,
    this.observers,
    String? name,
    String path = '',
    bool isVisible = true,
  }) : super(name: name ?? 'shell', path: path, isVisible: isVisible);

  final Widget Function(BuildContext context, dynamic state, Widget child)? builder;
  final List<ModularRoute> routes;
  final String? Function(BuildContext context, dynamic state)? redirect;
  final List<NavigatorObserver>? observers;
}
