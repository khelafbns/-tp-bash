#!/bin/bash
# check_disk.sh - Alerte si l'espace disque utilisé dépasse un seuil.
# Usage : ./check_disk.sh [seuil_en_pourcent]   (80 par défaut)

SEUIL="${1:-80}"

# Le seuil doit être un entier
if ! [[ "$SEUIL" =~ ^[0-9]+$ ]]; then
    echo "Erreur : le seuil doit être un entier (reçu : '$SEUIL')" >&2
    exit 2
fi

# 2e ligne de df, 5e colonne (Use%), sans le signe %
UTILISATION=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$UTILISATION" -ge "$SEUIL" ]; then
    echo "ALERTE : disque utilisé à ${UTILISATION}% (seuil : ${SEUIL}%)"
    exit 1
fi

echo "OK : disque utilisé à ${UTILISATION}% (seuil : ${SEUIL}%)"
exit 0
