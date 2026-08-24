# Guide de test manuel — Attribution automatique des tâches CRM (demande #9)

> Chantier réalisé le 2026-08-24 sur `wider-test`, en réponse au besoin d'Ana
> (briefing "5.1 Nouvelle opportunité et attribution", p.9) : pouvoir attribuer
> une tâche à n'importe quel Contact, et laisser Salesforce déterminer
> automatiquement le bon "Assign To" (`OwnerId`), y compris pour le contact
> Triviso "Manque resp ou à définir".

## Résumé des 5 étapes réalisées

| # | Étape | Ce qui a été fait |
|---|-------|--------------------|
| 1 | FLS du champ technique | `Contact.Utilisateur_Salesforce__c` (lookup vers User, déjà créé mais invisible) rendu accessible via le Permission Set `PS_Utilisateur_SF_Technique`. |
| 2 | Queue de repli | Création de la Queue **"Tâches non attribuées"**, membres : Ana Leal, Toni Cortes, Alexandre Gilbert, Admin Francois, Admin Upmind. |
| 3 | Rapprochement Contact ↔ User | `Utilisateur_Salesforce__c` peuplé pour les 3 collaborateurs internes Wider (Ana Leal, Toni Cortes, Alexandre Gilbert) — les comptes admin Upmind exclus. |
| 4 | Flow d'attribution | Flow `Task_Attribution_Automatique` (Before-Save sur Task), 100% dynamique (aucune valeur codée en dur). |
| 5 | Tests et activation | 6 scénarios validés par Apex anonyme (rollback), Flow **actif** sur `wider-test`. |

**Comportement final** : à la création ou modification d'une tâche, dès que le champ **Contact** (`WhoId`) est renseigné, "Assign To" (`OwnerId`) est calculé automatiquement :
- Contact interne (a un User Salesforce lié) → assigné à ce User → apparaît dans ses tâches Salesforce
- Contact externe ou "Manque resp ou à définir" → assigné à la Queue "Tâches non attribuées"
- Une réattribution manuelle n'est jamais écrasée tant que le Contact de la tâche ne change pas

## Cas de test à essayer toi-même dans l'org (wider-test)

Pour chaque cas : crée une tâche via le bouton "Nouvelle tâche" (panneau Activités, sur n'importe quel Compte/Projet), remplis le champ **Contact**, enregistre, puis ouvre la tâche et regarde le champ **"Assign To"**.

| Cas | Contact à choisir | Résultat attendu sur "Assign To" |
|---|---|---|
| **A** | Ana Leal, Toni Cortes ou Alexandre Gilbert | Le User correspondant (pas toi, pas le créateur) |
| **B** | **"Manque resp ou à définir"** | La Queue **"Tâches non attribuées"** |
| **C** | Un contact externe classique (architecte, MO...) | La Queue "Tâches non attribuées" |
| **D** | Prends la tâche du cas B, modifie son Contact vers Ana Leal, enregistre | "Assign To" bascule automatiquement sur Ana Leal |
| **E** | Crée une tâche avec Contact = Ana Leal ; une fois enregistrée, modifie manuellement "Assign To" vers Toni Cortes (sans toucher au Contact), enregistre ; puis modifie un autre champ (ex. Description) et enregistre à nouveau | "Assign To" reste sur Toni Cortes après la 2e sauvegarde (ta réattribution manuelle n'est pas écrasée) |
| **F** | Ne renseigne aucun Contact | "Assign To" reste sur toi (comportement standard, inchangé — le Flow ne s'active pas) |

**Astuce pour vérifier le cas A** : demande à Ana (ou connecte-toi en tant qu'elle si tu as les droits) de regarder sa liste "Mes tâches" — la tâche créée doit y apparaître.

**Astuce pour vérifier la Queue (cas B/C)** : la tâche n'apparaît plus dans "Mes tâches" du créateur ; elle est visible via un rapport filtré sur `Owner = Tâches non attribuées`, ou en ouvrant directement la tâche et en regardant le champ Owner.

## En cas de problème

Si un des cas ne donne pas le résultat attendu, note : le nom du cas (A à F), le nom exact du Contact utilisé, et ce que tu observes sur "Assign To" — je pourrai comparer avec les résultats de test déjà obtenus (voir entrée #9 de `HISTORIQUE-DEMANDES-WIDER.md`) pour diagnostiquer.
