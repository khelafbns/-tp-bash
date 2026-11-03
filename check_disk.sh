#!/bin/bash
# check_disk.sh - Alerte si l'espace disque utilisé dépasse un seuil (80% par défaut)
# Usage : ./check_disk.sh [seuil_en_pourcentage]

# Seuil : 1er argument, ou 80 s'il est absent
SEUIL=${1:-80}

# Vérifie que le seuil est bien un nombre entier
if ! [[ "$SEUIL" =~ ^[0-9]+$ ]]; then
    echo "Erreur : le seuil doit être un entier (reçu : '$SEUIL')" >&2
    exit 2
fi

# df / -> 2e ligne, 5e colonne (ex. "42%"), puis on retire le '%'
UTILISATION=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$UTILISATION" -ge "$SEUIL" ]; then
    echo "ALERTE : la partition / est utilisée à ${UTILISATION}% (seuil : ${SEUIL}%)"
    exit 1
fi

echo "OK : la partition / est utilisée à ${UTILISATION}% (seuil : ${SEUIL}%)"
exit 0
