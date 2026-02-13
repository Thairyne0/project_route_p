import 'package:flutter/material.dart';
import 'package:go_router_modular/go_router_modular.dart';

import 'app.module.dart';
import 'app.widget.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Modular.configure(
    appModule: AppModule(),
    initialRoute: '/welcome',
  );
  runApp(AppWidget());
}
