

import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/modules/home/pages/home.page.dart';

class HomeModule extends Module {
  @override
  FutureBinds (Injector i) { // Optional
  }

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/home', child: (context, state) => HomePage()),
  ];
}
