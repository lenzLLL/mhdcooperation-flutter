// Villes du Cameroun — LISTE UNIQUE de l'application (mobile + web).
//
// Règle : partout où l'on saisit une ville, c'est un sélecteur alimenté par
// cette liste, jamais un champ libre. Des libellés divergents ("Limbe" vs
// "Limbé") casseraient silencieusement les filtres par ville, qui comparent
// des chaînes exactes.
//
// Doit rester identique à VILLES_CAMEROUN côté web
// (mhd/src/lib/catalog-constants.ts).
const List<String> villesCameroun = [
  'Abong-Mbang',
  'Akonolinga',
  'Bafang',
  'Bafia',
  'Bafoussam',
  'Bamenda',
  'Bandjoun',
  'Batouri',
  'Belabo',
  'Bertoua',
  'Bogo',
  'Buea',
  'Dschang',
  'Douala',
  'Ebolowa',
  'Edéa',
  'Figuil',
  'Foumban',
  'Garoua',
  'Guider',
  'Kaélé',
  'Kontcha',
  'Kousséri',
  'Koza',
  'Kribi',
  'Kumba',
  'Limbé',
  'Loum',
  'Maroua',
  'Mbalmayo',
  'Mbouda',
  'Mokolo',
  'Monatélé',
  'Mora',
  'Nanga-Eboko',
  'Ngaoundéré',
  'Nkongsamba',
  'Obala',
  'Poli',
  'Rey Bouba',
  'Sangmélima',
  'Tibati',
  'Touboro',
  'Waza',
  'Yagoua',
  'Yaoundé',
];

/// Catégories de concours — mêmes valeurs que le sélecteur web.
const List<String> concoursCategories = [
  'Ingénierie',
  'Gestion et Management',
  'Médécine/Santé',
  'Administration',
  'Enseignement',
];
