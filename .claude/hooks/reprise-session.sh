#!/usr/bin/env bash
# Crochet de reprise de session (SessionStart), ajouté le 22 octobre 2026, adapté de celui de Budget perso.
# Au démarrage d'une session Claude Code : git fetch, puis alerte si main ou la branche de travail en ligne
# a changé depuis la dernière session et contient des commits absents de la copie de travail.
# Il ne touche jamais aux fichiers de travail ni aux branches locales : il lit seulement.
# Il ne remplace pas la règle de reprise de CLAUDE.md (git fetch origin main au début de chaque demande).

set -u
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Repère de la dernière session, rangé dans .git (jamais versionné, jamais publié).
REPERE="$(git rev-parse --git-dir)/daily-flow-reprise-session"
BRANCHE="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

# Chaîne JSON sans dépendre de jq : barre oblique inverse, guillemet et sauts de ligne échappés.
json() {
    local s="$1"
    s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"; s="${s//$'\r'/\\r}"; s="${s//$'\t'/\\t}"
    printf '"%s"' "$s"
}

# Sortie au format attendu par Claude Code : systemMessage pour Christophe,
# additionalContext pour Claude.
emettre() {
    local alerte=""
    [ -n "$1" ] && alerte="\"systemMessage\":$(json "$1"),"
    printf '{%s"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$alerte" "$(json "$2")"
}

# git fetch borné à 30 secondes, sans jamais demander d'identifiants.
borne() { if command -v timeout >/dev/null 2>&1; then timeout 30 "$@"; else "$@"; fi; }
if ! GIT_TERMINAL_PROMPT=0 borne git fetch --quiet origin 2>/dev/null; then
    m="Reprise de session : git fetch a échoué (réseau ou accès). Impossible de vérifier si le dépôt en ligne a changé : le vérifier à la main (git fetch origin main) avant de lire ou de modifier quoi que ce soit."
    emettre "$m" "$m"
    exit 0
fi

alertes=""
infos=""
ajouter_alerte() { alertes="${alertes}${alertes:+ ; }$1"; }

# Branches suivies : main (publiée par GitHub Pages) et la branche de travail, si elle existe en ligne.
refs="origin/main"
if [ -n "$BRANCHE" ] && [ "$BRANCHE" != "HEAD" ] && [ "$BRANCHE" != "main" ] \
   && git rev-parse --verify --quiet "refs/remotes/origin/$BRANCHE" >/dev/null; then
    refs="$refs origin/$BRANCHE"
fi

premier=1
[ -f "$REPERE" ] && premier=0
nouveau_repere=""
for ref in $refs; do
    sha="$(git rev-parse --verify --quiet "$ref" 2>/dev/null)" || continue
    court="$(git rev-parse --short "$sha")"
    infos="${infos}${infos:+, }$ref = $court"
    nouveau_repere="${nouveau_repere}${ref} ${sha}
"
    ancien=""
    [ -f "$REPERE" ] && ancien="$(awk -v r="$ref" '$1 == r { print $2 }' "$REPERE")"
    if git merge-base --is-ancestor "$sha" HEAD 2>/dev/null; then
        # Tout ce qui est en ligne est déjà dans la copie de travail (par exemple nos propres envois) : pas d'alerte.
        if [ -n "$ancien" ] && [ "$ancien" != "$sha" ]; then
            infos="${infos} (a avancé depuis la dernière session, commits déjà présents dans la copie)"
        fi
    else
        # Commits en ligne absents de la copie de travail : cas d'un dépôt fait hors session.
        n="$(git rev-list --count "HEAD..$sha" 2>/dev/null || echo '?')"
        if [ -n "$ancien" ] && [ "$ancien" != "$sha" ]; then
            ajouter_alerte "$ref a changé depuis la dernière session ($(git rev-parse --short "$ancien" 2>/dev/null || echo "$ancien") vers $court) et contient $n commit(s) absent(s) de la copie de travail"
        else
            ajouter_alerte "$ref contient $n commit(s) absent(s) de la copie de travail"
        fi
    fi
done

printf '%s' "$nouveau_repere" > "$REPERE" 2>/dev/null

if [ -n "$alertes" ]; then
    m="ALERTE reprise de session : $alertes. Le dire à Christophe avant toute autre chose et lui proposer de mettre à jour la branche de travail avant de lire ou de modifier quoi que ce soit (règle de reprise de CLAUDE.md)."
    emettre "$m" "$m (état en ligne : $infos)"
elif [ "$premier" = 1 ]; then
    emettre "" "Reprise de session : premier passage sur cette copie, repère enregistré ; copie de travail à jour ($infos)."
else
    emettre "" "Reprise de session : rien de nouveau en ligne depuis la dernière session, copie de travail à jour ($infos)."
fi
exit 0
