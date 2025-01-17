import 'dart:convert';
import 'package:hub/services/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String? globalToken;
DateTime? globalTokenExpiration;

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(tokenKey, token);
}

Future<void> loadToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(tokenKey);
  globalToken = token;
}

Future<void> saveTokenExpiration(DateTime expiration) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString(expirationKey, expiration.toIso8601String());
}

Future<void> loadTokenExpiration() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? expirationString = prefs.getString(expirationKey);
  if (expirationString == null) {
    await getToken();
  } else {
    globalTokenExpiration = DateTime.parse(expirationString);
  }
}

Future<void> getToken() async {
  Uri url = Uri.parse('https://www.finanshub.com/wp-json/jwt-auth/v1/token');
  Map<String, String> payload = {"username": "api", "password": "Admin11**"};

  try {
    http.Response response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      String token = responseData['token'];
      globalToken = token;
      await saveToken(token);

      globalTokenExpiration = DateTime.now().add(const Duration(hours: 3));
      await saveTokenExpiration(globalTokenExpiration!);
    } else {
      throw Exception('Could not get token. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get token: $e');
  }
}

Future<void> checkAndRefreshToken() async {
  if (globalTokenExpiration == null) {
    await loadTokenExpiration();
  }

  if (globalTokenExpiration == null || DateTime.now().isAfter(globalTokenExpiration!)) {
    await getToken();
  }
}

Future<void> loadOrFetchToken() async {
  await loadToken();
  await loadTokenExpiration();

  if (globalToken == null) {
    await getToken();
  } else {
    await checkAndRefreshToken();
  }
}
