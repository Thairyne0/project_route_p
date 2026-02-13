import 'dart:ui';

import 'package:project_route_p/ui/widgets/avatar.widget.dart';
import 'package:project_route_p/ui/widgets/buttons/cl_button.widget.dart';
import 'package:project_route_p/ui/widgets/customexpansiontile.widget.dart';
import 'package:project_route_p/utils/extension.util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../modules/juridical/constants/juridicals_routes.constants.dart';
import '../../utils/providers/authstate.util.provider.dart';
import 'constants/sizes.constant.dart';
import '../../utils/go_router_modular/routes/child_route.dart';
import '../../utils/go_router_modular/routes/i_modular_route.dart';
import '../../utils/go_router_modular/routes/module_route.dart';
import '../../utils/go_router_modular/routes/shell_modular_route.dart';
import 'package:project_route_p/utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';

class MenuLayout extends StatefulWidget {
  final List<ModularRoute> routes;
  final String? logoImagePath;
  final String? logoImagePathMini;

  const MenuLayout({super.key, required this.routes, this.logoImagePath, this.logoImagePathMini});

  @override
  createState() => _MenuLayoutState();
}

class _MenuLayoutState extends State<MenuLayout> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final navigationState = context.watch<NavigationState>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: 280,
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
        border: Border(right: BorderSide(color: CLTheme.of(context).borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (authState.currentTenant != null) ...[
            SizedBox(height: Sizes.padding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                titleAlignment: ListTileTitleAlignment.center,
                onTap: () {
                  context.customGoNamed(JuridicalRoutes.viewJuridical.name, params: {"juridicalId": authState.currentTenant!.id.toString()});
                },
                minLeadingWidth: 0,
                minTileHeight: 0,
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  "${authState.currentTenant?.businessName}",
                  style: CLTheme.of(context).bodyLabel.copyWith(color: CLTheme.of(context).primaryText, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "P.IVA ${authState.currentTenant?.vatNumber}",
                  style: CLTheme.of(context).smallLabel.copyWith(color: CLTheme.of(context).secondaryText),
                ),
                leading: CLAvatarWidget(name: authState.currentTenant!.businessName, medias: []),
              ),
            ),
            SizedBox(height: Sizes.padding / 2),
            if (authState.tenantList.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                child: CLButton(
                  text: 'Cambia profilo',
                  textStyle: CLTheme.of(context).bodyText,
                  hugeIcon: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, size: Sizes.medium, color: CLTheme.of(context).primaryText),
                  backgroundColor: CLTheme.of(context).primaryBackground,
                  onTap: () {
                    authState.setCurrentTenant(null);
                  },
                  context: context,
                  iconAlignment: IconAlignment.start,
                ),
              ),
            if (authState.tenantList.length > 1) SizedBox(height: Sizes.padding),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var route in widget.routes)
                    if (route is ChildRoute && route.isVisible)
                      _buildChildRoute(navigationState, route, 0)
                    else if (route is ShellModularRoute)
                      for (var subRoute in route.routes)
                        if (subRoute is ChildRoute && subRoute.isVisible)
                          _buildChildRoute(navigationState, subRoute, 0)
                        else if (subRoute is ModuleRoute && subRoute.isVisible)
                          if (subRoute.module.routes.where((childRoute) => (childRoute is ChildRoute && childRoute.isVisible)).isNotEmpty)
                            if (subRoute.module.routes
                                    .where(
                                      (childRoute) =>
                                          ((childRoute is ChildRoute && childRoute.isVisible || childRoute is ModuleRoute && childRoute.isVisible)),
                                    )
                                    .length ==
                                1)
                              _buildChildRoute(
                                navigationState,
                                (subRoute.module.routes.where((childRoute) => (childRoute is ChildRoute && childRoute.isVisible)).first as ChildRoute)
                                  ..icon = subRoute.icon
                                  ..hugeIcon = subRoute.hugeIcon
                                  ..path = subRoute.module.moduleRoute.path,
                                0,
                              )
                            else
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 0), child: _buildGroupRoute(navigationState, subRoute))
                          else
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 0), child: _buildGroupRoute(navigationState, subRoute)),
                  SizedBox(height: Sizes.padding),
                ],
              ),
            ),
          ),

          SizedBox(height: Sizes.padding),
        ],
      ),
    );
  }

  Widget _buildChildRoute(NavigationState navigationState, ChildRoute route, double padding) {
    return ListTile(
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.only(left: 38),
      // Container padding (8px) + spazio simmetrico (8px) + freccia (20px) + spacing (8px) = 36px per allineare l'icona
      hoverColor: Colors.transparent,
      minVerticalPadding: Sizes.padding / 2 + 4,
      minTileHeight: 0,
      leading:
          route.hasIcon
              ? route.buildIcon(
                size: Sizes.medium,
                color: _isSelected(navigationState, route.path) ? CLTheme.of(context).primary : CLTheme.of(context).primaryText,
              )
              : VerticalDivider(color: _getRouteColor(navigationState, route.path, isVerticalDivider: true), width: 2),
      title: Text(
        route.name,
        style: CLTheme.of(context).bodyLabel.copyWith(
          color: _isSelected(navigationState, route.path) ? CLTheme.of(context).primary : CLTheme.of(context).primaryText,
          fontWeight: _isSelected(navigationState, route.path) ? FontWeight.normal : FontWeight.normal,
        ),
        overflow: TextOverflow.fade,
        maxLines: 3,
      ),
      selected: _isSelected(navigationState, route.path),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
      onTap: () {
        if (!ResponsiveBreakpoints.of(context).isDesktop) {
          Scaffold.of(context).closeDrawer();
        }
        context.customGoNamed(route.name);
      },
    );
  }

  Widget _buildGroupRoute(NavigationState navigationState, ModuleRoute subRoute, {String basePath = ''}) {
    final currentPath = "$basePath${subRoute.path}"; // Percorso cumulativo
    final isSelected = _isSelected(navigationState, currentPath.replaceAll('//', '/'), isParentRoute: true);

    // Usa un ValueNotifier per tracciare lo stato di espansione
    final isExpandedNotifier = ValueNotifier<bool>(isSelected);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, child) {
        // Colore dinamico basato solo su selezione, non su espansione
        final iconColor = isSelected ? CLTheme.of(context).primary : CLTheme.of(context).primaryText;

        return CLExpansionTile(
          title: subRoute.name,
          isSelected: isSelected,
          onExpansionChanged: (expanded) {
            isExpandedNotifier.value = expanded;
          },
          leading: subRoute.buildIcon(size: Sizes.medium, color: iconColor) ?? Icon(Icons.folder, size: Sizes.medium, color: iconColor),
          children: [
            for (var childRoute in subRoute.module.routes)
              if (childRoute is ChildRoute && childRoute.isVisible)
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    context.customGoNamed(childRoute.routeName ?? childRoute.name);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Spazio simmetrico (8) + Freccia (20) + spacing (8) + centro icona (10) = 46px per centrare il divider con l'icona del padre
                        const SizedBox(width: 48),
                        SizedBox(
                          width: 2,
                          height: 24,
                          child: Center(
                            child: Container(
                              width: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')) ? 2 : 1,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _getRouteColor(
                                  navigationState,
                                  "$currentPath${childRoute.path}".replaceAll('//', '/'),
                                  isVerticalDivider: true,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 21),

                        Expanded(
                          child: Text(
                            childRoute.name,
                            style: CLTheme.of(
                              context,
                            ).bodyText.copyWith(color: _getRouteColor(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/'))),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (childRoute is ModuleRoute && childRoute.isVisible)
                if (childRoute.module.routes.where((childSubRoute) => (childSubRoute is ChildRoute && childSubRoute.isVisible)).length == 1)
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      // Usa il path completo per la navigazione
                      final fullRoutePath = "$currentPath${childRoute.path}".replaceAll('//', '/');
                      context.go(fullRoutePath);
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Spazio simmetrico (8) + Freccia (20) + spacing (8) + centro icona (10) = 46px per centrare il divider con l'icona del padre
                          const SizedBox(width: 48),
                          SizedBox(
                            width: 2,
                            height: 24,
                            child: Center(
                              child: Container(
                                width: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')) ? 2 : 1,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _getRouteColor(
                                    navigationState,
                                    "$currentPath${childRoute.path}".replaceAll('//', '/'),
                                    isVerticalDivider: true,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                          // Centro icona (10) + spacing (8) = 18px, totale 46+18=64px dove inizia il testo del padre
                          const SizedBox(width: 21),
                          Expanded(
                            child: Text(
                              ((childRoute.module.routes.where((childSubRoute) => (childSubRoute is ChildRoute && childSubRoute.isVisible)).first
                                        as ChildRoute)
                                    ..path = childRoute.module.moduleRoute.path)
                                  .name,
                              style: CLTheme.of(
                                context,
                              ).bodyLabel.copyWith(color: _getRouteColor(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/'))),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildGroupRoute(navigationState, childRoute, basePath: currentPath),
          ],
        );
      },
    );
  }

  Color _getRouteColor(NavigationState navigationState, String fullPath, {bool isVerticalDivider = false}) {
    Uri? currentUri = Router.of(context).routeInformationProvider?.value.uri;
    String normalizedFullPath = fullPath;
    if (normalizedFullPath.endsWith('/')) {
      normalizedFullPath = normalizedFullPath.substring(0, normalizedFullPath.length - 1);
    }
    return currentUri.toString() == normalizedFullPath
        ? CLTheme.of(context).primary
        : isVerticalDivider
        ? CLTheme.of(context).borderColor
        : CLTheme.of(context).primaryText;
  }

  bool _isSelected(NavigationState navigationState, String fullPath, {bool isParentRoute = false}) {
    Uri? currentUri = Router.of(context).routeInformationProvider?.value.uri;
    String normalizedFullPath = fullPath;
    if (normalizedFullPath.endsWith('/')) {
      normalizedFullPath = normalizedFullPath.substring(0, normalizedFullPath.length - 1);
    }
    String currentPath = currentUri.toString();

    if (isParentRoute) {
      // Per le route padre, verifica se siamo esattamente su quella route O su una sua sotto-route
      // Importante: deve iniziare con il path E poi avere uno slash, altrimenti /training-methodologist
      // matcherebbe anche /training-methodologist-juridicals
      return currentPath == normalizedFullPath ||
          (currentPath.startsWith(normalizedFullPath) &&
              currentPath.length > normalizedFullPath.length &&
              currentPath[normalizedFullPath.length] == '/');
    } else {
      // Per le route figlie, match esatto
      return currentPath == normalizedFullPath;
    }
  }
}
