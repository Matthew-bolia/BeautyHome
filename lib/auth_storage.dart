import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const _keyEmail = 'saved_email';
  static const _keyPassword = 'saved_password';
  static const _keyRemember = 'remember_me';

  /// Sauvegarde les credentials si l'utilisateur a coché "Se souvenir de moi"
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRemember, true);
  }

  /// Récupère les credentials sauvegardés (null si rien)
  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRemember) ?? false;
    if (!remember) return {'email': null, 'password': null};
    return {
      'email': prefs.getString(_keyEmail),
      'password': prefs.getString(_keyPassword),
    };
  }

  /// Efface les credentials sauvegardés
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRemember, false);
  }
}