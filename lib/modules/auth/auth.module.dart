import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/modules/auth/pages/login.page.dart';
import 'package:project_route_p/modules/auth/pages/register.page.dart';

class AuthModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, state) => LoginPage()), // Route principale
    ChildRoute('/register', child: (context, state) => RegisterPage()),
  ];
}
