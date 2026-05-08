import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_users_controller.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.loadUsers(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques rapides
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  controller.users.length.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  'Actifs',
                  controller.getActiveUsersCount().toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  'Inactifs',
                  controller.getInactiveUsersCount().toString(),
                  Colors.red,
                ),
                _buildStatCard(
                  'Admins',
                  controller.getAdminUsersCount().toString(),
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedStatus.value,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'active', child: Text('Actifs')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactifs'),
                      ),
                      DropdownMenuItem(value: 'recent', child: Text('Récents')),
                    ],
                    onChanged: (value) => controller.filterUsers(value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedRole.value,
                    decoration: const InputDecoration(
                      labelText: 'Rôle',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Utilisateurs'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admins')),
                      DropdownMenuItem(
                        value: 'superadmin',
                        child: Text('Super Admins'),
                      ),
                    ],
                    onChanged: (value) => controller.filterByRole(value!),
                  ),
                ),
              ],
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return const Center(child: Text('Aucun utilisateur trouvé'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: controller
                                    .getRoleColor(user['role'])
                                    .withAlpha(51),
                                child: Icon(
                                  user['role'] == 'user'
                                      ? Icons.person
                                      : user['role'] == 'admin'
                                          ? Icons.admin_panel_settings
                                          : Icons.security,
                                  color: controller.getRoleColor(user['role']),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      user['email'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user['phone'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(user['status'])
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: controller.getStatusColor(
                                      user['status'],
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  controller.getStatusText(user['status']),
                                  style: TextStyle(
                                    color: controller.getStatusColor(
                                      user['status'],
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rôle: ${controller.getRoleText(user['role'])}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Inscription: ${controller.formatDate(user['registrationDate'])}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Dernière connexion: ${controller.formatDate(user['lastLogin'])}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (user['role'] == 'user') ...[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${user['totalTransactions']} transactions',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        controller.formatAmount(
                                          user['totalSpent'],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Voir les détails de l'utilisateur
                                  },
                                  child: const Text('Voir détails'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.toggleUserStatus(user['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: user['status'] == 'active'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  child: Text(
                                    user['status'] == 'active'
                                        ? 'Désactiver'
                                        : 'Activer',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (user['role'] != 'super_admin') ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Changer le rôle:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: user['role'],
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'user',
                                        child: Text('Utilisateur'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'admin',
                                        child: Text('Admin'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.changeUserRole(
                                          user['id'],
                                          value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter un nouvel utilisateur
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
