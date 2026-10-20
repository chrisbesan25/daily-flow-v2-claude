# Fiche de pont : démarrage hors connexion de Budget perso et de Daily Flow

Établie le 20 octobre 2026. Fiche identique dans les dépôts chrisbesan25/Budget et chrisbesan25/daily-flow-v2-claude (dossier docs). Le CLAUDE.md de chaque dépôt fait foi en cas d'écart.

## Ce qui a été fait

Les deux apps, publiées sur le même site (chrisbesan25.github.io, même stockage et même cache du navigateur), ont chacune un service worker `sw.js` qui permet de les rouvrir sans réseau ou sur un réseau très faible, puis de se resynchroniser seules au retour du réseau. La synchronisation validée en septembre n'a pas changé : ni api.github.com (Budget) ni Supabase (Daily Flow) ne sont interceptés.

| | Budget perso | Daily Flow |
|---|---|---|
| Portée | `/Budget/` | `/daily-flow-v2-claude/` |
| Cache | `budget-sw-<VERSION>` | `daily-flow-v3-sw-<VERSION>` |
| Gardé en cache | la page | la page, supabase-js 2.117.0 et ses 8 modules (jsdelivr), Google Fonts |
| Page | réseau d'abord, 4 s au plus, puis dernière copie | idem |
| Bibliothèque, polices | sans objet | cache d'abord ; bibliothèque obligatoire à l'installation |
| Désactivation | `SW_ACTIF = false`, `docs/sw-arret.js`, désinscription manuelle | idem |

Chaque service worker ne crée et ne supprime que ses propres caches ; aucun code d'une app ne touche au stockage ou aux caches de l'autre.

## Vérifications

- Banc d'essai local (Playwright, les deux apps sur un même site, faux GitHub et faux Supabase qui vérifient réellement les versions, imitation de jsdelivr, données fictives) : 78 contrôles réussis, plus les essais de l'audit (mise à jour avec jsdelivr injoignable, coupure pendant l'installation, erreur Google Fonts, jeton Supabase expiré hors ligne, redémarrage du navigateur).
- Audit par un sous-agent indépendant, le 20 octobre 2026 : 8 constats, 4 corrigés dans le code (bibliothèque obligatoire, expression des imports, polices en CORS, échec d'écriture en cache), 4 traités par des règles écrites (adresses avec barre finale, désinscription manuelle, ancienne version servie sans signe, suppression du dépôt).
- Tests réels du 20 octobre 2026, PC et téléphone Android, Chrome : ouverture sans réseau des deux apps avec les données, saisie hors ligne gardée puis envoyée, polices conservées, 9 modules jsdelivr présents (structure réelle conforme à l'imitation du banc), deux inscriptions distinctes.

## Règles à retenir

- Favoris et icônes avec la barre finale (`/Budget/`, `/daily-flow-v2-claude/`), sinon pas d'ouverture hors ligne.
- Premier lancement sans réseau impossible : ouvrir l'app une fois en ligne après chaque installation.
- Toute modification de `sw.js` change `VERSION`. Après un dépôt, ouvrir chaque app en ligne, avec un bon réseau, sur chaque appareil, avant toute saisie.
- Une version qui change les clés ou le format des données doit savoir lire l'ancien format.
- Ne jamais « Effacer les données du site » pour désactiver un service worker : cela efface tout, pour les deux apps. Un nettoyage complet du navigateur reste possible : avant, vérifier que tout est envoyé dans les deux apps ; après, rouvrir chaque app une fois en ligne et ressaisir les codes.
- Avant de supprimer, de renommer un dépôt ou de le passer en privé (ce qui arrête GitHub Pages sur le plan gratuit) : désactiver d'abord le service worker de l'app et l'ouvrir en ligne sur chaque appareil, sinon l'ancienne copie reste servie sans fin.

## État au 20 octobre 2026 : chantier clos

- Mise à jour réelle vérifiée sur le PC et le téléphone : `VERSION` passée à `v2` dans les deux `sw.js`, caches `-v2` à la place des `-v1`, données intactes, aucune app n'a touché au cache de l'autre.
- Contrôle de tout l'historique des deux dépôts (20 octobre 2026) : aucune clé secrète, aucun mot de passe, aucune donnée personnelle sensible ; seules la clé publique Supabase (actuelle et ancienne « anon ») et des mentions du prénom figurent, publiques par conception ou faiblement personnelles.

## Restent notés, hors périmètre

- Daily Flow, hors ligne : « Dernière synchronisation » peut afficher une heure ancienne (comportement antérieur, sans enjeu pour les données) ; correction possible plus tard, à décider.
- Refus 409 de GitHub avec deux onglets Budget au retour du réseau : rattrapé sans perte, antérieur au chantier, hors périmètre.
