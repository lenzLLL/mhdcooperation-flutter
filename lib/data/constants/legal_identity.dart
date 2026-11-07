/// Identité de l'éditeur pour la politique de confidentialité. Miroir de
/// `src/lib/legal-identity.ts` côté web (qui prime en cas de divergence).
///
/// Google Play exige que le texte nomme l'application et le développeur
/// EXACTEMENT comme la fiche du Play Store : si le Play Console affiche un autre
/// nom, c'est ici qu'il faut l'aligner.
class LegalIdentity {
  LegalIdentity._();

  static const appName = 'MhD · Mr Help Documents';
  static const appAlias = 'MHD Cooperation';
  static const developerName = 'MHD Cooperation';
  static const androidPackage = 'com.mhdcooperation.com.mhdcooperation';
  static const website = 'https://mhdcooperation.site';
  static const email = 'helpdocs4@gmail.com';
  static const phone = '+237 681 186 114';
  static const country = 'Cameroun';
  static const policyUpdated = '7 novembre 2026';
}
