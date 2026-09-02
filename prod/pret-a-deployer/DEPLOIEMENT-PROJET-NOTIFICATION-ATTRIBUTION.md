# Dossier de mise en prod — Refonte flow Projet Notification Attribution

> Préparé le 2026-09-02, **en attente de validation msavane avant tout déploiement réel**.
> Testé en test (`wider-test`) : Contact + Tâche réels créés (email vérifié directement par msavane sur sa propre adresse), plusieurs itérations de contenu validées.

## 1. ⚠️ Ce chantier REMPLACE un flow actif en production — pas un ajout

Contrairement aux deux autres dossiers (Société du groupe, LWC documentSuiviProjet) qui sont purement additifs, celui-ci **reconstruit intégralement** le flow `Projet_Notification_Attribution`, actuellement **actif et fonctionnel en prod**. Le déploiement remplace son comportement, il ne s'ajoute pas à côté.

**Comportement actuel en prod (qui disparaîtra au déploiement)** :
- Déclenché quand un Projet passe de l'étape "Attribution" à "Ouvert".
- Envoie un email (montants/infos financières du projet) à 3 rôles portés par le Projet : Calculateur, Calculateur 2, Responsable commercial.
- Crée une tâche de log générique "Notification d'attribution envoyée".

**Nouveau comportement (ce dossier)** :
- Déclenché à la **création d'une Tâche** dont le champ Nom (`WhoId`) est renseigné avec un **Contact** (pas un Lead, pas vide).
- Envoie un email à ce Contact avec :
  - Objet : `Attribution de tache : {Sujet de la tâche} pour {Type de tâche}` (valeurs brutes des champs, sans reformulation grammaticale — validé par msavane le 2026-09-02).
  - Corps : Nom du projet lié (`WhatId`, si c'est un Projet__c), Détail (champ `Description`, appelé "Comments" dans le vocabulaire standard Salesforce), Date (`ActivityDate`).
- Le cas "Tâche assignée à un User" (`OwnerId`) n'est plus géré par ce flow — c'est la notification native Salesforce (déjà existante, hors flow) qui s'en charge.
- Aucune tâche de log n'est créée (fonctionnalité abandonnée, non redemandée dans le nouveau besoin).

**Conséquence pratique** : après déploiement, les transitions de Projet "Attribution → Ouvert" n'enverront plus d'email aux Calculateurs/Responsable commercial. Si cette notification métier est encore utile, il faut le signaler avant de déployer — elle n'a pas de remplaçant dans ce nouveau flow.

**✅ Validé par msavane le 2026-09-02** : le remplacement est accepté, la nouvelle logique doit s'appliquer telle quelle en prod.

**Vérification notification native User (cloche)** : confirmé via `NotificationTypeConfig` (métadonnée indépendante de ce flow) que le type `task_delegated_to` (notification native Salesforce "tâche assignée") est activé par défaut au niveau de l'org (desktop + mobile). Le flow reconstruit ne filtre que sur `WhoId` (Contact/Lead), jamais sur `OwnerId` — aucune interférence possible avec cette notification native, avant ou après déploiement.

## 2. Détail technique du nouveau flow

- Déclencheur : `Task`, Create, RecordAfterSave. Filtre d'entrée natif : `WhoId` non nul (opérateur `IsNull = false`, léger, pas de requête).
- `Get_Projet` (Get Records, Projet__c par Id = WhatId) puis `Get_Contact` (Get Records, Contact par Id = WhoId) — get first only, pas de boucle, bulk-safe par construction (les Get Records d'un flow record-triggered s'exécutent par interview, pas de risque de boucle imbriquée).
- `Decision_Est_Contact` : formule `frmlEstUnContact` = `LEFT(WhoId, 3) = "003"` (préfixe d'Id Contact dans cet org) — si Lead (`00Q`) ou vide, le flow s'arrête sans rien faire.
- `Decision_Email_Valide` : vérifie que le Contact a un email avant d'envoyer (`NOT(ISBLANK(Get_Contact.Email))`) — évite une erreur d'action si le Contact n'a pas d'adresse.
- Email envoyé via `emailSimple` (`storeOutputAutomatically=true`, cf. leçon retenue sur ce projet — sans ça Salesforce coche à tort "manually assign variables").

## 3. Risque volume / reprise

Aucun trigger ni flow existant ne crée des Tâches en masse dans cet org (vérifié : pas de `ApexTrigger` sur `Task`, pas de flow `RecordAfterSave` sur `Task` avant celui-ci, seulement 2 Tâches au total en test au moment de la préparation). Contrairement au chantier Société du groupe, **il n'y a pas de garde-fou anti-reprise dans ce flow** — ce n'est pas jugé nécessaire vu l'absence de mécanisme de création en masse de Tâches connu à ce jour.

**⚠️ À surveiller si une reprise de Tâches (migration Triviso ou autre) est mise en place un jour** : si des Tâches sont créées en masse avec un Contact en `WhoId`, ce flow enverra un email réel à chacun de ces contacts (souvent des clients externes). Revoir ce point avant toute reprise de Tâches.

## 4. Composants à déployer

Manifeste : `prod/manifest/package-projet-notification-attribution.xml`

```
sf project deploy start --manifest prod/manifest/package-projet-notification-attribution.xml --target-org <alias-prod>
```

Contenu : `Flow` : `Projet_Notification_Attribution` (nouvelle version, remplace la version active actuelle).

Aucune FLS/permission supplémentaire nécessaire — pas de nouveau champ ni de nouvelle classe.

## 5. Rollback

Si besoin de revenir à l'ancien comportement : redéployer l'ancienne version du flow (conservée dans l'historique git avant ce commit, ou récupérable depuis l'org prod tant que l'ancienne version n'a pas été supprimée — Salesforce garde les anciennes versions inactives d'un flow, il suffit de les réactiver depuis Setup > Flows sans redéploiement si l'historique de versions est encore présent côté org).

## 6. Portée non traitée / points ouverts

- Le cas Lead n'a pas pu être testé avec de vraies données (aucun Lead dans l'org test) — la logique de filtre est la même que pour Contact (recherche par préfixe d'Id), jugée fiable par analogie.
- Confirmer avant déploiement si la notification Calculateur/Responsable commercial (comportement actuel) doit être conservée ailleurs — non traité dans ce chantier, cf. section 1.
