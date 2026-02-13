class SharedManager {
  SharedManager._();

  static final Map<String, Object?> _store = <String, Object?>{};

  static bool? getBool(String key) {
    final value = _store[key];
    if (value is bool) return value;
    return null;
  }

  static Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }
}
