# Stock Flutter

Application Flutter de gestion de stock SAAS simplifiee, structuree en couches
`data / domain / presentation`, avec `GoRouter`, `Riverpod`, `dio`,
`Firebase Auth` et `Cloud Firestore`.

## Fonctionnalites

- Authentification email/mot de passe via Firebase.
- Isolation des donnees par client avec la structure
  `clients/{uid}/categories`, `clients/{uid}/products`, `clients/{uid}/movements`.
- Ajout de categories et de produits.
- Ajout d'entrees en stock.
- Enregistrement des ventes avec controle de stock insuffisant.
- Dashboard avec:
  - plage de dates
  - produits les plus vendus
  - ventes par categorie
  - produits sous le seuil de reapprovisionnement
- Notifications de stock critique via webhook optionnel en utilisant `dio`.

## Architecture

- `lib/app`: bootstrap applicatif et routing `GoRouter`
- `lib/core`: theme, bootstrap Firebase, client `dio`
- `lib/data`: services Firebase / dio et implementations des repositories
- `lib/domain`: modeles metier et contrats de repositories
- `lib/presentation`: ecrans, widgets et providers Riverpod

Cette structure suit l'approche observee dans le projet `auth` du repertoire
principal, mais en la renforcant pour coller au DDDA demande dans l'examen.

## Configuration Firebase

L'application est compilee pour fonctionner avec Firebase, mais il faut ajouter
vos propres fichiers/configurations Firebase pour l'executer completement :

- Android : `android/app/google-services.json`
- iOS/macOS : `ios/Runner/GoogleService-Info.plist`
- Optionnel selon votre setup : `flutterfire configure`

Si Firebase n'est pas configure, l'application affiche un ecran de setup au
demarrage au lieu de crasher.

## Validation

- `flutter analyze` : OK
- `flutter test` : OK

## Bilan

- Temps utilise pour cette realisation : environ 35 minutes
- Jetons consommes : non exposes par l'environnement d'execution Codex sur cette session
