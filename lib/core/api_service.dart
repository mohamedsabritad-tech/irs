import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_token.dart';
import 'preferences.dart';

class ApiService {
  static const _base = 'https://nexus-wos.wasmer.app/api/android/';

  static final _client = http.Client();

  static Map<String, String> _headers() {
    final h = {
      'Content-Type': 'application/json',
      'X-App-Token': AppToken.get(),
    };
    final t = Preferences.token;
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    return h;
  }

  static Future<http.Response> _req(
      String method, String path, Map<String, dynamic>? body) async {
    final uri = Uri.parse('$_base$path');
    final h = _headers();
    late http.Response res;
    if (method == 'GET') {
      res = await _client.get(uri, headers: h);
    } else if (method == 'DELETE') {
      res = await _client.delete(uri, headers: h);
    } else {
      res = await _client.post(uri, headers: h, body: jsonEncode(body ?? {}));
    }
    return res;
  }

  static Map<String, dynamic> _body(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return {'ok': true};
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    if (r.body.isNotEmpty) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    return {'ok': false, 'error': 'HTTP ${r.statusCode}'};
  }

  // --- Auth ---
  static Future<Map<String, dynamic>> login(
          String user, String pass, String? code) async =>
      _body(await _req('POST', 'auth/login', {
        if (user.isNotEmpty) 'username': user,
        if (pass.isNotEmpty) 'password': pass,
        if (code != null && code.isNotEmpty) 'code': code,
      }));

  static Future<Map<String, dynamic>> signup(
          String user, String pass) async =>
      _body(await _req('POST', 'auth/signup', {
        'username': user,
        'password': pass,
      }));

  static Future<Map<String, dynamic>> me() async =>
      _body(await _req('POST', 'auth/me', null));

  static Future<Map<String, dynamic>> logout() async =>
      _body(await _req('POST', 'auth/logout', null));

  // --- Accounts ---
  static Future<Map<String, dynamic>> getAccounts() async =>
      _body(await _req('GET', 'accounts', null));

  static Future<Map<String, dynamic>> addAccount(Map<String, dynamic> b) async =>
      _body(await _req('POST', 'accounts', b));

  static Future<Map<String, dynamic>> deleteAccount(String id) async =>
      _body(await _req('DELETE', 'accounts/$id', null));

  static Future<Map<String, dynamic>> batchAddAccounts(
          Map<String, dynamic> b) async =>
      _body(await _req('POST', 'accounts/batch-add', b));

  // --- Transfer ---
  static Future<Map<String, dynamic>> getTransferPlayers() async =>
      _body(await _req('GET', 'transfer', null));

  static Future<Map<String, dynamic>> addTransferPlayer(String gameId) async =>
      _body(await _req('POST', 'transfer', {'gameId': gameId}));

  static Future<Map<String, dynamic>> promoteTransferPlayer(
          Map<String, dynamic> b) async =>
      _body(await _req('POST', 'transfer/promote', b));

  static Future<Map<String, dynamic>> deleteTransferPlayer(String id) async =>
      _body(await _req('DELETE', 'transfer/$id', null));

  // --- Redeem ---
  static Future<Map<String, dynamic>> getRedeemCodes() async =>
      _body(await _req('GET', 'redeem/codes', null));

  static Future<Map<String, dynamic>> redeemCodes(
          Map<String, dynamic> b) async =>
      _body(await _req('POST', 'redeem', b));

  static Future<Map<String, dynamic>> getRedeemHistory({int limit = 50}) async =>
      _body(await _req('GET', 'redeem/history?limit=$limit', null));

  // --- Alliances ---
  static Future<Map<String, dynamic>> getAlliances() async =>
      _body(await _req('GET', 'alliances', null));

  static Future<Map<String, dynamic>> saveAlliance(
          Map<String, dynamic> b) async =>
      _body(await _req('POST', 'alliances', b));

  static Future<Map<String, dynamic>> deleteAlliance(String tag) async =>
      _body(await _req('DELETE', 'alliances/$tag', null));

  // --- Activity ---
  static Future<Map<String, dynamic>> getActivity({int limit = 100}) async =>
      _body(await _req('GET', 'activity?limit=$limit', null));

  // --- Player Records ---
  static Future<Map<String, dynamic>> getPlayerRecords() async =>
      _body(await _req('GET', 'player-records', null));

  // --- Settings ---
  static Future<Map<String, dynamic>> getSettings() async =>
      _body(await _req('GET', 'settings', null));

  static Future<Map<String, dynamic>> updateSettings(
          Map<String, dynamic> b) async =>
      _body(await _req('POST', 'settings', b));
}
