import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const defaultUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String _apiUrl = defaultUrl;

  static String get apiUrl => _apiUrl;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _apiUrl = prefs.getString('api_url') ?? defaultUrl;
  }

  static Future<void> setApiUrl(String url) async {
    final cleanUrl = url.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', cleanUrl);

    _apiUrl = cleanUrl;
  }
}

// Mempertahankan penggunaan apiUrl pada file yang sudah dibuat.
String get apiUrl => ApiConfig.apiUrl;

const batasWaktu = Duration(seconds: 10);
