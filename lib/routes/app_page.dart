import 'package:get/get.dart';
import 'package:mhdcooperation/modules/splash/bindings/splash_binding.dart';
import 'package:mhdcooperation/modules/splash/views/splash_view.dart';
import 'package:mhdcooperation/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:mhdcooperation/modules/onboarding/views/onboarding_view.dart';
import 'package:mhdcooperation/modules/welcome/bindings/welcome_binding.dart';
import 'package:mhdcooperation/modules/welcome/views/welcome_page.dart';
import 'package:mhdcooperation/modules/signin/views/login_board.dart';
import 'package:mhdcooperation/modules/signin/views/signup.dart';
import 'package:mhdcooperation/modules/signin/views/otp_bpard.dart';
import 'package:mhdcooperation/modules/main_layout/bindings/main_layout_binding.dart';
import 'package:mhdcooperation/modules/main_layout/views/main_layout_view.dart';
import 'package:mhdcooperation/modules/all_schools/bindings/all_schools_binding.dart';
import 'package:mhdcooperation/modules/all_schools/views/all_schools_view.dart';
import 'package:mhdcooperation/modules/all_services/bindings/all_services_binding.dart';
import 'package:mhdcooperation/modules/all_services/views/all_services_view.dart';
import 'package:mhdcooperation/modules/all_concours/bindings/all_concours_binding.dart';
import 'package:mhdcooperation/modules/all_concours/views/all_concours_view.dart';
import 'package:mhdcooperation/modules/concour_detail/views/concour_detail_view.dart';
import 'package:mhdcooperation/modules/school_detail/views/school_detail_view.dart';
import 'package:mhdcooperation/modules/service_detail/views/service_detail_view.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;
  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    // Welcome
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
    // Login
    GetPage(name: AppRoutes.login, page: () => const LoginBoard()),
    // Register
    GetPage(name: AppRoutes.register, page: () => const SignupBoard()),
    // OTP
    GetPage(name: AppRoutes.otp, page: () => const OtpBoard()),
    // Main layout
    GetPage(
      name: AppRoutes.home,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
    ),
    // All Schools
    GetPage(
      name: AppRoutes.allSchools,
      page: () => const AllSchoolsView(),
      binding: AllSchoolsBinding(),
    ),
    // All Services
    GetPage(
      name: AppRoutes.allServices,
      page: () => const AllServicesView(),
      binding: AllServicesBinding(),
    ),
    // All Concours
    GetPage(
      name: AppRoutes.allConcours,
      page: () => const AllConcoursView(),
      binding: AllConcoursBinding(),
    ),
    // Detail pages
    GetPage(
      name: AppRoutes.serviceDetail,
      page: () => ServiceDetailView(service: Get.arguments as Services),
    ),
    GetPage(
      name: AppRoutes.concoursDetail,
      page: () => ConcourDetailView(concour: Get.arguments as Concours),
    ),
    GetPage(
      name: AppRoutes.schoolDetail,
      page: () => SchoolDetailView(school: Get.arguments as School),
    ),
  ];
}
