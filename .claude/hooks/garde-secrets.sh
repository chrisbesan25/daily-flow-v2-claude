#!/usr/bin/env bash
# Garde-fou des secrets, ajouté le 10 novembre 2026 ; contrôles Git natifs ajoutés le même jour,
# après le premier test réel (un « git add X && git commit » enchaîné n'était pas vu).
# Il complète la section « Secrets et réglages de Claude Code » de CLAUDE.md, sans la remplacer.
#
# Trois façons de l'appeler :
#   - sans argument : crochet PreToolUse de Claude Code sur l'outil Bash (commande reçue en JSON) ;
#   - --pre-commit : crochet Git, au moment exact du commit (.claude/git-hooks/pre-commit) ;
#   - --pre-push   : crochet Git, au moment exact de l'envoi (.claude/git-hooks/pre-push).
#
# En crochet PreToolUse, il bloque (code 2) :
#   A. toute commande qui contient une forme connue de secret (jeton GitHub, clé secrète Supabase,
#      jeton JWT autre que anon, clé AWS ou Anthropic, clé privée, adresse de base avec mot de passe) ;
#   B. les contournements : git add -f, --no-verify ou commit -n, tout réglage de core.hooksPath ;
#   C. par prévision, un git commit ou un git push qui contiendrait un fichier exclu
#      (.claude/settings.local.json, CLAUDE.local.md, .env, .env.*), un .claude/settings.json avec
#      autre chose que la clé hooks, ou une ligne ajoutée avec une forme connue de secret ou un mot
#      de passe écrit en dur ; si la commande contient aussi un git add, les fichiers non suivis
#      sont examinés en entier.
#   Il active aussi, à chaque appel, les crochets Git du dépôt (core.hooksPath = .claude/git-hooks,
#   réglage local de la copie, seule chose qu'il modifie).
# En crochet Git, il refuse (code 1) le commit ou l'envoi qui contient l'un des cas de C : c'est le
# contrôle qui voit le contenu réel, quelle que soit la façon dont le commit a été lancé.
# Il n'affiche jamais la valeur trouvée. Sans git ou hors dépôt, il laisse passer.
# Limites : formes de secrets connues seulement (un mot de passe quelconque dans une commande lui
# échappe) ; dépôt de la session seulement ; s'il ne peut pas s'exécuter, il laisse passer.

set -u
mode="${1:-outil}"

