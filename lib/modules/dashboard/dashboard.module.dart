import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/modules/dashboard/pages/dashboard.page.dart';
import 'package:project_route_p/ui/layouts/shell_layout.dart';

class DashboardModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, state) => ShellLayout(child: DashboardPage())),
  ];
}
