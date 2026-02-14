

import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/modules/home/pages/home.page.dart';
import 'package:project_route_p/ui/layouts/shell_layout.dart';

class HomeModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, state) => ShellLayout(child: HomePage())),
  ];
}
