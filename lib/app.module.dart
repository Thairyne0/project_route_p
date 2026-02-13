
import 'package:go_router_modular/go_router_modular.dart';

import 'modules/home/home.module.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes =>
      [
        ModuleRoute('/home', module: HomeModule()),
      ];

}