import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/utils/app_config.dart';
import 'controllers/theme_controller.dart';
import 'data/services/cache_service.dart';
import 'data/services/logger_service.dart';
import 'data/services/session_service.dart';
import 'data/services/storage_service.dart';
import 'core/values/app_strings.dart';
import 'routes/app_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => LoggerService().init());
  await AppConfig().initialize();
  await _initServices();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ChristLumenApp());
}

Future<void> _initServices() async {
  // Storage Service
  await Get.putAsync(() => StorageService().init());

  // Session and cache services
  await Get.putAsync(() => SessionService().init());
  await Get.putAsync(() => CacheService().init());

  // API Service

  // Bible Service

  // Theme Controller (must be after StorageService)
  Get.put(ThemeController());
}

class ChristLumenApp extends StatelessWidget {
  const ChristLumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        // App Info
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Dynamic Theme based on user preferences
        theme: themeController.generateLightTheme(),
        darkTheme: themeController.generateDarkTheme(),
        themeMode: themeController.themeMode.value,

        // Routing
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        unknownRoute: GetPage(
          name: '/not-found',
          page: () =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        ),

        // Default Transitions
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),

        // Locale
        locale: const Locale('fr', 'FR'),
        fallbackLocale: const Locale('fr', 'FR'),

        // Builder for global overlays
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
