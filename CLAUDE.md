# Daily Flow : consignes pour Claude Code

Établi le 24 septembre 2026. Ce fichier est lu au début de chaque session. Il résume l'état réel de l'app et la méthode de travail de Christophe. En cas de doute sur le fonctionnement de Daily Flow, ce fichier et le code font foi. Les fiches du dossier docs décrivent la logique de Budget perso et les leçons tirées pour Daily Flow.

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

## L'app

- Un seul fichier index.html, publié par GitHub Pages sous chrisbesan25.github.io/daily-flow-v2-claude. Le dépôt est public.
- Données dans Supabase (projet daily-flow-v2-claude) : tables tasks, prefs et notes (notes inutilisée).
- Connexion par compte Supabase (e-mail et mot de passe), inscriptions fermées. La clé publishable est dans le fichier : elle est publique par conception. Aucun autre secret ne doit jamais entrer dans le dépôt.
- Bibliothèque figée : supabase-js 2.117.0. La changer seulement volontairement, après essai.
- Budget perso est publié sur le même site : les deux apps partagent le stockage du navigateur. Les clés de Daily Flow commencent par daily-flow-v3 (et df-uid pour les anciens appareils), celles de Budget par budget-.

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

## Déploiement

- Si une version change les clés de stockage : fermer tous les onglets sauf un sur chaque appareil avant de déployer.
- Après dépôt, GitHub Pages met quelques minutes à publier ; recharger en forçant sur le PC, fermer et rouvrir l'app sur le téléphone.

## Déjà vérifié : ne pas refaire

Recommandations du second complément du 24 septembre, traitées le jour même :
- Réponse tardive : testée au banc, aucun recul ni en ligne ni dans le stockage, grâce aux décisions prises en mémoire par chaque onglet. Le bloc 2 de Budget n'est pas à porter.
- Questions de conflit : textes alignés et déployés (bloc 3 de Budget).
- Champ touché pendant un réaffichage : risque jugé faible (au pire un appui perdu, jamais une donnée), non porté.
- Fermeture des autres onglets au déploiement : règle retenue (voir Déploiement).

## En attente

- Démarrage hors connexion (service worker) : décision reportée. À traiter avec Budget perso, qui partage le même site et donc le même cache du navigateur.

## Documents de référence (dossier docs)

- fiche-portage-synchro-daily-flow.md : logique de synchronisation validée sur Budget perso, 22 septembre 2026.
- complement-fiche-synchro-onglets-daily-flow.md : plusieurs onglets et relecture automatique, 23 septembre 2026.
- complement-2-verification-croisee-daily-flow.md : vérification croisée Budget et Daily Flow, 24 septembre 2026.

Les trois se lisent ensemble ; en cas de contradiction entre eux, le plus récent prévaut.
