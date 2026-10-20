import 'package:flutter/foundation.dart';
import 'package:mhdcooperation/data/services/api_client.dart';

/// Inscrit au journal d'audit (consulté par le super-admin) une action que
/// l'admin mobile fait encore directement dans Firestore (écoles, concours).
/// L'auteur est identifié par le serveur à partir du jeton de connexion.
class AuditService {
  static Future<void> log(String action, String targetId, String label) async {
    try {
      await ApiClient().post('/api/admin/journal', {
        'action': action,
        'targetId': targetId,
        'label': label,
      });
    } catch (e) {
      // L'action elle-même a réussi : un journal indisponible ne doit pas la
      // faire passer pour un échec auprès de l'admin.
      debugPrint('Journal d\'audit indisponible pour $action $targetId : $e');
    }
  }
}
