#!/bin/bash
# Prépare un Mac à construire l'application iOS : .env, dépendances, pods.
# À lancer une fois, depuis n'importe où dans le dépôt :  bash ios/preparer_mac.sh
# Rien n'est effacé ni écrasé : un fichier déjà présent est laissé tel quel.
set -euo pipefail

# Un Mac qui s'endort arrête les téléchargements (Firebase est long sur une
# connexion lente) : `caffeinate` le garde éveillé tant que le script tourne.
if [ -z "${MHD_EVEILLE:-}" ] && command -v caffeinate >/dev/null; then
  export MHD_EVEILLE=1
  exec caffeinate -dims bash "$0" "$@"
fi

cd "$(dirname "$0")/.."

debut=$(date +%s)
etape() { echo; echo "== [$(date +%H:%M:%S)] $* =="; }

etape "Outils (les mêmes que pour ChristLumen)"
for outil in flutter xcodebuild pod git; do
  command -v "$outil" >/dev/null || { echo "MANQUE : $outil"; exit 1; }
done
flutter --version | head -1
xcodebuild -version | head -2
echo "CocoaPods $(pod --version)"

etape ".env (hors git, embarqué dans l'application)"
# L'adresse de l'API n'a aucune valeur par défaut dans le code : sans elle,
# connexion, dossiers et paiements échouent. Elle est dans le .env du PC.
if [ ! -f .env ]; then
  echo "Sur le PC, ouvrez H:\\coding\\flutter\\mhdcooperation\\.env avec le Bloc-notes"
  echo "et copiez la ligne qui commence par MHD_API_BASE_URL="
  read -r -p "Collez-la ici puis appuyez sur Entrée : " ligne
  ligne="${ligne%$'\r'}"
  case "$ligne" in
    MHD_API_BASE_URL=https://*) printf '%s\n' "$ligne" > .env; echo "créé" ;;
    *) echo "Refusé : la ligne doit commencer par MHD_API_BASE_URL=https://"; exit 1 ;;
  esac
elif grep -q '^MHD_API_BASE_URL=https://' .env; then
  echo "déjà là"
else
  echo ".env présent mais sans ligne MHD_API_BASE_URL=https://... : à corriger"
  exit 1
fi

etape "Dépendances Flutter"
flutter precache --ios
flutter pub get

# Firebase se télécharge sans aucune barre de progression : la ligne peut rester
# immobile longtemps. Interrompre (Ctrl+C) et relancer est sans danger.
etape "Pods (Firebase est le plus long)"
if ! (cd ios && pod install); then
  echo
  echo "ÉCHEC de pod install. Relancer le script : les pods déjà téléchargés sont gardés."
  echo "Si l'erreur parle de « repo update » : cd ios && pod install --repo-update"
  exit 1
fi

echo
echo "Prêt en $(( ($(date +%s) - debut) / 60 )) min. Suite : open ios/Runner.xcworkspace"
