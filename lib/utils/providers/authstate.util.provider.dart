import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  bool isAuthenticated = false;
  Tenant? currentTenant;
  List<Tenant> tenantList = <Tenant>[];
  User? currentUser;
  final AuthManager currentManager = AuthManager();

  void setCurrentTenant(Tenant? tenant) {
    currentTenant = tenant;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    return true;
  }
}

class Tenant {
  Tenant({required this.id, required this.businessName, required this.vatNumber});

  final String id;
  final String businessName;
  final String vatNumber;
}

class User {
  User({required this.userInfo, this.idToken});

  final Map<String, dynamic> userInfo;
  final String? idToken;
}

class AuthManager {
  Future<void> logout() async {}
}
