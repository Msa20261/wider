# Dossier de mise en prod — LWC documentSuiviProjet (demande #28)

> Préparé le 2026-09-02, **en attente de validation msavane avant tout déploiement réel**.
> Testé en test (`wider-test`) : classe de test à 96% de couverture, smoke tests contre de vraies données réelles (Projet__c + Get_Document__c), démos laissées visibles sur le Projet `1251415`.

## 1. Résumé fonctionnel

Composant Lightning sur la page Projet, remplace l'approche Roll-Up abandonnée (demande #27, rollback) par une vue détaillée document par document :

- 3 tuiles de synthèse : Confirmé / En cours (non confirmé) + montant pondéré / Facturé.
- Tableau détaillé par document : référence, description, genre, statut Triviso complet, icônes Offert/Commandé/Facturé, montant HT, pondération, montant pondéré (calculé pour **chaque** document, pas seulement "en cours" — une pondération absente vaut 100%).
- Tableau de répartition par statut Triviso distinct (nombre de documents, montant total, montant pondéré total).
- Catégorisation par les flags fiables `DOC_Etat_Offert/Commande/Facture`, pas par le texte libre `Etat_document__c`.
- Brouillons exclus.

Bug trouvé et corrigé en cours de route : les montants stockés en Texte suivent le format numérique de la locale de l'org (`"24 343,7"` avec espace fine insécable en séparateur de milliers, virgule en décimal) — `Decimal.valueOf()` échouait silencieusement dessus. `parseDecimal()` normalise désormais avant conversion (`\p{Zs}` + remplacement virgule→point).

## 2. Composants à déployer

Manifeste : `prod/manifest/package-document-suivi-projet-lwc.xml`

```
sf project deploy start --manifest prod/manifest/package-document-suivi-projet-lwc.xml --target-org <alias-prod> --test-level RunSpecifiedTests --tests DocumentSuiviProjetController_TEST
```

Contenu :
- `ApexClass` : `DocumentSuiviProjetController` (nouveau), `DocumentSuiviProjetController_TEST` (nouveau)
- `LightningComponentBundle` : `documentSuiviProjet` (nouveau)

**Prod exige un `--test-level`** (contrairement à `NoTestRun` utilisable en sandbox) — `RunSpecifiedTests` avec la classe de test dédiée suffit, pas besoin de `RunLocalTests` malgré la couverture org-wide faible sur cet org (constaté à 4-8% lors des précédents déploiements de ce chantier) : `RunSpecifiedTests` ne vérifie que la couverture des classes réellement déployées (96% ici), pas la couverture globale de l'org.

**⚠️ FLS/accès classe non inclus dans ce manifeste, volontairement** — mêmes raisons que pour Société du groupe (fichiers `profiles/*.profile-meta.xml` trackés = versions complètes périmées, ne pas les déployer tels quels). À faire séparément, étape 2bis ci-dessous.

## 3. Étapes de déploiement — ordre important

1. Déployer le manifeste (commande ci-dessus).
2bis. **Accorder l'accès à la classe Apex** sur les 3 profils, via un fragment minimal séparé (mêmes précautions que Société du groupe — utiliser `Admin`, jamais `System Administrator` comme nom de fichier/membre) :
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Profile xmlns="http://soap.sforce.com/2006/04/metadata">
       <classAccesses>
           <apexClass>DocumentSuiviProjetController</apexClass>
           <enabled>true</enabled>
       </classAccesses>
   </Profile>
   ```
   Un fichier par profil (`Admin.profile-meta.xml`, `Sys Admin Plateform.profile-meta.xml`, `Custom Platform Profile.profile-meta.xml`), déployés depuis un dossier isolé ne contenant que ces 3 fragments.
   Vérifier après coup : `SELECT COUNT(Id) FROM SetupEntityAccess WHERE SetupEntityId = (SELECT Id FROM ApexClass WHERE Name='DocumentSuiviProjetController') AND Parent.ProfileId != null` → doit renvoyer 3.
3. **Placer le composant sur la page Projet en prod** — via Lightning App Builder (gear icon sur un enregistrement Projet → Modifier la page → glisser "Suivi financier des documents"), **pas** par édition de métadonnées : la page `Projet_Record_Page` de prod n'a pas été inspectée pour ce chantier, mieux vaut laisser msavane la placer visuellement comme il l'a fait en test, plutôt que risquer une édition XML à l'aveugle sur une page non vérifiée.
4. Vérifier sur un Projet réel avec des documents réels (si la reprise Document a commencé en prod d'ici là) que les totaux et le détail s'affichent correctement.

## 4. Rollback

Chantier purement additif, aucune donnée ni champ existant modifié.

- Retirer le composant de la page Projet (App Builder).
- `sf project delete source -m "LightningComponentBundle:documentSuiviProjet" -m "ApexClass:DocumentSuiviProjetController" -m "ApexClass:DocumentSuiviProjetController_TEST" --target-org <alias-prod>` (dans cet ordre — l'LWC dépend de la classe, à supprimer avant elle si jamais un ordre importe côté Salesforce).

## 5. Portée non traitée / points ouverts

- **Le composant n'a jamais été vu en production avec de vraies données** — la reprise Document en prod n'a pas encore de volume significatif au moment de la préparation de ce dossier (à vérifier au moment du déploiement réel).
- **Aucune modification demandée sur l'affichage** — msavane a confirmé que les champs existants couvrent le besoin, le mapping (déjà en prod depuis la demande #27bis) suffit à alimenter correctement le composant.
