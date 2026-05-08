import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/all_services/views/all_services_view.dart';
import 'package:mhdcooperation/modules/home/controllers/home_controller.dart';
import 'package:mhdcooperation/modules/main_layout/controllers/main_layout_controller.dart';
import 'package:mhdcooperation/widgets/home_app_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carrousel d'informations
                _buildCarousel(),

                const SizedBox(height: 24),

                // Section Services
                _buildServicesSection(),

                const SizedBox(height: 24),

                // Section Concours Récents
                _buildConcoursSection(),

                const SizedBox(height: 24),

                // Section Écoles
                _buildSchoolsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              controller.onCarouselChanged(index);
            },
          ),
          items: controller.carouselItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(item['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179), // 0.7 * 255
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Indicateurs du carrousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.carouselItems.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => controller.onCarouselChanged(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.carouselIndex.value == entry.key
                      ? Theme.of(Get.context!).primaryColor
                      : Colors.grey.withAlpha(76), // 0.3 * 255
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String name) {
    switch (name) {
      case 'Dossiers Concours et Recrutements':
        return Icons.school;
      case 'Dossiers BTS, Licence, Bachelor, Master et HND':
        return Icons.library_books;
      case 'Dossiers Passeport/CNI':
        return Icons.badge;
      case 'Dossiers certification IDE':
        return Icons.verified;
      case 'Rapport de stage':
        return Icons.work;
      case 'Dossiers inscription et préinscription universitaire':
        return Icons.account_balance;
      default:
        return Icons.build;
    }
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nos Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const AllServicesView());
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return GestureDetector(
                onTap: () => controller.onServiceTap(service),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withAlpha(25), // 0.1 * 255
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getServiceIcon(service.name),
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Expiré';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    return '${days}j ${hours}h ${minutes}m';
  }

  Widget _buildConcoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Concours à venir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  final mainLayoutController = Get.find<MainLayoutController>();
                  mainLayoutController.changePage(1);
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.concours.length,
            itemBuilder: (context, index) {
              final concours = controller.concours[index];
              return GestureDetector(
                onTap: () => controller.onConcoursTap(concours),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(25), // 0.1 * 255
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: concours.photoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: concours.photoUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Image.asset(
                                    "assets/images/c.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.school,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concours.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              concours.schoolName ?? 'École',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date du concours: ${_formatDate(concours.startDate)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Frais de dossiers: ${concours.applicationFees ?? 0} FCFA',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date limite: ${_formatRemainingTime(concours.applicationDeadline ?? DateTime.now())}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Écoles Partenaires',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  final mainLayoutController = Get.find<MainLayoutController>();
                  mainLayoutController.changePage(2); // Index pour Écoles
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.ecoles.length,
          itemBuilder: (context, index) {
            final school = controller.ecoles[index];
            return GestureDetector(
              onTap: () => controller.onSchoolTap(school),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25), // 0.1 * 255
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: school.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: school.logoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.school,
                                  color: Colors.grey[600],
                                  size: 30,
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.school,
                                color: Colors.grey[600],
                                size: 30,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            school.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            school.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  school.address ?? 'Adresse non disponible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
