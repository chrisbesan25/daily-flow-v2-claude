# Daily Flow : consignes pour Claude Code

Établi le 24 septembre 2026, mis à jour le 20 octobre 2026 (démarrage hors connexion). Ce fichier est lu au début de chaque session. Il résume l'état réel de l'app et la méthode de travail de Christophe. En cas de doute sur le fonctionnement de Daily Flow, ce fichier et le code font foi. Les fiches du dossier docs décrivent la logique de Budget perso et les leçons tirées pour Daily Flow.

## Méthode de travail (obligatoire)

- Répondre en français, en tutoyant, en commençant par « Christophe ».
- Avant une analyse ou une modification importante : reformuler la demande en quelques puces et attendre la validation.
- Diagnostic d'abord, sur le code réel. Aucun code avant validation explicite.
- Travailler bloc par bloc : sauvegarde avant modification, contrôle de syntaxe et test après chaque bloc.
- Banc d'essai avec un serveur simulé qui vérifie réellement les versions. Un serveur qui accepte tout masque les défauts.
- Livrer par une demande de fusion (pull request), jamais par une fusion directe. Christophe relit et décide.
- Toute interface nouvelle : maquette validée avant le code. La charte graphique de l'app est figée. La charte des livrables de Christophe ne s'applique pas à l'app.
- Contrôle de contraste de tout nouveau texte sur fond coloré, dans les neuf ambiances (seuil 4,5 pour un texte courant, 3 pour un texte large, critère 1.4.3 de la WCAG, niveau AA).
- Aucun tiret cadratin : rechercher et éliminer les caractères U+2014, U+2013 et U+2212 avant livraison, y compris dans les commentaires.
- Tests réels guidés pas à pas sur les deux appareils de Christophe (PC et téléphone Android), avec vérification dans les journaux Supabase quand c'est possible.
- Ne jamais présenter comme vérifié ce qui ne l'a pas été. Signaler les limites.
- Dépôt modifié en dehors de la session : au début de chaque nouvelle demande de Christophe, lancer `git fetch origin main` et comparer avec la version sur laquelle la session travaille. Si main a avancé (par exemple un fichier déposé par Christophe sur GitHub), le dire avant toute autre chose, et proposer de mettre à jour la branche de travail avant de lire ou de modifier quoi que ce soit. Une session travaille sur la copie faite à son ouverture : sans cette vérification, elle lit des fichiers périmés.

## L'app

