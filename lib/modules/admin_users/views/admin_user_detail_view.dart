import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import '../controllers/admin_user_detail_controller.dart';

class AdminUserDetailView extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminUserDetailView({super.key, required this.user});

  String _roleText(String role) {
    switch (role.toString().toLowerCase()) {
      case 'user':
        return 'Utilisateur';
      case 'admin':
        return 'Administrateur';
      case 'sadmin':
      case 'superadmin':
        return 'Super Admin';
      default:
        return 'Inconnu';
    }
  }

  Color _roleColor(String role) {
    switch (role.toString().toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'admin':
        return Colors.orange;
      case 'sadmin':
      case 'superadmin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status.toString().toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'admin-user-detail-${user['id']}';
    final controller = Get.isRegistered<AdminUserDetailController>(tag: tag)
        ? Get.find<AdminUserDetailController>(tag: tag)
        : Get.put(AdminUserDetailController(userId: user['id']), tag: tag);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails utilisateur'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
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
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: _roleColor(
                            user['role'],
                          ).withAlpha(50),
                          child: Icon(
                            Icons.person,
                            color: _roleColor(user['role']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? 'Utilisateur',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _roleText(user['role']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Email: ${user['email'] ?? '-'}'),
                    const SizedBox(height: 4),
                    Text('Téléphone: ${user['phone'] ?? '-'}'),
                    const SizedBox(height: 4),
                    Text(
                      'Statut: ${_statusText(user['status'] ?? 'inactive')}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inscrit le: ${_formatDate(user['registrationDate'])}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dernière connexion: ${_formatDate(user['lastLogin'])}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dossiers (${controller.dossiers.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.dossiers.isEmpty) {
                  return const Center(
                    child: Text('Aucun dossier trouvé pour cet utilisateur.'),
                  );
                }

                return ListView.separated(
                  itemCount: controller.dossiers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dossier = controller.dossiers[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.dossierDetail,
                        arguments: {'dossierId': dossier.id},
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
                              Text(
                                controller.getDossierLabel(dossier),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(
                                      controller.getTypeText(dossier),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      controller.getStatusText(dossier.status),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Montant: ${controller.formatAmount(dossier.amount)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(dossier.createdAt),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              if (dossier.gateway != null &&
                                  dossier.gateway!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Opérateur: ${dossier.gateway}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    return value?.toString() ?? '-';
  }
}
