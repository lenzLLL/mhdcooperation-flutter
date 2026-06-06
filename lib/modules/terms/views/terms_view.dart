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
            // Introduction
            _buildSection(
              title: 'Conditions Générales d\'Utilisation',
              content:
                  'Bienvenue sur MHD Cooperation. En utilisant notre application mobile, vous acceptez '
                  'd\'être lié par les présentes conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, '
                  'veuillez ne pas utiliser notre application.',
            ),

            const SizedBox(height: 24),

            // Définitions
            _buildSection(
              title: 'Définitions',
              content:
                  '• "Application" désigne l\'application mobile MHD Cooperation\n'
                  '• "Services" désigne tous les services fournis par l\'application\n'
                  '• "Utilisateur" désigne toute personne utilisant l\'application\n'
                  '• "Nous/Nos" désigne MHD Cooperation et ses représentants\n'
                  '• "Vous/Votre" désigne l\'utilisateur de l\'application',
            ),

            const SizedBox(height: 24),

            // Acceptation des conditions
            _buildSection(
              title: 'Acceptation des Conditions',
              content:
                  'En téléchargeant, installant ou utilisant l\'application, vous reconnaissez avoir lu, '
                  'compris et accepté d\'être lié par les présentes conditions d\'utilisation, ainsi que par notre '
                  'politique de confidentialité.',
            ),

            const SizedBox(height: 24),

            // Description des services
            _buildSection(
              title: 'Description des Services',
              content:
                  'MHD Cooperation fournit une plateforme permettant aux utilisateurs d\'accéder à :\n\n'
                  '• Informations sur les concours et recrutements\n'
                  '• Données sur les établissements éducatifs\n'
                  '• Services d\'accompagnement administratif\n'
                  '• Outils de recherche et de filtrage\n\n'
                  'Ces services sont fournis "en l\'état" et peuvent évoluer sans préavis.',
            ),

            const SizedBox(height: 24),

            // Obligations de l'utilisateur
            _buildSection(
              title: 'Obligations de l\'Utilisateur',
              content:
                  'En utilisant notre application, vous vous engagez à :\n\n'
                  '• Fournir des informations exactes et à jour\n'
                  '• Utiliser l\'application de manière responsable\n'
                  '• Ne pas violer les droits de propriété intellectuelle\n'
                  '• Ne pas utiliser l\'application à des fins illégales\n'
                  '• Respecter les droits des autres utilisateurs\n'
                  '• Ne pas tenter de compromettre la sécurité de l\'application',
            ),

            const SizedBox(height: 24),

            // Propriété intellectuelle
            _buildSection(
              title: 'Propriété Intellectuelle',
              content:
                  'L\'application et tous ses contenus (textes, images, logos, bases de données, etc.) '
                  'sont la propriété exclusive de MHD Cooperation ou de ses partenaires.\n\n'
                  'Vous êtes autorisé à utiliser ces contenus uniquement dans le cadre de l\'utilisation normale '
                  'de l\'application. Toute reproduction, distribution ou exploitation commerciale est interdite '
                  'sans autorisation préalable.',
            ),

            const SizedBox(height: 24),

            // Responsabilité
            _buildSection(
              title: 'Limitation de Responsabilité',
              content:
                  'MHD Cooperation s\'efforce de fournir des informations exactes et à jour, '
                  'mais ne peut garantir l\'exactitude, l\'exhaustivité ou la pertinence des informations fournies.\n\n'
                  'Nous ne sommes pas responsables des décisions prises sur la base des informations de l\'application, '
                  'ni des conséquences qui pourraient en découler.\n\n'
                  'L\'application est fournie "en l\'état" sans garantie d\'aucune sorte.',
            ),

            const SizedBox(height: 24),

            // Protection des données
            _buildSection(
              title: 'Protection des Données Personnelles',
              content:
                  'Le traitement de vos données personnelles est régi par notre politique de confidentialité, '
                  'que vous acceptez en utilisant l\'application.\n\n'
                  'Nous nous engageons à protéger vos données conformément aux réglementations en vigueur, '
                  'notamment le RGPD et les lois camerounaises sur la protection des données.',
            ),

            const SizedBox(height: 24),

            // Suspension et résiliation
            _buildSection(
              title: 'Suspension et Résiliation',
              content:
                  'Nous nous réservons le droit de suspendre ou résilier votre accès à l\'application '
                  'en cas de violation des présentes conditions.\n\n'
                  'Vous pouvez à tout moment cesser d\'utiliser l\'application.',
            ),

            const SizedBox(height: 24),

            // Modifications
            _buildSection(
              title: 'Modifications des Conditions',
              content:
                  'Nous pouvons modifier les présentes conditions à tout moment. '
                  'Les modifications seront publiées dans l\'application avec la date de dernière mise à jour.\n\n'
                  'Votre utilisation continue de l\'application après les modifications constitue votre acceptation '
                  'des nouvelles conditions.',
            ),

            const SizedBox(height: 24),

            // Droit applicable
            _buildSection(
              title: 'Droit Applicable et Juridiction',
              content:
                  'Les présentes conditions sont régies par le droit camerounais.\n\n'
                  'En cas de litige, les tribunaux de Yaoundé seront seuls compétents.',
            ),

            const SizedBox(height: 24),

            // Contact
            _buildSection(
              title: 'Contact',
              content:
                  'Pour toute question concernant ces conditions d\'utilisation, contactez-nous :\n\n'
                  'Email : legal@mhdcooperation.com\n'
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