problemes=""
signaler() { problemes="${problemes}
  - $1"; }

# Formes connues de secrets (expressions étendues). La clé publishable de Supabase et les jetons
# JWT de rôle anon sont publics par conception : ils ne sont pas visés. Les motifs sont écrits pour
# ne pas se reconnaître eux-mêmes (PG[P]ASSWORD, variable MOTIF_MDP) : ce fichier passe son propre contrôle.
SECRETS='gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|sb_secret_[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{20,}|-----BEGIN ([A-Z]+ )*PRIVATE KEY-----|postgres(ql)?://[^:/@[:space:]"]+:[^@[:space:]"]+@|PG[P]ASSWORD=[^[:space:]"$]+'
JWT='eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
MOTIF_MDP='(password|passwd|mot_?de_?passe)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{8,}["'"'"']'

# Rôle d'un jeton JWT, lu dans sa partie centrale (base64url), sans afficher le jeton.
role_jwt() {
    local p="${1#*.}"
    p="${p%%.*}"
    p="$(printf '%s' "$p" | tr '_-' '/+')"
    while [ $(( ${#p} % 4 )) -ne 0 ]; do p="${p}="; done
    printf '%s' "$p" | base64 -d 2>/dev/null | grep -Eo '"role" *: *"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/'
}

# Contrôle d'un texte : $1 = texte, $2 = où il se trouve (pour le message).
controler_texte() {
    local texte="$1" lieu="$2" j r
    if printf '%s' "$texte" | grep -Eq -- "$SECRETS"; then
        signaler "$lieu : forme connue de secret (jeton, clé ou mot de passe d'une base)"
    fi
    for j in $(printf '%s' "$texte" | grep -Eo -- "$JWT" | sort -u); do
        r="$(role_jwt "$j")"
        [ "$r" = "anon" ] || signaler "$lieu : jeton JWT de rôle « ${r:-illisible} » (seul le rôle anon est public)"
    done
}

# Fichier exclu, puis lignes ajoutées : $1 = chemin, $2 = lignes ajoutées, $3 = moment.
examiner_fichier() {
    local f="$1" ajouts="$2" moment="$3"
    case "$f" in
        .claude/settings.local.json|*/.claude/settings.local.json|CLAUDE.local.md|*/CLAUDE.local.md|.env|*/.env|.env.*|*/.env.*)
            signaler "$f ($moment) : fichier qui ne se versionne jamais (exclu par .gitignore)" ;;
    esac
    [ -z "$ajouts" ] && return 0
    controler_texte "$ajouts" "$f ($moment, ligne ajoutée)"
    if printf '%s' "$ajouts" | grep -Eiq -- "$MOTIF_MDP"; then
        signaler "$f ($moment, ligne ajoutée) : mot de passe apparemment écrit en dur"
    fi
}

# .claude/settings.json : seule la clé hooks est admise. $1 = contenu, $2 = version examinée.
examiner_reglages() {
    local autres
    if command -v jq >/dev/null 2>&1; then
        autres="$(printf '%s' "$1" | jq -r 'if type == "object" then (keys - ["hooks", "$schema"]) | join(", ") else "illisible" end' 2>/dev/null || echo "illisible")"
    else
        autres="$(printf '%s' "$1" | grep -Eo '"(permissions|allow|deny|ask|env|apiKeyHelper|additionalDirectories|defaultMode)"' | sort -u | tr '\n' ' ')"
    fi
    [ -n "$autres" ] && signaler ".claude/settings.json ($2) : réglage autre que hooks ($autres)"
}

lignes_ajoutees() { grep -E '^\+' | grep -vE '^\+\+\+ '; }

# Ce que le prochain commit enregistrerait : index (et, si $1 = avec_suivis, fichiers suivis modifiés,
# cas de git commit -a ; si $2 = avec_nouveaux, fichiers non suivis, cas d'un git add dans la commande).
examiner_commit() {
    local suivis="$1" nouveaux="$2" f liste contenu
    liste="$( { git diff --cached --name-only; [ "$suivis" = avec_suivis ] && git diff --name-only; } 2>/dev/null | sort -u )"
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        examiner_fichier "$f" "$( { git diff --cached -U0 -- "$f"; [ "$suivis" = avec_suivis ] && git diff -U0 -- "$f"; } 2>/dev/null | lignes_ajoutees )" "à enregistrer"
    done <<< "$liste"
    if [ "$nouveaux" = avec_nouveaux ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            if [ -f "$f" ] && grep -Iq . "$f" 2>/dev/null; then
                examiner_fichier "$f" "$(cat "$f")" "nouveau fichier"
            else
                examiner_fichier "$f" "" "nouveau fichier"
            fi
        done <<< "$(git ls-files --others --exclude-standard 2>/dev/null)"
    fi
    contenu="$(git show :.claude/settings.json 2>/dev/null)" && examiner_reglages "$contenu" "index"
    if [ "$suivis" = avec_suivis ] && [ -f .claude/settings.json ]; then
        examiner_reglages "$(cat .claude/settings.json)" "copie de travail"
    fi
}

# Ce qu'un envoi ferait partir : chacun des commits atteignables depuis $1 et sur aucune branche en ligne.
examiner_envoi() {
    local tete="$1" f c contenu
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        examiner_fichier "$f" "$(git log -p -U0 --format= "$tete" --not --remotes -- "$f" 2>/dev/null | lignes_ajoutees)" "à envoyer"
    done <<< "$(git log --name-only --format= "$tete" --not --remotes 2>/dev/null | sort -u)"
    for c in $(git rev-list "$tete" --not --remotes -- .claude/settings.json 2>/dev/null); do
        contenu="$(git show "$c:.claude/settings.json" 2>/dev/null)" && examiner_reglages "$contenu" "commit $(git rev-parse --short "$c") à envoyer"
    done
}

terminer() { # $1 = code de blocage, $2 = ce qui est bloqué
    [ -z "$problemes" ] && exit 0
    {
        printf 'GARDE-FOU SECRETS : %s.%s\n' "$2" "$problemes"
        printf 'Ne pas contourner ce blocage (ni git add -f, ni --no-verify, ni modification du crochet, des réglages ou de core.hooksPath). '
        printf 'Le dire à Christophe en tête de réponse et appliquer la section « Secrets et réglages de Claude Code » de CLAUDE.md. '
        printf 'Aucune valeur n'"'"'est affichée ici. Faux positif : seul Christophe décide.\n'
    } >&2
    exit "$1"
}

case "$mode" in
--pre-commit)
    cd "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || exit 0
    examiner_commit index_seul sans_nouveaux
    terminer 1 "commit refusé par le contrôle Git"
    ;;
--pre-push)
    cd "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || exit 0
    while read -r ref_locale sha_local ref_distante sha_distant; do
        case "$sha_local" in ""|*[!0]*) ;; *) continue ;; esac   # suppression de branche : rien n'est envoyé
        [ -n "$sha_local" ] && examiner_envoi "$sha_local"
    done
    terminer 1 "envoi refusé par le contrôle Git"
    ;;
esac

# Crochet PreToolUse : la commande arrive en JSON sur l'entrée standard.
entree="$(cat)"

# A. La commande elle-même.
controler_texte "$entree" "la commande"

# B. Contournements.
git_cmd='(^|[^[:alnum:]_-])git([[:space:]]+[^[:space:];|&]+)*[[:space:]]+'
fin_cmd='([^[:alnum:]_-]|$)'
if printf '%s' "$entree" | grep -Eq "${git_cmd}(add|stage)([[:space:]]+[^;|&]*)?[[:space:]](--force|-[a-zA-Z]*f[a-zA-Z]*)${fin_cmd}"; then
    signaler "la commande : git add forcé (-f ou --force), interdit par CLAUDE.md"
fi
if printf '%s' "$entree" | grep -Eq -- "--no-verify${fin_cmd}" \
   || printf '%s' "$entree" | grep -Eq "${git_cmd}commit([[:space:]]+[^;|&]*)?[[:space:]]-[a-zA-Z]*n[a-zA-Z]*${fin_cmd}"; then
    signaler "la commande : contrôles Git sautés (--no-verify ou commit -n)"
fi
if printf '%s' "$entree" | grep -Eiq 'core\.hookspath'; then
    signaler "la commande : réglage de core.hooksPath (il désactiverait les contrôles Git)"
fi

if cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    # Activation des crochets Git du dépôt, à chaque appel (la copie d'une session web est neuve).
    if [ -f .claude/git-hooks/pre-commit ] && [ "$(git config --local --get core.hooksPath 2>/dev/null)" != ".claude/git-hooks" ]; then
        git config --local core.hooksPath .claude/git-hooks 2>/dev/null
    fi

    # C. Prévision pour git commit et git push.
    fait_add=0; fait_commit=0; fait_push=0
    printf '%s' "$entree" | grep -Eq "${git_cmd}(add|stage)${fin_cmd}" && fait_add=1
    printf '%s' "$entree" | grep -Eq "${git_cmd}commit${fin_cmd}" && fait_commit=1
    printf '%s' "$entree" | grep -Eq "${git_cmd}push${fin_cmd}" && fait_push=1
    if [ "$fait_commit" = 1 ]; then
        if [ "$fait_add" = 1 ]; then examiner_commit avec_suivis avec_nouveaux; else examiner_commit avec_suivis sans_nouveaux; fi
    fi
    [ "$fait_push" = 1 ] && examiner_envoi HEAD
fi

terminer 2 "commande bloquée avant exécution"
