import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/modules/welcome/pages/welcome.page.dart';

class WelcomeModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, state) => WelcomePage()),
  ];
}
