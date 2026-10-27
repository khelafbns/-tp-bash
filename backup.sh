#!/bin/bash
# backup.sh - Archive un dossier (horodatée) et supprime les sauvegardes de plus de 7 jours.
# Usage : ./backup.sh <dossier_a_sauvegarder> [dossier_destination]

set -Eeuo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

DOSSIER="${1:-}"
DESTINATION="${2:-$HOME/backups}"
RETENTION_JOURS=7

if [ -z "$DOSSIER" ]; then
    echo "Usage : $0 <dossier> [destination]" >&2
    exit 2
fi

if [ ! -d "$DOSSIER" ]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas" >&2
    exit 1
fi

mkdir -p "$DESTINATION"

HORODATAGE=$(date +%Y-%m-%d_%H-%M-%S)
NOM=$(basename "$DOSSIER")
ARCHIVE="$DESTINATION/backup_${NOM}_${HORODATAGE}.tar.gz"

log "Début de la sauvegarde de '$DOSSIER'"
tar -czf "$ARCHIVE" -C "$(dirname "$DOSSIER")" "$NOM"
log "Archive créée : $ARCHIVE"

log "Nettoyage des sauvegardes de plus de ${RETENTION_JOURS} jours"
shopt -s nullglob
for fichier in "$DESTINATION"/backup_"${NOM}"_*.tar.gz; do
    if [ -n "$(find "$fichier" -mtime +"$RETENTION_JOURS")" ]; then
        rm -- "$fichier"
        log "Supprimée : $fichier"
    fi
done

log "Sauvegarde terminée avec succès"
exit 0
