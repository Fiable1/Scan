import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_scan.dart';

class ApiService {
  static const _urlKey = 'backend_url', _tokenKey = 'auth_token';

  static const String deployedBaseUrl = 'https://backend-ashen-kappa-32.vercel.app';

  static Future<String> baseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_urlKey) ?? deployedBaseUrl;
  }

  static Future<void> setBaseUrl(String v) async =>
      (await SharedPreferences.getInstance()).setString(_urlKey, v.replaceAll(RegExp(r'/+$'), ''));

  static Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  static Future<void> saveToken(String t) async =>
      (await SharedPreferences.getInstance()).setString(_tokenKey, t);

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove(_tokenKey);

  static Future<Map<String, dynamic>> _post(String path, Map body, {bool auth = false}) async {
    final u = '${await baseUrl()}/api/$path';
    final r = await http.post(Uri.parse(u),
        headers: {
          'Content-Type': 'application/json',
          if (auth && await token() != null) 'Authorization': 'Token ${await token()}'
        },
        body: jsonEncode(body));
    final j = r.body.isEmpty ? {} : jsonDecode(r.body);
    if (r.statusCode >= 400) throw Exception(j['detail'] ?? j.toString());
    return Map<String, dynamic>.from(j);
  }

  static Future<List<Map<String, dynamic>>> schools() async {
    final r = await http.get(Uri.parse('${await baseUrl()}/api/schools/'));
    if (r.statusCode >= 400) throw Exception('Could not load schools');
    return List<Map<String, dynamic>>.from(jsonDecode(r.body));
  }

  static Future<List<String>> districts() async {
    final r = await http.get(Uri.parse('${await baseUrl()}/api/districts/'));
    if (r.statusCode >= 400) throw Exception('Could not load districts');
    return List<String>.from(jsonDecode(r.body));
  }

  static Future<Map<String, dynamic>> login(String email, String password) =>
      _post('auth/login/', {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) =>
      _post('auth/register/', data);

  static Future<Map<String, dynamic>> lookup(String code) async {
    final r = await http.get(
        Uri.parse('${await baseUrl()}/api/books/lookup/?code=${Uri.encodeComponent(code)}'),
        headers: {'Authorization': 'Token ${await token()}'});
    if (r.statusCode >= 400) throw Exception('Lookup failed');
    return Map<String, dynamic>.from(jsonDecode(r.body));
  }

  static Future<BookScan> saveScan({
    required String code,
    required List<int> coverBytes,
    required String coverName,
    required Map<String, String> fields,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('${await baseUrl()}/api/scans/'));
    req.headers['Authorization'] = 'Token ${await token()}';
    req.fields['code'] = code;
    req.fields.addAll(fields);
    req.files.add(http.MultipartFile.fromBytes('cover', coverBytes, filename: coverName));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) throw Exception(body);
    return BookScan.fromJson(jsonDecode(body));
  }

  static Future<BookScan> saveScanNoCover({
    required String code,
    required Map<String, String> fields,
  }) async {
    final r = await http.post(Uri.parse('${await baseUrl()}/api/scans/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${await token()}'
        },
        body: jsonEncode({'code': code, ...fields}));
    if (r.statusCode >= 400) throw Exception(r.body);
    return BookScan.fromJson(jsonDecode(r.body));
  }

  static Future<List<BookScan>> scans({String q = ''}) async {
    final r = await http.get(
        Uri.parse('${await baseUrl()}/api/scans/list/?q=${Uri.encodeComponent(q)}'),
        headers: {'Authorization': 'Token ${await token()}'});
    if (r.statusCode >= 400) throw Exception('Could not load scans');
    return (jsonDecode(r.body) as List).map((e) => BookScan.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> analytics() async {
    final r = await http.get(Uri.parse('${await baseUrl()}/api/analytics/'),
        headers: {'Authorization': 'Token ${await token()}'});
    if (r.statusCode >= 400) throw Exception('Could not load analytics');
    return Map<String, dynamic>.from(jsonDecode(r.body));
  }

  static Future<http.Response> excel() async =>
      http.get(Uri.parse('${await baseUrl()}/api/scans/excel/'),
          headers: {'Authorization': 'Token ${await token()}'});

  static Future<bool> testConnection() async {
    try {
      final r = await http.get(Uri.parse('${await baseUrl()}/api/')).timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
