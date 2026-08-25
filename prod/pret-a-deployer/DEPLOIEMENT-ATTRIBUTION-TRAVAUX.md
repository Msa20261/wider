# Dossier de mise en prod — Objet "Attribution des travaux"

> Testé sur `wider-test` le 2026-08-25 (Apex + rollback, related list et
> lookup Contact confirmés fonctionnels). Composant entièrement nouveau
> (objet inédit) — rollback simple si non validé.

## 1. Résumé fonctionnel

Répond au besoin de msavane (à partir d'un mockup "Attribution des travaux") : pouvoir attribuer plusieurs lots de travaux (identifiés par un code CFC) à des sous-traitants, pour un même projet. Contrairement au mockup qui montrait 4 lignes fixes, c'est une **related list illimitée** (nouvel objet enfant), pas un nombre de champs fixé.

Nouvel objet `Attribution_Travaux__c` ("Attribution des travaux") :
- `Projet__c` — lookup requis vers `Projet__c`, relation enfants `Attributions_Travaux__r`
- `Travaux_CFC__c` — texte, label "Travaux (CFC)"
- `Sous_traitant__c` — lookup vers `Contact`, label "Sous-traitant"

Les montants sous-traitance estimés (interne/externe) restent les champs déjà existants sur `Projet__c` (`Montant_S_trait_int__c`/`Montant_S_trait_ext__c`) — pas dupliqués sur ce nouvel objet, confirmé avec msavane.

## 2. Composants à déployer

Manifeste : `prod/manifest/package-attribution-travaux.xml`

- `prod/force-app/main/default/objects/Attribution_Travaux__c/` (objet + 3 champs)
- `prod/force-app/main/default/profiles/Admin.profile-meta.xml` et `Custom Platform Profile.profile-meta.xml` — droits sur l'objet (Create/Read/Edit, Delete uniquement pour Admin) et sur les 2 champs non obligatoires (`Travaux_CFC__c`, `Sous_traitant__c` — `Projet__c` étant un champ requis, Salesforce interdit d'y attacher une FLS explicite, l'accès est implicite). Fichiers re-récupérés frais depuis prod le 2026-08-25 avant ajout de ces permissions, pour ne pas déployer à partir d'un état de profil obsolète.

## 3. Point d'attention — visibilité sur la page

**Comme pour la demande #12 (Projet Principal)** : `Projet__c` utilise une Lightning Record Page pour son affichage, en test et en prod. Ce dossier ne déploie que l'objet et les droits — **la related list "Attribution des travaux" devra être ajoutée manuellement à la page via Lightning App Builder** après déploiement (glisser le composant "Related List - Single" ou "Related Record List" en pointant vers la relation `Attributions_Travaux__c`).

Profitez-en pour vérifier en même temps si `Projet_Principal__c` (demande #12) a bien été ajouté à cette même page — les deux ajouts peuvent se faire dans la même session Lightning App Builder.

## 4. Étapes de déploiement

1. Déployer :
   ```
   sf project deploy start --manifest prod/manifest/package-attribution-travaux.xml --target-org <alias-prod>
   ```
2. Ajouter la related list à la page Projet en prod via Lightning App Builder (voir point 3).
3. Vérifier sur un Projet réel (ou de test) : créer une ligne "Attribution des travaux" avec un Sous-traitant, confirmer qu'elle apparaît dans la related list du Projet.

## 5. Rollback — si non validé

Composant entièrement nouveau (objet inédit), aucune donnée existante affectée :

- Retirer la related list de la Lightning Record Page (Lightning App Builder) si elle a été ajoutée.
- Supprimer l'objet via un manifeste `destructiveChanges.xml` ciblant `Attribution_Travaux__c` (type `CustomObject` — supprime l'objet et tous ses champs en une fois), ou simplement désactiver l'accès via les profils si on veut le garder mais le cacher.
