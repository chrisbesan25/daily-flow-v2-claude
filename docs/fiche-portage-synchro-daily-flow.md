# Fiche de portage : synchronisation GitHub validée sur Budget perso

**Établie le 22 septembre 2026, à reprendre dans le projet Daily Flow.**

## Objet

Cette fiche transmet au projet Daily Flow la logique de synchronisation corrigée et validée le 22 septembre 2026 sur l'app Budget perso. Elle ne présume rien du code de Daily Flow : la première étape du portage est de lire ce code et de vérifier que le symptôme a les mêmes causes.

Architecture de Budget perso, pour comparaison : fichier HTML unique hébergé sur GitHub Pages (dépôt public), données dans un fichier JSON d'un dépôt privé, lu et écrit par l'API GitHub (point d'accès contents), avec un code d'accès fine-grained collé une fois par appareil et stocké dans le navigateur, jamais dans le fichier.

## Symptôme commun

Des modifications faites puis sauvegardées sur un appareil n'apparaissaient pas sur l'autre. Christophe observe le même symptôme sur Daily Flow. C'est une hypothèse de cause commune, pas un constat.

## Causes identifiées sur Budget perso (reproduites en simulation)

1. **Synchro au seul chargement de la page.** Un téléphone reprend une app laissée en arrière-plan sans la recharger : l'appareil affiche donc une version périmée.
2. **Écrasement silencieux.** Quand GitHub refusait un envoi (code 409, fichier modifié ailleurs), l'app relisait la version en ligne, l'ignorait, puis renvoyait la sienne par-dessus. La modification de l'autre appareil était effacée sans message.
3. **Modifications non sauvegardées perdues.** Au démarrage, la version en ligne remplaçait la copie locale sans vérifier si celle-ci contenait des changements non envoyés.
4. **État trompeur.** Sans réseau au démarrage, le bandeau affichait « Connecté ».
5. **Code d'accès effacé à tort.** Une réponse 403 due à une limite de débit passagère était traitée comme un code refusé.

## Points à vérifier dans le code de Daily Flow avant tout portage

- À quel moment l'app lit-elle le fichier en ligne : seulement au chargement, ou aussi au retour au premier plan (événement visibilitychange) et au retour du réseau (événement online) ?
- Que fait-elle quand GitHub répond 409 ? Si elle relit puis renvoie sans comparer, c'est la cause 2.
- Mémorise-t-elle de façon durable (stockage du navigateur) la version en ligne de sa dernière synchro (le « sha » du fichier) ?
- Au démarrage, écrase-t-elle la copie locale sans tester la présence de modifications non envoyées ?
- Que signifie exactement son indicateur de connexion en cas d'échec réseau ?
- Comment traite-t-elle une réponse 403 ?

## Logique validée

**Quatre règles.**

1. Chaque modification est gardée sur l'appareil puis envoyée automatiquement environ 3 secondes après la dernière saisie ; un bouton permet l'envoi immédiat.
2. L'appareil mémorise la version en ligne de sa dernière synchro réussie (sa « base » : sha et contenu). Il ne remplace jamais en silence une version en ligne plus récente que sa base.
3. La synchro se relance à l'ouverture, au retour au premier plan, au retour du réseau et au retour d'une page restaurée depuis le cache du navigateur.
4. Si les données ont changé des deux côtés, l'utilisateur choisit la version à garder (version entière, pas de fusion).

**Décision de synchro, après lecture de la version en ligne.**

| Version en ligne changée depuis la base ? | Modifications locales non envoyées ? | Action |
|---|---|---|
| Non | Non | Rien, état « synchronisé » |
| Non | Oui | Envoi avec le sha de la base |
| Oui | Non | Reprise de la version en ligne |
| Oui | Oui | Si les contenus sont identiques : rien. Sinon : question à l'utilisateur |

**Détails qui ont compté.**

- **Modifications locales.** On les détecte en comparant le contenu actuel au contenu de la base, pas avec un simple drapeau. Ainsi une modification annulée ne déclenche pas d'envoi. Un appareil qui n'a jamais synchronisé est considéré comme modifié s'il possède une copie locale.
- **Contenu en cours d'envoi.** Il est mémorisé avant chaque envoi. Si la réponse de GitHub se perd (mise en veille), la synchro suivante reconnaît son propre envoi et ne signale pas de faux conflit.
- **Envoi à la mise en arrière-plan.** Il part en une seule requête, avec l'option keepalive et le sha de la base, sans relecture préalable. Si GitHub refuse, le cas est traité au retour au premier plan.
- **Synchros en file d'attente.** Elles sont exécutées l'une après l'autre, jamais en parallèle.
- **Envoi refusé par un 409 ou un 422.** Une nouvelle synchro complète est lancée une fois, après une courte pause.
- **Réponse 403.** Elle n'efface le code d'accès que si ce n'est pas une limite de débit (en-têtes x-ratelimit-remaining à 0 ou retry-after présent).
- **Bandeau d'état.** Il affiche l'état réel : synchronisé avec l'heure, envoi en cours, modifications en attente, hors connexion avec l'heure de la dernière synchro, code d'accès requis.
- **Normalisation des données.** La même fonction s'applique à la copie locale et à la version en ligne avant toute comparaison, faute de quoi des différences de forme passent pour des conflits.

**Clés de stockage utilisées par Budget perso**, à renommer pour Daily Flow afin que les deux apps ne se mélangent pas si elles partagent la même adresse github.io : copie locale, sha de base, contenu de base, contenu en cours d'envoi, date de dernière synchro, code d'accès. Point important : toutes les apps publiées sous le même compte GitHub Pages partagent le même stockage de navigateur, puisqu'il est rangé par site et non par dépôt.

## Implémentation de référence

Fichier index.html du dépôt public chrisbesan25/Budget, section intitulée « GITHUB (stockage privé) », et section « INIT » pour les écouteurs d'événements :
https://raw.githubusercontent.com/chrisbesan25/Budget/main/index.html

Fonctions à reprendre : ghGet, ghPut, ghFail, syncNow, doSync, push, adopt, markSynced, syncFailed, scheduleAutoSend, flushOnHide, showStatus, save, boot. La fonction normalizeData est propre aux données de Budget perso et doit être réécrite pour celles de Daily Flow.

## Banc d'essai à reproduire

Le serveur GitHub simulé doit vérifier réellement le sha à chaque envoi et répondre 409 en cas d'écart. Un serveur simulé qui accepte tout masque le défaut principal.

Scénarios validés sur Budget perso :
- acquis fonctionnels, et un seul envoi pour une séance de saisie lettre par lettre ;
- deux appareils ouverts en même temps : reprise au retour au premier plan, aucune perte ;
- vrai conflit, avec les deux réponses possibles ;
- modifications hors ligne, puis réouverture en ligne ;
- mise en veille juste après une saisie, y compris avec une réponse perdue ;
- appareil neuf ;
- passage depuis l'ancienne version ;
- code refusé et limite de débit.

Pour simuler une coupure réseau avec Playwright, il faut faire échouer la requête dans la fonction d'interception : le mode hors ligne du navigateur ne bloque pas les requêtes interceptées.

Validation finale sur Budget perso : tests réels sur deux appareils par Christophe, le 22 septembre 2026, tous concluants.

## Limites

- La logique n'a pas été testée sur le code de Daily Flow, que je n'ai pas lu.
- Le comportement de l'envoi à la mise en veille dépend du navigateur, en particulier sur iPhone. Son échec n'entraîne pas de perte, l'envoi partant au retour.
- En cas de conflit, le choix porte sur une version entière.

*Rédigé avec Claude Opus 5, le 22 septembre 2026.*
