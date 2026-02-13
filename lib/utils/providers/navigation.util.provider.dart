import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  NavigationState({
    String? pageName,
    List<NavigationBreadcrumb>? breadcrumbs,
  })  : pageName = pageName ?? 'Home',
        breadcrumbs = breadcrumbs ?? <NavigationBreadcrumb>[NavigationBreadcrumb.home()];

  String pageName;
  List<NavigationBreadcrumb> breadcrumbs;
}

class NavigationBreadcrumb {
  NavigationBreadcrumb({
    required this.name,
    required this.path,
    this.isClickable = true,
    this.pageActions = const <PageAction>[],
  });

  factory NavigationBreadcrumb.home() => NavigationBreadcrumb(name: 'Home', path: '/', isClickable: false);

  final String name;
  final String path;
  final bool isClickable;
  final List<PageAction> pageActions;
}

class PageAction {
  const PageAction({
    required this.builder,
    this.isMain = false,
    this.isSecondary = false,
  });

  final bool isMain;
  final bool isSecondary;
  final Widget Function(BuildContext context) builder;

  Widget toWidget(BuildContext context) => builder(context);
}
