# Complément à la fiche de portage : plusieurs onglets et relecture automatique

**Établi le 23 septembre 2026, à déposer dans le projet Daily Flow à côté de la fiche « fiche-portage-synchro-daily-flow » du 22 septembre 2026.**

Les deux documents se lisent ensemble. En cas de contradiction, celui-ci prévaut : il est plus récent et corrige une lacune du premier.

## Pourquoi ce complément existe

Le 22 septembre 2026, la synchronisation de Budget perso a été corrigée et validée. La logique retenue a été transmise au projet Daily Flow par une première fiche de portage.

Le 23 septembre, alors que le travail avait commencé dans le projet Daily Flow, Christophe a observé sur Budget perso deux symptômes que cette logique ne couvrait pas. Il est revenu dans le fil de travail de Budget perso, où Claude a :
- mené un diagnostic ;
- trouvé un défaut plus grave que les symptômes ne le laissaient paraître ;
- corrigé l'app en quatre blocs, testés un par un.

Christophe a ensuite validé la correction en conditions réelles le jour même.

La première fiche est donc incomplète sur un point essentiel : elle ne traite pas le cas de plusieurs onglets ouverts sur le même appareil. Si Daily Flow applique cette fiche telle quelle, il hérite probablement du même défaut. Ce complément explique ce qui a été trouvé, ce qui a été changé et ce qu'il faut faire dans Daily Flow.

## Les deux symptômes observés le 23 septembre

**Premier symptôme.** Une modification faite sur le téléphone n'apparaissait pas sur le PC tant qu'on ne rechargeait pas la page.

**Second symptôme.** Avec deux onglets Budget ouverts sur le téléphone, une modification faite dans l'un n'apparaissait dans l'autre qu'après rechargement.

## Ce que le diagnostic a trouvé

### Le retard du PC : un déclencheur manquant

La version du 22 septembre ne relisait GitHub qu'à cinq occasions :
- l'ouverture de la page ;
- le retour de visibilité (événement visibilitychange) ;
- la restauration depuis le cache de navigation ;
- le retour du réseau ;
- juste avant chaque envoi.

Or sur ordinateur, passer d'une autre fenêtre au navigateur ne déclenche pas forcément visibilitychange, puisque la page n'a jamais cessé d'être visible. Le PC restait donc sur une version ancienne, sans faire la moindre requête : le banc d'essai l'a montré sur 8 secondes d'observation.

Ce retard n'entraînait pas de perte entre deux appareils. Si l'on modifiait ensuite le PC resté en retard, la comparaison des versions déclenchait la question de conflit prévue par la première fiche.

Le cache du navigateur n'était pas en cause : lecture et écriture utilisent le mode `no-store`, qui interroge toujours le serveur.

### Les onglets : un défaut de perte silencieuse, plus grave que le symptôme

La logique de la première fiche repose sur une « base » : la version en ligne de la dernière synchro réussie, mémorisée dans le stockage du navigateur. Ce stockage est partagé par tous les onglets du même site. En revanche, les données affichées vivent dans la mémoire de chaque onglet, et la copie locale n'était relue qu'à l'ouverture de la page.

Voici ce qui se passait :
1. L'onglet B envoie une modification, et la base partagée avance.
2. L'onglet A, resté avec ses anciennes données en mémoire, les compare à cette nouvelle base.
3. Il conclut à tort qu'il a des modifications à envoyer, et renvoie ses anciennes données par-dessus celles de B.

Le banc d'essai l'a reproduit dans trois variantes, avec perte de la modification de B sur GitHub à chaque fois et sans aucune question :
- **B a fini son envoi, puis on revient dans A.** Il suffit de revenir dans A, sans rien y toucher, pour déclencher l'écrasement.
- **B envoie à sa mise en arrière-plan, puis retour immédiat dans A.** Même écrasement.
- **Deux fenêtres visibles côte à côte**, sans aucun événement. La première modification faite dans A efface celle de B.

