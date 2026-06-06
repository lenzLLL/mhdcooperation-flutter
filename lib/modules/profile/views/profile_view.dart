import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            onPressed: controller.navigateToSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.sessionService.currentUser.value;
        return RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGradientHeader(user),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    children: [
                      _buildMenuSection(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGradientHeader(dynamic user) {
    final topPadding =
        MediaQuery.of(Get.context!).padding.top + kToolbarHeight;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(102), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(76),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(52),
              child: user?.pictureUrl != null &&
                      (user!.pictureUrl as String).isNotEmpty
                  ? _buildProfileImage(user.pictureUrl!)
                  : Container(
                      color: Colors.white.withAlpha(51),
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Utilisateur',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 14,
            ),
          ),
          if (user?.role != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(76)),
              ),
              child: Text(
                user!.role.toUpperCase() == 'SADMIN'
                    ? 'Super Admin'
                    : user.role.toUpperCase() == 'ADMIN'
                    ? 'Administrateur'
                    : 'Utilisateur',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: controller.navigateToEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Modifier le profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withAlpha(178)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String pictureUrl) {
    if (pictureUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: pictureUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: Colors.white.withAlpha(51),
          child: const Icon(Icons.person, size: 52, color: Colors.white),
        ),
        errorWidget: (_, _, _) => Container(
          color: Colors.white.withAlpha(51),
          child: const Icon(Icons.person, size: 52, color: Colors.white),
        ),
      );
    }
    final file = File(pictureUrl);
    if (file.existsSync()) return Image.file(file, fit: BoxFit.cover);
    return CachedNetworkImage(
      imageUrl: pictureUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(
        color: Colors.white.withAlpha(51),
        child: const Icon(Icons.person, size: 52, color: Colors.white),
      ),
      errorWidget: (_, _, _) => Container(
        color: Colors.white.withAlpha(51),
        child: const Icon(Icons.person, size: 52, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: controller.navigateToNotifications,
          iconBg: Colors.orange.shade700,
        ),
        _buildMenuItem(
          icon: Icons.folder_open_outlined,
          title: 'Mes documents',
          onTap: controller.navigateToUserDossiers,
          iconBg: AppColors.primary,
        ),
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Aide & Support',
          onTap: controller.navigateToHelp,
          iconBg: Colors.green.shade600,
        ),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: 'À propos',
          onTap: controller.navigateToAbout,
          iconBg: Colors.purple.shade600,
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Politique de confidentialité',
          onTap: controller.navigateToPrivacy,
          iconBg: Colors.teal.shade600,
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          title: "Conditions d'utilisation",
          onTap: controller.navigateToTerms,
          iconBg: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg.withAlpha(28),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconBg, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
