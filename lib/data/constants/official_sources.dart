/// Sources officielles des informations « administration » affichées par MhD.
///
/// Miroir de `src/lib/official-sources.ts` côté web (qui prime en cas de
/// divergence). Chaque adresse a été ouverte et vérifiée le 2026-11-07. Ne rien
/// ajouter ici sans l'avoir ouvert : Google Play exige des liens clairs,
/// officiels et fonctionnels.
///
/// Volontairement absents : le MINREX (légalisation) et le ministère de la
/// Justice (casier judiciaire), injoignables au moment de la vérification.
class OfficialSource {
  final String label;
  final String url;
  final String covers;

  const OfficialSource({
    required this.label,
    required this.url,
    required this.covers,
  });
}

const _dgsn = OfficialSource(
  label: 'DGSN — Police camerounaise',
  url: 'https://www.dgsn.cm',
  covers: 'CNI, passeports, concours de la police',
);
const _dgi = OfficialSource(
  label: 'DGI — Direction Générale des Impôts',
  url: 'https://www.impots.cm/',
  covers: 'Impôts et téléprocédures fiscales',
);
const _dgiNiu = OfficialSource(
  label: 'DGI — Immatriculation (NIU)',
  url: 'https://www.impots.cm/fr/immatriculation',
  covers: "Numéro d'Identifiant Unique",
);
const _minfopra = OfficialSource(
  label: 'MINFOPRA — Fonction publique',
  url: 'https://www.minfopra.gov.cm/',
  covers: 'Concours administratifs et recrutements',
);
const _minfopraOnline = OfficialSource(
  label: 'MINFOPRA — Concours en ligne',
  url: 'https://concoursonline.minfopra.gov.cm/',
  covers: 'Inscription en ligne aux concours administratifs',
);
const _minesup = OfficialSource(
  label: 'MINESUP — Enseignement supérieur',
  url: 'https://www.minesup.gov.cm/',
  covers: 'Universités, établissements et formations',
);
const _minesupConcours = OfficialSource(
  label: 'MINESUP — Concours et décisions',
  url: 'https://www.minesup.gov.cm/index.php/category/concours/',
  covers: "Annonces de concours de l'enseignement supérieur",
);

/// Sources de chaque service (clé = id de `servicesCatalog`).
const Map<String, List<OfficialSource>> sourcesByService = {
  '1': [_minfopra, _minfopraOnline, _minesupConcours],
  '2': [_minesup, _minesupConcours],
  '3': [_dgsn],
  '4': [_dgsn],
  '6': [_minesup],
  '8': [_dgi, _dgiNiu],
};

const List<OfficialSource> concoursSources = [
  _minfopra,
  _minfopraOnline,
  _minesupConcours,
  _dgsn,
];

const List<OfficialSource> schoolSources = [_minesup, _minesupConcours];

const List<OfficialSource> allOfficialSources = [
  _minfopra,
  _minfopraOnline,
  _minesup,
  _minesupConcours,
  _dgsn,
  _dgi,
  _dgiNiu,
];

/// Mention affichée partout où MhD parle de démarches administratives.
const String notGovernmentNotice =
    "MhD · Mr Help Documents est un service privé d'accompagnement. Nous ne sommes affiliés à aucune administration ni à aucun organisme public et ne les représentons pas : nous vous aidons à constituer et à déposer vos dossiers. Les documents officiels sont délivrés par les administrations concernées.";

const String verifyAtSourceNotice =
    'Ces informations sont données à titre indicatif. Vérifiez toujours auprès de la source officielle.';
