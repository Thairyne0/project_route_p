
import 'package:go_router_modular/go_router_modular.dart';
import 'package:project_route_p/ui/layouts/shell_layout.dart';
import 'package:project_route_p/modules/home/pages/home.page.dart';
import 'package:project_route_p/modules/dashboard/pages/dashboard.page.dart';

import 'modules/auth/auth.module.dart';
import 'modules/welcome/welcome.module.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        // Rotte senza shell (login, welcome, etc.)
        ModuleRoute('/welcome', module: WelcomeModule()),
        ModuleRoute('/auth', module: AuthModule()),
        
        // Modulo Shell con layout fisso
        ModuleRoute('/shell', module: ShellModule()),
      ];

}

// Modulo Shell che gestisce le rotte con layout fisso
class ShellModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, state) => ShellLayout(child: HomePage())),
    ChildRoute('/home', child: (context, state) => ShellLayout(child: HomePage())),
    ChildRoute('/dashboard', child: (context, state) => ShellLayout(child: DashboardPage())),
  ];
}