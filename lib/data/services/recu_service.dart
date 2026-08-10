import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Téléchargement du reçu de versement (PDF) d'un dossier.
///
/// Le reçu est produit par le serveur (mêmes données, même mise en page que la
/// version web) : l'application ne le compose pas, elle le récupère authentifiée
/// puis l'enregistre sur l'appareil.
class RecuService {
  String get _baseUrl => dotenv.env['MHD_API_BASE_URL'] ?? '';

  /// Enregistre le reçu et renvoie le chemin du fichier.
  /// Lève une [RecuException] avec un message lisible en cas de refus serveur.
  Future<File> download(String dossierId) async {
    if (_baseUrl.isEmpty) {
      throw RecuException("Service indisponible : adresse du serveur non configurée.");
    }

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/api/dossiers/$dossierId/recu'),
      headers: {
        'Accept': 'application/pdf',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      // Le serveur explique ses refus en clair (« reçu disponible après
      // paiement ») : on relaie ce texte plutôt qu'un message générique.
      final body = res.body;
      final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(body);
      throw RecuException(match?.group(1) ?? "Le reçu n'a pas pu être généré.");
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/recu-mhd-${dossierId.substring(0, 8).toUpperCase()}.pdf');
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file;
  }
}

class RecuException implements Exception {
  final String message;
  RecuException(this.message);
  @override
  String toString() => message;
}
