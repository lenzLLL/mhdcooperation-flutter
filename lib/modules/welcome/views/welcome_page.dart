import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/values/app_value.dart';
import '../controllers/welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: themeController.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeController.backgroundColor,
                themeController.backgroundColor.withValues(alpha: 0.95),
                themeController.primaryColor.value.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo and title section
                  _buildHeader(themeController),

                  const SizedBox(height: 40),

                  // Description
                  _buildDescription(themeController),

                  const SizedBox(height: 60),

                  // Action buttons
                  _buildActionButtons(themeController),

                  const Spacer(),

                  // Footer text
                  _buildFooter(themeController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeController themeController) {
    return Column(
      children: [
        // Logo image
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: themeController.primaryColor.value.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 220,
            height: 90,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          AppStrings.welcomeTitle,
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: themeController.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          AppStrings.welcomeSubtitle,
          style: GoogleFonts.inter(
            fontSize: 17,
            color: themeController.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeController themeController) {
    return Text(
      AppStrings.welcomeDescription,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: themeController.textSecondaryColor,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(ThemeController themeController) {
    return Column(
      children: [
        // Login button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeController.primaryColor.value,
                themeController.primaryColor.value.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppValues.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: themeController.primaryColor.value.withValues(
                  alpha: 0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppValues.radiusMedium),
              ),
            ),
            child: Text(
              AppStrings.welcomeLogin,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Register button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: themeController.borderColor, width: 2),
            borderRadius: BorderRadius.circular(AppValues.radiusMedium),
          ),
          child: ElevatedButton(
            onPressed: controller.navigateToRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppValues.radiusMedium),
              ),
            ),
            child: Text(
              AppStrings.welcomeRegister,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeController.textPrimaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeController themeController) {
    return Text(
      AppStrings.welcomeFooter,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: themeController.textSecondaryColor,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }
}
