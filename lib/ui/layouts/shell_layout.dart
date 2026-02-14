import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';

class ShellLayout extends StatelessWidget {
  final Widget child;

  const ShellLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header fisso
          const AppHeader(),
          // Contenuto con sidebar
          Expanded(
            child: Row(
              children: [
                // Sidebar fisso
                const AppSidebar(),
                // Area contenuto dinamico (cambia con la navigazione)
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: child, // Qui viene renderizzato il contenuto della rotta
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
