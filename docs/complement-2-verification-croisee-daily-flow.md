# Second complément : vérification croisée Budget / Daily Flow du 24 septembre 2026

**Établi le 24 septembre 2026, à déposer dans le projet Daily Flow avec les deux documents précédents :**
- la fiche de portage du 22 septembre 2026 (« fiche-portage-synchro-daily-flow ») ;
- le complément du 23 septembre 2026 (« complement-fiche-synchro-onglets-daily-flow »).

Les trois se lisent ensemble. En cas de contradiction, le plus récent prévaut.

## Pourquoi ce second complément existe

Le 24 septembre, dans le projet Daily Flow, un défaut de perte silencieuse entre onglets a été trouvé puis corrigé. La copie locale et la base (la version en ligne de référence) y étaient rangées dans des clés séparées du stockage du navigateur. Voici comment la perte se produisait :
1. Un onglet en retard écrivait sa copie périmée.
2. Un autre onglet réécrivait ensuite sa base récente, si bien que le stockage mêlait la copie de l'un et la base de l'autre.
3. Un troisième onglet ouvert à ce moment prenait l'écart pour une modification locale et l'envoyait par-dessus la version en ligne, sans question.

La correction retenue dans Daily Flow : tout l'état local dans une seule clé, écrite d'un seul coup.

Budget perso rangeant lui aussi ses données en plusieurs clés, Christophe est revenu dans le fil de Budget pour faire vérifier ce point. Il a demandé un diagnostic avant toute correction, puis validé quatre corrections. Ce document rend compte de ce travail et en tire ce qui concerne Daily Flow en retour. Point important : **la vérification a mis au jour un second chemin de perte que la clé unique ne ferme pas à elle seule.**

## Ce que la vérification a trouvé sur Budget

### Les écritures séparées existaient bien

Budget rangeait son état dans quatre clés : la copie locale, le sha de base, le contenu de base, l'envoi en cours. L'inventaire du code a montré ceci :
- La base était écrite **sans la copie** à quatre endroits : au retour d'un envoi réussi, au retour de l'envoi fait à la mise en arrière-plan, quand l'app reconnaissait un envoi dont la réponse s'était perdue, et quand les deux côtés avaient changé mais contenaient les mêmes données.
- La copie était écrite **sans la base** à deux endroits : l'enregistrement d'une saisie et le bouton Sauvegarder.
- La seule opération qui écrivait les deux, la reprise d'une version en ligne, le faisait en quatre écritures successives.

La structure était donc la même que celle de Daily Flow avant sa correction.

### Le scénario de Daily Flow ne produisait pas de perte silencieuse sur Budget

Il a été testé à l'identique :
- un serveur GitHub simulé qui vérifie le sha à chaque envoi ;
- deux onglets sur la même adresse http://localhost, dans le même navigateur ;
- l'onglet A « gelé », c'est-à-dire privé de l'événement storage par un script injecté avant le chargement ;
- l'onglet B qui modifie et envoie, puis A qui modifie et enregistre ;
- les fenêtres de confirmation interceptées et les réponses choisies explicitement.

**La question apparaissait dans A dans tous les cas**, grâce au garde-fou ajouté le 23 septembre : avant d'enregistrer, l'onglet vérifie que la copie partagée n'a pas été modifiée par un autre onglet.

- **Réponse « garder l'autre onglet ».** La modification de B survit.
- **Réponse « garder cet onglet ».** Le stockage se retrouve dans l'état exact décrit sur Daily Flow : copie de A, base de B. Un troisième onglet ouvert à ce moment envoie la copie de A sans question, et la modification de B disparaît.

Ce dernier résultat est celui qu'aurait produit l'envoi de A lui-même, donc il est conforme au choix exprimé. En revanche, la question de l'époque ne disait pas clairement que ce choix effaçait le travail fait dans l'autre onglet.

### Un second chemin de perte : la réponse tardive

En relisant le code, un autre enchaînement est apparu. Le banc l'a confirmé, et la clé unique ne le ferme pas à elle seule :
1. L'onglet A interroge GitHub, mais la réponse tarde.
2. Pendant ce temps, l'onglet B reprend la version en ligne, modifie une donnée et l'envoie.
3. La réponse de A arrive enfin, avec le contenu d'avant l'envoi de B. A la prend pour une nouveauté et la reprend : la copie et la base repartent ensemble en arrière.

