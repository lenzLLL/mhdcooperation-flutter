import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/constants/legal_identity.dart';
import 'package:mhdcooperation/modules/privacy/controllers/privacy_controller.dart';

/// Une rubrique de la politique. Miroir de la page web `/confidentialite`
/// (qui prime en cas de divergence) : le texte doit rester identique.
class _Section {
  final String title;
  final String? intro;
  final List<String> items;
  final String? outro;

  const _Section({
    required this.title,
    this.intro,
    this.items = const [],
    this.outro,
  });
}

const List<_Section> _sections = [
  _Section(
    title: 'Données que nous collectons',
    items: [
      "Compte : nom, adresse email, numéro de téléphone, ville et, si vous l'ajoutez, photo de profil. Votre mot de passe est géré par Google Firebase Authentication : nous ne pouvons pas le lire.",
      "Dossiers : ville, quartier et pièces justificatives que vous déposez (photos ou PDF). Elles peuvent comprendre des pièces d'identité, actes de naissance ou diplômes.",
      'Paiements : numéro Mobile Money et opérateur saisis pour payer, montant, date, statut et référence de l\'opération. Nous ne voyons jamais votre code PIN : vous le saisissez sur votre téléphone, auprès de votre opérateur.',
      "Notifications : un identifiant technique de votre appareil, pour vous envoyer les alertes sur vos dossiers.",
      "Code promo : le code personnel créé pour votre compte et son utilisation.",
      "Journaux techniques : date, adresse IP et erreurs enregistrées par nos hébergeurs pour faire fonctionner et sécuriser le service.",
    ],
    outro:
        "Nous ne collectons ni votre position, ni vos contacts, ni vos SMS, et nous n'affichons aucune publicité.",
  ),
  _Section(
    title: 'Pourquoi nous les utilisons',
    items: [
      'Créer votre compte et vous identifier.',
      'Traiter et suivre vos dossiers, et vous accompagner dans vos démarches.',
      'Encaisser vos paiements et vous remettre un reçu.',
      "Vous informer de l'avancement de vos dossiers et répondre à vos demandes d'assistance.",
      'Sécuriser le service, prévenir la fraude et respecter nos obligations légales.',
    ],
    outro:
        'Vos données ne sont ni vendues, ni utilisées à des fins publicitaires.',
  ),
  _Section(
    title: 'Avec qui nous les partageons',
    items: [
      'Google (Firebase) : authentification, base de données, stockage des fichiers et notifications.',
      "Vercel : hébergement du site et de l'interface qui sert l'application.",
      'K-Pay (kpay.site) et votre opérateur Mobile Money (MTN, Orange) : exécution des paiements. Ils reçoivent votre numéro, le montant et l\'opérateur.',
      'Administrations et établissements : uniquement pour traiter la démarche que vous demandez, par exemple le dépôt de votre dossier.',
      "Les autorités, lorsque la loi nous l'impose.",
    ],
    outro:
        'Ces prestataires traitent vos données pour nous rendre le service et peuvent les héberger hors du Cameroun. Nous ne vendons pas vos données.',
  ),
  _Section(
    title: 'Durée de conservation',
    intro:
        'Votre compte et vos dossiers sont conservés tant que votre compte existe. Si vous demandez la suppression, nous supprimons votre compte, vos dossiers et vos pièces sous 30 jours.',
    outro:
        "Seuls les enregistrements de paiement (montant, date, opérateur, référence) sont conservés, pour nos obligations comptables et la lutte contre la fraude, pendant la durée exigée par la loi.",
  ),
  _Section(
    title: 'Sécurité',
    intro:
        "Les échanges entre votre appareil et nos serveurs sont chiffrés (HTTPS). La connexion passe par Google Firebase Authentication. Les fonctions d'administration sont réservées aux membres autorisés de l'équipe, et leurs actions sont enregistrées dans un journal. Aucun système n'étant infaillible, nous ne pouvons pas promettre une sécurité absolue : contactez-nous sans attendre si vous constatez un problème.",
  ),
  _Section(
    title: 'Vos droits',
    items: [
      'Consulter et corriger vos informations (nom, téléphone, ville, photo) dans Mon compte.',
      "Demander la suppression de votre compte et de vos données : dans l'application (Profil, puis Supprimer mon compte) ou sur ${LegalIdentity.website}/suppression-compte.",
      'Désactiver les notifications dans les réglages de votre téléphone.',
      'Nous écrire à ${LegalIdentity.email} pour toute autre demande. Nous répondons sous 30 jours.',
    ],
  ),
  _Section(
    title: 'Mineurs',
    intro:
        "Le service s'adresse aux candidats, élèves et étudiants. Un mineur utilise l'application avec l'accord de son parent ou tuteur, qui peut aussi nous écrire pour exercer ses droits.",
  ),
  _Section(
    title: 'Modifications de cette politique',
    intro:
        "Nous pouvons mettre à jour cette politique. La date de dernière mise à jour figure en bas de page. En cas de changement important, nous vous en informons dans l'application.",
  ),
];

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
            _buildIdentityCard(),
            for (var i = 0; i < _sections.length; i++) ...[
              const SizedBox(height: 24),
              _buildSection(index: i + 1, section: _sections[i]),
            ],
            const SizedBox(height: 32),

            // Date de dernière mise à jour
            Center(
              child: Text(
                'Dernière mise à jour : ${LegalIdentity.policyUpdated}',
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  TextStyle get _bodyStyle =>
      TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6);

  Widget _buildIdentityCard() {
    const rows = <(String, String)>[
      (
        'Application',
        '${LegalIdentity.appName} (également affichée « ${LegalIdentity.appAlias} »)',
      ),
      (
        'Développeur et responsable du traitement',
        "${LegalIdentity.developerName} — service privé d'accompagnement, ${LegalIdentity.country}",
      ),
      (
        'Disponible sur',
        'Android (identifiant ${LegalIdentity.androidPackage}) et ${LegalIdentity.website}',
      ),
      ('Contact', '${LegalIdentity.email} · ${LegalIdentity.phone}'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qui sommes-nous',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Cette politique s'applique à l'application ${LegalIdentity.appName} et au site ${LegalIdentity.website.replaceFirst('https://', '')}, édités par ${LegalIdentity.developerName}. Elle explique quelles données nous collectons, pourquoi, et comment vous gardez la main dessus.",
            style: _bodyStyle,
          ),
          const SizedBox(height: 12),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({required int index, required _Section section}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${section.title}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (section.intro != null) ...[
            const SizedBox(height: 12),
            Text(section.intro!, style: _bodyStyle),
          ],
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: _bodyStyle),
                  Expanded(child: Text(item, style: _bodyStyle)),
                ],
              ),
            ),
          if (section.outro != null) ...[
            const SizedBox(height: 12),
            Text(section.outro!, style: _bodyStyle),
          ],
        ],
      ),
    );
  }
}
