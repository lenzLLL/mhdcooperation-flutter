import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/values/app_strings.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF111827) // backgroundDark
          : const Color(0xFFF9FAFB), // background light
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with pulse animation
              _buildAnimatedLogo(),

              const SizedBox(height: 40),

              // App Name
              _buildAppName(isDarkMode),

              const SizedBox(height: 12),

              // Tagline
              _buildTagline(isDarkMode),

              const SizedBox(height: 80),

              // Loading indicator
              _buildLoadingIndicator(themeController, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(20),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  Widget _buildAppName(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? const Color(0xFFF9FAFB) // textPrimaryDark
                    : const Color(0xFF111827), // textPrimary
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Text(
              AppStrings.splashTagline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(
                  0xFF9CA3AF,
                ), // textSecondary color (same in both themes)
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(
    ThemeController themeController,
    bool isDarkMode,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Obx(
                  () => CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeController.primaryColor.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.splashLoading,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
