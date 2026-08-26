# Dossier de mise en prod — Labels de champs + nouveaux champs sur Projet (demande #18)

> Déployé et vérifié en prod le 2026-08-26. Ce fichier documente ce qui a été fait,
> à titre de mémoire — le déploiement lui-même est déjà réalisé.

## 1. Résumé

msavane a modifié des labels de champs sur `Projet__c` et créé de nouveaux champs directement
en test, sans les commiter au repo. Comparaison Tooling API (`FieldDefinition`) sur les 95
champs custom de `Projet__c` :

- **20 champs absents de prod** (nouveaux) : `Autres_intervenants__c`, `Avancement__c`,
  `Date_contrat__c`, `Date_d_but_travaux__c`, `Date_fin_travaux__c`, `Factur__c`,
  `Garanties_et_retenues__c`, `Genre_de_dossier__c`, `Incoterm__c`, `Monnaie__c`,
  `Montant_S_trait_ext__c`, `Montant_S_trait_int__c`, `Non_adjug__c`, `Perte_calcul_e__c`,
  `Projet_Principal__c`, `R_f_client_No_contrat__c`, `R_sultat_projet__c`, `Sous_traitant_3__c`,
  `Sous_traitant_4__c`, `TravauxCF_C__c`.
- **21 champs avec un label différent** entre test (source de vérité) et prod — voir le détail
  dans `HISTORIQUE-DEMANDES-WIDER.md`, demande #18.

## 2. Composants déployés

Manifeste : `prod/manifest/package-projet-labels-nouveaux-champs.xml`

- 41 fichiers `prod/force-app/main/default/objects/Projet__c/fields/*.field-meta.xml`
- `prod/force-app/main/default/profiles/Admin.profile-meta.xml` (FLS des 20 nouveaux champs
  ajoutée, additif — les autres permissions du profil ne sont pas touchées)
- `prod/force-app/main/default/profiles/Custom Platform Profile.profile-meta.xml` (idem)

Commande utilisée (manifeste seul en échec à cause des deux `packageDirectories` du projet,
cf. incident déjà rencontré demande #16 — contourné avec `--source-dir` explicite) :

```
sf project deploy start \
  --source-dir "prod/force-app/main/default/objects/Projet__c/fields" \
  --source-dir "prod/force-app/main/default/profiles" \
  --target-org wider-prod
```

## 3. Vérifications faites après déploiement

- Ré-interrogation `FieldDefinition` sur les 95 champs : prod = test, 0 écart (ni champ manquant,
  ni label différent).
- 40/40 entrées `FieldPermissions` correctes pour les 20 nouveaux champs sur `System
  Administrator` et `Custom Platform Profile` (lecture+édition, sauf `Factur__c` en lecture seule
  car champ formule).
- Non-régression : FLS pré-existante sur `Projet__c.Etape__c` (champ sans rapport) intacte des
  deux côtés, confirmant le comportement additif du déploiement de Profile.

## 4. Rollback — si besoin

- **Labels** : redéployer les anciennes valeurs de label depuis `git show <commit-avant>` sur les
  21 fichiers concernés (pas de perte de données, un label est un simple changement d'affichage).
- **20 nouveaux champs** : suppression via `destructiveChanges.xml` si nécessaire — aucune donnée
  n'existait avant leur création par msavane en test, mais vérifier en prod si des valeurs ont déjà
  été saisies sur des Projets avant de supprimer.
- **FLS** : pas de rollback nécessaire séparément, elle disparaît avec le champ si celui-ci est
  supprimé.

## 5. Découverte importante, hors périmètre de cette demande

En vérifiant les FLS de ce déploiement, deux chantiers déjà documentés comme "dossier prêt" se
sont révélés **jamais réellement déployés en prod** :

- **Demande #5** (mapping `ADRES_ID_entete`, fusion `ScheduleJobAccount`/`ScheduleJobContact`,
  demande #15/#16) : `Account.ADRES_ID_entete_TECH__c` n'existe pas en prod.
- **Demande #13** (Attribution des travaux) : l'objet `Attribution_Travaux__c` n'existe pas du
  tout en prod.

Les dossiers `prod/pret-a-deployer/` correspondants existent et sont prêts, mais n'ont jamais
été effectivement poussés vers `wider-prod`. À signaler à msavane et prioriser séparément.
