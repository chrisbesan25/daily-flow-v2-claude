#!/usr/bin/env bash
# Garde-fou des secrets (crochet PreToolUse sur l'outil Bash), ajouté le 10 novembre 2026.
# Il complète la section « Secrets et réglages de Claude Code » de CLAUDE.md, sans la remplacer.
#
# Avant chaque commande Bash, il bloque (code 2) :
#   A. toute commande qui contient une forme connue de secret (jeton GitHub, clé secrète Supabase,
#      jeton JWT autre que anon, clé AWS ou Anthropic, clé privée, adresse de base avec mot de passe) ;
#   B. pour git commit et git push, tout envoi qui contiendrait :
#      1. un fichier exclu (.claude/settings.local.json, CLAUDE.local.md, .env, .env.*) ;
#      2. un .claude/settings.json avec autre chose que la clé hooks (permissions, par exemple) ;
#      3. une ligne ajoutée avec une forme connue de secret ou un mot de passe écrit en dur.
# Il ne modifie rien et n'affiche jamais la valeur trouvée. Sans git ou hors dépôt, il laisse passer.
# Limites : il ne contrôle que le dépôt de la session (CLAUDE_PROJECT_DIR) et les formes de secrets
# qu'il connaît ; un mot de passe quelconque dans une commande lui échappe.

set -u
entree="$(cat)"

problemes=""
signaler() { problemes="${problemes}
  - $1"; }

# Formes connues de secrets (expressions étendues). La clé publishable de Supabase et les jetons
# JWT de rôle anon sont publics par conception : ils ne sont pas visés.
SECRETS='gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|sb_secret_[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{20,}|-----BEGIN ([A-Z]+ )*PRIVATE KEY-----|postgres(ql)?://[^:/@[:space:]"]+:[^@[:space:]"]+@|PGPASSWORD=[^[:space:]"$]+'
JWT='eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
MOT_DE_PASSE='(password|passwd|mot_?de_?passe)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{8,}["'"'"']'

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

# A. La commande elle-même.
controler_texte "$entree" "la commande"

# B. git commit ou git push : contrôle de ce qui serait enregistré ou envoyé.
if printf '%s' "$entree" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]+[^[:space:];|&]+)*[[:space:]]+(commit|push)([^[:alnum:]_-]|$)'; then
    if cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
        base=""
        git rev-parse --verify --quiet origin/main >/dev/null && base="origin/main...HEAD"

        # Fichiers concernés : indexés, modifiés et suivis (cas de git commit -a), et commits pas encore sur main.
        fichiers="$( { git diff --cached --name-only; git diff --name-only;
                       [ -n "$base" ] && git diff --name-only "$base"; } 2>/dev/null | sort -u )"

        while IFS= read -r f; do
            [ -z "$f" ] && continue
            case "$f" in
                .claude/settings.local.json|*/.claude/settings.local.json|CLAUDE.local.md|*/CLAUDE.local.md|.env|*/.env|.env.*|*/.env.*)
                    signaler "$f : fichier qui ne se versionne jamais (exclu par .gitignore)" ;;
            esac
            ajouts="$( { git diff --cached -U0 -- "$f"; git diff -U0 -- "$f";
                         [ -n "$base" ] && git diff -U0 "$base" -- "$f"; } 2>/dev/null \
                       | grep -E '^\+' | grep -vE '^\+\+\+ ' )"
            [ -z "$ajouts" ] && continue
            controler_texte "$ajouts" "$f (ligne ajoutée)"
            if printf '%s' "$ajouts" | grep -Eiq -- "$MOT_DE_PASSE"; then
                signaler "$f (ligne ajoutée) : mot de passe apparemment écrit en dur"
            fi
        done <<< "$fichiers"

        # .claude/settings.json : seule la clé hooks est admise, dans l'index comme dans la copie de travail.
        for version in index copie; do
            if [ "$version" = index ]; then
                contenu="$(git show :.claude/settings.json 2>/dev/null)" || continue
            else
                [ -f .claude/settings.json ] || continue
                contenu="$(cat .claude/settings.json)"
            fi
            if command -v jq >/dev/null 2>&1; then
                autres="$(printf '%s' "$contenu" | jq -r 'if type == "object" then (keys - ["hooks", "$schema"]) | join(", ") else "illisible" end' 2>/dev/null || echo "illisible")"
            else
                autres="$(printf '%s' "$contenu" | grep -Eo '"(permissions|allow|deny|ask|env|apiKeyHelper|additionalDirectories|defaultMode)"' | sort -u | tr '\n' ' ')"
            fi
            [ -n "$autres" ] && signaler ".claude/settings.json ($version) : réglage autre que hooks ($autres)"
        done
    fi
fi

if [ -n "$problemes" ]; then
    {
        printf 'GARDE-FOU SECRETS : commande bloquée avant exécution.%s\n' "$problemes"
        printf 'Ne pas contourner ce blocage (ni git add -f, ni modification du crochet ou des réglages). '
        printf 'Le dire à Christophe en tête de réponse et appliquer la section « Secrets et réglages de Claude Code » de CLAUDE.md. '
        printf 'Aucune valeur n'"'"'est affichée ici. Faux positif : seul Christophe décide.\n'
    } >&2
    exit 2
fi
exit 0
