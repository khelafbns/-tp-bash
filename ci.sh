#!/bin/bash
# ci.sh - Pipeline CI minimal : clone/pull, "tests", journalisation, code de sortie explicite.
# Usage : ./ci.sh <url_du_depot> [dossier_de_travail]
# Codes de sortie : 0 = succès, 1 = usage, 2 = échec git, 3 = échec des tests

set -Eeuo pipefail

LOG_FILE="${CI_LOG:-ci.log}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage : $0 <url_du_depot> [dossier_de_travail]" >&2
    exit 1
}

mettre_a_jour_depot() {
    if [ -d "$WORKDIR/.git" ]; then
        log "Mise à jour du dépôt : git pull"
        git -C "$WORKDIR" pull --ff-only 2>&1 | tee -a "$LOG_FILE" || {
            log "ECHEC : git pull"
            exit 2
        }
    else
        log "Clonage de $REPO_URL dans $WORKDIR"
        git clone "$REPO_URL" "$WORKDIR" 2>&1 | tee -a "$LOG_FILE" || {
            log "ECHEC : git clone"
            exit 2
        }
    fi
}

lancer_tests() {
    local echecs=0
    log "Lancement des tests"

    if [ -z "$(ls -A "$WORKDIR" | grep -v '^\.git$' || true)" ]; then
        log "TEST 1 ECHEC : dépôt vide"
        echecs=$((echecs + 1))
    else
        log "TEST 1 OK : le dépôt contient des fichiers"
    fi

    local script
    while IFS= read -r script; do
        if bash -n "$script" 2>>"$LOG_FILE"; then
            log "TEST 2 OK : syntaxe valide ($script)"
        else
            log "TEST 2 ECHEC : erreur de syntaxe ($script)"
            echecs=$((echecs + 1))
        fi
    done < <(find "$WORKDIR" -name '*.sh' -not -path '*/.git/*')

    return "$echecs"
}

REPO_URL="${1:-}"
[ -z "$REPO_URL" ] && usage
WORKDIR="${2:-./ci-workspace}"

log "=== Début du pipeline ==="
mettre_a_jour_depot

if lancer_tests; then
    log "=== Pipeline terminé : SUCCES ==="
    exit 0
else
    log "=== Pipeline terminé : ECHEC (tests) ==="
    exit 3
fi
