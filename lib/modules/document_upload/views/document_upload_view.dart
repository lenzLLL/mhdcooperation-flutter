import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/services/api_client.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:path/path.dart' as path;

/// Limite du serveur (Vercel refuse les requêtes de plus de 4,5 Mo).
const _maxBytes = 4 * 1024 * 1024;

/// Formats acceptés par le serveur, par extension.
const _mimeByExtension = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.pdf': 'application/pdf',
};

class _TrackedDocument {
  final String name;
  final String status;
  final String? rejectionReason;

  const _TrackedDocument(this.name, this.status, this.rejectionReason);
}

/// Dépôt des pièces, une par une : chaque fichier est rattaché à la pièce
/// demandée via l'API (même route que le site), qui contrôle le format et met
/// à jour son statut — c'est ce que l'administration examine.
class DocumentUploadView extends StatefulWidget {
  final String dossierId;
  final String? serviceId;
  final String? concoursId;
  final String itemTitle;
  final List<String> requiredDocuments;

  const DocumentUploadView({
    super.key,
    required this.dossierId,
    this.serviceId,
    this.concoursId,
    required this.itemTitle,
    this.requiredDocuments = const [],
  });

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
  final _api = ApiClient();
  List<_TrackedDocument>? _documents;
  String? _loadError;
  // Pièce en cours d'envoi (une à la fois).
  String? _uploading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/api/dossiers/${widget.dossierId}');
      final tracking = (res['dossier']?['documentsTracking'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .map((d) => _TrackedDocument(
                d['name']?.toString() ?? '',
                d['status']?.toString() ?? 'pending',
                d['rejectionReason']?.toString(),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _documents = tracking.isNotEmpty
            ? tracking
            : widget.requiredDocuments.map((n) => _TrackedDocument(n, 'pending', null)).toList();
        _loadError = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Impossible de charger les pièces du dossier.');
    }
  }

  void _snack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<File?> _pick() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded),
              title: const Text('Choisir un fichier (PDF, image)'),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    if (source == 'file') {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );
      final p = result?.files.single.path;
      return p == null ? null : File(p);
    }
    // Photos réduites et compressées : une photo de téléphone brute dépasse
    // souvent la limite du serveur, et reste lisible à 2000 px.
    final picked = await ImagePicker().pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    return picked == null ? null : File(picked.path);
  }

  Future<void> _upload(_TrackedDocument doc) async {
    final file = await _pick();
    if (file == null) return;
    final mime = _mimeByExtension[path.extension(file.path).toLowerCase()];
    if (mime == null) {
      _snack('Format non autorisé. Formats acceptés : JPG, PNG, WEBP, PDF.', Colors.orange);
      return;
    }
    if (await file.length() > _maxBytes) {
      _snack('Le fichier dépasse la taille maximale de 4 Mo.', Colors.orange);
      return;
    }
    setState(() => _uploading = doc.name);
    try {
      await _api.postFile(
        '/api/dossiers/${widget.dossierId}/documents',
        file: file,
        contentType: mime,
        fields: {'documentName': doc.name},
      );
      _snack('« ${doc.name} » envoyé.', Colors.green);
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, Colors.red);
    } catch (_) {
      _snack('Échec de l\'envoi. Vérifiez votre connexion et réessayez.', Colors.red);
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  void _finish() {
    Get.offAllNamed(AppRoutes.userDossiers);
    Get.toNamed(AppRoutes.dossierDetail, arguments: {'dossierId': widget.dossierId});
  }

  @override
  Widget build(BuildContext context) {
    final docs = _documents;
    final sent = docs?.where((d) => d.status != 'pending' && d.status != 'rejected').length ?? 0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _uploading == null ? _finish : null,
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pièces du dossier',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.itemTitle,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (docs != null && docs.isNotEmpty)
                            Text(
                              '$sent / ${docs.length} pièce(s) envoyée(s)',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, textAlign: TextAlign.center),
                          TextButton(onPressed: _load, child: const Text('Réessayer')),
                        ],
                      ),
                    ),
                  )
                : docs == null
                    ? const Center(child: CircularProgressIndicator())
                    : docs.isEmpty
                        ? const Center(child: Text('Aucune pièce demandée pour ce dossier.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                Text(
                                  'Formats acceptés : JPG, PNG, WEBP ou PDF, 4 Mo maximum par fichier.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 14),
                                ...docs.map(_documentCard),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _uploading == null ? _finish : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text(
                                      'Terminer',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(_TrackedDocument doc) {
    final (String label, Color color, IconData icon) = switch (doc.status) {
      'uploaded' => ('Envoyé', AppColors.secondary, Icons.schedule_rounded),
      'validated' => ('Validé', const Color(0xFF10B981), Icons.check_circle_rounded),
      'rejected' => ('À revoir', Colors.red, Icons.error_rounded),
      _ => ('À fournir', Colors.grey, Icons.radio_button_unchecked),
    };
    final busy = _uploading == doc.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(label, style: TextStyle(color: color, fontSize: 12)),
                if (doc.status == 'rejected' && doc.rejectionReason != null)
                  Text(
                    'Motif : ${doc.rejectionReason}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (doc.status != 'validated')
            busy
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : TextButton(
                    onPressed: _uploading == null ? () => _upload(doc) : null,
                    child: Text(doc.status == 'pending' ? 'Envoyer' : 'Remplacer'),
                  ),
        ],
      ),
    );
  }
}
