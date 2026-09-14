# Cahier des charges — Boutik Malin

## 1. Nom provisoire et contexte

**Boutik Malin** est une application mobile Flutter de **gestion de stock** destinée aux petits commerçants et artisans locaux (épicerie de quartier, atelier d'artisanat, petit producteur) qui souhaitent suivre leur inventaire — produits, quantités, prix — sans dépendre d'une connexion internet ni d'un logiciel de caisse complexe.

## 2. Problème / besoin

De nombreux commerçants locaux gèrent encore leur stock sur papier ou de mémoire. Cela rend difficile de savoir précisément ce qu'il reste en rayon, de connaître la valeur totale du stock, ou de repérer à temps qu'un produit est sur le point de manquer. Boutik Malin propose un outil simple et autonome, utilisable entièrement hors ligne, pour enregistrer les produits, suivre les entrées/sorties de stock et être alerté en cas de rupture proche.

## 3. Utilisateurs cibles

- **Le commerçant / artisan** : seul utilisateur de l'application. Il gère son catalogue de produits, enregistre les mouvements de stock (réapprovisionnement, vente) et consulte l'état de son inventaire.

L'application est **mono-utilisateur** et fonctionne entièrement sur l'appareil du commerçant, ce qui justifie pleinement un stockage local sans synchronisation.

## 4. Fonctionnalités

### Fonctionnalités principales
1. **Catalogue de produits** — liste des produits avec recherche par nom et filtre par catégorie.
2. **Fiche produit** — ajout et modification d'un produit : nom, catégorie, prix unitaire, quantité en stock, seuil d'alerte, photo.
3. **Mouvements de stock** — enregistrer une entrée (réapprovisionnement) ou une sortie (vente/perte), avec quantité, date et motif.
4. **Historique des mouvements** — journal consultable des entrées/sorties, globalement ou par produit.
5. **Alertes de stock bas** — mise en évidence des produits dont la quantité passe sous le seuil défini.
6. **Tableau de bord** — vue d'ensemble à l'ouverture de l'app : valeur totale du stock, nombre de produits en alerte, derniers mouvements enregistrés.

### Fonctionnalité optionnelle
- **Export du stock (CSV)** — exporter la liste du stock actuel dans un fichier consultable en dehors de l'application.

## 5. Données manipulées

| Donnée | Description |
|---|---|
| Produit | nom, catégorie, prix unitaire, quantité en stock, seuil d'alerte, photo |
| Catégorie | nom de la catégorie de produits |
| Mouvement de stock | produit concerné, type (entrée/sortie), quantité, date, motif |

## 6. Type de stockage

Stockage **local uniquement**, via **sqflite** (base de données SQLite embarquée) pour les produits, les catégories et les mouvements de stock, et **shared_preferences** pour les préférences simples (seuils par défaut, paramètres d'affichage). Ce choix a un sens fonctionnel fort ici : l'application est utilisée par un seul commerçant sur son propre appareil, sans besoin de synchronisation ni de serveur distant.

## 7. Exigences non fonctionnelles

- **Ergonomie** : navigation simple à 3 niveaux maximum (accueil/dashboard → liste → détail), enregistrement d'un mouvement de stock en quelques appuis.
- **Performance** : chargement de la liste de produits fluide même avec plusieurs dizaines d'articles ; images redimensionnées pour éviter les ralentissements.
- **Sécurité** : aucune donnée envoyée en ligne ; les données restent sur l'appareil du commerçant.
- **Accès hors ligne** : l'application doit être 100 % fonctionnelle sans connexion internet, le stockage étant local.
- **Sobriété / écoconception** : compression des images ajoutées au catalogue, limitation des reconstructions inutiles de widgets.

## 8. Critères de réussite et limites du projet

**Critères de réussite**
- Le commerçant peut ajouter, modifier et supprimer un produit de son catalogue.
- Le commerçant peut enregistrer une entrée ou une sortie de stock, et voir la quantité mise à jour immédiatement.
- Le tableau de bord affiche la valeur totale du stock et les produits en alerte de rupture.
- L'historique des mouvements est consultable et persiste après fermeture de l'application.
- L'application reste utilisable sans connexion internet.

**Limites assumées du projet (hors périmètre)**
- Pas de gestion de commandes clients ni de vente en ligne.
- Pas de compte utilisateur avec authentification en ligne.
- Pas de synchronisation multi-appareils (données locales à l'appareil).
- Pas de scan de code-barres (fonctionnalité envisageable en évolution future).
