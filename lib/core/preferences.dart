import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String? get token => _p.getString('jwt');
  static set token(String? v) => _p.setString('jwt', v ?? '');

  static String? get username => _p.getString('username');
  static set username(String? v) => _p.setString('username', v ?? '');

  static String? get role => _p.getString('role');
  static set role(String? v) => _p.setString('role', v ?? '');

  static String get apiUrl {
    final v = _p.getString('api_url');
    return (v != null && v.isNotEmpty) ? v : 'https://nexus-wos.wasmer.app';
  }
  static set apiUrl(String v) => _p.setString('api_url', v);

  static bool get isLoggedIn => token != null && token!.isNotEmpty;
  static void clear() => _p.clear();
}
