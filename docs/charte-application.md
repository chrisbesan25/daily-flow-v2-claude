# Charte de l'application Daily Flow

**Version 1.1 du 22 octobre 2026 · Christophe** (1.0 du même jour : relevé du code ; 1.1 : décision de Christophe sur les couples sous les seuils)

> **Ce document décrit, il ne prescrit pas.** Il relève l'allure que l'application applique aujourd'hui, à partir de son code, comme le prévoit la section 7.1 de la charte des livrables (version 1.6.8 du 21 octobre 2026). Il ne change rien à l'application : ni couleur, ni police, ni mise en page.
>
> **Source relevée** : `index.html` de la branche `main`, commit `feaa532`, empreinte SHA-256 `97adfc1ace97f01abff97d8434b0cf3eac56a26becffafb6db6cfaeed32f7aa6` (objet git `bdd6cf8`, identique à celui de `main` sur GitHub le 22 octobre 2026). GitHub Pages a publié ce même commit (déploiement n° 44, réussi le 22 octobre 2026 à 6 h 28, heure UTC). **Non vérifié** : l'identité octet par octet avec la page servie, que la session n'a pas pu télécharger (accès à chrisbesan25.github.io refusé par le mandataire réseau le 22 octobre 2026).
>
> **Copie** : une copie de ce fichier va dans le Contexte du projet Claude de Daily Flow. En cas d'écart, le fichier du dépôt fait foi pour l'allure de l'app.

---

## 1. Statut et portée

La charte des livrables (section 7.1) donne à chaque application sa propre charte. Celle-ci **fixe les couleurs et les polices** de Daily Flow et prévaut, pour ces deux points, sur la charte des livrables. Pour le reste, la charte des livrables s'applique, notamment les seuils de contraste de sa section 1.11.

Les seuils de contraste restent obligatoires, **sauf pour les couples que Christophe a acceptés par écrit et que la section 5.1 énumère**. Un couple nouveau sous le seuil se soumet à Christophe avant d'être employé.

**Décision du 22 octobre 2026.** Avant ce relevé, le seul accord écrit sur les contrastes était la décision R10 du 21 octobre 2026, qui couvre deux couples de l'ambiance ivoire. Le relevé a trouvé d'autres couples sous les seuils, dans les neuf ambiances, en huit familles. Christophe les a tous acceptés tels quels le 22 octobre 2026 (« familles : on laisse tout comme c'est aujourd'hui »). Tous ces couples sont énumérés en section 5.1 ; au 22 octobre 2026, l'app n'emploie aucun couple sous les seuils sans accord écrit, et rien n'y est changé.

---

## 2. Polices

Deux polices chargées depuis Google Fonts, par une seule adresse : `https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@500;700;800&family=Schibsted+Grotesk:wght@400;500;600;700&display=swap`. La même adresse figure dans `sw.js` (constante `POLICES`) : le service worker garde la feuille et les fichiers de police en cache pour le démarrage hors connexion. Police de repli : `system-ui`, puis `sans-serif`.

| Police | Variable | Graisses chargées | Emploi |
|---|---|---|---|
| **Bricolage Grotesque** | `--fd` | 500, 700, 800 | Titres et libellés : titre du jour (30 px, 800) ; onglets de catégorie (19 px, 700) et onglet Corbeille (16 px, 600) ; titres de tâche (21 px, 700) ; intitulé « Terminées » (13 px, 700, capitales) ; libellés en capitales des feuilles, du menu et des conflits (11 px, 700) ; titre de la feuille couleur (18 px, 700) ; titres des fenêtres (18 px, 800) ; marque « DAILY FLOW » de la connexion et de l'écran de chargement (11 px, 800) ; boutons pleins « Fermer », de connexion et de conflit, pastilles « Déplacer vers » (14 px, 700) ; valeurs des conflits (17 px, 700) ; état vide (19 px, 700). |
| **Schibsted Grotesk** | `--fb` | 400, 500, 600, 700 | Police du corps (`body`). Sous-titre du jour (15 px, 500) ; détails des tâches (15,5 px, 500) ; zone « Nouvelle tâche » et saisie dans une tâche (17 px, 500) ; champs de catégorie et de connexion (16 px, 600) ; boutons du menu et « Vider la corbeille » (14 px, 700) ; boutons des fenêtres (13 px, 700) ; cartes d'état (15 px, 600 et 13,5 px, 400) ; textes du menu, des conflits et de la connexion (13 à 14,5 px, 400 à 600) ; lien « Mot de passe oublié ? » (14 px, 600, souligné). |
| Police des boutons du navigateur (non fixée) | | | Bouton « + » d'ajout de catégorie (21 px, 500) et croix « ✕ » de fermeture des fenêtres (20 px, 400) : un `button` n'hérite pas de la police et le code n'en fixe pas. Fenêtres de confirmation du navigateur (`confirm`). |

