import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.navigateToSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.sessionService.currentUser.value;

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic if needed
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar et informations principales
                _buildProfileHeader(user),

                const SizedBox(height: 32),

                // Menu des options
                _buildMenuSection(),

                const SizedBox(height: 32),

                // Bouton de déconnexion
                _buildLogoutButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(Get.context!).primaryColor.withAlpha(51),
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: user?.pictureUrl != null
                ? CachedNetworkImage(
                    imageUrl: user!.pictureUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Nom et email
        Text(
          user?.name ?? 'Utilisateur',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          user?.email ?? 'email@example.com',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          onTap: controller.navigateToHelp,
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'À propos',
          onTap: controller.navigateToAbout,
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Politique de confidentialité',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          title: 'Conditions d\'utilisation',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(Get.context!).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
