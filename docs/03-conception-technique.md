# Dossier de conception technique — Boutik Malin

## 1. Architecture générale

Structure de dossiers Flutter classique, organisée par rôle :

```
lib/
├── main.dart
├── models/
│   ├── product.dart
│   ├── category.dart
│   └── stock_movement.dart
├── services/
│   └── database_service.dart        # accès sqflite (CRUD)
├── providers/
│   ├── product_provider.dart        # catalogue, alertes, dashboard
│   ├── stock_movement_provider.dart # enregistrement des mouvements
│   └── settings_provider.dart       # seuil par défaut, thème
├── screens/
│   ├── dashboard_screen.dart
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   ├── product_form_screen.dart
│   ├── stock_movement_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── stat_card.dart
│   ├── product_card.dart
│   ├── alert_tile.dart
│   └── movement_tile.dart
└── utils/
    ├── constants.dart
    └── formatters.dart               # formatage prix (intl), dates
```

## 2. Classes métier

| Classe | Attributs | Rôle |
|---|---|---|
| `Product` | `id`, `name`, `categoryId`, `unitPrice`, `quantity`, `alertThreshold`, `photoPath` | Représente un produit du catalogue et son état de stock actuel. |
| `Category` | `id`, `name` | Regroupe les produits pour le filtrage. |
| `StockMovement` | `id`, `productId`, `type` (enum `entry` / `exit`), `quantity`, `date`, `reason` | Trace un mouvement de stock (entrée ou sortie) lié à un produit. |

## 3. Gestion des données

- **sqflite** : base SQLite locale avec 3 tables — `products`, `categories`, `stock_movements` (clé étrangère `productId` vers `products`).
- Enregistrer un mouvement de stock déclenche, dans une même transaction sqflite : insertion dans `stock_movements` + mise à jour de `quantity` dans `products`.
- **shared_preferences** : seuil d'alerte par défaut, thème clair/sombre.
- Pas de données distantes ni de synchronisation (application mono-utilisateur, mono-appareil — cf. cahier des charges §6).

## 4. Gestion d'état

**Provider**, choisi pour sa simplicité et son adéquation avec le périmètre de deux semaines.

- `ProductProvider` : expose la liste des produits, les produits en alerte (calculé : `quantity <= alertThreshold`), la valeur totale du stock (calculé : somme `quantity * unitPrice`), et les méthodes CRUD (ajout/modification/suppression de produit).
- `StockMovementProvider` : expose l'historique des mouvements et la méthode `registerMovement()` qui met à jour le stock via `ProductProvider` et notifie les écouteurs.
- `SettingsProvider` : seuil par défaut, thème.

Les écrans consomment les providers via `Consumer`/`context.watch` en ciblant précisément les widgets concernés, pour éviter les reconstructions inutiles de toute la page.

## 5. Navigation

- `BottomNavigationBar` à 4 onglets (Dashboard, Produits, Historique, Paramètres) géré par un `IndexedStack` dans un écran racine `HomeScreen`, pour conserver l'état de chaque onglet.
- Navigation vers le détail/formulaire via `Navigator.push` (routes nommées `/product-detail`, `/product-form`, `/stock-movement`), avec passage de paramètres (`productId`) via les arguments de route.
- Le FAB "Nouveau mouvement" est accessible depuis le Dashboard et la liste produits.

## 6. Packages et plugins

| Package | Usage |
|---|---|
| `sqflite` | Base de données locale |
| `path` | Construction du chemin de la base de données |
| `provider` | Gestion d'état |
| `image_picker` | Ajout d'une photo produit (caméra/galerie) |
| `intl` | Formatage des prix et des dates |
| `csv` | Génération du fichier d'export (fonctionnalité optionnelle) |

Liste volontairement limitée (5-6 packages), cohérente avec la recommandation du périmètre (2 à 5 packages importants).

## 7. Tests prévus

- **Tests unitaires** : calcul du statut d'alerte d'un produit (`quantity <= alertThreshold`), calcul de la valeur totale du stock, mise à jour de quantité après un mouvement (entrée/sortie).
- **Tests de widgets** : affichage d'une `ProductCard` (nom, prix, badge d'alerte), validation du formulaire d'ajout de produit (champs obligatoires, prix positif).
- **Tests d'intégration** : parcours complet "ajouter un produit → l'enregistrer → le retrouver dans la liste avec la bonne quantité".

## 8. Debugging et performance

- **Flutter DevTools** : suivi des rebuilds inutiles (vérifier que seuls les widgets `Consumer` ciblés se reconstruisent lors d'un mouvement de stock), inspection mémoire pour les images produits.
- **Optimisation images** : redimensionnement/compression des photos ajoutées via `image_picker` avant stockage, pour limiter la taille de l'application et la mémoire utilisée.
- **Logs** : utilisation de `debugPrint` ciblé pendant le développement, retiré avant la version finale.

## 9. Déploiement

- Icône d'application définie via `flutter_launcher_icons`.
- Configuration Android minimale (`applicationId`, `minSdkVersion`).
- Génération d'un App Bundle (`flutter build appbundle`) si demandé.
- `README.md` avec description du projet, captures d'écran, prérequis et étapes d'installation.
- Dépôt GitHub avec commits réguliers reflétant l'avancement (structure → modèles → écrans → gestion d'état → tests).
