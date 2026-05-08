import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application Configuration
class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();
  // Environment variables
  late bool debugMode;
  late bool demoMode;
  static const String _debugModeDefine = String.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: '',
  );
  static const String _demoModeDefine = String.fromEnvironment(
    'DEMO_MODE',
    defaultValue: '',
  );

  /// Initialize configuration from .env file
  Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Allow release builds to keep running even if the asset is missing.
    }

    debugMode =
        (_firstNonEmpty([
                  _debugModeDefine,
                  _dotenvValue('DEBUG_MODE'),
                  kDebugMode.toString(),
                ]) ??
                'false')
            .toLowerCase() ==
        'true';
    demoMode =
        (_firstNonEmpty([
                  _demoModeDefine,
                  _dotenvValue('DEMO_MODE'),
                  'false',
                ]) ??
                'false')
            .toLowerCase() ==
        'true';
  }

  /// Get full API URL with endpoint

  /// Format media URL (handles relative paths from backend)

  /// Check if debug mode is enabled
  bool get isDebugMode => debugMode;
  bool get isDemoMode => demoMode;
  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  String? _dotenvValue(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }
}
