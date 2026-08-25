# Dossier de mise en prod — Lookup Projet Principal / Sous-projets

> Testé sur `wider-test` le 2026-08-25 (Apex + rollback, relation bidirectionnelle
> confirmée). Composant entièrement nouveau (aucune version antérieure en prod
> à archiver pour le champ) — rollback simple si non validé.

## 1. Résumé fonctionnel

Répond au besoin de msavane : dans le système, certains projets sont des "projets chapeau" (projets principaux) avec de multiples "sous-projets" rattachés — souvent de petites interventions moins importantes pour le suivi commercial. Ajoute un lien Projet → Projet pour modéliser cette hiérarchie.

Champ `Projet__c.Projet_Principal__c` : lookup vers `Projet__c`, label **"Projet principal"**, relation enfants accessible via `Sous_Projets__r`. Pas de règle de validation anti-auto-référence (refusée explicitement par msavane). Portée volontairement limitée à la création du champ pour cette itération — pas de champ de filtrage ("est un sous-projet") ni de vue dédiée pour l'instant, à revoir plus tard si besoin.

## 2. Composants à déployer

Manifeste : `prod/manifest/package-projet-principal.xml`

- `prod/force-app/main/default/objects/Projet__c/fields/Projet_Principal__c.field-meta.xml` (le champ)
- `prod/force-app/main/default/profiles/Admin.profile-meta.xml` et `Custom Platform Profile.profile-meta.xml` — **contiennent uniquement l'ajout de FLS sur ce nouveau champ**, retirés fraîchement de l'org prod le 2026-08-25 juste avant construction de ce dossier (pas des copies de `wider-test`) pour éviter tout déploiement à partir d'un état de profil obsolète. Le déploiement de Profile dans Salesforce est additif sur les `fieldPermissions` : il n'affecte pas les permissions existantes non mentionnées dans le fichier.

## 3. Point d'attention — placement sur la page

**Le layout classique `Projet__c-Projet Layout` en prod est très différent de celui de `wider-test`** : en prod, il ne contient que 4 champs au total (`Mandant__c` n'y figure même pas), contrairement à `wider-test` où ce layout liste la majorité des champs. Ça indique que l'écran de saisie réel en prod est probablement piloté par une **Lightning Record Page** (Flexipage) plutôt que par ce layout classique.

**Ce dossier ne déploie donc pas de modification de layout** — ajouter la copie du layout de test aurait été trompeur (il ne reflète pas la structure réelle de la page prod) et risqué (écraser la structure existante du layout classique prod sans savoir si elle est utilisée). **Une fois le champ déployé, il faudra l'ajouter manuellement à l'endroit pertinent de l'écran Projet en prod** (Lightning App Builder si c'est une Flexipage, ou le layout classique sinon) — étape à faire dans l'interface, à la main, après ce déploiement.

## 4. Étapes de déploiement

1. Déployer :
   ```
   sf project deploy start --manifest prod/manifest/package-projet-principal.xml --target-org <alias-prod>
   ```
2. Ajouter manuellement le champ "Projet principal" à l'écran de la fiche Projet en prod (voir point 3 ci-dessus).
3. Vérifier sur un Projet réel (ou de test) que le champ est visible, modifiable, et que la relation `Sous_Projets__r` fonctionne (créer un sous-projet de test, vérifier qu'il apparaît bien listé depuis le projet principal).

## 5. Rollback — si non validé

Composant entièrement nouveau, aucune version antérieure à restaurer :

- **FLS** : simplement ne pas déployer les 2 fichiers de profil, ou les redéployer sans la section `fieldPermissions` ajoutée.
- **Champ** : suppression via un manifeste `destructiveChanges.xml` ciblant `Projet__c.Projet_Principal__c` (voir `prod/pret-a-deployer/rollback/` pour un exemple utilisé sur un précédent chantier). Aucune donnée existante affectée puisque c'est un nouveau champ, jamais rempli en prod.
