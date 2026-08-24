# Dossier de mise en prod — Duplicate Rules & Matching Rules (Compte/Contact/Projet)

> Créées et testées par msavane sur `wider-test` entre le 2026-08-17 et le 2026-08-24.
> Objectif : couvrir les 3 canaux de création (Triviso, Simap, Manuel) pour Compte, Contact et Projet.

## 1. Résumé fonctionnel

Trois canaux créent des Comptes/Contacts/Projets dans l'org, avec des champs clés différents :

| Objet | Triviso | Simap | Manuel |
|---|---|---|---|
| Compte | `ADRES_ID__c` | Nom du compte | Nom du compte |
| Contact | `ADRES_ID__c` | Nom + Compte associé | Nom + Compte associé |
| Projet | `Numero_projet__c` | Nom du projet + `Numero_Simap__c` | Nom du projet |

Ce dossier déploie les règles couvrant Simap et Manuel (le canal Triviso pour Projet était déjà couvert par `TestProj`/`TestProjet`, non modifié ici, donc non inclus dans ce package).

## 2. Composants à déployer

Manifeste : `prod/manifest/package-duplicate-rules.xml`

| Composant | Type | Détail |
|---|---|---|
| `Account.DuplicatAccount_V1` | DuplicateRule | Canal Simap/Manuel — **Block** insert (modifié, était Allow) |
| `Account.DupliAccountV2` | DuplicateRule | Canal Triviso — **Block** insert (nouveau) |
| `Contact.DupliContact_V1` | DuplicateRule | Canal Simap/Manuel — **Block** insert (modifié, était Allow) |
| `Contact.DupliContactV2` | DuplicateRule | Canal Triviso — **Block** insert (nouveau) |
| `Projet__c.DupliProjetV2` | DuplicateRule | Canal Simap — **Block** insert (nouveau) |
| `Projet__c.DupliProjetV3` | DuplicateRule | Canal Manuel — **Block** insert (nouveau) |
| `Account.RuleAccount_V1` | MatchingRule | `Name`, Exact |
| `Account.RuleAccount_V2` | MatchingRule | `ADRES_ID__c`, Exact |
| `Contact.RuleContact_V1` | MatchingRule | `LastName`+`FirstName`+`AccountId`, Exact |
| `Contact.RuleContact_V2` | MatchingRule | `ADRES_ID__c`, Exact |
| `Projet__c.RuleProjet_V2` | MatchingRule | `Numero_Simap__c`+`Name`, Exact (les 2 doivent matcher) |
| `Projet__c.RuleProjetV3` | MatchingRule | `Name` seul, Exact |

Les fichiers `matchingRules/*.matchingRule-meta.xml` de ce dossier ne contiennent **que** les 6 règles ci-dessus — les autres règles custom présentes dans `wider-test` (`TestAccount`, `Contact_Matching_Email_Telephone_Langue_Compte`, `ReglePersonAccount`) ne sont volontairement **pas** incluses : leur nom ne correspond pas à leur critère réel et elles sont hors périmètre des 3 canaux Compte/Contact/Projet — à traiter séparément si besoin.

## 3. Écarts connus — non bloquants pour ce déploiement, décision assumée par msavane

- **`RuleProjetV3` ne compare que `Name`**, pas le Compte associé (`Nom_du_compte__c`). Testé en Apex sur `wider-test` (2026-08-24) : un Projet de même nom mais avec un **Compte différent** est bloqué quand même (faux positif).
- Cette même règle bloque aussi un Projet de même nom avec un **`Numero_Simap__c` différent** (les Duplicate Rules sont indépendantes entre elles : `DupliProjetV3` matche sur le Nom seul, peu importe ce que fait `DupliProjetV2`).
- **Impact confirmé sur `Fl_ScrenConvertirEnProjet_DRAFT`** (flow Simap MO/DT, voir `DEPLOIEMENT-SIMAP-MO-DT.md`) : ce Screen Flow route tout échec de `Create Records` (Compte/Contact/Projet) vers un `ErrorScreen` générique ("Use one of these records? Merci de contacter votre administrateur Salesforce"), sans possibilité de forcer la création. Un Projet homonyme créé via Simap chez un client différent tombera sur cet écran.
- **Décision de msavane (2026-08-24) : risque accepté tel quel.** Si ce comportement devient gênant en usage réel, corriger `RuleProjetV3` en lui ajoutant `Nom_du_compte__c` comme second critère résoudra les deux cas d'un coup.

## 4. Étapes de déploiement

```
sf project deploy start --manifest prod/manifest/package-duplicate-rules.xml --target-org <alias-prod>
```

Aucune dépendance de champ/profil : `ADRES_ID__c`, `Numero_Simap__c`, `Name` sont des champs standard ou déjà présents en prod (à vérifier que `ADRES_ID__c` existe bien sur Account et Contact en prod avant déploiement — c'est un champ unique, sa création doit se faire séparément si absente).

Après déploiement, vérifier dans Setup → Duplicate Rules que les 6 règles sont actives et dans le bon ordre relatif aux règles déjà en place en prod (le `sortOrder` de la sandbox n'est pas forcément pertinent si la prod a d'autres règles existantes — à ajuster manuellement si besoin).

## 5. Rollback — ce qui existait avant

- `Account.DuplicatAccount_V1` et `Contact.DupliContact_V1` existaient déjà en `Allow` (alerte seulement, pas de blocage) avant cette évolution — pas de nouveau critère de matching, seul `actionOnInsert` a changé (`Allow` → `Block`). Rollback : rouvrir la règle dans Setup et repasser `actionOnInsert` sur `Allow`, ou redéployer avec ce champ modifié.
- `Account.DupliAccountV2`, `Contact.DupliContactV2`, `Projet__c.DupliProjetV2`, `Projet__c.DupliProjetV3` et les 4 Matching Rules associées (`RuleAccount_V2`, `RuleContact_V2`, `RuleProjet_V2`, `RuleProjetV3`) sont entièrement nouveaux — rollback = les désactiver (`isActive=false`) ou les supprimer via Setup, aucune donnée n'est affectée (ce sont des règles de contrôle, pas des enregistrements).
