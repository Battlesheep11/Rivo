import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  final SharedPreferences prefs;

  AppStorage(this.prefs);

  static Future<AppStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorage(prefs);
  }

  // Example usage
  Future<void> saveToken(String token) async {
    await prefs.setString('auth_token', token);
  }

  String? get token => prefs.getString('auth_token');
}
