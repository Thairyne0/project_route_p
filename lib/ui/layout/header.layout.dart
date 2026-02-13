import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:project_route_p/utils/extension.util.dart';
import '../../modules/profile/constants/users_routes.constants.dart';
import 'package:project_route_p/utils/providers/navigation.util.provider.dart';
import '../../utils/providers/authstate.util.provider.dart';
import '../../utils/providers/theme.util.provider.dart';
import '../../utils/providers/notifications_panel.util.provider.dart';
import '../widgets/avatar.widget.dart';
import '../widgets/cl_container.widget.dart';
import 'breadcrumbs.layout.dart';
import 'constants/sizes.constant.dart';
import '../cl_theme.dart';

class HeaderLayout extends StatefulWidget {
  const HeaderLayout({super.key, this.headerColor, this.headerHeight, this.iconColor, this.iconSize});

  final Color? headerColor;
  final double? headerHeight;
  final Color? iconColor;
  final double? iconSize;

  @override
  State<HeaderLayout> createState() => _HeaderLayoutState();
}

class _HeaderLayoutState extends State<HeaderLayout> {
  GlobalKey profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AuthState authState = Provider.of<AuthState>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: widget.headerHeight,
          padding: EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 2),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: CLTheme.of(context).borderColor, width: 1)), color: widget.headerColor),

          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!ResponsiveBreakpoints.of(context).isDesktop)
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: CLTheme.of(context).primaryText, size: 24),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              if (!ResponsiveBreakpoints.of(context).isDesktop) SizedBox(width: Sizes.padding),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(reverse: true, scrollDirection: Axis.horizontal, child: BreadcrumbsLayout()),
                ),
              ),
              // Toggle Dark Mode con HugeIcon
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: HugeIcon(
                      icon: themeProvider.isDarkMode ? HugeIcons.strokeRoundedSun03 : HugeIcons.strokeRoundedMoon02,
                      color: CLTheme.of(context).primaryText,
                      size: 20,
                    ),
                    tooltip: themeProvider.isDarkMode ? 'Modalità chiara' : 'Modalità scura',
                    onPressed: () async {
                      await themeProvider.toggleTheme();
                    },
                  );
                },
              ),
              SizedBox(width: Sizes.padding / 2),
              // Icona notifiche
              Consumer<NotificationsPanelProvider>(
                builder: (context, notificationsPanelProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          notificationsPanelProvider.isCurrentSection(PanelSection.notifications)
                              ? CLTheme.of(context).primaryBackground
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification03, color: CLTheme.of(context).primaryText, size: 20),
                      tooltip: 'Notifiche',
                      onPressed: () {
                        notificationsPanelProvider.toggle(PanelSection.notifications);
                      },
                    ),
                  );
                },
              ),
              SizedBox(width: Sizes.padding / 2),
              // Icona chatbot
              Consumer<NotificationsPanelProvider>(
                builder: (context, notificationsPanelProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          notificationsPanelProvider.isCurrentSection(PanelSection.chatbot)
                              ? CLTheme.of(context).primaryBackground
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedAiChat02, color: CLTheme.of(context).primaryText, size: 20),
                      tooltip: 'Assistente AI',
                      onPressed: () {
                        notificationsPanelProvider.toggle(PanelSection.chatbot);
                      },
                    ),
                  );
                },
              ),
              SizedBox(width: Sizes.padding),
              InkWell(
                onTap: () async {
                  // Salva il context originale prima di aprire il dialog
                  final originalContext = context;
                  await showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext dialogContext) {
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            right: Sizes.padding,
                            top: Sizes.padding * 3.3,
                            child: Material(
                              color: Colors.transparent,
                              child: IntrinsicWidth(
                                child: CLContainer(
                                  contentPadding: EdgeInsets.all(Sizes.padding),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        minTileHeight: 0,
                                        minVerticalPadding: 0,
                                        contentPadding: EdgeInsets.zero,
                                        leading: HugeIcon(
                                          icon: HugeIcons.strokeRoundedUser,
                                          color: CLTheme.of(dialogContext).primaryText,
                                          size: Sizes.medium,
                                        ),
                                        title: Text('Profilo', style: CLTheme.of(dialogContext).bodyText),
                                        onTap: () {
                                          Navigator.pop(dialogContext);
                                          originalContext.customGoNamed(ProfileRoutes.userProfile.name);
                                        },
                                      ),
                                      SizedBox(height: Sizes.padding),
                                      ListTile(
                                        minTileHeight: 0,
                                        minVerticalPadding: 0,
                                        contentPadding: EdgeInsets.zero,
                                        leading: HugeIcon(
                                          icon: HugeIcons.strokeRoundedLogout01,
                                          color: CLTheme.of(dialogContext).danger,
                                          size: Sizes.medium,
                                        ),
                                        title: Text('Logout', style: CLTheme.of(dialogContext).bodyText.override(color: CLTheme.of(context).danger)),
                                        onTap: () async {
                                          await authState.currentManager.logout();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: CLAvatarWidget(
                        medias: [],
                        elementToPreview: 1,
                        name:
                            "${authState.currentUser?.userInfo['userInfo']['firstName']} ${authState.currentUser?.userInfo['userInfo']['lastName']}",
                      ),
                    ),
                    SizedBox(width: Sizes.padding / 2),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${authState.currentUser?.userInfo['userInfo']['firstName']} ${authState.currentUser?.userInfo['userInfo']['lastName']}",
                          style: CLTheme.of(context).bodyText,
                        ),
                        Text("${authState.currentUser?.userInfo['email']}", style: CLTheme.of(context).smallLabel),
                      ],
                    ),
                  ],
                ),
              ),

              /*  CLButton.secondary(
                    text: 'Logout',
                    icon: Icons.logout,
                    onTap: () async {
                      await authState.currentManager.logout();
                    },
                    context: context,
                    iconAlignment: IconAlignment.start,
                  ),*/
            ],
          ),
        ),

        ResponsiveBreakpoints.of(context).isDesktop
            ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  height: Sizes.headerOffset/2,
                  decoration: BoxDecoration(color: CLTheme.of(context).primaryBackground.withValues(alpha: 0.2)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: Sizes.padding, right: Sizes.padding, bottom: Sizes.padding, top: Sizes.padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              reverse: true,
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                navigationState.pageName,
                                style: CLTheme.of(context).title.override(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Sizes.padding),
                        // Actions principali
                        ...navigationState.breadcrumbs.last.pageActions
                            .where((pageAction) => pageAction.isMain == true)
                            .map(
                              (pageAction) => Padding(
                                padding: EdgeInsets.only(left: navigationState.breadcrumbs.last.pageActions.length == 1 ? 0.0 : Sizes.padding),
                                child: pageAction.toWidget(context),
                              ),
                            ),
                        navigationState.breadcrumbs.last.pageActions.where((pageAction) => !pageAction.isMain && !pageAction.isSecondary).isNotEmpty
                            ? SizedBox(width: 16)
                            : SizedBox.shrink(),
                        // Menu con le azioni secondarie
                        if (navigationState.breadcrumbs.last.pageActions.where((pageAction) => pageAction.isMain == false).isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              // Salva il context originale prima di aprire il dialog
                              final originalContext = context;
                              await showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (BuildContext dialogContext) {
                                  return Stack(
                                    children: <Widget>[
                                      Positioned(
                                        left: MediaQuery.of(dialogContext).size.width - 362,
                                        top: 120,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
                                            width: 320.0,
                                            decoration: BoxDecoration(
                                              color: CLTheme.of(dialogContext).secondaryBackground,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: CLTheme.of(dialogContext).alternate,
                                                  spreadRadius: 3,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 0), // Cambia la posizione dell'ombra
                                                ),
                                              ],
                                              borderRadius: BorderRadius.circular(Sizes.padding),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                                                  child: Text("Azioni", style: CLTheme.of(dialogContext).bodyLabel),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                                                  child: Divider(thickness: 1.0, color: CLTheme.of(dialogContext).alternate),
                                                ),
                                                ...navigationState.breadcrumbs.last.pageActions
                                                    .where((pageAction) => pageAction.isMain == false)
                                                    .map((pageAction) => pageAction.toWidget(originalContext)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, size: Sizes.medium, color: CLTheme.of(context).secondaryText),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            : ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: widget.headerHeight,
                  decoration: BoxDecoration(color: CLTheme.of(context).primaryBackground.withValues(alpha: 0.7)),
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(navigationState.pageName, style: CLTheme.of(context).heading4, overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                      ),
                      SizedBox(width: Sizes.padding),
                      if (navigationState.breadcrumbs.last.pageActions.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return CLContainer(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: Sizes.padding * 2),
                                    itemCount: navigationState.breadcrumbs.last.pageActions.length,
                                    itemBuilder: (context, index) {
                                      return navigationState.breadcrumbs.last.pageActions[index].toWidget(context);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, size: Sizes.medium, color: CLTheme.of(context).primaryText),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
