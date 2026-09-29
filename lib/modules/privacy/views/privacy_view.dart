import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/privacy/controllers/privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Données que nous collectons',
              content:
                  'Nous collectons les informations que vous fournissez lors de la création de votre compte (nom, email, téléphone, ville) et lors du dépôt d\'un dossier (pièces justificatives, ville, quartier).',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '2. Utilisation des données',
              content:
                  'Vos données servent uniquement à traiter vos dossiers, à vous accompagner dans vos démarches et à vous tenir informé de leur avancement. Elles ne sont ni vendues, ni cédées à des tiers.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '3. Conservation et sécurité',
              content:
                  'Vos documents sont stockés de façon sécurisée et ne sont accessibles qu\'à vous et à l\'équipe de la coopérative en charge du traitement de votre dossier.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '4. Vos droits',
              content:
                  'Vous pouvez consulter, corriger ou demander la suppression de vos données personnelles à tout moment en nous contactant à helpdocs4@gmail.com.',
            ),

            const SizedBox(height: 32),

            // Date de dernière mise à jour
            Center(
              child: Text(
                'Dernière mise à jour : Mai 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
