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
| 1 | 2026-08-13 | Ana | Tâche | Ajouter l'astérisque rouge (*information requise) sur le champ **Sous-type** de la Tâche : sans sous-type choisi, impossible d'ajouter un commentaire, mais rien ne l'indique visuellement comme obligatoire → confusion, ressemble à un bug. | à traiter | — | Connexion org de test en attente d'authentification MCP (voir section Connexion org de test). |
| 2 | 2026-08-13 | Ana | Tâche | **Créer une série récurrente** (case à cocher lors de la création d'une tâche) ne fonctionne pas. Demande de vérifier ce que c'est, à quoi ça sert, et pourquoi ça ne marche pas. | à traiter | — | Fonctionnalité standard Salesforce (Recurrence sur Task) — à confirmer sur l'org réelle. |

Statuts possibles : `à traiter` / `en cours` / `traité en test` / `prêt pour prod` / `déployé en prod`.

## Connexion org de test

- Aucun org "Wider" n'est authentifié en local via `sf org list` (Salesforce CLI).
- Le connecteur MCP `claude.ai SF Wider STG` (https://sf-wider-stg.upmind.fr/mcp) est installé mais **non authentifié**.
- Action requise côté msavane : lancer `/mcp` dans Claude Code et autoriser "claude.ai SF Wider STG" pour permettre l'inspection directe de l'org (champs, page layouts, validation rules, Activity Settings).
