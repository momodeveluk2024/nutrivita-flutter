import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('NUTRIVITA_API_URL');
    if (configuredUrl.isNotEmpty) {
      return _withoutTrailingSlash(configuredUrl);
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/v1';
    }

    return 'http://localhost:8080/v1';
  }

  static const signup = '/auth/signup';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const verifyEmail = '/auth/verify-email';
  static const me = '/me';
  static const meProfile = '/me/profile';
  static const mePreferences = '/me/preferences';
  static const streak = '/me/streak';
  static const foods = '/foods';
  static const logs = '/logs';
  static const todayIntake = '/logs/today/intake';
  static const weekIntake = '/logs/week';
  static const favorites = '/favorites';
  static const reminders = '/reminders';
  static const recommendations = '/recommendations';

  static String food(String id) => '/foods/$id';
  static String log(String id) => '/logs/$id';
  static String favorite(String id) => '/favorites/$id';
  static String reminder(String id) => '/reminders/$id';

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
