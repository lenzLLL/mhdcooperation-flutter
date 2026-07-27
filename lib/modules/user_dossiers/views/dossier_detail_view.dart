import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/models/dossier_model.dart';
import 'package:mhdcooperation/modules/user_dossiers/controllers/dossier_detail_controller.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class DossierDetailView extends GetView<DossierDetailController> {
  const DossierDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Don't cast arguments directly - controller handles both DossierModel and Map cases
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final title = controller.dossier.value?.itemTitle ?? 'Dossier';
          return Text(title);
        }),
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        color: const Color(0xFFF6F8FB),
        child: Obx(() {
          final ctrl = controller;
          final current = ctrl.dossier.value;
          final sessionService = Get.find<SessionService>();
          final currentUser = sessionService.currentUser.value;
          final canEditStatus =
              currentUser != null &&
              (currentUser.role.toUpperCase() == 'ADMIN' ||
                  currentUser.role.toUpperCase() == 'SADMIN');
          if (current == null) {
            return const Center(child: Text('Dossier introuvable'));
          }

          return Column(
            children: [
              // Header du dossier
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1F4A78), const Color(0xFF3A78B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.itemTitle ?? 'Dossier ${current.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.flag,
                            label: 'Statut',
                            value: _getStatusText(current.status),
                            color: _getStatusColor(current.status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.calendar_today,
                            label: 'Créé',
                            value: _formatDate(current.createdAt),
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (canEditStatus) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: current.status,
                          decoration: const InputDecoration(
                            labelText: 'Changer le statut',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                          ),
                          dropdownColor: const Color(0xFF1F4A78),
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(
                              value: 'en_cours',
                              child: Text(
                                'En cours',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'valide',
                              child: Text(
                                'Validé',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'incomplet',
                              child: Text(
                                'Incomplet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'rejete',
                              child: Text(
                                'Rejeté',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null && value != current.status) {
                              ctrl.updateDossierStatus(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Pièces à fournir — visibles seulement une fois le dossier payé.
              _buildDocumentsSection(context, current),

              // Messages
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Messages',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ctrl.messages.length} message(s)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ctrl.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ctrl.messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun message',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              reverse: false,
                              itemCount: ctrl.messages.length,
                              itemBuilder: (context, index) {
                                final msg = ctrl.messages[index];
                                final sessionService =
                                    Get.find<SessionService>();
                                final currentUser =
                                    sessionService.currentUser.value;
                                final isCurrentUser =
                                    msg.authorId == currentUser?.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Align(
                                    alignment: isCurrentUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.78,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? const Color(0xFF243B5B)
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(18),
                                            topRight: const Radius.circular(18),
                                            bottomLeft: Radius.circular(
                                              isCurrentUser ? 18 : 4,
                                            ),
                                            bottomRight: Radius.circular(
                                              isCurrentUser ? 4 : 18,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  msg.authorName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: isCurrentUser
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                if (msg
                                                    .authorRole
                                                    .isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getStatusColor(
                                                            msg.authorRole,
                                                          ).withAlpha(
                                                            (0.2 * 255).round(),
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      msg.authorRole,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _getStatusColor(
                                                          msg.authorRole,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (msg.text.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                msg.text,
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                                style: TextStyle(
                                                  color: isCurrentUser
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                            if (msg.files.isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: msg.files.map((f) {
                                                  final fileName = f
                                                      .split('/')
                                                      .last;
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      final uri = Uri.parse(f);
                                                      if (await canLaunchUrl(
                                                        uri,
                                                      )) {
                                                        await launchUrl(
                                                          uri,
                                                          mode: LaunchMode
                                                              .externalApplication,
                                                        );
                                                      } else {
                                                        Get.showSnackbar(
                                                          GetSnackBar(
                                                            title: 'Erreur',
                                                            message:
                                                                'Impossible d\'ouvrir le fichier.',
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isCurrentUser
                                                            ? Colors
                                                                  .grey
                                                                  .shade100
                                                            : const Color(
                                                                0xFF1F4A78,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        border: Border.all(
                                                          color: isCurrentUser
                                                              ? Colors
                                                                    .grey
                                                                    .shade300
                                                              : Colors
                                                                    .transparent,
                                                        ),
                                                        boxShadow: isCurrentUser
                                                            ? [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.04,
                                                                      ),
                                                                  blurRadius:
                                                                      10,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        4,
                                                                      ),
                                                                ),
                                                              ]
                                                            : null,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.download,
                                                            size: 14,
                                                            color: isCurrentUser
                                                                ? Colors.black87
                                                                : Colors.white,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              fileName,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    isCurrentUser
                                                                    ? Colors
                                                                          .black87
                                                                    : Colors
                                                                          .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                            const SizedBox(height: 6),
                                            Text(
                                              _formatTime(msg.createdAt),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isCurrentUser
                                                    ? Colors.grey.shade300
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80), // Espace pour le bottom sheet
            ],
          );
        }),
      ),
      resizeToAvoidBottomInset: true,
      bottomSheet: Obx(() {
        final ctrl = controller;
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ctrl.attachedFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      children: ctrl.attachedFiles.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final file = entry.value;
                        final fileName = file.split('/').last;
                        return Chip(
                          label: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onDeleted: () => ctrl.attachedFiles.removeAt(idx),
                          backgroundColor: Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl.messageController,
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          hintText: 'Votre message...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFF2C3E50),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: ctrl.isUploading.value
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: ctrl.isUploading.value
                            ? null
                            : ctrl.pickFiles,
                        icon: const Icon(
                          Icons.attach_file,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: ctrl.isUploading.value
                            ? null
                            : ctrl.sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Pièces du dossier : tant que le paiement n'est pas confirmé (statut
  /// `pending`), on annonce seulement ce qui sera demandé ; le dépôt s'ouvre
  /// après paiement. Même règle que la version web.
  Widget _buildDocumentsSection(BuildContext context, DossierModel dossier) {
    final docs = dossier.documentsTracking.isNotEmpty
        ? dossier.documentsTracking.map((d) => d.name).toList()
        : (dossier.requiredDocuments ?? const <String>[]);
    if (docs.isEmpty) return const SizedBox.shrink();

    final awaitingPayment = dossier.status.toLowerCase() == 'pending';
    final validated = dossier.documentsTracking
        .where((d) => d.status == 'validated')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  awaitingPayment ? Icons.lock_outline_rounded : Icons.folder_open_rounded,
                  size: 20,
                  color: awaitingPayment ? Colors.grey : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pièces à fournir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!awaitingPayment && dossier.documentsTracking.isNotEmpty)
                  Text(
                    '$validated/${dossier.documentsTracking.length}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (awaitingPayment)
              Text(
                '${docs.length} pièce(s) à prévoir. Le dépôt sera ouvert dès la '
                'confirmation du paiement.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              )
            else ...[
              ...docs.take(4).map(
                    (name) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(name, style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (docs.length > 4)
                Text(
                  '+ ${docs.length - 4} autre(s)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.documentUpload,
                    arguments: {
                      'dossierId': dossier.id,
                      'serviceId': dossier.serviceId,
                      'concoursId': dossier.concoursId,
                      'itemTitle': dossier.itemTitle ?? '',
                      'requiredDocuments': docs,
                    },
                  ),
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Déposer mes pièces'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F4A78),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) return 'Gratuit';
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'encours':
        return Colors.orange;
      case 'valide':
        return Colors.green.shade700;
      case 'incomplet':
        return Colors.red.shade700;
      case 'rejete':
      case 'rejeté':
        return Colors.red.shade700;
      case 'termine':
      case 'terminé':
        return Colors.green.shade800;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'encours':
        return 'En cours';
      case 'valide':
        return 'Validé';
      case 'incomplet':
        return 'Incomplet';
      case 'rejete':
      case 'rejeté':
        return 'Rejeté';
      case 'termine':
      case 'terminé':
        return 'Terminé';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hours = date.hour.toString().padLeft(2, '0');
      final minutes = date.minute.toString().padLeft(2, '0');
      return '$day/$month/${date.year} $hours:$minutes';
    }
  }
}
