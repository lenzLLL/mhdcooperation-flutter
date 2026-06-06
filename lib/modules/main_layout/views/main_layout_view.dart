import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:mhdcooperation/modules/admin_transactions/bindings/admin_transactions_binding.dart';
import 'package:mhdcooperation/modules/admin_transactions/views/admin_transactions_view.dart';
import 'package:mhdcooperation/modules/admin_dossiers/bindings/admin_dossiers_binding.dart';
import 'package:mhdcooperation/modules/admin_dossiers/views/admin_dossiers_view.dart';
import 'package:mhdcooperation/modules/admin_metrics/bindings/admin_metrics_binding.dart';
import 'package:mhdcooperation/modules/admin_metrics/views/admin_metrics_view.dart';
import 'package:mhdcooperation/modules/admin_users/bindings/admin_users_binding.dart';
import 'package:mhdcooperation/modules/admin_users/views/admin_users_view.dart';
import 'package:mhdcooperation/modules/admin_schools/bindings/admin_schools_binding.dart';
import 'package:mhdcooperation/modules/admin_schools/views/admin_schools_view.dart';
import 'package:mhdcooperation/modules/admin_concours/bindings/admin_concours_binding.dart';
import 'package:mhdcooperation/modules/admin_concours/views/admin_concours_view.dart';
import 'package:mhdcooperation/modules/all_concours/views/all_concours_view.dart';
import 'package:mhdcooperation/modules/home/views/home_view.dart';
import 'package:mhdcooperation/modules/all_schools/views/all_schools_view.dart';
import 'package:mhdcooperation/modules/profile/views/profile_view.dart';
import 'package:mhdcooperation/widgets/icon_text_row.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const AllConcoursView(),
      const AllSchoolsView(),
      const ProfileView(),
    ];
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: Drawer(
        backgroundColor: AppColors.backgroundDark,
        child: Column(
          children: [
            // Header with user info
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    final sessionService = Get.find<SessionService>();
                    final user = sessionService.currentUser.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: user?.pictureUrl?.isNotEmpty == true
                                  ? _buildDrawerProfileImage(user!.pictureUrl!)
                                  : const CircleAvatar(
                                      radius: 30,
                                      child: Icon(Icons.person, size: 30),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user?.name ?? 'Utilisateur',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'email@example.com',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.role == 'SADMIN'
                                ? 'Super Admin'
                                : user?.role == 'ADMIN'
                                ? 'Admin'
                                : 'Utilisateur',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  IconTextRow(
                    title: "Accueil",
                    icon: Icons.home_outlined,
                    onTap: () {
                      controller.changePage(0);
                      controller.closeDrawer();
                    },
                  ),
                  IconTextRow(
                    title: "Concours",
                    icon: Icons.menu_book_outlined,
                    onTap: () {
                      controller.changePage(1);
                      controller.closeDrawer();
                    },
                  ),
                  IconTextRow(
                    title: "Écoles",
                    icon: Icons.school_outlined,
                    onTap: () {
                      controller.changePage(2);
                      controller.closeDrawer();
                    },
                  ),
                  IconTextRow(
                    title: "Profil",
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      controller.changePage(3);
                      controller.closeDrawer();
                    },
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Conditional menu based on user role
                  Obx(() {
                    final sessionService = Get.find<SessionService>();
                    final user = sessionService.currentUser.value;
                    final role = user?.role.toUpperCase();
                    final isAdmin = role == 'ADMIN' || role == 'SADMIN';

                    if (isAdmin) {
                      final isSadmin = role == 'SADMIN';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const Text(
                              textAlign: TextAlign.left,
                              'Administration',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Tableau de bord (revenus) : SADMIN uniquement
                          if (isSadmin)
                            IconTextRow(
                              title: "Tableau de Bord",
                              icon: Icons.dashboard,
                              onTap: () {
                                Get.to(
                                  () => const AdminMetricsView(),
                                  binding: AdminMetricsBinding(),
                                );
                                controller.closeDrawer();
                              },
                            ),
                          // Transactions (données financières) : SADMIN uniquement
                          if (isSadmin)
                            IconTextRow(
                              title: "Transactions",
                              icon: Icons.receipt_long,
                              onTap: () {
                                Get.to(
                                  () => const AdminTransactionsView(),
                                  binding: AdminTransactionsBinding(),
                                );
                                controller.closeDrawer();
                              },
                            ),
                          IconTextRow(
                            title: "Gestion Dossiers",
                            icon: Icons.folder_special,
                            onTap: () {
                              Get.to(
                                () => const AdminDossiersView(),
                                binding: AdminDossiersBinding(),
                              );
                              controller.closeDrawer();
                            },
                          ),
                          IconTextRow(
                            title: "Utilisateurs",
                            icon: Icons.people,
                            onTap: () {
                              Get.to(
                                () => const AdminUsersView(),
                                binding: AdminUsersBinding(),
                              );
                              controller.closeDrawer();
                            },
                          ),
                          IconTextRow(
                            title: "Gestion des Écoles",
                            icon: Icons.school,
                            onTap: () {
                              Get.to(
                                () => const AdminSchoolsView(),
                                binding: AdminSchoolsBinding(),
                              );
                              controller.closeDrawer();
                            },
                          ),
                          IconTextRow(
                            title: "Gestion des Concours",
                            icon: Icons.menu_book,
                            onTap: () {
                              Get.to(
                                () => const AdminConcoursView(),
                                binding: AdminConcoursBinding(),
                              );
                              controller.closeDrawer();
                            },
                          ),
                        ],
                      );
                    } else {
                      return IconTextRow(
                        title: "Mes documents",
                        icon: Icons.folder_open,
                        onTap: () {
                          Get.toNamed(AppRoutes.userDossiers);
                          controller.closeDrawer();
                        },
                      );
                    }
                  }),
                ],
              ),
            ),
            // Logout button at bottom
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => controller.logout(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withAlpha(204),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: AppColors.primary.withAlpha(30),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
              label: 'Concours',
            ),
            NavigationDestination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school, color: AppColors.primary),
              label: 'Écoles',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerProfileImage(String pictureUrl) {
    if (pictureUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: pictureUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
        errorWidget: (context, url, error) =>
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
      );
    }

    final file = File(pictureUrl);
    if (file.existsSync()) {
      return Image.file(file, width: 60, height: 60, fit: BoxFit.cover);
    }

    return CachedNetworkImage(
      imageUrl: pictureUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
      errorWidget: (context, url, error) =>
          const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
    );
  }
}
