import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:path/path.dart' as path;

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
  final List<File> _selectedFiles = [];
  bool _isUploading = false;
  int _uploadProgress = 0;
  bool _done = false;

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null && mounted) {
      const maxBytes = 10 * 1024 * 1024;
      final file = File(picked.path);
      if (file.lengthSync() > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image trop volumineuse (> 10 Mo)'),
            backgroundColor: Colors.orange,
          ));
        }
        return;
      }
      setState(() => _selectedFiles.add(file));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty && mounted) {
      const maxBytes = 10 * 1024 * 1024;
      final all = picked.map((x) => File(x.path)).toList();
      final valid = all.where((f) => f.lengthSync() <= maxBytes).toList();
      final skipped = all.length - valid.length;
      if (skipped > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$skipped image(s) ignorée(s) (> 10 Mo)'),
          backgroundColor: Colors.orange,
        ));
      }
      if (valid.isNotEmpty) setState(() => _selectedFiles.addAll(valid));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && mounted) {
      const maxBytes = 10 * 1024 * 1024;
      final oversized = result.files.where((f) => f.size > maxBytes).toList();
      if (oversized.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${oversized.length} fichier(s) ignorés (> 10 Mo)'),
          backgroundColor: Colors.orange,
        ));
      }
      final valid = result.files
          .where((f) => f.size <= maxBytes && f.path != null)
          .toList();
      if (valid.isEmpty) return;
      setState(() {
        for (final f in valid) {
          _selectedFiles.add(File(f.path!));
        }
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_selectedFiles.isEmpty) return;
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });
    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;
      final urls = <String>[];

      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
        final ref = storage
            .ref('dossiers/${widget.dossierId}/documents/$fileName');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        urls.add(url);
        if (mounted) setState(() => _uploadProgress = i + 1);
      }

      await firestore.collection('dossiers').doc(widget.dossierId).update({
        'documents': FieldValue.arrayUnion(urls),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) setState(() => _done = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Get.offAllNamed(AppRoutes.userDossiers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _skip() => Get.offAllNamed(AppRoutes.userDossiers);

  bool _isPdf(File file) => file.path.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dossier créé avec succès !',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.itemTitle,
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pour accélérer le traitement de votre dossier, envoyez vos documents dès maintenant. Vous pouvez aussi le faire plus tard depuis "Mes dossiers".',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.5),
                            ),
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
            child: _done
                ? _buildDoneWidget()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.requiredDocuments.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD1E8FF)),
                              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [
                                  Icon(Icons.checklist_rounded, size: 16, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text('Documents requis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                ]),
                                const SizedBox(height: 10),
                                ...widget.requiredDocuments.map((doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(children: [
                                    const Icon(Icons.radio_button_unchecked, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(doc, style: const TextStyle(fontSize: 13))),
                                  ]),
                                )),
                                const SizedBox(height: 4),
                                Text(
                                  'Vous pouvez compléter ces documents maintenant ou depuis votre dossier plus tard.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          children: [
                            Expanded(
                                child: _pickButton(Icons.camera_alt_rounded,
                                    'Appareil\nphoto', _pickFromCamera)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _pickButton(Icons.photo_library_rounded,
                                    'Galerie', _pickFromGallery)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _pickButton(Icons.attach_file_rounded,
                                    'Fichier\nPDF', _pickFile)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_selectedFiles.isNotEmpty) ...[
                          Text(
                            '${_selectedFiles.length} document(s) sélectionné(s)',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                              _selectedFiles.length,
                              (i) => _fileCard(_selectedFiles[i], i)),
                          const SizedBox(height: 24),
                          if (_isUploading)
                            Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(
                                      color: AppColors.primary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Envoi $_uploadProgress/${_selectedFiles.length}...',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5))
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _uploadDocuments,
                                  icon: const Icon(
                                      Icons.cloud_upload_rounded,
                                      color: Colors.white),
                                  label: const Text('Envoyer les documents',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ),
                        ] else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.upload_file_rounded,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('Aucun document sélectionné',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(
                                  'Utilisez les boutons ci-dessus pour ajouter vos documents',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Ignorer pour l\'instant',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
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

  Widget _pickButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileCard(File file, int index) {
    final isPdf = _isPdf(file);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isPdf
                ? Container(
                    width: 48,
                    height: 48,
                    color: Colors.red.shade50,
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.red, size: 28),
                  )
                : Image.file(file, width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path.basename(file.path),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _selectedFiles.removeAt(index)),
            icon:
                const Icon(Icons.close_rounded, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 64),
          ),
          const SizedBox(height: 20),
          const Text('Documents envoyés !',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Redirection en cours...',
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }
}