**Graisses** : 800 pour les grands titres et la marque ; 700 pour les titres de tâche, les onglets, les libellés et les boutons ; 600 pour les intitulés de champ et l'onglet Corbeille ; 500 pour les détails, les sous-titres et la saisie ; 400 pour le texte courant du menu. Deux écarts relevés, sans effet sur l'allure voulue : la graisse 500 de Bricolage Grotesque est chargée sans qu'aucun texte l'emploie ; la graisse 600 de l'onglet Corbeille n'est pas chargée pour cette police, et le navigateur prend alors la plus proche au-dessus, 700 (règle de correspondance des polices CSS, non vérifiée à l'écran).

**Tailles** : toutes en px, fixes. La seule règle de largeur d'écran (`@media(max-width:420px)`) retire le retrait des boutons d'action ; aucune taille de texte ne change. Les tailles réelles sont donc les mêmes sur le PC et sur le téléphone. La page demande au navigateur de bloquer le zoom (`user-scalable=no`). Espacement des mots porté à 0,05 à 0,08 em sur la plupart des textes.

**Symboles et émojis** : « 📥 » et « 📤 » (export et import), flèches « ← » et « → » (déplacer une catégorie), « ✕ » (fermer), points de suspension. Les émojis sont dessinés par la police d'émojis de l'appareil.

---

## 3. Couleurs

### 3.1 Neuf ambiances

L'ambiance se choisit par le premier des deux boutons ronds en haut à droite ; elle est enregistrée et synchronisée (champ `theme`). **Ambiance par défaut : galet.** Huit ambiances claires et une sombre (encre). Chaque ambiance redéfinit sept jetons sur `body[data-amb]` :

| Ambiance | `--paper` | `--ink` | `--ink2` | `--ink3` | `--hair` | `--chip` | `--field` | Aperçu (dégradé à 140 degrés) |
|---|---|---|---|---|---|---|---|---|
| galet | `#F3F4F1` | `#16211C` | `#5C6B63` | `#94A29B` | `rgba(22,33,28,.1)` | `rgba(22,33,28,.055)` | `#FFFFFF` | `#F3F4F1` vers `#D8DDD4` |
| ivoire | `#F8F6F0` | `#211D16` | `#6B6355` | `#A29A8C` | `rgba(33,29,22,.1)` | `rgba(33,29,22,.055)` | `#FFFFFF` | `#F8F6F0` vers `#E5E0D2` |
| brume | `#EFF2F5` | `#161D24` | `#5A6774` | `#93A0AC` | `rgba(22,29,36,.1)` | `rgba(22,29,36,.055)` | `#FFFFFF` | `#EFF2F5` vers `#D3DAE2` |
| sauge | `#ECF2EC` | `#152018` | `#57685C` | `#8FA095` | `rgba(21,32,24,.1)` | `rgba(21,32,24,.055)` | `#FBFDFB` | `#ECF2EC` vers `#CBDDCC` |
| ciel | `#EDF3F8` | `#131E28` | `#54697A` | `#8CA1B1` | `rgba(19,30,40,.1)` | `rgba(19,30,40,.055)` | `#FBFDFF` | `#EDF3F8` vers `#CDDFED` |
| rosee | `#F7EFF1` | `#241619` | `#75585E` | `#AC9097` | `rgba(36,22,25,.1)` | `rgba(36,22,25,.055)` | `#FFFCFD` | `#F7EFF1` vers `#EBD3DA` |
| sable | `#F5F0E7` | `#221C10` | `#6F6450` | `#A69A82` | `rgba(34,28,16,.1)` | `rgba(34,28,16,.055)` | `#FFFDF8` | `#F5F0E7` vers `#E8DCC4` |
| lavande | `#F1EFF7` | `#191624` | `#605A75` | `#9791AC` | `rgba(25,22,36,.1)` | `rgba(25,22,36,.055)` | `#FCFBFF` | `#F1EFF7` vers `#D9D4EC` |
| encre | `#151A18` | `#F0F3F1` | `#9BA8A1` | `#5E6A64` | `rgba(240,243,241,.12)` | `rgba(240,243,241,.08)` | `#1E2422` | `#232B27` vers `#101613` |

| Jeton | Rôle |
|---|---|
| `--paper` | Fond de page et de l'écran de connexion ; texte des boutons pleins |
| `--ink` | Texte principal ; fond des boutons pleins ; coche et case d'une tâche faite |
| `--ink2` | Texte secondaire : sous-titre, détails, libellés de champ, notes, lien discret, onglet Corbeille actif |
| `--ink3` | Texte tertiaire : onglets inactifs, « + », « Terminées », textes indicatifs, libellés de la feuille couleur, croix ; cercle d'une case à cocher ; bouton d'ajout au repos |
| `--hair` | Filets entre tâches, bordures des champs et des boutons, piste de la barre de progression |
| `--chip` | Fond des boutons ronds, des cartes d'état, du bouton « Annuler », des boutons du menu ; appui sur une tâche |
| `--field` | Fond des champs de saisie, de la feuille couleur et des fenêtres |

Le changement d'ambiance est animé (fond et texte en 0,7 seconde) ; les couleurs intermédiaires de cette transition ne sont pas relevées.

### 3.2 Jetons communs (`:root`) et valeurs écrites en dur

| Valeur | Emploi |
|---|---|
| `--danger` `#EF4444` | Bouton « Vider la corbeille » (texte, bordure à 30 %, survol à 8 %), bouton « Supprimer » d'une catégorie (fond), survol de la corbeille dans les actions d'une tâche, pastille d'alerte de synchronisation |
| `--success` `#10B981` | Pastille « synchronisé », survol du bouton « Restaurer » |
| `#F59E0B` | Pastille « en attente » |
| `#FFFFFF` (blanc) | Texte et coches des tâches colorées, icônes des boutons colorés, texte du bouton « Supprimer » |
| `rgba(255,255,255, .18 à .85)` | Voiles et textes blancs atténués des tâches colorées : boutons d'action 18 % (survol de la corbeille 35 %), case faite 30 %, cercle 60 %, bord de la case faite 80 %, titre d'une tâche faite 65 %, détails 85 % |
| `rgba(0,0,0,.35)` et `rgba(0,0,0,.4)` | Voile sous la feuille couleur et sous les fenêtres, avec un flou de 4 px |
| `#F3F4F1`, `#16211C`, `#94A29B`, `rgba(22,33,28,.15)` | Écran de chargement (valeurs de galet, fixes quelle que soit l'ambiance) ; `#F3F4F1` aussi pour la couleur de la barre du navigateur (`theme-color`) |
| Ombres `rgba(0,0,0, .07 à .22)` | Zone de saisie, bouton d'ajout, feuille, fenêtres |

### 3.3 Couleurs des tâches

Une tâche sans couleur est enregistrée avec `#FFFFFF` et s'affiche sans fond, sur le fond de l'ambiance. Une tâche colorée devient un bloc plein, **toujours en texte blanc**, quelle que soit la teinte.

| Famille | Teintes (constante) |
|---|---|
| Couleurs pleines (`SOLIDS`) | `#3B82F6` `#6366F1` `#8B5CF6` `#EC4899` `#EF4444` `#F97316` `#22C55E` `#14B8A6` `#06B6D4` `#0EA5E9` `#D946EF` `#F43F5E` |
| Pastels (`PASTELS`) | `#85B1F9` `#9EA0F6` `#B79AF9` `#F38EC0` `#F58B8B` `#FBA86F` `#76DB9B` `#6DD3C8` `#65D2E4` `#6AC7F1` `#E78CF5` `#F8889B` |

Une tâche faite est atténuée : toute la rangée passe à 50 % d'opacité, titre barré ; son titre passe en `--ink3` (sans couleur) ou en blanc à 65 % (colorée). À l'appui, une tâche colorée s'éclaircit de 5 % (`filter:brightness(1.05)`). En glissement, la rangée passe à 50 % d'opacité.

### 3.4 Couleurs des catégories

Palette proposée à la création et à la modification d'une catégorie (`CAT_COLORS`) : `#FF5A36` `#0052FF` `#8B5CF6` `#EC4899` `#EF4444` `#F97316` `#EAB308` `#22C55E` `#14B8A6` `#06B6D4` `#D946EF` `#84CC16`. Catégories par défaut : **Perso** `#FF5A36` et **Pro** `#0052FF`.

La couleur de la catégorie sert au texte et au soulignement (4 px) de l'onglet actif, au remplissage de la barre de progression, au fond du bouton d'ajout dès qu'un texte est saisi, et à la pastille des boutons « Déplacer vers ». L'onglet Corbeille actif est en `--ink2`.

**Non relu** : les catégories réellement enregistrées dans la base (table `prefs`, champ `cats`), faute d'accès accordé à la base pour ce chantier. Le contrôle couvre donc les douze couleurs proposées ; une couleur venue d'une version plus ancienne de l'app ne serait pas couverte.

### 3.5 Formes

Rayons : 14 à 16 px pour les champs, les boutons, les cartes et les rangées de tâche ; 20 px pour une tâche colorée ; 22 px pour la zone de saisie ; 24 px pour les fenêtres ; 26 px pour le haut de la feuille couleur ; cercle pour les boutons ronds, les cases à cocher, les pastilles et les couleurs à choisir ; pilule pour les boutons « Déplacer vers ». Largeur de contenu bornée à 560 px (`--maxw`), centrée.

---

## 4. Méthode du contrôle de contraste

La même que pour Budget le 22 octobre 2026.

- Formule de la WCAG (luminance relative, linéarisation à 0,04045), seuils de la section 1.11 de la charte des livrables : **4,5 pour 1** en texte courant, **3 pour 1** en texte large, soit au moins 24 px, ou 18,66 px en gras.
- Graisse 700 et au-delà comptée comme grasse ; 600 comptée comme non grasse (choix prudent). Les titres de tâche (21 px, 700), les onglets de catégorie (19 px, 700), le titre du jour (30 px, 800) et l'état vide (19 px, 700) sont donc des textes larges, au seuil de 3 ; tout le reste est au seuil de 4,5, y compris le « + » (21 px, 500), la croix (20 px, 400) et les titres de 18 px.
- Transparences composées sur le fond réel, en sRGB, comme le navigateur : `--chip` et `--hair` sur `--paper` ou `--field` selon l'écran ; l'opacité d'une rangée (50 %) ou de l'état vide (35 %) s'applique au groupe, texte et fond ensemble, posé sur `--paper`.
- Filtre d'éclaircissement d'une tâche colorée à l'appui (1,05) appliqué au rendu de la rangée, avant son opacité, dans l'ordre que fixe CSS.
- Dégradés : aucun texte n'est posé sur un dégradé. Les aperçus d'ambiance sont des pastilles sans texte ; le fondu sous la zone de saisie (de `--paper` vers transparent) passe sous un champ à fond plein (`--field`). Aucun calcul aux extrémités n'est donc nécessaire.
- Tailles en px réels : identiques à toutes les largeurs d'écran (section 2).
- États compris : survol (au PC seulement, à la souris), appui sur une tâche, saisie (texte tapé et texte indicatif), glissement d'une tâche. Les états désactivés sont hors du critère 1.4.3 (composants inactifs) ; ils sont calculés pour information en section 5.3.
- Valeurs arrondies au centième ; aucune valeur affichée ne passe un seuil par l'effet de l'arrondi.
- Trait de biffure d'une tâche faite colorée : là où il croise une lettre, le blanc à 65 % se peint deux fois et paraît à environ 88 %. Non retenu : le corps de la lettre, hors du trait, garde 65 %.

**Contrôles faits le 22 octobre 2026.** Calcul par un script (Python) sur les valeurs lues dans `index.html`, sans recopie à la main. Second calcul indépendant (JavaScript) : formule, seuil selon la taille et la graisse, arrondi, et relecture de chacune des 1 943 valeurs des tableaux de ce fichier, ainsi que des comptes de la section 5 ; aucun écart, et le contrôle signale bien une valeur volontairement faussée. Rendu par Chromium de la feuille de style réelle, dans les neuf ambiances (appui et survol forcés par l'outil de débogage du navigateur) : 990 couleurs de texte et de fond mesurées au pixel (30 situations et 55 textes par ambiance), couvrant toutes les compositions de la section 4 (onglets, tâches faites, à l'appui, en glissement, colorées sur quatre teintes, état vide, menu, texte indicatif, survol, bouton désactivé) ; écart maximal de 1,55 niveau sur 255 (arrondis du navigateur), aucun couple ne change de côté du seuil. **Non vérifié** : le rendu avec les vraies polices (Google Fonts injoignable depuis la session, mesures faites avec un caractère plein d'une police de repli), le lissage du texte et les réglages des deux appareils de Christophe.

---

## 5. Couples de texte et de fond sous les seuils

2 074 couples ont été calculés (neuf ambiances, tous les états de la section 4). 1 601 sont sous le seuil, hors états désactivés.

| Famille | Couples sous le seuil | Où |
|---|---|---|
| Accord R10 du 21 octobre 2026 | 2 | 5.1 (ivoire : onglets inactifs, onglet actif `#FF5A36`) |
| A. Onglets de catégorie inactifs, hors ivoire | 7 | 5.1 |
| B. Onglet de catégorie actif | 55 | 5.1 |
| C. Autres textes en `--ink3` | 64 | 5.1 |
| D. Tâches sans couleur à 50 % (faites, en glissement) | 45 | 5.1 |
| E. Tâches de couleur pleine, texte blanc | 46 | 5.1 |
| F. Tâches pastel, texte blanc | 60 | 5.1 |
| G. Tâches colorées faites ou en glissement | 1 296 | 5.1 et annexe |
| H. Rouge d'alerte | 26 | 5.1 |

Dans les tableaux, **une valeur en gras est sous le seuil** ; une valeur en maigre l'atteint. Les ambiances sont nommées comme dans le code (`rosee` pour rosée).

### 5.1 Couples acceptés par écrit

Deux accords écrits de Christophe, l'un du 21 octobre 2026 (R10), l'autre du 22 octobre 2026 (familles A à H).

**Accord du 21 octobre 2026 : décision R10, contrastes de l'ambiance ivoire gardés tels quels.** Texte de l'action R10, tel que `CLAUDE.md` le portait jusqu'au commit `2baa791` du 21 octobre 2026 : « trancher sur deux contrastes de l'ambiance ivoire (onglets inactifs 2,58, onglet Perso actif 2,87, sous le seuil de 3), charte figée en attendant ». Clôture inscrite dans `CLAUDE.md` le même jour : « R10 close sans changement (contrastes de l'ambiance ivoire gardés tels quels, charte figée) ».

| Élément | Texte | Fond | Taille, graisse | Seuil | Contraste | Accord |
|---|---|---|---|---|---|---|
| Onglet de catégorie inactif (toute catégorie) | `--ink3` `#A29A8C` | `--paper` `#F8F6F0` | 19 px, 700 (texte large) | 3 | 2,58 | 21 octobre 2026 (R10) |
| Onglet de catégorie actif en `#FF5A36` (Perso par défaut) | `#FF5A36` | `--paper` `#F8F6F0` | 19 px, 700 (texte large) | 3 | 2,87 | 21 octobre 2026 (R10) |

**Portée retenue** : ces deux couples exactement, c'est-à-dire ces deux couleurs, dans cet emploi, dans l'ambiance ivoire. L'accord porte sur la paire de couleurs : il vaut pour l'onglet inactif de toute catégorie, et pour l'onglet actif de toute catégorie en `#FF5A36`. L'onglet Corbeille, plus petit, n'en relève pas (paragraphe suivant). Les deux valeurs recalculées le 22 octobre 2026 sont celles que citait R10.

**Couverture douteuse de R10**, levée par l'accord du 22 octobre 2026 : la clôture parle des « contrastes de l'ambiance ivoire », sans les borner, alors que l'action n'en visait que deux. Les autres couples de l'ambiance ivoire sous le seuil (colonne ivoire des familles B, C, D, G et H ; les familles E et F ne dépendent pas de l'ambiance) n'étaient donc pas tenus pour acceptés par R10. Le cas le plus proche est l'onglet Corbeille inactif : même couleur, même contraste (2,58), mais 16 px en graisse 600, donc au seuil de 4,5 et non de 3.

**Accord du 22 octobre 2026 : familles A à H, acceptées telles quelles par Christophe** (« familles : on laisse tout comme c'est aujourd'hui »). Ces couples étaient tous dans l'app avant la charte des livrables 1.6.8 ; aucun n'est nouveau. Avant cette date, aucun accord écrit ne les couvrait. L'accord vaut aussi pour les couples de l'ambiance ivoire dont la couverture par R10 était douteuse.

#### A. Onglets de catégorie inactifs, hors ivoire

`--ink3` sur `--paper`. L'ambiance ivoire est couverte par R10 ; encre atteint le seuil.

| Élément | Taille, graisse | Seuil | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Onglet de catégorie inactif .tab (ink3 sur paper) | 19 px, 700 | 3 | **2,41** | **2,58** | **2,38** | **2,42** | **2,39** | **2,58** | **2,45** | **2,65** | 3,12 |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### B. Onglet de catégorie actif

Couleur de la catégorie sur `--paper`, 19 px, 700, texte large, seuil 3. Perso (`#FF5A36`) en ivoire est couvert par R10 et figure ici pour mémoire. Sous le seuil : Perso dans les sept autres ambiances claires, et six des douze couleurs proposées (`#F97316`, `#EAB308`, `#22C55E`, `#14B8A6`, `#06B6D4`, `#84CC16`) dans les huit ambiances claires. Pro (`#0052FF`) atteint le seuil partout. En encre, toutes les couleurs atteignent le seuil.

| Couleur de catégorie | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|
| `#FF5A36` (Perso) | **2,81** | **2,87** | **2,76** | **2,73** | **2,77** | **2,74** | **2,73** | **2,72** | 5,67 |
| `#0052FF` (Pro) | 5,21 | 5,32 | 5,12 | 5,06 | 5,14 | 5,09 | 5,07 | 5,05 | 3,06 |
| `#8B5CF6` | 3,84 | 3,92 | 3,77 | 3,73 | 3,79 | 3,74 | 3,73 | 3,72 | 4,16 |
| `#EC4899` | 3,19 | 3,26 | 3,14 | 3,10 | 3,15 | 3,12 | 3,11 | 3,10 | 4,99 |
| `#EF4444` | 3,41 | 3,48 | 3,35 | 3,31 | 3,36 | 3,33 | 3,32 | 3,30 | 4,68 |
| `#F97316` | **2,54** | **2,59** | **2,49** | **2,47** | **2,51** | **2,48** | **2,47** | **2,46** | 6,28 |
| `#EAB308` | **1,74** | **1,77** | **1,71** | **1,69** | **1,71** | **1,70** | **1,69** | **1,68** | 9,18 |
| `#22C55E` | **2,06** | **2,11** | **2,03** | **2,01** | **2,04** | **2,02** | **2,01** | **2,00** | 7,73 |
| `#14B8A6` | **2,25** | **2,30** | **2,22** | **2,19** | **2,23** | **2,20** | **2,19** | **2,18** | 7,07 |
| `#06B6D4` | **2,20** | **2,25** | **2,16** | **2,14** | **2,17** | **2,15** | **2,14** | **2,13** | 7,25 |
| `#D946EF` | 3,13 | 3,20 | 3,08 | 3,04 | 3,09 | 3,06 | 3,05 | 3,03 | 5,09 |
| `#84CC16` | **1,79** | **1,83** | **1,76** | **1,74** | **1,77** | **1,75** | **1,74** | **1,73** | 8,91 |

L'accord couvre les douze couleurs proposées, quelles que soient celles des catégories enregistrées, non relues (section 3.4). Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### C. Autres textes en `--ink3`

`--ink3` sur `--paper` (onglet Corbeille, « + », « Terminées ») ou sur `--field` (texte indicatif, libellés, croix). Sous le seuil dans les neuf ambiances, encre comprise. La colonne ivoire, de couverture douteuse par R10, est couverte par l'accord du 22 octobre 2026.

| Élément | Taille, graisse | Seuil | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Onglet Corbeille inactif .trash-tab (ink3 sur paper) | 16 px, 600 | 4,5 | **2,41** | **2,58** | **2,38** | **2,42** | **2,39** | **2,58** | **2,45** | **2,65** | **3,12** |
| Bouton + .tab-add (ink3 sur paper) | 21 px, 500 | 4,5 | **2,41** | **2,58** | **2,38** | **2,42** | **2,39** | **2,58** | **2,45** | **2,65** | **3,12** |
| Intitulé Terminées .done-lbl (ink3 sur paper) | 13 px, 700 | 4,5 | **2,41** | **2,58** | **2,38** | **2,42** | **2,39** | **2,58** | **2,45** | **2,65** | **3,12** |
| Zone Nouvelle tâche, texte indicatif ::placeholder (ink3 sur field) | 17 px, 500 | 4,5 | **2,66** | **2,79** | **2,67** | **2,69** | **2,62** | **2,86** | **2,73** | **2,93** | **2,80** |
| Libellés .clbl de la feuille et des catégories (ink3 sur field) | 11 px, 700 | 4,5 | **2,66** | **2,79** | **2,67** | **2,69** | **2,62** | **2,86** | **2,73** | **2,93** | **2,80** |
| Croix de fermeture .modal-close (ink3 sur field) | 20 px, 400 | 4,5 | **2,66** | **2,79** | **2,67** | **2,69** | **2,62** | **2,86** | **2,73** | **2,93** | **2,80** |
| État vide .es p (ink3, bloc à 35 %, sur paper) | 19 px, 700 | 3 | **1,32** | **1,34** | **1,31** | **1,32** | **1,32** | **1,35** | **1,32** | **1,35** | **1,42** |

S'y ajoute l'écran de chargement, aux couleurs fixes : marque « DAILY FLOW » `#94A29B` sur `#F3F4F1`, 11 px, 800, seuil 4,5 : **2,41**.

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### D. Tâches sans couleur à 50 % (faites, en glissement)

Rangée à 50 % d'opacité sur `--paper` ; à l'appui ou en glissement, fond `--chip`. Le titre d'une tâche en glissement (`--ink`) atteint le seuil (section 5.4).

| Élément | Taille, graisse | Seuil | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Tâche terminée, titre (ink3, rangée à 50 %, sur paper) | 21 px, 700 | 3 | **1,50** | **1,54** | **1,49** | **1,50** | **1,50** | **1,55** | **1,51** | **1,56** | **1,70** |
| Tâche terminée, appui, titre (ink3 sur chip, rangée à 50 %) | 21 px, 700 | 3 | **1,42** | **1,46** | **1,41** | **1,43** | **1,42** | **1,46** | **1,43** | **1,48** | **1,54** |
| Tâche terminée, détails (ink2, rangée à 50 %, sur paper) | 15,5 px, 500 | 4,5 | **2,02** | **2,08** | **2,03** | **2,04** | **2,03** | **2,10** | **2,03** | **2,12** | **2,75** |
| Tâche terminée, appui, détails (ink2 sur chip, rangée à 50 %) | 15,5 px, 500 | 4,5 | **1,92** | **1,97** | **1,93** | **1,94** | **1,92** | **2,00** | **1,92** | **2,01** | **2,50** |
| Tâche en glissement, détails (ink2 sur chip, rangée à 50 %) | 15,5 px, 500 | 4,5 | **1,92** | **1,97** | **1,93** | **1,94** | **1,92** | **2,00** | **1,92** | **2,01** | **2,50** |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### E. Tâches de couleur pleine, texte blanc

Blanc sur la teinte, indépendant de l'ambiance. Les titres atteignent le seuil sur sept teintes ; les détails (blanc à 85 %) et la saisie sont sous le seuil sur les douze.

| Couleur de la tâche | Titre, 21 px, 700, seuil 3 | Titre à l'appui, seuil 3 | Détails, 15,5 px, 500, seuil 4,5 | Détails à l'appui, seuil 4,5 | Saisie, 17 px, 500, seuil 4,5 |
|---|---|---|---|---|---|
| `#3B82F6` | 3,68 | 3,39 | **3,10** | **3,14** | **3,68** |
| `#6366F1` | 4,47 | 4,11 | **3,70** | **3,75** | **4,47** |
| `#8B5CF6` | 4,23 | 3,92 | **3,51** | **3,58** | **4,23** |
| `#EC4899` | 3,53 | 3,22 | **2,93** | **2,91** | **3,53** |
| `#EF4444` | 3,76 | 3,44 | **3,09** | **3,07** | **3,76** |
| `#F97316` | **2,80** | **2,63** | **2,41** | **2,45** | **2,80** |
| `#22C55E` | **2,28** | **2,07** | **2,00** | **1,97** | **2,28** |
| `#14B8A6` | **2,49** | **2,26** | **2,17** | **2,17** | **2,49** |
| `#06B6D4` | **2,43** | **2,20** | **2,11** | **2,11** | **2,43** |
| `#0EA5E9` | **2,77** | **2,52** | **2,38** | **2,39** | **2,77** |
| `#D946EF` | 3,46 | 3,16 | **2,88** | **2,86** | **3,46** |
| `#F43F5E` | 3,67 | 3,38 | **3,01** | **3,01** | **3,67** |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### F. Tâches pastel, texte blanc

Blanc sur la teinte, indépendant de l'ambiance. Sous le seuil pour toutes les teintes et tous les états.

| Couleur de la tâche | Titre, 21 px, 700, seuil 3 | Titre à l'appui, seuil 3 | Détails, 15,5 px, 500, seuil 4,5 | Détails à l'appui, seuil 4,5 | Saisie, 17 px, 500, seuil 4,5 |
|---|---|---|---|---|---|
| `#85B1F9` | **2,18** | **1,99** | **1,96** | **1,97** | **2,18** |
| `#9EA0F6` | **2,38** | **2,17** | **2,12** | **2,13** | **2,38** |
| `#B79AF9` | **2,33** | **2,13** | **2,08** | **2,09** | **2,33** |
| `#F38EC0` | **2,22** | **2,02** | **1,99** | **1,96** | **2,22** |
| `#F58B8B` | **2,35** | **2,15** | **2,08** | **2,07** | **2,35** |
| `#FBA86F` | **1,92** | **1,79** | **1,75** | **1,77** | **1,92** |
| `#76DB9B` | **1,70** | **1,53** | **1,57** | **1,51** | **1,70** |
| `#6DD3C8` | **1,78** | **1,61** | **1,63** | **1,58** | **1,78** |
| `#65D2E4` | **1,77** | **1,60** | **1,62** | **1,56** | **1,77** |
| `#6AC7F1` | **1,90** | **1,72** | **1,73** | **1,69** | **1,90** |
| `#E78CF5` | **2,22** | **2,02** | **1,98** | **1,95** | **2,22** |
| `#F8889B` | **2,34** | **2,17** | **2,07** | **2,08** | **2,34** |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### G. Tâches colorées faites ou en glissement

Rangée à 50 % d'opacité posée sur `--paper`, donc différente dans chaque ambiance ; titre en blanc à 65 % pour une tâche faite, en blanc pour une tâche en glissement ; détails en blanc à 85 %. Sous le seuil pour les 24 teintes, dans les neuf ambiances et tous les états. Le tableau donne, pour chaque teinte et chaque état, la plus faible et la plus forte des neuf valeurs ; le détail par ambiance est en annexe.

| Couleur de la tâche | Terminée, titre | Terminée, appui, titre | Terminée, détails | Terminée, appui, détails | Glissement, titre | Glissement, détails |
|---|---|---|---|---|---|---|
| `#3B82F6` | **1,52** à **1,81** | **1,53** à **1,84** | **1,71** à **2,16** | **1,73** à **2,22** | **1,86** à **2,47** | **1,71** à **2,16** |
| `#6366F1` | **1,60** à **1,96** | **1,62** à **2,00** | **1,82** à **2,39** | **1,85** à **2,45** | **2,00** à **2,76** | **1,82** à **2,39** |
| `#8B5CF6` | **1,58** à **1,92** | **1,60** à **1,97** | **1,80** à **2,34** | **1,83** à **2,40** | **1,97** à **2,69** | **1,80** à **2,34** |
| `#EC4899` | **1,54** à **1,78** | **1,55** à **1,80** | **1,75** à **2,16** | **1,76** à **2,18** | **1,92** à **2,49** | **1,75** à **2,16** |
| `#EF4444` | **1,58** à **1,83** | **1,59** à **1,84** | **1,81** à **2,24** | **1,82** à **2,27** | **2,00** à **2,60** | **1,81** à **2,24** |
| `#F97316` | **1,42** à **1,62** | **1,43** à **1,64** | **1,57** à **1,89** | **1,59** à **1,93** | **1,70** à **2,13** | **1,57** à **1,89** |
| `#22C55E` | **1,33** à **1,46** | **1,34** à **1,48** | **1,45** à **1,66** | **1,45** à **1,66** | **1,54** à **1,83** | **1,45** à **1,66** |
| `#14B8A6` | **1,36** à **1,52** | **1,37** à **1,54** | **1,49** à **1,75** | **1,50** à **1,76** | **1,60** à **1,94** | **1,49** à **1,75** |
| `#06B6D4` | **1,36** à **1,50** | **1,37** à **1,52** | **1,49** à **1,72** | **1,50** à **1,73** | **1,60** à **1,91** | **1,49** à **1,72** |
| `#0EA5E9` | **1,41** à **1,59** | **1,42** à **1,61** | **1,56** à **1,86** | **1,58** à **1,88** | **1,69** à **2,08** | **1,56** à **1,86** |
| `#D946EF` | **1,53** à **1,77** | **1,55** à **1,79** | **1,74** à **2,13** | **1,75** à **2,15** | **1,91** à **2,46** | **1,74** à **2,13** |
| `#F43F5E` | **1,58** à **1,81** | **1,59** à **1,82** | **1,81** à **2,22** | **1,82** à **2,25** | **1,99** à **2,58** | **1,81** à **2,22** |
| `#85B1F9` | **1,28** à **1,45** | **1,29** à **1,46** | **1,38** à **1,62** | **1,39** à **1,64** | **1,46** à **1,75** | **1,38** à **1,62** |
| `#9EA0F6` | **1,32** à **1,51** | **1,32** à **1,53** | **1,43** à **1,71** | **1,44** à **1,73** | **1,51** à **1,86** | **1,43** à **1,71** |
| `#B79AF9` | **1,31** à **1,50** | **1,32** à **1,52** | **1,42** à **1,69** | **1,43** à **1,71** | **1,50** à **1,84** | **1,42** à **1,69** |
| `#F38EC0` | **1,30** à **1,47** | **1,30** à **1,46** | **1,40** à **1,65** | **1,40** à **1,65** | **1,48** à **1,80** | **1,40** à **1,65** |
| `#F58B8B` | **1,32** à **1,50** | **1,32** à **1,51** | **1,43** à **1,70** | **1,44** à **1,71** | **1,52** à **1,87** | **1,43** à **1,70** |
| `#FBA86F` | **1,24** à **1,37** | **1,24** à **1,38** | **1,32** à **1,51** | **1,33** à **1,53** | **1,38** à **1,62** | **1,32** à **1,51** |
| `#76DB9B` | **1,19** à **1,29** | **1,20** à **1,30** | **1,26** à **1,39** | **1,24** à **1,36** | **1,31** à **1,48** | **1,26** à **1,39** |
| `#6DD3C8` | **1,21** à **1,32** | **1,22** à **1,33** | **1,28** à **1,43** | **1,27** à **1,41** | **1,34** à **1,53** | **1,28** à **1,43** |
| `#65D2E4` | **1,21** à **1,31** | **1,21** à **1,32** | **1,28** à **1,43** | **1,26** à **1,40** | **1,34** à **1,52** | **1,28** à **1,43** |
| `#6AC7F1` | **1,23** à **1,36** | **1,24** à **1,36** | **1,32** à **1,49** | **1,31** à **1,47** | **1,38** à **1,60** | **1,32** à **1,49** |
| `#E78CF5` | **1,30** à **1,46** | **1,30** à **1,47** | **1,40** à **1,65** | **1,40** à **1,64** | **1,49** à **1,80** | **1,40** à **1,65** |
| `#F8889B` | **1,32** à **1,50** | **1,33** à **1,51** | **1,43** à **1,70** | **1,44** à **1,72** | **1,52** à **1,86** | **1,43** à **1,70** |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

#### H. Rouge d'alerte

`--danger` `#EF4444`. En encre, « Vider la corbeille » au repos atteint le seuil.

| Élément | Taille, graisse | Seuil | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Vider la corbeille .empty-trash (danger sur paper) | 14 px, 700 | 4,5 | **3,41** | **3,48** | **3,35** | **3,31** | **3,36** | **3,33** | **3,32** | **3,30** | 4,68 |
| Vider la corbeille, survol (danger sur danger 8 %) | 14 px, 700 | 4,5 | **3,09** | **3,15** | **3,03** | **3,00** | **3,05** | **3,02** | **3,01** | **2,99** | **4,36** |
| Bouton Supprimer .btn-danger (blanc sur danger) | 13 px, 700 | 4,5 | **3,76** | **3,76** | **3,76** | **3,76** | **3,76** | **3,76** | **3,76** | **3,76** | **3,76** |

Accord : **accepté tel quel par Christophe le 22 octobre 2026**.

### 5.2 Couples sous le seuil sans accord écrit

Aucun au 22 octobre 2026. Un couple nouveau sous le seuil se soumet à Christophe avant d'être employé (section 7).

### 5.3 Hors du critère 1.4.3

**Pour information.** La section 1.11 de la charte des livrables vise le texte.

**États désactivés.** Le critère 1.4.3 de la WCAG exclut le texte des composants inactifs. Ces états sont passagers (bouton pendant un envoi) ou signalent une action impossible (« Déplacer » en bout de liste) :

| Élément | Taille, graisse | Seuil | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Connexion, bouton .lg-go désactivé (paper sur ink, bouton à 60 %) | 14 px, 700 | 4,5 | **4,25** | **4,32** | **4,31** | **4,25** | **4,30** | **4,41** | **4,28** | **4,46** | 6,35 |
| Connexion, lien .lg-link désactivé (ink2 à 60 % sur paper) | 14 px, 600 | 4,5 | **2,38** | **2,47** | **2,40** | **2,42** | **2,39** | **2,51** | **2,39** | **2,53** | **3,39** |
| Conflit, bouton .cf-go désactivé (paper sur ink, bouton à 40 %) | 14 px, 700 | 4,5 | **2,37** | **2,40** | **2,37** | **2,36** | **2,38** | **2,41** | **2,37** | **2,43** | **3,62** |
| Boutons Déplacer .move-row désactivés (ink2 à 30 % sur field) | 13 px, 700 | 4,5 | **1,52** | **1,54** | **1,53** | **1,53** | **1,52** | **1,55** | **1,53** | **1,56** | **1,77** |

**Repères graphiques, non calculés** : icônes des boutons ronds et des actions, cercles et coches des cases, pastilles de synchronisation, soulignement des onglets, pastilles de couleur et d'ambiance, barre de progression, bordures des champs. Ils relèvent du critère 1.4.11 de la WCAG (contraste du non-textuel), que la charte des livrables ne fixe pas.

### 5.4 Couples au-dessus des seuils

Tous les autres couples de texte atteignent le seuil dans les neuf ambiances. Plus faible et plus forte des neuf valeurs :

| Élément | Taille, graisse | Seuil | Plus faible | Plus fort |
|---|---|---|---|---|
| Titre du jour h1 (ink sur paper) | 30 px, 800 | 3 | 14,76 (sauge) | 15,76 (encre) |
| Sous-titre du jour h1 small (ink2 sur paper) | 15 px, 500 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Onglet Corbeille actif (ink2 sur paper) | 16 px, 600 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Bouton + .tab-add, survol (ink2 sur paper) | 21 px, 500 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Titre de tâche .ttitle (ink sur paper) | 21 px, 700 | 3 | 14,76 (sauge) | 15,76 (encre) |
| Titre de tâche, appui .row:active (ink sur chip) | 21 px, 700 | 3 | 12,81 (encre) | 13,99 (lavande) |
| Détails .tdetails (ink2 sur paper) | 15,5 px, 500 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Détails, appui (ink2 sur chip) | 15,5 px, 500 | 4,5 | 4,58 (galet) | 5,80 (encre) |
| Saisie dans la tâche .tedit (ink sur paper) | 17 px, 500 | 4,5 | 14,76 (sauge) | 15,76 (encre) |
| Tâche en glissement .row.drg, titre (ink sur chip, rangée à 50 %) | 21 px, 700 | 3 | 3,01 (galet) | 4,37 (encre) |
| Zone Nouvelle tâche #inp, saisie (ink sur field) | 17 px, 500 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Titre de la feuille .sht (ink sur field) | 18 px, 700 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Pastille Déplacer vers .move-pill (ink sur field) | 14 px, 700 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Pastille Déplacer vers, survol (ink sur chip) | 14 px, 700 | 4,5 | 11,27 (encre) | 15,45 (lavande) |
| Bouton Fermer .scl (paper sur ink) | 14 px, 700 | 4,5 | 14,76 (sauge) | 15,76 (encre) |
| Titre de modale .modal-title (ink sur field) | 18 px, 800 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Nom de catégorie, saisie (ink sur field) | 16 px, 600 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Boutons Déplacer .move-row (ink2 sur field) | 13 px, 700 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Boutons Déplacer, survol (ink2 sur chip) | 13 px, 700 | 4,5 | 5,03 (ciel) | 5,68 (lavande) |
| Bouton principal .btn-primary (paper sur ink) | 13 px, 700 | 4,5 | 14,76 (sauge) | 15,76 (encre) |
| Bouton Annuler .btn-cancel (ink2 sur chip) | 13 px, 700 | 4,5 | 5,03 (ciel) | 5,68 (lavande) |
| Libellés du menu .sy-lbl (ink2 sur field) | 11 px, 700 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Carte d'état .sy-t (ink sur chip, menu) | 15 px, 600 | 4,5 | 11,27 (encre) | 15,45 (lavande) |
| Carte d'état .sy-s (ink2 sur chip, menu) | 13,5 px, 400 | 4,5 | 5,03 (ciel) | 5,68 (lavande) |
| Bouton du menu .sy-btn (ink sur field) | 14 px, 700 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Compte .sy-acc (ink2 sur field) | 14 px, 400 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Bouton du menu .sbtn (ink sur chip) | 14 px, 700 | 4,5 | 11,27 (encre) | 15,45 (lavande) |
| Conflit .cf-n et .cf-p (ink2 sur field) | 13 px, 600 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Conflit .cf-k Ici, Ailleurs (ink2 sur field) | 11 px, 700 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Conflit .cf-v (ink sur field) | 17 px, 700 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Conflit .cf-m (ink2 sur field) | 13 px, 400 | 4,5 | 5,60 (ciel) | 6,39 (encre) |
| Conflit, bouton .cf-go (paper sur ink) | 14 px, 700 | 4,5 | 14,76 (sauge) | 15,76 (encre) |
| Connexion, marque .lg-mark (ink2 sur paper) | 11 px, 800 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Connexion, libellés .lg-f span (ink2 sur paper) | 13 px, 600 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Connexion, saisie (ink sur field) | 16 px, 600 | 4,5 | 14,12 (encre) | 17,25 (lavande) |
| Connexion, bouton .lg-go (paper sur ink) | 14 px, 700 | 4,5 | 14,76 (sauge) | 15,76 (encre) |
| Connexion, bouton .lg-alt (ink sur chip) | 14 px, 700 | 4,5 | 12,81 (encre) | 13,99 (lavande) |
| Connexion, note .lg-note (ink2 sur paper) | 13,5 px, 400 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Connexion, lien .lg-link (ink2 sur paper) | 14 px, 600 | 4,5 | 5,09 (galet) | 7,13 (encre) |
| Connexion, carte .sy-t (ink sur chip) | 15 px, 600 | 4,5 | 12,81 (encre) | 13,99 (lavande) |
| Connexion, carte .sy-s (ink2 sur chip) | 13,5 px, 400 | 4,5 | 4,58 (galet) | 5,80 (encre) |

Atteignent aussi le seuil : les valeurs en maigre des tableaux de la section 5.1 (onglets inactifs et « Vider la corbeille » en encre, couleurs de catégorie au-dessus de 3, titres des tâches de couleur pleine sur sept teintes).

---

## 6. Budget perso

Budget perso a sa propre charte, dans son dépôt (chrisbesan25/Budget, `docs/charte-application.md`, version 1.1 du 22 octobre 2026). Les deux apps partagent le même site, mais pas leur allure.

---

## 7. Règles d'évolution

1. Aucune couleur ni police de l'app ne change sans l'accord de Christophe.
2. Toute teinte nouvelle est vérifiée au calcul avant emploi, dans les neuf ambiances, et sa valeur de contraste est notée en commentaire dans le code (charte des livrables, section 1.11).
3. Un couple nouveau sous le seuil se soumet à Christophe avant emploi ; s'il est accepté, il entre en section 5.1 avec la date de l'accord.
4. À chaque changement d'allure ou nouvel accord sur un couple sous le seuil, ce fichier est mis à jour (version et date), puis sa copie dans le Contexte du projet Claude.

---

## Annexe : famille G, détail par ambiance

**Couleurs pleines.** Seuil 3 pour les titres (21 px, 700), 4,5 pour les détails (15,5 px, 500).

| Couleur, état | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|
| `#3B82F6`, terminée, titre | **1,52** | **1,52** | **1,52** | **1,52** | **1,52** | **1,52** | **1,52** | **1,52** | **1,81** |
| `#3B82F6`, terminée, appui, titre | **1,54** | **1,53** | **1,54** | **1,54** | **1,53** | **1,54** | **1,54** | **1,54** | **1,84** |
| `#3B82F6`, terminée, détails | **1,71** | **1,71** | **1,71** | **1,71** | **1,71** | **1,72** | **1,72** | **1,71** | **2,16** |
| `#3B82F6`, terminée, appui, détails | **1,74** | **1,73** | **1,74** | **1,74** | **1,73** | **1,74** | **1,75** | **1,74** | **2,22** |
| `#3B82F6`, glissement, titre | **1,86** | **1,86** | **1,87** | **1,87** | **1,86** | **1,87** | **1,88** | **1,87** | **2,47** |
| `#3B82F6`, glissement, détails | **1,71** | **1,71** | **1,71** | **1,71** | **1,71** | **1,72** | **1,72** | **1,71** | **2,16** |
| `#6366F1`, terminée, titre | **1,60** | **1,60** | **1,60** | **1,60** | **1,60** | **1,60** | **1,60** | **1,60** | **1,96** |
| `#6366F1`, terminée, appui, titre | **1,62** | **1,62** | **1,62** | **1,62** | **1,62** | **1,62** | **1,63** | **1,62** | **2,00** |
| `#6366F1`, terminée, détails | **1,82** | **1,82** | **1,82** | **1,83** | **1,82** | **1,83** | **1,83** | **1,83** | **2,39** |
| `#6366F1`, terminée, appui, détails | **1,85** | **1,85** | **1,85** | **1,86** | **1,85** | **1,86** | **1,86** | **1,86** | **2,45** |
| `#6366F1`, glissement, titre | **2,00** | **2,00** | **2,01** | **2,01** | **2,00** | **2,01** | **2,01** | **2,01** | **2,76** |
| `#6366F1`, glissement, détails | **1,82** | **1,82** | **1,82** | **1,83** | **1,82** | **1,83** | **1,83** | **1,83** | **2,39** |
| `#8B5CF6`, terminée, titre | **1,58** | **1,58** | **1,58** | **1,59** | **1,58** | **1,58** | **1,59** | **1,58** | **1,92** |
| `#8B5CF6`, terminée, appui, titre | **1,60** | **1,60** | **1,60** | **1,61** | **1,60** | **1,60** | **1,61** | **1,60** | **1,97** |
| `#8B5CF6`, terminée, détails | **1,80** | **1,80** | **1,80** | **1,81** | **1,80** | **1,80** | **1,81** | **1,80** | **2,34** |
| `#8B5CF6`, terminée, appui, détails | **1,83** | **1,83** | **1,83** | **1,84** | **1,83** | **1,83** | **1,84** | **1,83** | **2,40** |
| `#8B5CF6`, glissement, titre | **1,98** | **1,97** | **1,98** | **1,99** | **1,98** | **1,98** | **1,99** | **1,98** | **2,69** |
| `#8B5CF6`, glissement, détails | **1,80** | **1,80** | **1,80** | **1,81** | **1,80** | **1,80** | **1,81** | **1,80** | **2,34** |
| `#EC4899`, terminée, titre | **1,54** | **1,54** | **1,55** | **1,55** | **1,55** | **1,54** | **1,54** | **1,54** | **1,78** |
| `#EC4899`, terminée, appui, titre | **1,55** | **1,55** | **1,56** | **1,56** | **1,56** | **1,55** | **1,55** | **1,56** | **1,80** |
| `#EC4899`, terminée, détails | **1,75** | **1,75** | **1,76** | **1,76** | **1,76** | **1,75** | **1,75** | **1,76** | **2,16** |
| `#EC4899`, terminée, appui, détails | **1,77** | **1,76** | **1,77** | **1,78** | **1,77** | **1,76** | **1,77** | **1,77** | **2,18** |
| `#EC4899`, glissement, titre | **1,93** | **1,92** | **1,93** | **1,94** | **1,93** | **1,92** | **1,93** | **1,93** | **2,49** |
| `#EC4899`, glissement, détails | **1,75** | **1,75** | **1,76** | **1,76** | **1,76** | **1,75** | **1,75** | **1,76** | **2,16** |
| `#EF4444`, terminée, titre | **1,59** | **1,58** | **1,59** | **1,59** | **1,59** | **1,58** | **1,59** | **1,59** | **1,83** |
| `#EF4444`, terminée, appui, titre | **1,60** | **1,59** | **1,60** | **1,60** | **1,60** | **1,59** | **1,60** | **1,60** | **1,84** |
| `#EF4444`, terminée, détails | **1,82** | **1,81** | **1,82** | **1,83** | **1,83** | **1,81** | **1,82** | **1,82** | **2,24** |
| `#EF4444`, terminée, appui, détails | **1,83** | **1,82** | **1,84** | **1,84** | **1,84** | **1,83** | **1,83** | **1,84** | **2,27** |
| `#EF4444`, glissement, titre | **2,01** | **2,00** | **2,01** | **2,02** | **2,02** | **2,00** | **2,01** | **2,01** | **2,60** |
| `#EF4444`, glissement, détails | **1,82** | **1,81** | **1,82** | **1,83** | **1,83** | **1,81** | **1,82** | **1,82** | **2,24** |
| `#F97316`, terminée, titre | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,62** |
| `#F97316`, terminée, appui, titre | **1,43** | **1,43** | **1,44** | **1,44** | **1,44** | **1,43** | **1,43** | **1,44** | **1,64** |
| `#F97316`, terminée, détails | **1,58** | **1,57** | **1,58** | **1,58** | **1,58** | **1,58** | **1,58** | **1,58** | **1,89** |
| `#F97316`, terminée, appui, détails | **1,60** | **1,59** | **1,60** | **1,60** | **1,60** | **1,59** | **1,59** | **1,60** | **1,93** |
| `#F97316`, glissement, titre | **1,70** | **1,70** | **1,71** | **1,71** | **1,71** | **1,70** | **1,70** | **1,71** | **2,13** |
| `#F97316`, glissement, détails | **1,58** | **1,57** | **1,58** | **1,58** | **1,58** | **1,58** | **1,58** | **1,58** | **1,89** |
| `#22C55E`, terminée, titre | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,46** |
| `#22C55E`, terminée, appui, titre | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,48** |
| `#22C55E`, terminée, détails | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,46** | **1,45** | **1,45** | **1,66** |
| `#22C55E`, terminée, appui, détails | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,66** |
| `#22C55E`, glissement, titre | **1,55** | **1,54** | **1,55** | **1,55** | **1,54** | **1,55** | **1,55** | **1,55** | **1,83** |
| `#22C55E`, glissement, détails | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,46** | **1,45** | **1,45** | **1,66** |
| `#14B8A6`, terminée, titre | **1,36** | **1,36** | **1,36** | **1,36** | **1,36** | **1,37** | **1,37** | **1,37** | **1,52** |
| `#14B8A6`, terminée, appui, titre | **1,37** | **1,37** | **1,37** | **1,37** | **1,37** | **1,38** | **1,38** | **1,38** | **1,54** |
| `#14B8A6`, terminée, détails | **1,50** | **1,50** | **1,50** | **1,50** | **1,49** | **1,50** | **1,50** | **1,50** | **1,75** |
| `#14B8A6`, terminée, appui, détails | **1,51** | **1,51** | **1,51** | **1,51** | **1,50** | **1,51** | **1,51** | **1,51** | **1,76** |
| `#14B8A6`, glissement, titre | **1,60** | **1,60** | **1,61** | **1,61** | **1,60** | **1,61** | **1,61** | **1,61** | **1,94** |
| `#14B8A6`, glissement, détails | **1,50** | **1,50** | **1,50** | **1,50** | **1,49** | **1,50** | **1,50** | **1,50** | **1,75** |
| `#06B6D4`, terminée, titre | **1,36** | **1,36** | **1,36** | **1,36** | **1,36** | **1,36** | **1,36** | **1,36** | **1,50** |
| `#06B6D4`, terminée, appui, titre | **1,37** | **1,37** | **1,37** | **1,37** | **1,37** | **1,38** | **1,38** | **1,37** | **1,52** |
| `#06B6D4`, terminée, détails | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,50** | **1,50** | **1,50** | **1,72** |
| `#06B6D4`, terminée, appui, détails | **1,50** | **1,50** | **1,50** | **1,50** | **1,50** | **1,51** | **1,51** | **1,50** | **1,73** |
| `#06B6D4`, glissement, titre | **1,60** | **1,60** | **1,60** | **1,60** | **1,60** | **1,61** | **1,61** | **1,61** | **1,91** |
| `#06B6D4`, glissement, détails | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,50** | **1,50** | **1,50** | **1,72** |
| `#0EA5E9`, terminée, titre | **1,41** | **1,41** | **1,41** | **1,41** | **1,41** | **1,42** | **1,42** | **1,41** | **1,59** |
| `#0EA5E9`, terminée, appui, titre | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,43** | **1,43** | **1,43** | **1,61** |
| `#0EA5E9`, terminée, détails | **1,57** | **1,56** | **1,57** | **1,57** | **1,56** | **1,57** | **1,57** | **1,57** | **1,86** |
| `#0EA5E9`, terminée, appui, détails | **1,58** | **1,58** | **1,58** | **1,58** | **1,58** | **1,59** | **1,59** | **1,59** | **1,88** |
| `#0EA5E9`, glissement, titre | **1,69** | **1,69** | **1,69** | **1,69** | **1,69** | **1,70** | **1,70** | **1,69** | **2,08** |
| `#0EA5E9`, glissement, détails | **1,57** | **1,56** | **1,57** | **1,57** | **1,56** | **1,57** | **1,57** | **1,57** | **1,86** |
| `#D946EF`, terminée, titre | **1,54** | **1,53** | **1,54** | **1,54** | **1,54** | **1,53** | **1,54** | **1,54** | **1,77** |
| `#D946EF`, terminée, appui, titre | **1,55** | **1,55** | **1,55** | **1,56** | **1,55** | **1,55** | **1,55** | **1,55** | **1,79** |
| `#D946EF`, terminée, détails | **1,74** | **1,74** | **1,75** | **1,75** | **1,75** | **1,74** | **1,75** | **1,74** | **2,13** |
| `#D946EF`, terminée, appui, détails | **1,76** | **1,75** | **1,76** | **1,77** | **1,76** | **1,75** | **1,76** | **1,76** | **2,15** |
| `#D946EF`, glissement, titre | **1,91** | **1,91** | **1,92** | **1,93** | **1,92** | **1,91** | **1,92** | **1,92** | **2,46** |
| `#D946EF`, glissement, détails | **1,74** | **1,74** | **1,75** | **1,75** | **1,75** | **1,74** | **1,75** | **1,74** | **2,13** |
| `#F43F5E`, terminée, titre | **1,58** | **1,58** | **1,59** | **1,59** | **1,59** | **1,58** | **1,58** | **1,59** | **1,81** |
| `#F43F5E`, terminée, appui, titre | **1,59** | **1,59** | **1,60** | **1,60** | **1,60** | **1,59** | **1,59** | **1,60** | **1,82** |
| `#F43F5E`, terminée, détails | **1,81** | **1,81** | **1,82** | **1,82** | **1,82** | **1,81** | **1,81** | **1,82** | **2,22** |
| `#F43F5E`, terminée, appui, détails | **1,83** | **1,82** | **1,84** | **1,84** | **1,84** | **1,83** | **1,83** | **1,83** | **2,25** |
| `#F43F5E`, glissement, titre | **2,00** | **1,99** | **2,01** | **2,02** | **2,01** | **2,00** | **2,00** | **2,01** | **2,58** |
| `#F43F5E`, glissement, détails | **1,81** | **1,81** | **1,82** | **1,82** | **1,82** | **1,81** | **1,81** | **1,82** | **2,22** |

**Pastels.** Seuil 3 pour les titres (21 px, 700), 4,5 pour les détails (15,5 px, 500).

| Couleur, état | galet | ivoire | brume | sauge | ciel | rosee | sable | lavande | encre |
|---|---|---|---|---|---|---|---|---|---|
| `#85B1F9`, terminée, titre | **1,28** | **1,28** | **1,28** | **1,28** | **1,28** | **1,29** | **1,29** | **1,28** | **1,45** |
| `#85B1F9`, terminée, appui, titre | **1,29** | **1,29** | **1,29** | **1,29** | **1,29** | **1,29** | **1,30** | **1,29** | **1,46** |
| `#85B1F9`, terminée, détails | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,62** |
| `#85B1F9`, terminée, appui, détails | **1,39** | **1,39** | **1,39** | **1,39** | **1,39** | **1,39** | **1,40** | **1,39** | **1,64** |
| `#85B1F9`, glissement, titre | **1,46** | **1,46** | **1,46** | **1,46** | **1,46** | **1,46** | **1,46** | **1,46** | **1,75** |
| `#85B1F9`, glissement, détails | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,62** |
| `#9EA0F6`, terminée, titre | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,51** |
| `#9EA0F6`, terminée, appui, titre | **1,33** | **1,32** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,53** |
| `#9EA0F6`, terminée, détails | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,71** |
| `#9EA0F6`, terminée, appui, détails | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,73** |
| `#9EA0F6`, glissement, titre | **1,51** | **1,51** | **1,51** | **1,52** | **1,51** | **1,52** | **1,52** | **1,52** | **1,86** |
| `#9EA0F6`, glissement, détails | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,71** |
| `#B79AF9`, terminée, titre | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,50** |
| `#B79AF9`, terminée, appui, titre | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,52** |
| `#B79AF9`, terminée, détails | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,69** |
| `#B79AF9`, terminée, appui, détails | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,43** | **1,71** |
| `#B79AF9`, glissement, titre | **1,50** | **1,50** | **1,50** | **1,51** | **1,50** | **1,50** | **1,51** | **1,50** | **1,84** |
| `#B79AF9`, glissement, détails | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,42** | **1,69** |
| `#F38EC0`, terminée, titre | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,47** |
| `#F38EC0`, terminée, appui, titre | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,46** |
| `#F38EC0`, terminée, détails | **1,41** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,41** | **1,41** | **1,65** |
| `#F38EC0`, terminée, appui, détails | **1,40** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,40** | **1,41** | **1,65** |
| `#F38EC0`, glissement, titre | **1,49** | **1,48** | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,80** |
| `#F38EC0`, glissement, détails | **1,41** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,41** | **1,41** | **1,65** |
| `#F58B8B`, terminée, titre | **1,32** | **1,32** | **1,32** | **1,33** | **1,33** | **1,32** | **1,32** | **1,32** | **1,50** |
| `#F58B8B`, terminée, appui, titre | **1,33** | **1,32** | **1,33** | **1,33** | **1,33** | **1,32** | **1,33** | **1,33** | **1,51** |
| `#F58B8B`, terminée, détails | **1,44** | **1,43** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,70** |
| `#F58B8B`, terminée, appui, détails | **1,44** | **1,44** | **1,44** | **1,45** | **1,45** | **1,44** | **1,44** | **1,44** | **1,71** |
| `#F58B8B`, glissement, titre | **1,53** | **1,52** | **1,53** | **1,53** | **1,53** | **1,53** | **1,53** | **1,53** | **1,87** |
| `#F58B8B`, glissement, détails | **1,44** | **1,43** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,70** |
| `#FBA86F`, terminée, titre | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,37** |
| `#FBA86F`, terminée, appui, titre | **1,25** | **1,24** | **1,25** | **1,25** | **1,25** | **1,25** | **1,25** | **1,25** | **1,38** |
| `#FBA86F`, terminée, détails | **1,32** | **1,32** | **1,32** | **1,33** | **1,33** | **1,32** | **1,32** | **1,33** | **1,51** |
| `#FBA86F`, terminée, appui, détails | **1,33** | **1,33** | **1,33** | **1,34** | **1,34** | **1,33** | **1,33** | **1,34** | **1,53** |
| `#FBA86F`, glissement, titre | **1,39** | **1,38** | **1,39** | **1,39** | **1,39** | **1,39** | **1,39** | **1,39** | **1,62** |
| `#FBA86F`, glissement, détails | **1,32** | **1,32** | **1,32** | **1,33** | **1,33** | **1,32** | **1,32** | **1,33** | **1,51** |
| `#76DB9B`, terminée, titre | **1,19** | **1,19** | **1,19** | **1,19** | **1,19** | **1,20** | **1,19** | **1,19** | **1,29** |
| `#76DB9B`, terminée, appui, titre | **1,20** | **1,20** | **1,20** | **1,20** | **1,20** | **1,20** | **1,20** | **1,20** | **1,30** |
| `#76DB9B`, terminée, détails | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,39** |
| `#76DB9B`, terminée, appui, détails | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,36** |
| `#76DB9B`, glissement, titre | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,32** | **1,31** | **1,31** | **1,48** |
| `#76DB9B`, glissement, détails | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,26** | **1,39** |
| `#6DD3C8`, terminée, titre | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,32** |
| `#6DD3C8`, terminée, appui, titre | **1,22** | **1,22** | **1,22** | **1,22** | **1,22** | **1,22** | **1,22** | **1,22** | **1,33** |
| `#6DD3C8`, terminée, détails | **1,28** | **1,28** | **1,28** | **1,28** | **1,28** | **1,29** | **1,29** | **1,29** | **1,43** |
| `#6DD3C8`, terminée, appui, détails | **1,27** | **1,27** | **1,27** | **1,27** | **1,27** | **1,27** | **1,27** | **1,27** | **1,41** |
| `#6DD3C8`, glissement, titre | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,53** |
| `#6DD3C8`, glissement, détails | **1,28** | **1,28** | **1,28** | **1,28** | **1,28** | **1,29** | **1,29** | **1,29** | **1,43** |
| `#65D2E4`, terminée, titre | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,31** |
| `#65D2E4`, terminée, appui, titre | **1,21** | **1,21** | **1,21** | **1,21** | **1,21** | **1,22** | **1,22** | **1,22** | **1,32** |
| `#65D2E4`, terminée, détails | **1,28** | **1,28** | **1,28** | **1,28** | **1,28** | **1,29** | **1,29** | **1,28** | **1,43** |
| `#65D2E4`, terminée, appui, détails | **1,26** | **1,26** | **1,26** | **1,27** | **1,26** | **1,27** | **1,27** | **1,27** | **1,40** |
| `#65D2E4`, glissement, titre | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,34** | **1,52** |
| `#65D2E4`, glissement, détails | **1,28** | **1,28** | **1,28** | **1,28** | **1,28** | **1,29** | **1,29** | **1,28** | **1,43** |
| `#6AC7F1`, terminée, titre | **1,24** | **1,24** | **1,24** | **1,24** | **1,23** | **1,24** | **1,24** | **1,24** | **1,36** |
| `#6AC7F1`, terminée, appui, titre | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,24** | **1,36** |
| `#6AC7F1`, terminée, détails | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,49** |
| `#6AC7F1`, terminée, appui, détails | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,31** | **1,47** |
| `#6AC7F1`, glissement, titre | **1,38** | **1,38** | **1,38** | **1,38** | **1,38** | **1,39** | **1,39** | **1,38** | **1,60** |
| `#6AC7F1`, glissement, détails | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,32** | **1,49** |
| `#E78CF5`, terminée, titre | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,30** | **1,46** |
| `#E78CF5`, terminée, appui, titre | **1,30** | **1,30** | **1,30** | **1,31** | **1,30** | **1,30** | **1,30** | **1,30** | **1,47** |
| `#E78CF5`, terminée, détails | **1,40** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,41** | **1,41** | **1,65** |
| `#E78CF5`, terminée, appui, détails | **1,40** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,41** | **1,40** | **1,64** |
| `#E78CF5`, glissement, titre | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,49** | **1,80** |
| `#E78CF5`, glissement, détails | **1,40** | **1,40** | **1,41** | **1,41** | **1,41** | **1,40** | **1,41** | **1,41** | **1,65** |
| `#F8889B`, terminée, titre | **1,32** | **1,32** | **1,32** | **1,33** | **1,33** | **1,32** | **1,32** | **1,32** | **1,50** |
| `#F8889B`, terminée, appui, titre | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,33** | **1,51** |
| `#F8889B`, terminée, détails | **1,44** | **1,43** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,70** |
| `#F8889B`, terminée, appui, détails | **1,45** | **1,44** | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,45** | **1,72** |
| `#F8889B`, glissement, titre | **1,53** | **1,52** | **1,53** | **1,53** | **1,53** | **1,53** | **1,53** | **1,53** | **1,86** |
| `#F8889B`, glissement, détails | **1,44** | **1,43** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,44** | **1,70** |
