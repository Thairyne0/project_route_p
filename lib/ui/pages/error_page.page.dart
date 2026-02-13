import 'package:project_route_p/modules/auth/constants/auth_routes.constants.dart';
import 'package:project_route_p/modules/dashboard/constants/dashboard_routes.constants.dart';
import 'package:project_route_p/ui/widgets/buttons/cl_button.widget.dart';
import 'package:project_route_p/utils/extension.util.dart';
import 'package:project_route_p/utils/providers/errorstate.util.provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class ErrorPage extends StatefulWidget {
  final int? errorCode;
  final String? errorDetail;
  final String? errorMessage;

  const ErrorPage({super.key, this.errorCode, this.errorDetail, this.errorMessage});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  String _getErrorTitle(int? errorCode) {
    switch (errorCode) {
      case 401:
        return "Sessione Scaduta";
      case 403:
        return "Accesso Negato";
      default:
        return "Errore";
    }
  }

  String _getErrorMessage(int? errorCode) {
    switch (errorCode) {
      case 401:
        return "La tua sessione è scaduta. Effettua nuovamente il login per continuare.";
      case 403:
        return "Non hai i permessi necessari per accedere a questa risorsa.";
      default:
        return "Si è verificato un errore imprevisto.";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final errorState = context.watch<ErrorState>();

    // Usa il codice da ErrorState se disponibile, altrimenti usa i parametri del widget
    final displayErrorCode = errorState.hasError ? errorState.errorCode : widget.errorCode;

    // Usa i dettagli aggiuntivi dal backend se disponibili (opzionale)
    final backendDetail = errorState.hasError ? errorState.errorDetail : widget.errorDetail;

    return Scaffold(
      backgroundColor: CLTheme.of(context).primaryBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(displayErrorCode == 401 ? Icons.lock_outline : Icons.block, size: 100, color: CLTheme.of(context).danger),
                const SizedBox(height: Sizes.padding * 2),
                Text(
                  "${displayErrorCode ?? 'Errore'} - ${_getErrorTitle(displayErrorCode)}",
                  style: CLTheme.of(context).heading1.override(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.padding),
                Text(
                  _getErrorMessage(displayErrorCode),
                  style: CLTheme.of(context).title.override(color: CLTheme.of(context).secondaryText),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: Sizes.padding * 4),
                CLButton.secondary(
                  text: displayErrorCode == 401 ? "Vai al Login" : "Torna alla Dashboard",
                  onTap: () async {
                    errorState.clearError();
                    if (displayErrorCode == 401) {
                      context.customGoNamed(AuthRoutes.login.name);
                    } else {
                      context.customGoNamed(DashboardRoutes.dashboard.name);
                    }
                  },
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