- Un fichier index.html, publié par GitHub Pages sous chrisbesan25.github.io/daily-flow-v2-claude/ (toujours avec la barre finale). Le dépôt est public.
- Seule exception à la règle du fichier unique (20 octobre 2026) : sw.js, le service worker du démarrage hors connexion. docs/sw-arret.js est sa version d'arrêt de secours.
- Données dans Supabase (projet daily-flow-v2-claude) : tables tasks, prefs et notes (notes inutilisée).
- Connexion par compte Supabase (e-mail et mot de passe), inscriptions fermées. La clé publishable est dans le fichier : elle est publique par conception. Aucun autre secret ne doit jamais entrer dans le dépôt.
- Bibliothèque figée : supabase-js 2.117.0. La changer seulement volontairement, après essai. Si elle change : modifier aussi BIBLIO dans sw.js (même adresse que l'import) et passer VERSION à la suivante. Même règle pour l'adresse Google Fonts (POLICES dans sw.js).
- Budget perso est publié sur le même site : les deux apps partagent le stockage du navigateur. Les clés de Daily Flow commencent par daily-flow-v3 (et df-uid pour les anciens appareils), celles de Budget par budget-. Caches du service worker : daily-flow-v3-sw-* pour Daily Flow, budget-sw-* pour Budget (20 octobre 2026) ; aucun code ne touche aux caches de l'autre app.

## Synchronisation : acquis à ne pas casser

- Tout l'état local tient dans une seule clé, daily-flow-v3-etat, écrite d'un seul coup et seulement si quelque chose a changé.
- Chaque tâche a sa base : la dernière version vue en ligne (updated_at et champs gérés). Une modification locale se détecte par comparaison avec la base, jamais par un drapeau.
- Chaque écriture est conditionnelle : elle n'aboutit que si la version en ligne est encore celle de la base.
- Chaque onglet décide sur sa propre mémoire, jamais sur le stockage partagé.
- Le temps réel est un simple signal de relecture. Les suppressions arrivent par un abonnement sans filtre.
- Relectures : ouverture, retour au premier plan, focus de la fenêtre (une par tranche de 2 secondes), retour du réseau, page restaurée, reconnexion du canal, et relecture légère (identifiants et versions) toutes les 30 secondes quand la page est visible.
- L'événement storage est un signal de relecture du serveur, jamais une recopie de l'état d'un autre onglet. Il est filtré sur les clés exactes. Déconnexion et connexion se propagent aux autres onglets.
- Double modification : fusion par champ ; question seulement si le même champ a deux valeurs différentes. La version en ligne l'emporte sans question pour trois champs seulement : l'ordre (position), la date de mise en corbeille (deleted_at) et l'ambiance (theme). Le fait d'être ou non à la corbeille (deleted) suit la règle générale : question si les deux côtés divergent.
- Textes des questions de conflit validés le 24 septembre 2026 (« Modifiée à deux endroits », « Ici », « Ailleurs », conséquence de chaque réponse). Ne pas les changer sans validation.
- Saisie en cours : seulement si quelque chose a été tapé dans la zone d'édition. Une zone simplement ouverte n'empêche pas le rafraîchissement.

## Base de données

- Sécurité par ligne active, politiques de propriétaire uniquement (user_id égal à l'identifiant du compte connecté). Aucun droit pour le rôle anonyme.
- Toute nouvelle table : sécurité par ligne, politiques de propriétaire et droits accordés au seul rôle authenticated, dans la migration qui la crée, et ajout au temps réel si l'app l'écoute. À partir du 30 octobre 2026, Supabase n'accorde plus de droits d'office aux nouvelles tables (courriel de Supabase du 23 septembre 2026).
- Aucune migration sans feu vert explicite de Christophe.

## Démarrage hors connexion (vérifié au banc et en réel le 20 octobre 2026)

- sw.js, portée /daily-flow-v2-claude/ seulement, cache daily-flow-v3-sw-<VERSION> ; il ne supprime que les caches daily-flow-v3-sw-*.
- Page en « réseau d'abord » : version en ligne revalidée (cache: 'no-cache'), sinon, sans réseau ou au-delà de 4 s, la dernière copie enregistrée ; une réponse arrivée en retard met la copie à jour pour l'ouverture suivante.
- supabase-js 2.117.0 et les 8 modules qu'il importe depuis jsdelivr : cache d'abord (adresses à version fixe). Ils sont obligatoires à l'installation : si l'un manque (réseau coupé, jsdelivr injoignable), l'installation échoue et la version déjà en place reste en service avec son cache. Les modules d'une version précédente du cache sont repris sans réseau.
- Google Fonts (feuille et fichiers) : cache d'abord, rafraîchis en arrière-plan en CORS ; une réponse en erreur ne remplace jamais la bonne copie.
- Supabase (données, connexion, temps réel) n'est jamais intercepté. L'import de supabase-js dans le module n'a pas été modifié.
- L'enregistrement est dans un script classique placé avant le module, avec la constante SW_ACTIF : il s'exécute même si la bibliothèque ne se charge pas.
- Vérifié en réel le 20 octobre 2026 sur le PC et le téléphone Android :
  - cache de 16 entrées sur le PC (page, 9 modules jsdelivr, feuille Google Fonts, 5 fichiers de police) ;
  - démarrage sans réseau avec les tâches et les polices, sans écran de connexion ;
  - tâche ajoutée hors ligne (« 1 modification en attente ») puis envoyée au retour du réseau ;
  - deux inscriptions distinctes dans chrome://serviceworker-internals.
- Vérifié au banc, pas en réel : jeton Supabase expiré hors ligne (l'app s'ouvre, le jeton est rafraîchi au retour du réseau) ; mise à jour pendant que jsdelivr est injoignable ; coupure en pleine installation.
- Mise à jour réelle vérifiée le 20 octobre 2026 sur le PC et le téléphone : passage de VERSION à v2, cache daily-flow-v3-sw-v2 complet à la place de v1, démarrage sans réseau avec les tâches, cache de Budget intact.
- Limites connues :
  - premier lancement sans réseau non couvert : l'app doit avoir été ouverte une fois en ligne après chaque installation (sur réseau mobile, la laisser ouverte une vingtaine de secondes) ;
  - une adresse sans barre finale ne s'ouvre pas hors ligne : favoris et icônes doivent finir par /daily-flow-v2-claude/ (vérifié le 20 octobre 2026) ;
  - après un déploiement, une ouverture hors ligne ou sur réseau lent sert l'ancienne page, sans signe visible, jusqu'à la prochaine ouverture en ligne rapide ;
  - hors ligne, « Dernière synchronisation » peut afficher une heure ancienne : l'heure n'est enregistrée sur l'appareil que lorsque les données changent (persist n'écrit que si le contenu change). Comportement antérieur, devenu visible hors ligne ; aucune donnée en jeu.

### Désactivation (dans l'ordre de préférence)

1. SW_ACTIF=false dans index.html, puis déposer : à la prochaine ouverture en ligne, la page retire son service worker et ses caches daily-flow-v3-sw-*, sans toucher à Budget.
2. Secours : remplacer le contenu de sw.js par celui de docs/sw-arret.js et déposer (à combiner avec 1 pour un arrêt complet).
3. Sur un seul appareil, sans dépôt :
   - PC : F12, Appli, Service workers, « Unregister » sur la portée /daily-flow-v2-claude/, puis Espace de stockage du cache : supprimer seulement daily-flow-v3-sw-*.
   - Android : chrome://serviceworker-internals (page disponible, vérifié le 20 octobre 2026), « Unregister » sur la ligne dont la portée est /daily-flow-v2-claude/ seulement.
- Ne jamais utiliser « Effacer les données du site » ni « Effacer et réinitialiser » pour désactiver le service worker (utiliser les trois moyens ci-dessus) : cela efface aussi les modifications en attente, la session et toutes les données locales de Budget, dont son code d'accès.
- Nettoyage complet du navigateur (habitude de Christophe, cookies compris) : possible. Avant, vérifier « Tout est enregistré en ligne » ici et aucune modification en attente dans Budget ; après, rouvrir chaque app une fois en ligne et ressaisir les codes, ce qui remet en place le démarrage hors connexion. L'exception « toujours autoriser les cookies » de Chrome ne protège pas d'un nettoyage manuel (règle convenue le 20 octobre 2026).

## Déploiement

- Si une version change les clés de stockage : fermer tous les onglets sauf un sur chaque appareil avant de déployer.
- Après dépôt, GitHub Pages met quelques minutes à publier ; recharger en forçant sur le PC, fermer et rouvrir l'app sur le téléphone.
- Service worker (depuis le 20 octobre 2026) :
  - une modification de sw.js change toujours VERSION ; une modification de la seule page n'en a pas besoin ;
  - après un dépôt, ouvrir l'app en ligne, avec un bon réseau, sur chaque appareil, et vérifier que la nouvelle version est affichée avant toute saisie ;
  - une version qui change les clés ou le format des données doit savoir lire l'ancien format : une ancienne page peut encore tourner hors ligne ;
  - avant de supprimer, de renommer le dépôt ou de le passer en privé (ce qui arrête GitHub Pages sur le plan gratuit) : désactiver d'abord (voir « Désactivation ») et ouvrir l'app en ligne sur chaque appareil, sinon l'ancienne copie reste servie sans fin.

## Déjà vérifié : ne pas refaire

Recommandations du second complément du 24 septembre, traitées le jour même :
- Réponse tardive : testée au banc, aucun recul ni en ligne ni dans le stockage, grâce aux décisions prises en mémoire par chaque onglet. Le bloc 2 de Budget n'est pas à porter.
- Questions de conflit : textes alignés et déployés (bloc 3 de Budget).
- Champ touché pendant un réaffichage : risque jugé faible (au pire un appui perdu, jamais une donnée), non porté.
- Fermeture des autres onglets au déploiement : règle retenue (voir Déploiement).

## En attente

- Démarrage hors connexion : chantier clos le 20 octobre 2026, rien en attente.
- À décider plus tard : hors ligne, « Dernière synchronisation » peut afficher une heure ancienne (voir « Limites connues »).

## Documents de référence (dossier docs)

- fiche-portage-synchro-daily-flow.md : logique de synchronisation validée sur Budget perso, 22 septembre 2026.
- complement-fiche-synchro-onglets-daily-flow.md : plusieurs onglets et relecture automatique, 23 septembre 2026.
- complement-2-verification-croisee-daily-flow.md : vérification croisée Budget et Daily Flow, 24 septembre 2026.

- fiche-pont-hors-connexion.md : démarrage hors connexion de Budget et de Daily Flow, 20 octobre 2026.
- sw-arret.js : version d'arrêt de secours du service worker (voir « Désactivation »).

Les trois premières se lisent ensemble ; en cas de contradiction entre elles, la plus récente prévaut. Ce CLAUDE.md prévaut sur toutes.
