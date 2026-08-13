# Historique des demandes — Org Wider

> Fichier créé avec Claude Code le 2026-08-13, à la demande de msavane,
> pour suivre les demandes remontées par les testeurs sur l'org **Wider**
> (retours de test), leur traitement en `test/`, et leur passage en `prod/`.

## Contexte

Ce repo sert à traiter les retours de test sur l'org **Wider** :
- `test/` : demandes reçues et travaillées côté sandbox de test.
- `prod/` : demandes validées en test et prêtes à être déployées en prod.

## Suivi des demandes

| # | Date | Demandeur | Objet | Demande | Statut test | Statut prod | Notes |
|---|------|-----------|-------|---------|-------------|-------------|-------|
| 1 | 2026-08-13 | Ana | Tâche | Ajouter l'astérisque rouge (*information requise) sur le champ **Sous-type** (`TaskSubtype`) de la Tâche : sans sous-type choisi, impossible d'ajouter un commentaire, mais rien ne l'indique visuellement comme obligatoire → confusion, ressemble à un bug. | **traité en test** (déployé 2026-08-13, Deploy ID `0AfbW000009QrxySAC`) | à valider par Ana avant passage prod | `TaskSubtype` : `updateable=false` (non modifiable après création) et `restrictedPicklist=true` (valeurs Task/Email/ListEmail/Cadence/Call/LinkedIn figées par Salesforce, non personnalisables). Fix appliqué : `Task-Task Layout`, comportement `TaskSubtype` passé de `Edit` à `Required`. |
| 2 | 2026-08-13 | Ana | Tâche | **Créer une série récurrente** (case à cocher lors de la création d'une tâche) ne fonctionne pas. Demande de vérifier ce que c'est, à quoi ça sert, et pourquoi ça ne marche pas. | **traité en test** (déployé 2026-08-13, Deploy ID `0AfbW000009QrxySAC`) | à valider par Ana avant passage prod | Champ réel : `IsRecurrence` ("Create Recurring Series of Tasks"). Cause : absent du layout du Quick Action global **NewTask** (utilisé partout en Lightning). `enableRecurringTasks=true` déjà actif en Activity Settings, donc pas un souci de config org. Fix appliqué : ajout du champ `IsRecurrence` au layout du Quick Action `NewTask`. |
| 3 | 2026-08-13 | msavane | Tâche | Créer un champ custom **Categorie Tâche** (picklist) pour remplacer l'usage métier de `TaskSubtype` (qui est verrouillé après création et à valeurs figées). Valeurs : Tâche, Tâche SAV, Rédiger offre, Mise à jour offre, Remplir soumission, Marché Public, Projet à suivre, Offre interne. | à traiter | — | API name à valider (éviter `Type__c`, mot réservé SOQL/Apex) — proposition `Categorie_Tache__c`. Reste à définir : layouts/quick actions cibles (`Task-Task Layout`, `NewTask`, `LogACall`...), requis ou non. |

Statuts possibles : `à traiter` / `en cours` / `traité en test` / `prêt pour prod` / `déployé en prod`.

## Connexion org de test

- Org de test connecté via Salesforce CLI : alias `wider-test`, username `admin.wider@upmind.fr.test`, instance `https://widersa2025--test.sandbox.my.salesforce.com` (connexion établie le 2026-08-13 via `sf org login web`).
- Le connecteur MCP `claude.ai SF Wider STG` reste non authentifié — non utilisé, le flux CLI est privilégié pour ce projet.
