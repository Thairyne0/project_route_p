import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildMenuItem(
            context,
            icon: Icons.home,
            label: 'Home',
            route: '/shell/home',
          ),
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/shell/dashboard',
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            route: '/shell/profile',
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            route: '/shell/settings',
          ),
          const Spacer(),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            route: '/auth',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isSelected = currentRoute.startsWith(route);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      onTap: () {
        context.go(route);
      },
    );
  }
}