L'état obtenu est cohérent, mais il est ancien. Sans saisie pendant ce temps, la situation se corrigeait à la synchro suivante.

Avec une saisie pendant ce temps, une question de conflit apparaissait, et elle trompait l'utilisateur. Elle présentait la version en ligne comme venant d'ailleurs, alors qu'elle contenait sa propre modification faite une minute plus tôt. Au banc, la réponse « garder cet appareil » a effacé cette modification de GitHub.

**Avec une clé unique, une réponse tardive écrit un état ancien, mais cohérent, donc parfaitement plausible : la clé unique ne la détecte pas.**

### Une gêne mineure

Une reprise différée, exécutée au moment où l'on quittait un champ, pouvait réafficher la liste pendant que l'on touchait le champ suivant. Le premier appui était alors perdu.

## Les corrections apportées à Budget (validées le 24 septembre)

### Bloc 1 : tout l'état dans une seule clé, écrite d'un seul coup

Clé `budget-etat` : `{ local, baseSha, baseJson, inflight }`.
- **Lecture.** Une fonction `readState()` lit la clé.
- **Écriture.** Une fonction `writeState(changements)` relit l'état, applique les changements et réécrit le tout en une seule écriture.
- **Reprise d'une version en ligne.** Elle écrit copie et base ensemble.
- **Heure de dernière synchro et code d'accès.** Ils restent dans des clés à part : purement informatifs, ils n'ont pas à être cohérents avec le reste.
- **Migration.** Au premier lancement, `migrateState()` lit une fois les anciennes clés, écrit la nouvelle, puis supprime les anciennes.

### Bloc 2 : rejet des réponses tardives

Avant chaque lecture de GitHub, l'app note le sha de base. Au retour de la réponse, elle vérifie deux choses :
- le sha de base a-t-il changé, parce qu'un autre onglet a synchronisé ?
- la copie partagée a-t-elle changé, parce qu'un autre onglet a enregistré ?

