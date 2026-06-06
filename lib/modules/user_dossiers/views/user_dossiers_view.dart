import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import '../controllers/user_dossiers_controller.dart';

class UserDossiersView extends GetView<UserDossiersController> {
  const UserDossiersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.home);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
        ),
        title: const Text('Mes documents'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.dossiers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_off, size: 72, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun dossier trouvé',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vos dossiers apparaîtront ici après paiement ou création.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadUserDossiers,
                    child: const Text('Recharger'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadUserDossiers,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.dossiers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dossier = controller.dossiers[index];
              final sessionService = Get.find<SessionService>();
              final currentUser = sessionService.currentUser.value;
              final isAdmin =
                  currentUser != null &&
                  (currentUser.role.toUpperCase() == 'ADMIN' ||
                      currentUser.role.toUpperCase() == 'SADMIN');

              return GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.dossierDetail,
                  arguments: isAdmin ? {'dossierId': dossier.id} : dossier,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dossier.itemTitle?.isNotEmpty == true
                                        ? dossier.itemTitle!
                                        : 'Dossier ${dossier.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Chip(
                                        backgroundColor: Colors.grey.shade100,
                                        label: Text(
                                          controller.getDossierType(dossier),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // IDs are intentionally hidden for clarity; services are static
                                      // and concours details are fetched when available.
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: controller
                                    .getStatusColor(dossier.status)
                                    .withAlpha((0.15 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.getStatusText(dossier.status),
                                style: TextStyle(
                                  color: controller.getStatusColor(
                                    dossier.status,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Montant',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.formatAmount(dossier.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Créé le',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dossier.createdAt.day}/${dossier.createdAt.month}/${dossier.createdAt.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (dossier.gateway != null &&
                            dossier.gateway!.isNotEmpty)
                          Text(
                            'Opérateur: ${dossier.gateway}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        if (dossier.userPhone != null &&
                            dossier.userPhone!.isNotEmpty)
                          Text(
                            'Téléphone: ${dossier.userPhone}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
