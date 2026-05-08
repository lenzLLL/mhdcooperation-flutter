import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';
import '../data/services/storage_service.dart';
import '../core/themes/app_theme.dart';

/// Global Theme Controller - Manages app theme and colors dynamically
class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  // Observable colors
  final Rx<Color> primaryColor = AppColors.primary.obs;
  final Rx<Color> secondaryColor = AppColors.secondary.obs;

  // Suivi du mode système (true = automatique, false = manuel)
  final Rx<bool> useSystemTheme = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreferences();
  }

  /// Load theme preferences from storage
  Future<void> _loadThemePreferences() async {
    // Charger la préférence pour le mode système
    final savedUseSystemTheme =
        await _storageService.getString('use_system_theme') ?? 'true';
    useSystemTheme.value = savedUseSystemTheme == 'true';

    // Charger le mode de thème
    final savedThemeMode = await _storageService.getThemeMode();

    if (useSystemTheme.value) {
      // Si mode système = automatique
      themeMode.value = ThemeMode.system;
    } else {
      // Si mode manuel, utiliser la valeur sauvegardée
      themeMode.value = savedThemeMode == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    // Load primary color
    final savedPrimaryColor = await _storageService.getInt('primary_color');
    if (savedPrimaryColor != 0) {
      primaryColor.value = Color(savedPrimaryColor);
    }

    // Load secondary color
    final savedSecondaryColor = await _storageService.getInt('secondary_color');
    if (savedSecondaryColor != 0) {
      secondaryColor.value = Color(savedSecondaryColor);
    }
  }

  /// Check if dark mode is active
  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      // Retourner false par défaut en mode système
      // (Flutter gère l'affichage selon les préférences système)
      return false;
    }
    return themeMode.value == ThemeMode.dark;
  }

  /// Get background color based on theme
  Color get backgroundColor {
    return isDarkMode ? AppColors.backgroundDark : AppColors.background;
  }

  /// Get surface color based on theme
  Color get surfaceColor {
    return isDarkMode ? AppColors.surfaceDark : AppColors.surface;
  }

  /// Get text primary color based on theme
  Color get textPrimaryColor {
    return isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
  }

  /// Get text secondary color based on theme
  Color get textSecondaryColor {
    return isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  /// Get border color based on theme
  Color get borderColor {
    return isDarkMode ? AppColors.borderDark : AppColors.border;
  }

  /// Get primary gradient
  LinearGradient get primaryGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor.value, primaryColor.value.withValues(alpha: 0.8)],
    );
  }

  /// Get secondary gradient
  LinearGradient get secondaryGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        secondaryColor.value,
        secondaryColor.value.withValues(alpha: 0.8),
      ],
    );
  }

  /// Toggle dark mode (seulement en mode manuel)
  Future<void> toggleDarkMode() async {
    if (useSystemTheme.value) {
      // Passer en mode manuel d'abord
      useSystemTheme.value = false;
      await _storageService.saveString('use_system_theme', 'false');
    }

    // Basculer le mode sombre/clair
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    // Sauvegarder le nouveau mode
    await _storageService.saveThemeMode(
      themeMode.value == ThemeMode.dark ? 'dark' : 'light',
    );
    Get.changeThemeMode(themeMode.value);
  }

  /// Basculer entre mode automatique (système) et mode manuel
  Future<void> toggleAutoMode() async {
    useSystemTheme.value = !useSystemTheme.value;
    await _storageService.saveString(
      'use_system_theme',
      useSystemTheme.value ? 'true' : 'false',
    );

    if (useSystemTheme.value) {
      // Passer en mode système
      themeMode.value = ThemeMode.system;
    } else {
      // Passer en mode manuel (light ou dark selon la sauvegarde)
      final savedThemeMode = await _storageService.getThemeMode();
      themeMode.value = savedThemeMode == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    Get.changeThemeMode(themeMode.value);
  }

  /// Update primary color
  Future<void> updatePrimaryColor(Color color) async {
    primaryColor.value = color;
    await _storageService.saveInt('primary_color', color.toARGB32());
  }

  /// Update secondary color
  Future<void> updateSecondaryColor(Color color) async {
    secondaryColor.value = color;
    await _storageService.saveInt('secondary_color', color.toARGB32());
  }

  /// Generate dynamic theme based on saved colors
  ThemeData generateLightTheme() {
    final baseTheme = AppTheme.lightTheme;
    return baseTheme.copyWith(
      primaryColor: primaryColor.value,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor.value,
        secondary: secondaryColor.value,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor.value,
      ),
    );
  }

  /// Generate dynamic dark theme based on saved colors
  ThemeData generateDarkTheme() {
    final baseTheme = AppTheme.darkTheme;
    return baseTheme.copyWith(
      primaryColor: primaryColor.value,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor.value,
        secondary: secondaryColor.value,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor.value,
      ),
    );
  }
}
