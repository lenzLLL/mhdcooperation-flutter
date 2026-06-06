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
            // Introduction
            _buildSection(
              title: 'Introduction',
              content:
                  'MHD Cooperation s\'engage à protéger la confidentialité et les données personnelles de ses utilisateurs. '
                  'Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations.',
            ),

            const SizedBox(height: 24),

            // Collecte des données
            _buildSection(
              title: 'Collecte des Données',
              content:
                  'Nous collectons les informations suivantes :\n\n'
                  '• Informations d\'identification (nom, email, numéro de téléphone)\n'
                  '• Données de connexion et d\'utilisation de l\'application\n'
                  '• Informations sur vos préférences et intérêts\n'
                  '• Données de localisation (avec votre consentement)\n\n'
                  'Ces données sont collectées uniquement avec votre consentement explicite.',
            ),

            const SizedBox(height: 24),

            // Utilisation des données
            _buildSection(
              title: 'Utilisation des Données',
              content:
                  'Vos données sont utilisées pour :\n\n'
                  '• Fournir et améliorer nos services\n'
                  '• Personnaliser votre expérience utilisateur\n'
                  '• Vous contacter concernant vos demandes\n'
                  '• Assurer la sécurité de notre plateforme\n'
                  '• Respecter nos obligations légales',
            ),

            const SizedBox(height: 24),

            // Partage des données
            _buildSection(
              title: 'Partage des Données',
              content:
                  'Nous ne vendons, n\'échangeons ni ne louons vos données personnelles à des tiers. '
                  'Vos données peuvent être partagées uniquement dans les cas suivants :\n\n'
                  '• Avec votre consentement explicite\n'
                  '• Pour respecter nos obligations légales\n'
                  '• Pour protéger nos droits et ceux de nos utilisateurs\n'
                  '• Avec des prestataires de services de confiance (sous contrat strict)',
            ),

            const SizedBox(height: 24),

            // Sécurité des données
            _buildSection(
              title: 'Sécurité des Données',
              content:
                  'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles appropriées '
                  'pour protéger vos données contre l\'accès non autorisé, la modification, la divulgation ou la destruction.\n\n'
                  'Cependant, aucune méthode de transmission sur Internet n\'est 100% sécurisée.',
            ),

            const SizedBox(height: 24),

            // Vos droits
            _buildSection(
              title: 'Vos Droits',
              content:
                  'Conformément au RGPD et aux lois camerounaises sur la protection des données, vous disposez des droits suivants :\n\n'
                  '• Droit d\'accès à vos données\n'
                  '• Droit de rectification\n'
                  '• Droit à l\'effacement\n'
                  '• Droit à la limitation du traitement\n'
                  '• Droit à la portabilité\n'
                  '• Droit d\'opposition\n\n'
                  'Pour exercer ces droits, contactez-nous à privacy@mhdcooperation.com',
            ),

            const SizedBox(height: 24),

            // Cookies et technologies similaires
            _buildSection(
              title: 'Cookies et Technologies Similaires',
              content:
                  'Nous utilisons des cookies et technologies similaires pour améliorer votre expérience. '
                  'Ces technologies nous aident à :\n\n'
                  '• Mémoriser vos préférences\n'
                  '• Analyser l\'utilisation de notre application\n'
                  '• Personnaliser le contenu\n\n'
                  'Vous pouvez contrôler l\'utilisation des cookies via les paramètres de votre appareil.',
            ),

            const SizedBox(height: 24),

            // Modifications
            _buildSection(
              title: 'Modifications de cette Politique',
              content:
                  'Nous pouvons modifier cette politique de confidentialité à tout moment. '
                  'Les modifications seront publiées sur cette page avec la date de dernière mise à jour.\n\n'
                  'Votre utilisation continue de nos services après les modifications constitue votre acceptation de la nouvelle politique.',
            ),

            const SizedBox(height: 24),

            // Contact
            _buildSection(
              title: 'Contact',
              content:
                  'Pour toute question concernant cette politique de confidentialité ou vos données personnelles, '
                  'contactez notre délégué à la protection des données :\n\n'
                  'Email : privacy@mhdcooperation.com\n'
                  'Téléphone : +237658639119\n'
                  'Adresse : Yaoundé, Cameroun',
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
