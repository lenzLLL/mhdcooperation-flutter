import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import '../controllers/admin_dossiers_controller.dart';

class AdminDossiersView extends GetView<AdminDossiersController> {
  const AdminDossiersView({super.key});

  bool get _isSadmin {
    final role = Get.find<SessionService>().currentUser.value?.role.toUpperCase();
    return role == 'SADMIN';
  }

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
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Row(
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
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text('Récents'),
                          ),
                        ],
                        onChanged: (value) =>
                            controller.filterDossiers(value!),
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
                          DropdownMenuItem(
                            value: 'valide',
                            child: Text('Validés'),
                          ),
                          DropdownMenuItem(
                            value: 'en_cours',
                            child: Text('En cours'),
                          ),
                          DropdownMenuItem(
                            value: 'incomplet',
                            child: Text('Incomplets'),
                          ),
                          DropdownMenuItem(
                            value: 'rejete',
                            child: Text('Rejetés'),
                          ),
                        ],
                        onChanged: (value) =>
                            controller.filterByStatus(value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedCity.value,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: controller.getAllCities().map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(
                        city == 'all' ? 'Toutes les villes' : city,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => controller.filterByCity(value!),
                ),
              ],
            ),
          )),

          // Statistiques rapides
          Obx(
            () => Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Métriques des dossiers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          controller.totalDossiers.toString(),
                          Colors.blue,
                          onTap: () => controller.filterByStatus('all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Validés',
                          controller.validDossiers.toString(),
                          Colors.green,
                          onTap: () => controller.filterByStatus('valide'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'En cours',
                          controller.inProgressDossiers.toString(),
                          Colors.orange,
                          onTap: () => controller.filterByStatus('en_cours'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Incomplets',
                          controller.incompleteDossiers.toString(),
                          Colors.red,
                          onTap: () => controller.filterByStatus('incomplet'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Liste des dossiers
          Expanded(
            child: Obx(() {
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
                        Icon(
                          Icons.folder_off,
                          size: 72,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Aucun dossier trouvé',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Les dossiers s’affichent ici dès qu’ils sont créés ou mis à jour.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.loadDossiers,
                          child: const Text('Recharger'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadDossiers,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.dossiers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dossier = controller.dossiers[index];
                    final isExpired = controller.isExpired(dossier['echeance']);
                    final documents =
                        (dossier['documents'] as List<dynamic>?)
                            ?.whereType<String>()
                            .toList() ??
                        <String>[];

                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        '/dossier-detail',
                        arguments: {'dossierId': dossier['id']},
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dossier['type'] ??
                                              'Dossier ${dossier['id']}',
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
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              label: Text(
                                                controller.getStatusText(
                                                  dossier['status'],
                                                ),
                                                style: TextStyle(
                                                  color: controller
                                                      .getStatusColor(
                                                        dossier['status'],
                                                      ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (documents.isNotEmpty)
                                              Chip(
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                label: Text(
                                                  '${documents.length} doc(s)',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
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
                                          .getStatusColor(dossier['status'])
                                          .withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      controller.getStatusText(
                                        dossier['status'],
                                      ),
                                      style: TextStyle(
                                        color: controller.getStatusColor(
                                          dossier['status'],
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
                                  if (_isSadmin)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            controller.formatAmount(
                                              dossier['montant'] as int? ?? 0,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_isSadmin) const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          controller.formatDate(
                                            dossier['dateCreation'] as DateTime,
                                          ),
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
                              Text(
                                dossier['userName'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (dossier['userEmail'] != null &&
                                  dossier['userEmail'].toString().isNotEmpty)
                                Text(
                                  dossier['userEmail'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isExpired ? 'Expiré' : 'Actif',
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (documents.isNotEmpty)
                                    Text(
                                      documents.join(' • '),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(76), width: 1.5),
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
      ),
    );
  }
}
