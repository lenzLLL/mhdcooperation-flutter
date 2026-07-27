import 'package:mhdcooperation/data/models/services.dart';

/// Numéro WhatsApp unique de la coopérative (toutes les redirections WhatsApp).
/// Doit rester identique à WHATSAPP_NUMBER côté web.
const String autreWhatsappNumber = '237681186114';

/// Catalogue STATIQUE unique des services — source de vérité partagée entre
/// l'accueil et la page « Nos Services » (avant ce fichier, chaque contrôleur
/// avait sa propre liste, avec des ids en collision : « Impôts » id '1' côté
/// accueil ↔ « Concours et Recrutements » id '1' côté page services).
final List<Services> servicesCatalog = [
  Services(
    id: '1',
    name: 'Dossiers Concours et Recrutements',
    desc:
        'Nous mettons à votre disposition la liste de tous les concours disponibles dans le territoire du Cameroun',
  ),
  Services(
    id: '2',
    name: 'Dossiers BTS, Licence, Bachelor, Master et HND',
    desc:
        "Constituez vos dossiers d examen facilement et rapidement grace à notre équipe expérimenté et dynamique",
  ),
  Services(
    id: '3',
    name: 'Dossiers Passeport/CNI',
    desc:
        'Constituez vos dossiers de passeport ou de cni facilement et rapidement grace à notre équipe expérimenté et dynamique',
  ),
  Services(
    id: '4',
    name: 'Certificat de police',
    desc:
        'Constituez votre certificat de police facilement et rapidement grâce à notre équipe expérimentée et dynamique',
  ),
  Services(
    id: '5',
    name: 'Rapport de stage',
    desc:
        'En cas de difficulté dans vos rapports de stage faites appel à notre équipe pour vous assister dans votre travail.',
  ),
  Services(
    id: '6',
    name: 'Dossiers inscription et préinscription universitaire',
    desc:
        "Vous voulez vous inscrire dans une université et vous ne savez pas comment faire? n'hésitez pas contactez nous",
  ),
  Services(
    id: '8',
    name: 'Services Impôts/Fiscalité',
    desc:
        'Vos démarches fiscales simples, rapides et sécurisées : création NIU, déclarations, attestations et bien plus.',
    subOptions: const [
      ServiceSubOption(id: 'niu_creation', label: 'Création du NIU', price: 5000),
      ServiceSubOption(id: 'niu_activation', label: 'Activation des NIU', price: 5000),
      ServiceSubOption(id: 'igs_dsf', label: 'Déclaration IGS et DSF', price: 15000),
      ServiceSubOption(id: 'irpp', label: 'Déclaration IRPP', price: 15000),
      ServiceSubOption(id: 'paiement_ligne', label: 'Paiement en ligne des Impôts', price: 5000),
      ServiceSubOption(
          id: 'reset_dgi', label: 'Réinitialisation mot de passe DGI (Harmony)', price: 5000),
      ServiceSubOption(id: 'attest_niu', label: "Attestation d'immatriculation (NIU)", price: 10000),
      ServiceSubOption(id: 'acf', label: 'Attestation de conformité fiscale (ACF)', price: 15000),
    ],
  ),
];

/// Formules du service « Dossiers Passeport/CNI ».
/// Doit rester identique à CNI_PASSEPORT_OPTIONS côté web
/// (mhd/src/lib/service-pricing.ts).
const List<ServiceSubOption> cniPasseportOptions = [
  ServiceSubOption(id: 'cni_simple', label: 'CNI — simple', price: 25000),
  ServiceSubOption(id: 'cni_vip', label: 'CNI — VIP', price: 30000),
  ServiceSubOption(id: 'cni_super_vip', label: 'CNI — Super VIP', price: 50000),
  ServiceSubOption(id: 'passeport_classe_k', label: 'Passeport — Classe K', price: 100000),
  ServiceSubOption(id: 'passeport_vip', label: 'Passeport — VIP Pass', price: 135000),
  ServiceSubOption(id: 'passeport_super_vip', label: 'Passeport — Super VIP', price: 150000),
];

const List<String> _docsCni = [
  'Acte de naissance',
  'Carte originale ou ancienne CNI',
];

const List<String> _docsPasseport = [
  'Acte de naissance',
  'CNI',
  'Acte de naissance du parent',
  "Acte de naissance de l'enfant (si mineur)",
];

/// Pièces exigées par formule CNI/Passeport (demandées après paiement).
List<String> documentsForSubOption(String subOptionId) {
  if (subOptionId.startsWith('cni_')) return _docsCni;
  if (subOptionId.startsWith('passeport_')) return _docsPasseport;
  return const [];
}

/// Entrée « Autre » (redirection WhatsApp) : affichée en fin de liste sur
/// l'accueil ; la page « Nos Services » a sa propre carte dédiée.
final Services autreService = Services(
  id: '7',
  name: 'Autre',
  desc:
      "Votre besoin n'est pas dans la liste ? Contactez-nous directement sur WhatsApp, nous trouverons une solution ensemble.",
  whatsappNumber: autreWhatsappNumber,
);
