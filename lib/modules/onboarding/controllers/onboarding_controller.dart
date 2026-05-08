import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      icon: Icons.assignment_turned_in_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
      ),
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      icon: Icons.speed_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      ),
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      icon: Icons.verified_user_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      icon: Icons.celebration_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
      ),
    ),
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Navigate to next page
  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skip onboarding
  void skipOnboarding() {
    completeOnboarding();
  }

  /// Complete onboarding and navigate
  Future<void> completeOnboarding() async {
    await _storageService.saveBool('has_completed_onboarding', true);
    Get.offAllNamed(AppRoutes.welcome);
  }

  /// Update current page
  void onPageChanged(int index) {
    currentPage.value = index;
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
