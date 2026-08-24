# Dossier de mise en prod — Notification email à l'attribution du Projet

> Testé et validé par msavane sur `wider-test` le 2026-08-24 (email réel envoyé et reçu,
> lien vers la fiche projet vérifié). Composant entièrement nouveau (aucune version
> antérieure en prod à archiver) — rollback = désactivation/suppression simple.

## 1. Résumé fonctionnel

Répond au besoin d'Ana (briefing "3. Attribution") : quand `Projet__c.Etape__c` passe de "Attribution" à "Ouvert", le Flow `Projet_Notification_Attribution` :

1. Envoie un email identique (nom du projet, compte, montants renseignés, lien direct vers la fiche projet, signature) à :
   - `Responsable_commercial__c` (Contact)
   - `Calculateur__c` (User)
   - `Calculateur_2__c` (User)

   Un destinataire vide est simplement ignoré (pas d'erreur, pas d'email vide).
2. Crée une tâche de traçabilité sur le Projet (`WhatId`), Sujet "Notification d'attribution envoyée", Statut Open ("Ouvert"), pour garder une preuve que la notification a bien été envoyée.

Le Flow ne réagit qu'à la transition précise Attribution → Ouvert (formule `AND(ISCHANGED(Etape__c), PRIORVALUE(Etape__c) = "Attribution")`) — un projet qui passe d'une autre étape à Ouvert, ou qui reste sur Ouvert lors d'une sauvegarde ultérieure, ne redéclenche rien.

## 2. Composants à déployer

Manifeste : `prod/manifest/package-notification-attribution.xml`
Fichier source : `prod/force-app/main/default/flows/Projet_Notification_Attribution.flow-meta.xml`

Le fichier packagé est en `<status>Active</status>` — **le déploiement l'activera immédiatement en prod**, sans étape d'activation manuelle séparée.

## 3. Pré-requis à vérifier en prod avant déploiement

- **Deliverability (Setup → Email Administration → Deliverability)** : doit être sur "Tous les emails" (All Email), sinon aucun email ne partira. Non vérifié depuis cette session (aucun org prod Wider connecté en CLI ici).
- **Aucune adresse d'expéditeur organisationnelle (Org-Wide Email Address) configurée** sur `wider-test` au moment de ce développement — les emails partent avec l'adresse de l'utilisateur/l'automatisation à l'origine de la sauvegarde. Si une Org-Wide Email Address existe en prod et qu'on veut un expéditeur dédié, il faudra l'ajouter dans le Flow (actions `Send Email`, paramètre `senderAddress`) avant déploiement — non fait ici, à la demande initiale rien n'a été précisé sur ce point.
- Vérifier que `Projet__c.Calculateur__c` / `Calculateur_2__c` (lookups User) et `Responsable_commercial__c` (lookup Contact) existent avec les mêmes noms d'API en prod — confirmé dans le schéma standard Wider, pas de raison de divergence attendue.

## 4. Étapes de déploiement

1. Vérifier le point Deliverability ci-dessus dans l'org prod.
2. Déployer le flow :
   ```
   sf project deploy start --manifest prod/manifest/package-notification-attribution.xml --target-org <alias-prod>
   ```
3. Test de validation en prod (recommandé, sur un vrai Projet ou un projet de test dédié) : passer un Projet de "Attribution" à "Ouvert" avec Responsable commercial/Calculateur renseignés sur une adresse que vous contrôlez, vérifier la réception de l'email et le bon fonctionnement du lien vers la fiche, puis vérifier la création de la tâche de traçabilité.

## 5. Rollback — si la fonctionnalité n'est pas validée

Composant entièrement nouveau, aucune version antérieure à restaurer. Deux options, de la plus simple à la plus complète :

- **Désactivation rapide** : Setup → Flows → `Projet_Notification_Attribution` → Deactivate. Le Flow reste dans l'org mais ne s'exécute plus — arrêt immédiat des emails, aucune tâche de traçabilité créée, aucun impact sur les données existantes.
- **Suppression complète** : après désactivation, supprimer le Flow depuis Setup (ou via `sf project deploy start` avec un manifeste `destructiveChanges.xml` supprimant `Projet_Notification_Attribution`) si on veut retirer entièrement le composant de l'org.

Dans les deux cas, aucune donnée existante n'est affectée : le Flow ne modifie que la création de nouvelles tâches de traçabilité et l'envoi d'emails au moment de la transition — il ne touche à aucun champ du Projet lui-même, donc rien à restaurer côté données.

## 6. Portée non traitée

La demande initiale d'Ana incluait aussi "déclenchement création projet dans Triviso dès Attribution" — **explicitement mis de côté**, comme pour la demande #6 (Probabilité Projet) : aucun mécanisme Salesforce→Triviso n'existe aujourd'hui pour créer un projet côté Triviso (seul le sens Triviso→Salesforce existe via `FL_ScheduleProxyToProjetSales`). À cadrer séparément avec l'équipe Triviso avant toute implémentation.
