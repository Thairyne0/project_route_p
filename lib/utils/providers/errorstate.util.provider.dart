import 'package:flutter/foundation.dart';

class ErrorState extends ChangeNotifier {
  int? errorCode;
  String? errorDetail;
  String? errorMessage;

  bool get hasError => errorCode != null || errorDetail != null || errorMessage != null;

  void setError({int? code, String? detail, String? message}) {
    errorCode = code;
    errorDetail = detail;
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorCode = null;
    errorDetail = null;
    errorMessage = null;
    notifyListeners();
  }
}
