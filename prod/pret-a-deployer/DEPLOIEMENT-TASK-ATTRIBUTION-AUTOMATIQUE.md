# Dossier de mise en prod — Attribution automatique des tâches CRM (demande #9)

> Testé et activé par msavane sur `wider-test` le 2026-08-24 (6/6 tests Apex passés,
> rollback à chaque fois — aucune donnée conservée).

## 1. Résumé fonctionnel

`Task.OwnerId` est un champ non nillable, préempli par Salesforce avec le créateur de la tâche
(Ana), pas le bon responsable. Le Flow `Task_Attribution_Automatique` (Before-Save sur Task,
Create + Update) réévalue `OwnerId` à chaque tâche nouvelle ou dont le `WhoId` change :

- Si le Contact de `WhoId` a un User Salesforce correspondant (champ technique
  `Contact.Utilisateur_Salesforce__c`) → `OwnerId` = ce User.
- Sinon → `OwnerId` = la Queue `Tâches non attribuées`.
- Une réattribution manuelle d'`OwnerId` (sans changement de `WhoId`) n'est jamais écrasée.

Logique 100% dynamique : la Queue est retrouvée par `Group.DeveloperName`, aucune valeur codée
en dur — le flow est déployé tel quel, sans adaptation par environnement.

## 2. Composants à déployer

Manifeste : `prod/manifest/package-task-attribution-automatique.xml`

- `prod/force-app/main/default/objects/Contact/fields/Utilisateur_Salesforce__c.field-meta.xml`
  (champ technique, Lookup(User), non requis, non affiché sur les pages)
- `prod/force-app/main/default/permissionsets/PS_Utilisateur_SF_Technique.permissionset-meta.xml`
  (lecture/édition sur ce champ — en prod comme en test, ce Permission Set n'est nécessaire que
  pour qu'un admin puisse consulter/modifier le champ manuellement dans l'UI ; le flow tourne en
  contexte système et n'en a pas besoin pour fonctionner)
- `prod/force-app/main/default/queues/Taches_non_attribuees.queue-meta.xml` — **membres adaptés à
  la prod** (voir point de vigilance ci-dessous)
- `prod/force-app/main/default/flows/Task_Attribution_Automatique.flow-meta.xml` (statut `Active`,
  s'activera immédiatement)

**Point de vigilance — composition de la Queue** : en test, la Queue a 5 membres (Ana Leal, Toni
Cortes, Alexandre Gilbert, Admin Francois, Admin Upmind), reflet des comptes présents dans le
sandbox. En prod, seuls 3 de ces comptes existent réellement : **Ana Leal, Alexandre Gilbert,
Admin Upmind** — vérifié le 2026-08-26 (`admin.wider@upmind.fr`, `a.leal4@wider-sa.ch`,
`gilbert@wider-sa.ch`, tous actifs). Ni Toni Cortes ni "Admin Francois" n'ont de compte User en
prod (Francois est un admin technique propre au sandbox ; Toni Cortes n'a pas encore de licence
Salesforce en prod). Le fichier `Taches_non_attribuees.queue-meta.xml` de `prod/force-app` a donc
une liste de membres différente de celui de test — **normal et volontaire, ne pas essayer de faire
correspondre les deux à l'identique**.

## 3. Étapes de déploiement

1. Déployer le package :
   ```
   sf project deploy start --manifest prod/manifest/package-task-attribution-automatique.xml --target-org <alias-prod>
   ```
2. Exécuter dans l'ordre, via Setup → Apex anonyme, les 2 scripts de `prod/pret-a-deployer/rollback/` :
   - `01_assigner_permset_admin_prod.apex` (assigne le Permission Set à l'admin prod)
   - `02_peupler_contacts_internes_prod.apex` (rapproche Ana Leal et Alexandre Gilbert avec leur
     User ; **Toni Cortes reste volontairement non rapproché**, cf. point de vigilance ci-dessus —
     à refaire quand son compte User existera en prod)
3. Test de validation en prod (recommandé) : créer/modifier une tâche avec `WhoId` = Contact Ana
   Leal ou Alexandre Gilbert, vérifier que `OwnerId` bascule sur le bon User ; avec un Contact
   externe ou Toni Cortes, vérifier que `OwnerId` bascule sur la Queue `Tâches non attribuées`.

## 4. Rollback — si non validé

- **Le plus simple** : désactiver le flow (Setup → Flows → `Task_Attribution_Automatique` →
  Deactivate). Aucune donnée n'est perdue, `OwnerId` cesse simplement d'être réévalué
  automatiquement.
- Pour revenir à un état totalement propre : supprimer aussi le rapprochement fait à l'étape 2
  (vider `Utilisateur_Salesforce__c` sur les Contacts Ana Leal / Alexandre Gilbert) — aucune tâche
  existante n'est modifiée rétroactivement par un rollback, le flow n'agit qu'au moment de la
  sauvegarde.
- Aucune tâche existante n'est affectée par le déploiement lui-même (le flow ne s'applique qu'aux
  créations/modifications futures avec changement de `WhoId`).

## 5. Portée non traitée

Toni Cortes n'ayant pas de User Salesforce en prod, toute tâche qui devrait normalement lui être
attribuée tombera dans la Queue `Tâches non attribuées` jusqu'à la création de son compte — à
signaler à msavane si ça devient bloquant en usage réel.
