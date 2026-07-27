import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ConcourDetailView extends StatelessWidget {
  final Concours concour;

  const ConcourDetailView({super.key, required this.concour});

  String _formatDate(DateTime date) {
    final months = [
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
    if (diff.isNegative) return 'Terminé';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    return '${days}j ${hours}h ${minutes}m';
  }

  Future<void> _launchDocumentUrl(BuildContext context) async {
    if (concour.docUrl == null || concour.docUrl!.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun document disponible')),
        );
      }
      return;
    }

    final docUrl = concour.docUrl!.trim();

    // Validation basique de l'URL
    if (!docUrl.startsWith('http://') &&
        !docUrl.startsWith('https://') &&
        !docUrl.startsWith('file://')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format d\'URL non supporté')),
        );
      }
      return;
    }

    try {
      final Uri? url = Uri.tryParse(docUrl);

      if (url == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL du document invalide')),
          );
        }
        return;
      }

      // Vérifier si l'URL peut être lancée
      if (!await canLaunchUrl(url)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune application ne peut ouvrir ce document'),
            ),
          );
        }
        return;
      }

      // Lancer l'URL avec gestion d'erreur
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Exception catch (e) {
      // Log l'erreur pour le débogage (sera supprimé en production)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().split(':').first}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isClosed =
        concour.status.toLowerCase() != 'active' ||
        (concour.applicationDeadline != null &&
            concour.applicationDeadline!.isBefore(DateTime.now()));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  concour.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (concour.photoUrl != null && concour.photoUrl!.isNotEmpty)
                    concour.photoUrl!.startsWith('assets/')
                        ? Image.asset(concour.photoUrl!, fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: concour.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.school,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                  else
                    Container(
                      color: Colors.blue[300],
                      child: const Center(
                        child: Icon(
                          Icons.school,
                          size: 72,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(24),
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (concour.schoolLogoUrl != null &&
                          concour.schoolLogoUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: concour.schoolLogoUrl!.startsWith('assets/')
                                ? Image.asset(
                                    concour.schoolLogoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: concour.schoolLogoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[200]),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.school,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concour.schoolName ?? 'École non spécifiée',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              concour.ville ?? 'Ville non précisée',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isClosed ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isClosed ? 'Clos' : 'Actif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isClosed
                                ? Colors.red[700]
                                : Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSmallInfoRow(
                    icon: Icons.category,
                    label: 'Catégorie',
                    value: concour.sessionCategory ?? 'Non spécifié',
                  ),
                  const SizedBox(height: 12),
                  _buildSmallInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Période',
                    value:
                        '${_formatDate(concour.startDate)} · ${_formatDate(concour.endDate)}',
                  ),
                  const SizedBox(height: 12),
                  _buildSmallInfoRow(
                    icon: Icons.attach_money,
                    label: 'Frais de dossier',
                    value: concour.applicationFees != null
                        ? '${concour.applicationFees!.toStringAsFixed(0)} FCFA'
                        : 'Gratuit',
                  ),
                  const SizedBox(height: 12),
                  _buildSmallInfoRow(
                    icon: Icons.access_time,
                    label: 'Date limite',
                    value: concour.applicationDeadline != null
                        ? _formatRemainingTime(concour.applicationDeadline!)
                        : 'Non précisée',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('À propos du concours'),
                  const SizedBox(height: 12),
                  Text(
                    concour.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoPanel(
                    context,
                    title: 'Détails clés',
                    rows: [
                      _buildInfoItem(
                        'Début',
                        _formatDate(concour.startDate),
                        Icons.play_arrow,
                      ),
                      _buildInfoItem(
                        'Fin',
                        _formatDate(concour.endDate),
                        Icons.stop_circle,
                      ),
                      _buildInfoItem(
                        'Âge',
                        concour.ageLimit != null
                            ? '${concour.ageLimit} ans'
                            : 'Non spécifié',
                        Icons.cake,
                      ),
                      _buildInfoItem(
                        'Dernière modif',
                        _formatDate(concour.updatedAt),
                        Icons.update,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isClosed
                              ? null
                              : () {
                                  Get.toNamed(
                                    AppRoutes.payment,
                                    arguments: {
                                      'type': 'concours',
                                      'itemId': concour.id,
                                      'itemTitle': concour.title,
                                      'amount': concour.applicationFees ?? 0.0,
                                      'concoursId': concour.id,
                                    },
                                  );
                                },
                          icon: const Icon(Icons.send),
                          label: const Text('Postuler'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (concour.docUrl != null && concour.docUrl!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchDocumentUrl(context),
                            icon: const Icon(Icons.download),
                            label: const Text('Document'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Arrêté officiel du concours (PDF) — téléchargeable sans compte.
                  if (concour.pdfUrl != null && concour.pdfUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildArreteCard(context, concour.pdfUrl!),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArreteCard(BuildContext context, String pdfUrl) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _launchUrlOrWarn(context, pdfUrl),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arrêté du concours',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Document officiel (PDF)',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  /// Ouvre une URL de document ou prévient si elle est inexploitable.
  Future<void> _launchUrlOrWarn(BuildContext context, String rawUrl) async {
    final url = Uri.tryParse(rawUrl.trim());
    if (url == null || !await canLaunchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir ce document.')),
        );
      }
      return;
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget _buildSmallInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoPanel(BuildContext context, {required String title, required List<Widget> rows}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
