import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import '../controllers/admin_metrics_controller.dart';

class AdminMetricsView extends GetView<AdminMetricsController> {
  const AdminMetricsView({super.key});

  bool get _isSadmin {
    final role = Get.find<SessionService>().currentUser.value?.role.toUpperCase();
    return role == 'SADMIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.loadMetrics(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métriques principales
              const Text(
                'Métriques Clés',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Utilisateurs',
                      controller.formatNumber(controller.totalUsers.value),
                      Icons.people,
                      Colors.blue,
                      '+${controller.getGrowthPercentage().toStringAsFixed(1)}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Transactions',
                      controller.formatNumber(
                        controller.totalTransactions.value,
                      ),
                      Icons.payment,
                      Colors.green,
                      '+${controller.getTransactionGrowthPercentage().toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_isSadmin) ...[
                    Expanded(
                      child: _buildMetricCard(
                        'Revenus',
                        controller.formatCurrency(controller.totalRevenue.value),
                        Icons.attach_money,
                        Colors.orange,
                        'Total',
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _buildMetricCard(
                      'Dossiers Actifs',
                      controller.activeDossiers.toString(),
                      Icons.folder,
                      Colors.purple,
                      'En cours',
                    ),
                  ),
                ],
              ),

              // Retrait de l'argent : super-admin uniquement. L'opération
              // Mobile Money elle-même est exécutée depuis la console web
              // (c'est elle qui détient les clés de la passerelle).
              if (_isSadmin) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.snackbar(
                      "Retrait de l'argent",
                      "Le retrait s'effectue depuis la console web d'administration.",
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: const Text("Retirer l'argent"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Section revenus — SADMIN uniquement
              if (_isSadmin) ...[
                const Text(
                  'Revenus par Service',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(25),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: PieChart(
                    PieChartData(
                      sections: controller.revenueByService.map((service) {
                        final colors = [
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.red,
                          Colors.purple,
                        ];
                        final index =
                            controller.revenueByService.indexOf(service);
                        return PieChartSectionData(
                          value: service['percentage'],
                          title: '${service['percentage']}%',
                          color: colors[index % colors.length],
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: controller.revenueByService.map((service) {
                    final colors = [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.red,
                      Colors.purple,
                    ];
                    final index =
                        controller.revenueByService.indexOf(service);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service['service'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],

              // Graphique de croissance des utilisateurs
              const Text(
                'Croissance des Utilisateurs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < controller.userGrowth.length) {
                              return Text(
                                controller.userGrowth[value.toInt()]['month'],
                                style: const TextStyle(fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.userGrowth.map((data) {
                          final index = controller.userGrowth.indexOf(data);
                          return FlSpot(
                            index.toDouble(),
                            data['users'].toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withAlpha(25),
                        ),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Liste détaillée des services
              const Text(
                'Détails par Service',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...controller.revenueByService.map((service) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service['service'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.formatCurrency(service['revenue']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${service['percentage']}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
