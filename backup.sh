#!/bin/bash
# backup.sh - Archive un dossier, horodate l'archive, supprime les sauvegardes de plus de 7 jours
# Usage : ./backup.sh <dossier_a_sauvegarder> [dossier_destination]

set -Eeuo pipefail
trap 'echo "Erreur à la ligne $LINENO, sauvegarde interrompue." >&2' ERR

DOSSIER="${1:-}"
DEST="${2:-./sauvegardes}"

# Vérifications
if [ -z "$DOSSIER" ]; then
    echo "Usage : $0 <dossier> [destination]" >&2
    exit 1
fi

if [ ! -d "$DOSSIER" ]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas." >&2
    exit 1
fi

# Préparation
mkdir -p "$DEST"
HORODATAGE=$(date +%Y-%m-%d_%H-%M-%S)
NOM=$(basename "$DOSSIER")
ARCHIVE="$DEST/${NOM}_${HORODATAGE}.tar.gz"

# Création de l'archive
tar -czf "$ARCHIVE" -C "$(dirname "$DOSSIER")" "$NOM"
echo "Sauvegarde créée : $ARCHIVE"

# Suppression des sauvegardes de plus de 7 jours
for fichier in $(find "$DEST" -maxdepth 1 -name "${NOM}_*.tar.gz" -mtime +7); do
    rm -f "$fichier"
    echo "Ancienne sauvegarde supprimée : $fichier"
done

exit 0
