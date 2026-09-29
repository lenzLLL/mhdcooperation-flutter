import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/terms/controllers/terms_controller.dart';

class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'Utilisation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Objet',
              content:
                  'MhD (Mr Help Documents) met à disposition une plateforme d\'accompagnement pour la constitution de dossiers de concours, d\'inscription et de services administratifs au Cameroun.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '2. Compte utilisateur',
              content:
                  'Vous êtes responsable de l\'exactitude des informations fournies et de la confidentialité de vos identifiants. Tout dossier déposé engage votre responsabilité quant à l\'authenticité des pièces.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '3. Frais et paiements',
              content:
                  'Les frais affichés correspondent au service ou au concours choisi. Le montant exact est indiqué avant tout paiement. Un dossier n\'est traité qu\'après règlement des frais correspondants.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '4. Responsabilité',
              content:
                  'MhD s\'engage à accompagner au mieux vos démarches mais ne saurait garantir l\'admission à un concours ni se substituer aux décisions des établissements et administrations.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: '5. Contact',
              content:
                  'Pour toute question relative aux présentes conditions, contactez-nous à helpdocs4@gmail.com.',
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
