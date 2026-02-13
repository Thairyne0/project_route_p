class ProfileRoutes {
  static const userProfile = _RouteInfo('userProfile', '/profile');
}

class _RouteInfo {
  const _RouteInfo(this.name, this.path);
  final String name;
  final String path;
}
