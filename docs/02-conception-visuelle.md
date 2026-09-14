# Dossier de conception visuelle — Boutik Malin

**Lien Figma (wireframes) :** _[à compléter avec le lien de partage Figma]_

## 1. Layout général mobile

L'application repose sur une structure mobile standard, pensée pour une utilisation rapide et à une main :

- **AppBar** en haut de chaque écran, avec le titre de l'écran et, selon le contexte, une icône d'action (recherche, notifications, modifier/supprimer).
- **BottomNavigationBar** à 4 onglets fixes : Dashboard, Produits, Historique, Paramètres. Chaque onglet conserve son état grâce à un `IndexedStack`.
- **Bouton d'action flottant (FAB)** "+" présent sur le Dashboard et la liste des produits, pour enregistrer un mouvement de stock ou ajouter un produit sans naviguer plusieurs écrans.
- **Zone de contenu** scrollable, organisée en cartes (cards) pour regrouper l'information de façon lisible.

## 2. Wireframes des écrans principaux

| Écran | Contenu clé |
|---|---|
| **Accueil / Dashboard** | 3 cartes statistiques (valeur totale du stock, produits en alerte, mouvements du jour), liste des alertes de stock bas, liste des derniers mouvements, FAB. |
| **Liste des produits** | Barre de recherche, filtres par catégorie (chips), cartes produits (photo, nom, prix, quantité, badge d'alerte), FAB. |
| **Détail produit** | Photo, informations complètes (catégorie, prix, quantité, seuil), bouton "Enregistrer un mouvement", historique des mouvements du produit. |
| **Ajout / édition produit** | Zone photo, formulaire (nom, catégorie, prix unitaire, quantité initiale, seuil d'alerte), validation des champs, boutons Enregistrer/Annuler. |
| **Nouveau mouvement de stock** | Sélecteur de produit, toggle Entrée/Sortie, quantité (+/-), motif, aperçu du stock résultant, bouton Valider. |
| **Historique** | Filtres (type, période, catégorie), liste chronologique groupée par date. |
| **Paramètres** | Seuil d'alerte par défaut, export CSV, thème clair/sombre, version de l'app. |

## 3. Flux utilisateurs

**Parcours 1 — Ajouter un produit**
Dashboard ou Liste produits → FAB "+" → Formulaire d'ajout (photo + informations) → Enregistrer → retour à la Liste produits, nouveau produit visible.

**Parcours 2 — Enregistrer une sortie de stock (vente)**
Détail produit (ou FAB) → Nouveau mouvement → sélection "Sortie" → quantité + motif → Valider → retour à l'écran précédent, quantité mise à jour immédiatement.

**Parcours 3 — Consulter une alerte et réapprovisionner**
Dashboard → carte "Produits en alerte" → sélection d'un produit → Détail produit → bouton "Enregistrer un mouvement" → "Entrée" → quantité réapprovisionnée → stock mis à jour, sortie de l'état d'alerte si le seuil est dépassé.

## 4. Style de base

### Palette de couleurs

| Couleur | Code | Usage |
|---|---|---|
| Bleu foncé | `#1F3A5F` | Couleur principale (AppBar, éléments de navigation, titres) |
| Corail | `#E84C3D` | Accent — alertes de stock bas, actions importantes |
| Vert | `#2ECC71` | Indicateurs positifs (stock suffisant) |
| Blanc cassé | `#FAFAFA` | Fond général |
| Gris foncé | `#2C2C2C` | Texte principal |

### Typographie
Police sans-serif simple et lisible (type Inter ou Roboto), avec une hiérarchie claire : grands titres pour les écrans, texte moyen pour les cartes, texte plus petit pour les métadonnées (dates, catégories).

### Boutons et messages
- Bouton principal plein (couleur primaire) pour l'action attendue (Enregistrer, Valider).
- Bouton secondaire discret (contour ou texte) pour Annuler.
- Messages d'erreur affichés directement sous le champ concerné, en rouge/corail, avec un texte explicite (ex. "Le prix doit être supérieur à 0").

## 5. Accessibilité simple

- Zones tactiles suffisamment grandes (boutons et cartes d'au moins 44x44 px) pour une utilisation confortable au pouce.
- Contraste élevé entre le texte et le fond, particulièrement pour les badges d'alerte.
- Tailles de police lisibles sans zoom, cohérentes sur l'ensemble des écrans.
- Icônes toujours accompagnées d'un libellé texte pour éviter toute ambiguïté (pas d'icône seule pour une action importante).