Dans les deux cas, la réponse est jetée et la lecture recommence, deux fois au plus. Une réponse 304 (rien n'a changé en ligne) n'est pas concernée.

### Bloc 3 : des questions qui disent ce qui sera perdu

- **Entre onglets.** « Un autre onglet de Budget a modifié les données pendant ta saisie. OK = garder la version de l'autre onglet : ta dernière saisie ici est perdue. Annuler = garder cet onglet : ta saisie est conservée, mais les modifications faites dans l'autre onglet depuis ton dernier affichage ici sont perdues. »
- **Entre appareils.** Même principe : chaque réponse précise ce qu'elle fait perdre.

### Bloc 4 : pas de réaffichage sous un champ qu'on vient de toucher

Une saisie est considérée en cours dans deux cas :
- un champ a été tapé et pas encore validé (règle du 23 septembre) ;
- un champ a reçu le focus il y a moins de 3 secondes.

Pendant ce temps, aucune reprise ni relecture ne réaffiche la page. Une reprise en attente est revérifiée chaque seconde et s'applique dès que la saisie est terminée.

## Résultats

**Banc d'essai : 21 scénarios sur 21**, plus la relecture périodique par requêtes conditionnelles. Sont couverts :
- tous les scénarios des 22 et 23 septembre, y compris la migration depuis une copie ancienne ;
- le scénario de Daily Flow, avec les deux réponses ;
- la réponse tardive, désormais rejetée : aucune question trompeuse, rien de perdu ;
- le champ touché qui reste en place, et les frappes enchaînées d'un champ à l'autre qui arrivent toutes au bon endroit.

**Validation réelle par Christophe, le 24 septembre 2026.**
- Une modification sur le téléphone apparaît sur le PC environ 10 secondes après, sans toucher au PC.
- Deux onglets sur le téléphone restent à jour.

## Ce que je préconise pour Daily Flow

1. **Vérifier si Daily Flow rejette les réponses tardives.** Sa clé unique empêche le mélange copie/base, mais pas la reprise d'une réponse ancienne. Test à reproduire :
   - retenir la réponse GitHub d'un onglet ;
   - laisser un autre onglet synchroniser, modifier et envoyer ;
   - libérer la réponse retenue ;
   - vérifier que rien ne recule dans le stockage ni sur GitHub.

   S'il échoue, porter le bloc 2.
2. **Vérifier la formulation des questions** de conflit et, si besoin, reprendre celles du bloc 3.
3. **Vérifier le comportement quand on touche un champ** pendant qu'un autre onglet écrit. Si le champ disparaît sous le doigt, porter le bloc 4.
4. **Au déploiement d'une version qui change les clés de stockage, fermer tous les onglets sauf un sur chaque appareil.** Un onglet resté sur l'ancienne version continuerait d'écrire dans des clés que la nouvelle ignore.

## Techniques de banc ajoutées

- **Réponse tardive.** Dans la fonction d'interception, on garde la requête sans y répondre, avec une copie du contenu du serveur à cet instant. On la libère plus tard avec ce contenu.
- **Frappe au clavier.** Pour taper dans un champ déjà rempli, tout sélectionner avant de taper. Sinon les chiffres s'ajoutent à la valeur existante, ce qui ressemble à tort à une frappe mal dirigée.
- **Onglet gelé.** Il faut empêcher l'enregistrement de l'écouteur storage par un script injecté avant le chargement, comme l'indiquait déjà le complément du 23 septembre.

## Implémentation de référence

Fichier index.html du dépôt public chrisbesan25/Budget, version en ligne depuis le 24 septembre 2026 :
https://raw.githubusercontent.com/chrisbesan25/Budget/main/index.html

Éléments à reprendre :
- **État et migration** : `K_STATE`, `readState`, `writeState`, `migrateState`, `setBase(sha, json, extra)`.
- **Réponse tardive** : le repère `shaAvant` et le rejet de la réponse au début de `doSync`.
- **Saisie en cours** : `FOCUS_GRACE`, `isEditing`, `schedulePending`.
- **Questions de conflit** : les textes dans `save` et `doSync`.

## Métadonnées de fin

**Recommandations hiérarchisées**

- **Priorité 1 : tester la réponse tardive sur Daily Flow.** Justification : c'est le seul chemin de perte connu que sa correction du 24 septembre ne couvre pas. Risque : il se produit rarement, donc il peut passer inaperçu longtemps en usage réel.
- **Priorité 2 : aligner les questions de conflit.** Justification : une réponse donnée sans comprendre ce qu'elle efface équivaut à une perte. Risque : faible, le changement ne touche que des textes.
- **Priorité 3 : porter le délai de grâce du focus si le test le justifie.** Justification : confort de saisie. Risque : un réaffichage retardé de quelques secondes après un simple appui.

**Hypothèses clés**

- Daily Flow utilise la même logique de synchronisation que Budget, complétée de sa propre clé unique.
- Daily Flow est publié sous chrisbesan25.github.io et partage donc le stockage du navigateur avec Budget. Leurs clés doivent rester distinctes : celle de Budget est désormais `budget-etat`.
- Le vrai GitHub se comporte comme le serveur simulé pour les refus d'envoi (409) et les réponses 304.

**Sources structurantes**

- MDN, « Window: storage event », consulté le 23 septembre 2026 : https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event
- MDN, « Request: cache property », consulté le 23 septembre 2026 : https://developer.mozilla.org/en-US/docs/Web/API/Request/cache
- GitHub Docs, « Best practices for using the REST API » (version d'API du 10 mars 2026), consulté le 23 septembre 2026 : https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api

**Limites**

- Le code de Daily Flow n'a pas été lu dans ce fil : tout ce qui le concerne est à vérifier sur place.
- L'app n'utilise aucun verrou entre onglets. Chaque écriture de la clé unique est complète, mais une séquence « lire puis écrire » de deux onglets pourrait en théorie se croiser. La fenêtre est de l'ordre de la microseconde.
- L'iPhone et le gel réel d'un onglet par un téléphone n'ont pas été testés.

**Modèle utilisé** : Claude Opus 5, le 24 septembre 2026.
