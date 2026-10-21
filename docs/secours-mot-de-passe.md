# Daily Flow : secours en cas d'oubli du mot de passe

Fiche établie le 21 octobre 2026 (chantier R3). Les deux moyens ci-dessous ont été testés le jour même.

## Avant tout

- Le mot de passe de Daily Flow est rangé dans le gestionnaire de mots de passe. Regarder d'abord là.
- Un oubli ne fait perdre aucune donnée. Les tâches restent sur chaque appareil, et celles qui sont en attente partent après la reconnexion.
- Ne jamais supprimer puis recréer le compte : le nouveau compte aurait un autre identifiant, et les tâches en ligne ne lui seraient plus rattachées.
- Ne jamais donner son vrai mot de passe à une IA, même provisoire.

## Moyen 1 : le lien « Mot de passe oublié ? » de l'app (le moyen normal)

1. Sur l'écran de connexion (ou de reconnexion), saisir l'adresse e-mail du compte, puis appuyer sur « Mot de passe oublié ? ».
2. Ouvrir le courriel « Daily Flow : ton code pour changer de mot de passe » (regarder aussi les indésirables).
3. Dans l'app, saisir le code, puis le nouveau mot de passe (12 caractères au moins, pris dans le gestionnaire et enregistré avant d'appuyer), deux fois.
4. « Enregistrer le nouveau mot de passe », puis « Continuer ».
5. Les autres appareils demandent ensuite de se reconnecter, avec le nouveau mot de passe. Leurs modifications en attente sont gardées.

Même chemin, une fois connecté : menu, rubrique Compte, « Changer le mot de passe ».

Limites du service d'envoi par défaut de Supabase (documentation consultée le 21 octobre 2026) :
- 2 courriels par heure au plus pour tout le projet, chiffre que Supabase peut changer sans préavis. En cas de « Trop de demandes », attendre une heure.
- Envoi seulement aux adresses des membres de l'équipe de l'organisation Supabase. L'adresse du compte Daily Flow en fait partie (vérifié le 21 octobre 2026). Si elle change, l'ajouter à l'équipe ou configurer un serveur d'envoi personnalisé.
- Le courriel dépend du modèle « Reset password » (Authentication, Emails, Templates), modifié le 21 octobre 2026 pour contenir `{{ .Token }}`. Sans cette variable, le courriel ne contient plus de code et le moyen 1 ne marche plus.

Le bouton « Send password recovery » du tableau de bord (Authentication, Users) n'apporte rien de plus : pour saisir un code, il faut ouvrir l'écran de l'app, qui envoie lui-même un nouveau code, et seul le dernier reçu est valable.

## Moyen 2 : la requête SQL du tableau de bord (dernier recours)

À utiliser seulement si le moyen 1 est impossible (courriel qui n'arrive pas, adresse perdue). Il faut pouvoir se connecter au tableau de bord Supabase, qui a son propre mot de passe.

1. Tableau de bord Supabase, projet daily-flow-v2-claude, SQL Editor, nouvelle requête.
2. Contrôle (remplacer l'adresse) ; il doit y avoir une ligne :
   ```sql
   select id, email from auth.users where email = 'ADRESSE-DU-COMPTE';
   ```
3. Mot de passe **provisoire** (12 caractères au moins, utilisé une seule fois) :
   ```sql
   update auth.users
   set encrypted_password = extensions.crypt('MOT-DE-PASSE-PROVISOIRE', extensions.gen_salt('bf', 10)),
       updated_at = now()
   where email = 'ADRESSE-DU-COMPTE';
   ```
   Attendu : 1 ligne modifiée.
4. Supprimer aussitôt cette requête de la liste de l'éditeur SQL si elle y figure : elle contient le mot de passe en clair.
5. Se connecter dans l'app avec le mot de passe provisoire.
6. Dès que les courriels fonctionnent de nouveau : menu, « Changer le mot de passe », pour le remplacer par un mot de passe définitif pris dans le gestionnaire.

À savoir :
- Ce changement passe à côté du serveur de connexion : il ne ferme pas les sessions des autres appareils, qui restent connectés.
- Testé le 21 octobre 2026 sur un compte d'essai, supprimé ensuite. Requête acceptée (1 ligne), ancien mot de passe refusé à la connexion, mot de passe provisoire accepté dans l'app. Le format produit (`$2a$10$`) est celui que Supabase utilise lui-même.
- Méthode non documentée par Supabase : elle peut cesser de fonctionner si Supabase change le chiffrement des mots de passe ou les droits de l'éditeur SQL.
