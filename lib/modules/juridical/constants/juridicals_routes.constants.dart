class JuridicalRoutes {
  static const viewJuridical = _RouteInfo('viewJuridical', '/juridicals/:juridicalId');
}

class _RouteInfo {
  const _RouteInfo(this.name, this.path);
  final String name;
  final String path;
}