Le symptôme perçu (« l'autre onglet ne se met pas à jour ») masquait donc un défaut plus grave : l'onglet en retard réécrivait GitHub.

## Pourquoi Daily Flow est probablement concerné

La première fiche décrivait une logique pensée pour plusieurs appareils, pas pour plusieurs onglets. Toute app qui l'applique sans y ajouter la gestion des onglets reproduit ce défaut dès que deux onglets sont ouverts.

**Budget et Daily Flow partagent le même stockage de navigateur.** Les deux apps sont publiées sous la même adresse, chrisbesan25.github.io, et le navigateur range son stockage par site, pas par dépôt. Deux conséquences :
- **Des clés distinctes.** Les noms de clés de Daily Flow doivent être distincts de ceux de Budget, qui commencent tous par `budget-`.
- **Un filtre sur les clés exactes.** Un onglet Budget reçoit les notifications de modification du stockage faites par Daily Flow, et inversement. Chaque app doit donc filtrer ces notifications sur ses propres clés exactes.

## Les corrections apportées à Budget perso, en quatre blocs

### Bloc 1 : un onglet ne travaille jamais sur des données plus anciennes que la copie partagée

C'est le bloc qui supprime la perte. Chaque onglet retient la version exacte de la copie locale qu'il a lue ou écrite en dernier.

- **Avant toute synchro et à chaque retour** (visibilité, focus, restauration), il vérifie si un autre onglet a modifié la copie locale depuis. Si oui, il la reprend et se réaffiche avant de faire quoi que ce soit d'autre.
- **À l'enregistrement.** Si un autre onglet a écrit entre-temps, l'app pose la question au lieu d'écraser : OK pour garder la version de l'autre onglet, Annuler pour garder celle-ci.
- **À la mise en arrière-plan.** L'envoi immédiat est annulé si un autre onglet a écrit plus récemment.

### Bloc 2 : les onglets se préviennent entre eux

L'app écoute l'événement `storage`, que le navigateur envoie à tous les autres onglets du même site quand l'un d'eux modifie le stockage. Il n'est jamais reçu par l'onglet qui a fait la modification. À réception, l'onglet reprend la copie locale et se réaffiche. Le filtre porte sur la clé exacte de la copie locale ; les clés d'état (code d'accès, base, heure de synchro) ne font que rafraîchir le bandeau.

Ce bloc rend le cas des deux fenêtres côte à côte fluide, sans question. Il ne suffit pas seul : un onglet gelé par le téléphone peut ne pas recevoir l'événement. C'est pourquoi le bloc 1 reste la vraie protection.

### Bloc 3 : relecture au retour du focus de la fenêtre

L'événement `focus` de la fenêtre déclenche une relecture, en plus de la visibilité. Comme les deux arrivent souvent ensemble, une seule relecture est faite par tranche de 2 secondes.

### Bloc 4 : relecture périodique légère

Toutes les 30 secondes, tant que la page est visible, l'app relit GitHub en requête conditionnelle : elle renvoie l'empreinte (ETag) de sa dernière lecture complète dans l'en-tête `If-None-Match`. Si rien n'a changé, GitHub répond 304 sans contenu. Selon la documentation GitHub, une telle réponse ne consomme pas le quota principal quand la requête est authentifiée.

Le reste du fonctionnement :
- La relecture est silencieuse dans le bandeau, qui ne montre que l'heure de dernière synchro.
- Elle s'arrête quand la page passe en arrière-plan, et elle est sautée pendant une saisie.
- Elle respecte l'en-tête `X-Poll-Interval` si GitHub en envoie un.
- Il a été vérifié que l'API GitHub accepte l'en-tête `If-None-Match` envoyé depuis une page web et rend l'ETag lisible par le script.

### Une subtilité découverte en cours de route : un curseur posé n'est pas une saisie

La première version du bloc 2 considérait qu'un onglet était « en saisie » dès que le curseur était dans un champ, et reportait alors la reprise. Or sur ordinateur, le curseur reste souvent posé dans un champ sans qu'on tape : l'onglet ne se mettait plus jamais à jour.

La définition retenue est plus précise : une saisie est en cours seulement si un champ a été tapé et pas encore validé (événement `input` reçu, pas encore d'événement `change` ni de sortie du champ). Seul ce cas retarde une reprise ou une relecture, pour ne jamais réafficher sous les doigts de l'utilisateur.

## Résultats

**Banc d'essai.** Tous les scénarios passent :
- les trois variantes de perte entre onglets ;
- l'onglet gelé qui ne reçoit jamais l'événement : mis à jour au retour, question posée s'il est modifié directement ;
- la saisie en cours qui n'est pas réaffichée ;
- la clé d'une autre app du même site, sans effet ;
- une minute de relectures sans changement, qui ne produit que des réponses 304 et aucun envoi ;
- l'onglet caché, qui ne fait aucune requête.

Tous les scénarios du 22 septembre repassent aussi : acquis, deux appareils, vrai conflit, hors ligne, mise en veille, appareil neuf, passage depuis l'ancienne version, erreurs d'accès.

**Validation réelle par Christophe, le 23 septembre 2026.**
- Une modification faite sur le téléphone apparaît sur le PC en 7 à 8 secondes, sans toucher au PC.
- Elle apparaît immédiatement en revenant d'une autre fenêtre vers le navigateur.
- Deux onglets sur le téléphone restent à jour l'un par rapport à l'autre.

## Ce que je préconise pour Daily Flow, dans l'ordre

1. **Tant que la correction n'est pas faite, un seul onglet Daily Flow ouvert par appareil.** C'est la seule précaution qui écarte le risque de perte sans toucher au code.
2. **Commencer par le diagnostic, sur le code réel de Daily Flow.** Poser ces questions au code :
   - Les données affichées sont-elles gardées en mémoire après l'ouverture ?
   - La base ou tout autre repère de version est-il partagé par les onglets ?
   - Existe-t-il une relecture au retour du focus, une relecture périodique, un écouteur `storage` ?
3. **Reproduire le test de perte avant toute correction** : deux onglets, modification dans B, retour dans A, modification dans A, puis vérifier que la modification de B survit sur GitHub. S'il échoue, le défaut est confirmé.
4. **Porter les blocs dans l'ordre : 1, puis 2, 3 et 4.** Le bloc 1 supprime la perte ; les suivants apportent le confort. Tester après chaque bloc.
5. **Nommer les clés de stockage de Daily Flow avec un préfixe qui lui est propre**, jamais `budget-`, et filtrer l'écouteur `storage` sur ces clés exactes.

## Pièges à ne pas refaire au banc d'essai

- **Une vraie adresse http.** Pour tester deux onglets, il faut servir la page sur une vraie adresse, par exemple `http://localhost`, et ouvrir les deux pages dans le même contexte de navigateur. Sinon le stockage n'est pas partagé comme sur un vrai appareil.
- **Un serveur simulé qui vérifie les versions.** Il doit vérifier réellement le sha à chaque envoi et répondre 409 en cas d'écart. Pour le bloc 4, il doit aussi gérer l'ETag et répondre 304.
- **Simuler un onglet gelé.** Il faut empêcher l'onglet d'enregistrer son écouteur `storage`, par un script injecté avant le chargement de la page. Bloquer l'événement après coup ne fonctionne pas de façon fiable.
- **Les fenêtres fermées d'office.** Playwright ferme d'office les fenêtres de confirmation en répondant Annuler. Un test qui modifie réellement les deux côtés déclenche un vrai conflit, et le résultat reflète cette réponse implicite, pas un défaut. Il faut donc intercepter les fenêtres et choisir la réponse explicitement.
- **Le mode hors ligne de Playwright** ne bloque pas les requêtes interceptées (déjà signalé dans la première fiche).

## Implémentation de référence

Fichier index.html du dépôt public chrisbesan25/Budget, version en ligne depuis le 23 septembre 2026 :
https://raw.githubusercontent.com/chrisbesan25/Budget/main/index.html

Éléments ajoutés à reprendre, en plus de ceux de la première fiche :
- **Mémoire de l'onglet** : `tabLocal`, `pendingAdopt`.
- **Détection de la saisie en cours** : `fieldTyping` et les écouteurs `input`, `change` et `focusout`.
- **Reprise de la copie locale** : `isEditing`, `localChangedElsewhere`, `syncFromLocal`, `refreshFromLocal`.
- **Garde-fous** dans `save`, `saveToGitHub`, `flushOnHide` et au début de `doSync`.
- **Écoute entre onglets** : l'écouteur `storage`.
- **Retour sur l'app** : `checkOnReturn`, avec l'écouteur `focus`.
- **Relecture périodique** : `schedulePoll`, `ghGet(etag)` et la constante `POLL_INTERVAL`.

## Métadonnées de fin

**Recommandations hiérarchisées**

- **Priorité 1 : un seul onglet Daily Flow par appareil jusqu'à correction.** Justification : c'est le seul moyen immédiat d'écarter une perte silencieuse. Risque : un oubli suffit à la provoquer.
- **Priorité 1 : diagnostic et test de perte sur le code de Daily Flow avant tout portage.** Justification : le défaut n'est que probable tant que ce code n'a pas été lu. Risque : porter une correction inutile ou mal adaptée.
- **Priorité 2 : porter le bloc 1, puis tester.** Justification : c'est lui qui supprime la perte. Risque : une saisie abandonnée si l'utilisateur répond OK à la question lors d'une modification simultanée dans deux onglets. C'est un cas rare et assumé.
- **Priorité 3 : porter les blocs 2, 3 et 4.** Justification : confort et réactivité. Risque : davantage de requêtes, mais la documentation GitHub indique que les réponses 304 authentifiées ne consomment pas le quota principal.

**Hypothèses clés**

- Daily Flow applique la logique de la première fiche, ou une logique proche, sans gestion des onglets.
- Daily Flow est publié sous chrisbesan25.github.io et partage donc le stockage de Budget.
- Le comportement réel de GitHub pour les réponses 304 est conforme à sa documentation. Il n'a pas pu être observé directement : la bonne réactivité constatée par Christophe prouve que la relecture fonctionne, pas que les réponses sont des 304.

**Sources structurantes**

- MDN, « Window: storage event », consulté le 23 septembre 2026 : https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event
- MDN, « Request: cache property », consulté le 23 septembre 2026 : https://developer.mozilla.org/en-US/docs/Web/API/Request/cache
- GitHub Docs, « Best practices for using the REST API » (version d'API du 10 mars 2026), consulté le 23 septembre 2026 : https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api

**Limites**

- Le code de Daily Flow n'a pas été lu : tout ce qui le concerne ici est à vérifier.
- Le comportement d'un onglet gelé par un téléphone réel et celui de Safari sur iPhone n'ont pas été testés.
- En cas de conflit, le choix porte sur une version entière, sans fusion ligne par ligne.

**Modèle utilisé** : Claude Opus 5, le 23 septembre 2026.
