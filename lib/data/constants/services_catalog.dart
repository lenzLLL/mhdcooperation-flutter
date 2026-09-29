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
        "Constituez vos dossiers d'examen facilement et rapidement grâce à notre équipe expérimentée et dynamique",
  ),
  Services(
    id: '3',
    name: 'Dossiers Passeport/CNI',
    desc:
        'Constituez vos dossiers de passeport ou de CNI facilement et rapidement grâce à notre équipe expérimentée et dynamique',
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
  ServiceSubOption(
    id: 'cni_simple',
    label: 'CNI — simple',
    price: 25000,
    description: "Constitution et dépôt de votre dossier de CNI, avec suivi jusqu'au retrait.",
  ),
  ServiceSubOption(
    id: 'cni_vip',
    label: 'CNI — VIP',
    price: 30000,
    description: 'Traitement prioritaire de votre dossier de CNI et suivi personnalisé.',
  ),
  ServiceSubOption(
    id: 'cni_super_vip',
    label: 'CNI — Super VIP',
    price: 50000,
    description: 'Prise en charge complète et accélérée : nous gérons toutes les démarches de votre CNI.',
  ),
  ServiceSubOption(
    id: 'passeport_classe_k',
    label: 'Passeport — Classe K',
    price: 125000,
    description:
        "Formule standard : constitution et dépôt de votre dossier de passeport, suivi jusqu'à la délivrance.",
  ),
  ServiceSubOption(
    id: 'passeport_vip',
    label: 'Passeport — VIP Pass',
    price: 135000,
    description: 'Traitement prioritaire de votre dossier de passeport et suivi personnalisé.',
  ),
  ServiceSubOption(
    id: 'passeport_super_vip',
    label: 'Passeport — Super VIP',
    price: 150000,
    description: 'Prise en charge complète et accélérée de votre passeport, du dossier au retrait.',
  ),
];

/// Formules du service « Certificat de police ».
/// Doit rester identique à POLICE_OPTIONS côté web
/// (mhd/src/lib/service-pricing.ts).
const List<ServiceSubOption> policeOptions = [
  ServiceSubOption(
    id: 'simple',
    label: 'Simple',
    price: 20000,
    description: "Demande de votre certificat de police et suivi jusqu'au retrait.",
  ),
  ServiceSubOption(
    id: 'vip',
    label: 'VIP',
    price: 25000,
    description: 'Traitement prioritaire de votre demande et suivi personnalisé.',
  ),
  ServiceSubOption(
    id: 'super_vip',
    label: 'Super VIP',
    price: 40000,
    description: 'Prise en charge complète et accélérée de votre certificat de police.',
  ),
  ServiceSubOption(
    id: 'minrex',
    label: 'Légalisation + MINREX',
    price: 100000,
    description:
        "Certificat de police légalisé au Ministère des Relations Extérieures (MINREX), pour un usage à l'étranger.",
  ),
];

/// Pièce toujours exigée pour un dossier BTS/Licence/…
/// Doit rester identique à BTS_BASE_DOCUMENTS côté web.
const List<String> btsBaseDocuments = ["Carte d'identité"];

/// Pièces d'un dossier BTS : la base commune puis celles de l'école pour ce niveau.
List<String> btsDocuments(Map<String, List<String>> docsParNiveau, String niveau) =>
    {...btsBaseDocuments, ...(docsParNiveau[niveau] ?? const <String>[])}.toList();

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
