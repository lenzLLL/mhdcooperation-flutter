import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/values/app_value.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: themeController.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildTopBar(),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.pages.length,
                  itemBuilder: (context, index) {
                    final page = controller.pages[index];
                    return _buildPage(page);
                  },
                ),
              ),

              // Bottom section with indicators and buttons
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Obx(() {
          if (controller.currentPage.value < controller.pages.length - 1) {
            return TextButton(
              onPressed: controller.skipOnboarding,
              child: Text(
                AppStrings.onboardingSkip,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: themeController.textSecondaryColor,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildPage(dynamic page) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: page.gradient,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: page.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(page.icon, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 60),

            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeController.textPrimaryColor,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: themeController.textSecondaryColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (index) => _buildIndicator(
                  isActive: index == controller.currentPage.value,
                  gradient: controller.pages[index].gradient,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Obx(() {
            final isLastPage =
                controller.currentPage.value == controller.pages.length - 1;
            final primaryColor = themeController.primaryColor.value;
            final currentGradient = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
            );

            return Row(
              children: [
                // Back button
                if (controller.currentPage.value > 0)
                  Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: themeController.borderColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppValues.radiusMedium,
                      ),
                    ),
                    child: IconButton(
                      onPressed: controller.previousPage,
                      icon: const Icon(Icons.arrow_back),
                      color: themeController.textSecondaryColor,
                    ),
                  ),

                // Next/Finish button
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: currentGradient,
                      borderRadius: BorderRadius.circular(
                        AppValues.radiusMedium,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentGradient.colors.first.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppValues.radiusMedium,
                          ),
                        ),
                      ),
                      child: Text(
                        isLastPage
                            ? AppStrings.onboardingStart
                            : AppStrings.onboardingNext,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required bool isActive,
    required LinearGradient gradient,
  }) {
    final themeController = Get.find<ThemeController>();
    final primaryColor = themeController.primaryColor.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : themeController.borderColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
