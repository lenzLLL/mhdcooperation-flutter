import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_transactions_controller.dart';

class AdminTransactionsView extends GetView<AdminTransactionsController> {
  const AdminTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Utilisateurs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.loadTransactions(),
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
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Toutes'),
                          ),
                          DropdownMenuItem(
                            value: 'today',
                            child: Text('Aujourd\'hui'),
                          ),
                          DropdownMenuItem(
                            value: 'week',
                            child: Text('Cette semaine'),
                          ),
                          DropdownMenuItem(
                            value: 'month',
                            child: Text('Ce mois'),
                          ),
                        ],
                        onChanged: (value) =>
                            controller.filterTransactions(value!),
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
                            value: 'completed',
                            child: Text('Terminées'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('En attente'),
                          ),
                          DropdownMenuItem(
                            value: 'failed',
                            child: Text('Échouées'),
                          ),
                        ],
                        onChanged: (value) => controller.filterByStatus(value!),
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

          // Liste des transactions
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.transactions.isEmpty) {
                return const Center(child: Text('Aucune transaction trouvée'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
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
                                transaction['reference'],
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
                                      .getStatusColor(transaction['status'])
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: controller.getStatusColor(
                                      transaction['status'],
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  controller.getStatusText(
                                    transaction['status'],
                                  ),
                                  style: TextStyle(
                                    color: controller.getStatusColor(
                                      transaction['status'],
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
                            transaction['userName'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            transaction['userEmail'],
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
                                      transaction['type'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      transaction['libelle'] ??
                                          transaction['service'] ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                controller.formatAmount(transaction['amount']),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if ((transaction['paymentPhone'] as String?)
                                  ?.isNotEmpty ==
                              true)
                            Text(
                              'N° paiement: ${transaction['paymentPhone']} (${transaction['gateway']})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          Text(
                            controller.formatDate(transaction['date']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
}
