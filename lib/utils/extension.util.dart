import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensions on BuildContext {
  void customGoNamed(
    String name, {
    Map<String, String>? params,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    GoRouter.of(this).goNamed(
      name,
      pathParameters: params ?? const {},
      queryParameters: queryParams ?? const {},
      extra: extra,
    );
  }
}
