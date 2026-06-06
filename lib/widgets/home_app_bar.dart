import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/modules/main_layout/controllers/main_layout_controller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 72,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.find<MainLayoutController>().openDrawer(),
        icon: const Icon(Icons.menu, color: Colors.white),
      ),
      centerTitle: false,
      title: Obx(() {
        final user = Get.find<SessionService>().currentUser.value;
        final firstName = (user?.name ?? '').split(' ').first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_getGreeting()}${firstName.isNotEmpty ? ', $firstName' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            Text(
              'Que recherchez-vous ?',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          final user = Get.find<SessionService>().currentUser.value;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Get.find<MainLayoutController>().changePage(3),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(127),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: user?.pictureUrl != null &&
                          user!.pictureUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.pictureUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _defaultAvatar(),
                          errorWidget: (_, _, _) => _defaultAvatar(),
                        )
                      : _defaultAvatar(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.white.withAlpha(51),
      child: const Icon(Icons.person, color: Colors.white, size: 22),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
