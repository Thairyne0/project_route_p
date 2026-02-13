import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../utils/providers/appstate.util.provider.dart';
import '../../utils/go_router_modular/go_router_modular_configure.dart';
import '../../utils/providers/authstate.util.provider.dart';
import '../cl_theme.dart';
import 'constants/sizes.constant.dart';
import 'header.layout.dart';
import 'menu.layout.dart';
import 'notifications_panel.layout.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppLayout extends StatefulWidget {
  const AppLayout({super.key, required this.shellChild});

  final Widget shellChild;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WidgetsBindingObserver, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Salva lo stato o ferma determinate azioni
    } else if (state == AppLifecycleState.resumed) {
      // Ripristina alcune azioni, se necessario
    }
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages("it", timeago.ItMessages());
    return Consumer2<AppState, AuthState>(
      builder: (context, appState, authState, child) {
        return Scaffold(
          backgroundColor: CLTheme.of(context).primaryBackground,
          endDrawer: _buildEndDrawer(context),
          drawer: _buildMainDrawer(),
          body: _buildResponsiveLayout(context, appState),
        );
      },
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    return Text("jkfnirnfifr");
  }

  Widget _buildMainDrawer() {
    return Drawer(child: GoRouterModular.get<MenuLayout>());
  }

  Widget _buildResponsiveLayout(BuildContext context, AppState appState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveBreakpoints.of(context).isDesktop) {
          return _buildDesktopLayout(appState);
        } else {
          return _buildMobileLayout(appState);
        }
      },
    );
  }

  Widget _buildDesktopLayout(AppState appState) {
    return Row(
      children: [
        GoRouterModular.get<MenuLayout>(),
        Expanded(
          child: Stack(
            children: [
              // Contenuto della pagina con padding per l'header
              Positioned.fill(child: widget.shellChild),
              // Header con blur - sovrapposto in alto, crea effetto glass morphism
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HeaderLayout(
                  headerColor: CLTheme.of(context).secondaryBackground,
                  headerHeight: Sizes.headerOffset / 2,
                ),
              ),
            ],
          ),
        ),
        const NotificationsPanel(),
      ],
    );
  }

  Widget _buildMobileLayout(AppState appState) {
    return Stack(
      children: [
        // Contenuto della pagina con padding per l'header
        Positioned.fill(child: Padding(padding: const EdgeInsets.only(top: Sizes.headerOffset), child: widget.shellChild)),
        // Header con blur - sovrapposto in alto
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: HeaderLayout(
            headerColor: CLTheme.of(context).primaryBackground,
            headerHeight: Sizes.headerOffset / 2,
          ),
        ),
      ],
    );
  }
}
