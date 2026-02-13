class DashboardRoutes {
  static const dashboard = _RouteInfo('dashboard', '/dashboard');
}

class _RouteInfo {
  const _RouteInfo(this.name, this.path);
  final String name;
  final String path;
}
