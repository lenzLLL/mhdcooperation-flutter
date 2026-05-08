import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/modules/main_layout/controllers/main_layout_controller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.find<MainLayoutController>().openDrawer();
        },
        icon: const Icon(Icons.menu),
      ),
      actions: [
        const SizedBox(width: 5),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
            ),
            Positioned(
              right: 11,
              top: 11,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 5),
      ],
      title: Obx(() {
        final sessionService = Get.find<SessionService>();
        final user = sessionService.currentUser.value;
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: user?.pictureUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user!.pictureUrl!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Icon(Icons.person, size: 30),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 30),
                    )
                  : const Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Utilisateur'),
                Text(
                  user?.email ?? 'email@example.com',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}