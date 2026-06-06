import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/dossier_model.dart';
import 'package:mhdcooperation/data/services/dossier_service.dart';
import 'package:mhdcooperation/modules/home/controllers/home_controller.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/data/services/concours_service.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class UserDossiersController extends GetxController {
  final DossierService _dossierService = Get.find<DossierService>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxList<DossierModel> dossiers = <DossierModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDossiers();
  }

  Future<void> loadUserDossiers() async {
    try {
      isLoading.value = true;
      final userId = _sessionService.currentUser.value?.id;
      if (userId == null || userId.isEmpty) {
        dossiers.clear();
        return;
      }
      final results = await _dossierService.loadDossiersForUser(userId);

      // Enrich dossiers: for services, get title from AllServicesController (static);
      // for concours, fetch concours details from Firestore via ConcoursService.
      final enriched = <DossierModel>[];

      // Try to get services controller (may already be initialized in app)
      HomeController? servicesController;
      try {
        servicesController = Get.find<HomeController>();
      } catch (_) {
        servicesController = null;
      }

      final concoursService = ConcoursService();

      for (final d in results) {
        var updated = d;

        // If it's a service and we have a services list, fill the title from there
        if ((d.itemType == 'service' ||
            (d.serviceId != null && d.serviceId!.isNotEmpty))) {
          final sid = d.serviceId ?? '';
          if (servicesController != null && sid.isNotEmpty) {
            final svc = servicesController.services.firstWhere(
              (s) => s.id == sid,
              orElse: () => Services(id: '', name: '', desc: ''),
            );
            if (svc.id.isNotEmpty) {
              updated = updated.copyWith(
                itemTitle: svc.name,
                itemType: 'service',
              );
            }
          }
        }

        // If it's a concours and we have an id but no title, fetch it
        if ((d.itemType == 'concours' ||
                (d.concoursId != null && d.concoursId!.isNotEmpty)) &&
            (d.itemTitle == null || d.itemTitle!.isEmpty)) {
          final cid = d.concoursId ?? '';
          if (cid.isNotEmpty) {
            try {
              final Concours? c = await concoursService.getConcours(cid);
              if (c != null) {
                updated = updated.copyWith(
                  itemTitle: c.title,
                  itemType: 'concours',
                );
              }
            } catch (e) {
              debugPrint('Failed to fetch concours $cid: $e');
            }
          }
        }

        enriched.add(updated);
      }

      dossiers.assignAll(enriched);
    } catch (e) {
      debugPrint('Erreur lors du chargement des dossiers utilisateur: $e');
      dossiers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String getStatusText(String status) {
    switch (status) {
      case 'valide':
        return 'Validé';
      case 'en_cours':
        return 'En cours';
      case 'incomplet':
        return 'Incomplet';
      case 'rejete':
        return 'Rejeté';
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }

  String getDossierType(DossierModel dossier) {
    if (dossier.itemType.isNotEmpty) {
      return dossier.itemType == 'concours' ? 'Concours' : 'Service';
    }
    if (dossier.serviceId != null && dossier.serviceId!.isNotEmpty) {
      return 'Service';
    }
    if (dossier.concoursId != null && dossier.concoursId!.isNotEmpty) {
      return 'Concours';
    }
    return 'Dossier';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'valide':
      case 'paid':
        return Colors.green;
      case 'en_cours':
        return Colors.blue;
      case 'incomplet':
        return Colors.orange;
      case 'rejete':
        return Colors.red;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
