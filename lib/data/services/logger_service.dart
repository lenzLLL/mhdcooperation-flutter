import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService extends GetxService {
  late File _logFile;

  Future<LoggerService> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/logs.txt');
      
      if (!await _logFile.exists()) {
        await _logFile.create();
      }
      
      // Clear logs on fresh start (optional, or append)
      await _logFile.writeAsString('--- Log started at ${DateTime.now()} ---\n', mode: FileMode.append);

      _setupErrorInterception();
    } catch (e) {
      debugPrint('Error initializing LoggerService: $e');
    }
    return this;
  }

  void _setupErrorInterception() {
    // Intercept Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error: ${details.exceptionAsString()}\nStack trace: ${details.stack}\n');
    };

    // Intercept Platform errors (async/etc)
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error: $error\nStack trace: $stack\n');
      return true;
    };
  }

  Future<void> _logError(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';
    
    try {
      await _logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
    
    if (kDebugMode) {
      print(logMessage);
    }
  }

  /// Manually log an error
  static void log(dynamic error, [StackTrace? stack]) {
    if (Get.isRegistered<LoggerService>()) {
      Get.find<LoggerService>()._logError('Manual Log: $error\nStack trace: $stack\n');
    }
  }
}
