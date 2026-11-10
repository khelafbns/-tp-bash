#!/usr/bin/env bash
# ci.sh : mini pipeline CI (clone/pull, tests, logs horodatés)
# Usage : ./ci.sh <url_du_depot>
set -Eeuo pipefail

# ---------- Codes de sortie ----------
E_USAGE=1
E_GIT=2
E_TESTS=3

# ---------- Argument ----------
REPO_URL="${1:-}"          # ${1:-} évite l'erreur de set -u si absent

if [ -z "$REPO_URL" ]; then
    echo "Usage : $0 <url_du_depot>" >&2
    exit "$E_USAGE"
fi

# ---------- Configuration ----------
WORKDIR="$HOME/tp-bash/ci-workspace"
LOG_FILE="$HOME/tp-bash/logs/ci.log"
REPO_DIR="$WORKDIR/$(basename "$REPO_URL" .git)"
mkdir -p "$WORKDIR" "$(dirname "$LOG_FILE")"

# ---------- Fonctions ----------
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$LOG_FILE"
}

sync_repo() {
    if [ -d "$REPO_DIR/.git" ]; then
        log INFO "Mise à jour du dépôt (git pull)"
        git -C "$REPO_DIR" pull --ff-only
    else
        log INFO "Clonage de $REPO_URL"
        git clone "$REPO_URL" "$REPO_DIR"
    fi
}

run_tests() {
    log INFO "Exécution des tests"
    [ -d "$REPO_DIR/.git" ] || { log ERROR "Dépôt invalide"; return 1; }
    [ -f "$REPO_DIR/README.md" ] || { log ERROR "README.md manquant"; return 1; }
    log INFO "2 tests réussis"
}

# ---------- Pipeline ----------
log INFO "=== Début du pipeline ==="

if ! sync_repo; then
    log ERROR "Échec de l'étape git"
    exit "$E_GIT"
fi

if ! run_tests; then
    log ERROR "Échec des tests"
    exit "$E_TESTS"
fi

log INFO "=== Pipeline terminé avec succès ==="
exit 0
