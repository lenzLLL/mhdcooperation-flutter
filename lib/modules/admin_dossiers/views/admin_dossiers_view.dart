import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dossiers_controller.dart';

class AdminDossiersView extends GetView<AdminDossiersController> {
  const AdminDossiersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Dossiers'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.loadDossiers(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedFilter.value,
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
                      DropdownMenuItem(value: 'recent', child: Text('Récents')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgents')),
                      DropdownMenuItem(
                        value: 'expired',
                        child: Text('Expirés'),
                      ),
                    ],
                    onChanged: (value) => controller.filterDossiers(value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedStatus.value,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'valide', child: Text('Validés')),
                      DropdownMenuItem(
                        value: 'en_cours',
                        child: Text('En cours'),
                      ),
                      DropdownMenuItem(
                        value: 'incomplet',
                        child: Text('Incomplets'),
                      ),
                      DropdownMenuItem(value: 'rejete', child: Text('Rejetés')),
                    ],
                    onChanged: (value) => controller.filterByStatus(value!),
                  ),
                ),
              ],
            ),
          ),

          // Statistiques rapides
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  controller.dossiers.length.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  'Validés',
                  controller.dossiers
                      .where((d) => d['status'] == 'valide')
                      .length
                      .toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  'En cours',
                  controller.dossiers
                      .where((d) => d['status'] == 'en_cours')
                      .length
                      .toString(),
                  Colors.orange,
                ),
                _buildStatCard(
                  'Incomplets',
                  controller.dossiers
                      .where((d) => d['status'] == 'incomplet')
                      .length
                      .toString(),
                  Colors.red,
                ),
              ],
            ),
          ),

          // Liste des dossiers
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.dossiers.isEmpty) {
                return const Center(child: Text('Aucun dossier trouvé'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.dossiers.length,
                itemBuilder: (context, index) {
                  final dossier = controller.dossiers[index];
                  final isExpired = controller.isExpired(dossier['echeance']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dossier #${dossier['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(dossier['status'])
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: controller.getStatusColor(
                                      dossier['status'],
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  controller.getStatusText(dossier['status']),
                                  style: TextStyle(
                                    color: controller.getStatusColor(
                                      dossier['status'],
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dossier['userName'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            dossier['userEmail'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dossier['type'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Documents: ${dossier['documents'].join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                controller.formatAmount(dossier['montant']),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Créé: ${controller.formatDate(dossier['dateCreation'])}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? Colors.red.withAlpha(25)
                                      : Colors.green.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isExpired
                                      ? 'Expiré'
                                      : 'Échéance: ${controller.formatDate(dossier['echeance'])}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isExpired
                                        ? Colors.red
                                        : Colors.green,
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
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Voir les détails du dossier
                                  },
                                  child: const Text('Voir détails'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Modifier le statut
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: controller.getStatusColor(
                                      dossier['status'],
                                    ),
                                  ),
                                  child: const Text('Modifier'),
                                ),
                              ),
                            ],
                          ),
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
