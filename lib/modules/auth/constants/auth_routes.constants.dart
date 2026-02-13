class AuthRoutes {
  static const login = _RouteInfo('login', '/login');
}

class _RouteInfo {
  const _RouteInfo(this.name, this.path);
  final String name;
  final String path;
}
