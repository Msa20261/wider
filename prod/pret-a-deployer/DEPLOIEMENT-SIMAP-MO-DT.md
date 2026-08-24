# Dossier de mise en prod — Mapping Service achat/demandeur → Client-MO/Direction Travaux

> Référence : demande #4 dans `HISTORIQUE-DEMANDES-WIDER.md`
> Préparé le 2026-08-17, testé et validé en Draft (v3) sur `wider-test`.
> **Ne pas déployer avant validation métier explicite.**

## 1. Résumé fonctionnel

Sur le flow `Fl_ScrenConvertirEnProjet_DRAFT` (conversion Publication SIMAP → Projet) :
- Le **Service achat** de la publication est recherché/créé comme Compte (+ Contact) et mappé sur **Client/MO** du Projet.
- Le **Service demandeur** est recherché/créé comme Compte (+ Contact) et mappé sur **Direction Travaux** du Projet.
- Recherche avant création (pas de doublon) — testé avec deux publications partageant le même Service achat, confirmé fonctionnel.
- Écran de confirmation si un Compte/Contact correspondant existe déjà ; écran de confirmation dédié si un nouveau a été créé.
- Correction d'un bug existant : l'adresse du Service achat n'est plus insérée à tort dans `Adresse_Facturation__c`.
- Rattachement automatique d'un Contact existant réutilisé au nouveau Compte si celui-ci vient d'être créé (évite une incohérence Compte/Contact).

## 2. Composants à déployer

Voir le manifeste : `prod/manifest/package.xml`

| Composant | Type | Détail |
|---|---|---|
| `Publication_Simap__c.Nom_service_demandeur__c` | CustomField | Nom d'organisme du Service demandeur |
| `Publication_Simap__c.Contact_bureau_d_achat__c` | CustomField | Contact individuel du Service achat |
| `Publication_Simap__c.Contact_service_demandeur__c` | CustomField | Contact individuel du Service demandeur |
| `PublicationSimap` | ApexClass | Mapping des nouveaux champs depuis l'API SIMAP |
| `SimapPublicationDetailService` | ApexClass | Ajout du champ `contactPerson` au wrapper `SimapAdress` |
| `PublicationSimapTest` | ApexClass | Classe de test (ajoutée au dossier le 2026-08-24, absente initialement) |
| `SimapPublicationDetailServiceTest` | ApexClass | Classe de test (ajoutée au dossier le 2026-08-24, absente initialement) |
| `MockHttpSimapResponse` | ApexClass | Mock HTTP utilisé par les tests ci-dessus (dépendance de test) |
| `Fl_ScrenConvertirEnProjet_DRAFT` | Flow | Nouvelle version (logique Compte/Contact MO+DT) |

Fichiers source : `prod/force-app/main/default/**` (copie de la version validée en test).

## 3. ⚠️ Non inclus dans le déploiement automatique : droits de profil

Les 3 nouveaux champs nécessitent une visibilité (lecture + édition) sur les profils **System Administrator (Admin)** et **Custom Platform Profile**, déjà validée sur `wider-test`.

**Ne pas déployer les fichiers `.profile-meta.xml` de test tels quels vers la prod** : les profils prod peuvent avoir divergé de ceux de test sur d'autres permissions non liées à ce sujet (d'où le dossier `prod/divergences/` du repo), et un déploiement complet de profil écraserait ces différences.

**À faire manuellement en prod**, pour les deux profils **System Administrator** et **Custom Platform Profile** :
1. Setup → Object Manager → Publication Simap → Fields & Relationships → sélectionner chacun des 3 champs → **Set Field-Level Security** → cocher Visible (+ Read-Only si souhaité, testé avec édition activée sur les deux profils en test).

Ou, si un déploiement via Metadata API est préféré : récupérer le profil **depuis la prod** (pas depuis test), y ajouter uniquement ces blocs `fieldPermissions`, puis déployer ce fichier prod modifié :

```xml
<fieldPermissions>
    <editable>true</editable>
    <field>Publication_Simap__c.Contact_bureau_d_achat__c</field>
    <readable>true</readable>
</fieldPermissions>
<fieldPermissions>
    <editable>true</editable>
    <field>Publication_Simap__c.Contact_service_demandeur__c</field>
    <readable>true</readable>
</fieldPermissions>
<fieldPermissions>
    <editable>true</editable>
    <field>Publication_Simap__c.Nom_service_demandeur__c</field>
    <readable>true</readable>
</fieldPermissions>
```

Les droits déjà en place et vérifiés compatibles (aucune action requise) :
- Accès aux 2 classes Apex : déjà `enabled=true` par défaut sur les deux profils.
- CRUD Create/Edit/Read sur Account, Contact, Projet__c : déjà présents sur les deux profils.
- FLS sur les champs `Maitre_d_ouvrage__c`, `Maitre_d_ouvrage_Contact__c`, `Direction_des_travaux_Compte__c`, `Direction_des_travaux__c` (Projet__c) : déjà en édition sur les deux profils.

## 4. Tests Apex

Exécutés sur `wider-test` le 2026-08-17 :
- `PublicationSimapTest`, `SimapPublicationDetailServiceTest`, `SimapUtilsTest`, `SimapHeadersServiceTest` → **42/42 passent (100%)**, aucune régression.
- Couverture : `SimapPublicationDetailService.cls` 100% ; `PublicationSimap.cls` 97% (les 2 lignes non couvertes sont des branches `else` préexistantes, non liées à cette évolution). Les nouvelles lignes de mapping (Service achat/demandeur, contacts) sont couvertes par `testUpdatePublicationWithDetails`.
- Aucun nouveau test dédié n'a été écrit spécifiquement pour les 3 nouveaux champs — la couverture vient du test existant qui exerce déjà `updatePublicationWithDetails`.

**Mise à jour du 2026-08-24** : `PublicationSimapTest` et `SimapPublicationDetailServiceTest` (+ `MockHttpSimapResponse`, le mock HTTP dont ils dépendent) manquaient du dossier de déploiement initial — seules les classes d'implémentation y étaient. Corrigé : les 3 classes sont maintenant dans `prod/force-app/main/default/classes/` et dans `prod/manifest/package.xml`. Re-testé sur `wider-test` avec le code actuel : **11/11 tests passent (100%)**. Sans ces classes, un déploiement en prod aurait pu échouer si `PublicationSimapTest`/`SimapPublicationDetailServiceTest` n'existaient pas déjà côté prod (aucun org prod connecté pour le vérifier depuis cette session) — les inclure lève le doute.

## 5. Point de vigilance vérifié : règle de validation

`VR_Maitre_ouvrage` (active sur `Projet__c`) interdit de renseigner `Maitre_d_ouvrage_Contact__c` si `Maitre_d_ouvrage__c` est vide. La logique du flow a été relue pour ce cas précis (y compris le correctif de rattachement automatique) : le Compte MO est toujours résolu avant ou en même temps que le Contact, dans tous les chemins. **Aucun conflit attendu**, mais à garder en tête si un comportement inattendu apparaît en prod.

## 6. Étapes de déploiement recommandées

1. **Vérifier l'état actuel de `Fl_ScrenConvertirEnProjet_DRAFT` en prod** avant de déployer (version active actuelle, pour savoir ce qui sera remplacé) — non vérifiable depuis cette session (aucun org prod Wider connecté en CLI ici).
2. Déployer les champs + classes Apex + flow via le manifeste :
   ```
   sf project deploy start --manifest prod/manifest/package.xml --target-org <alias-prod>
   ```
3. Le flow est inclus avec `<status>Draft</status>` — **il ne sera pas actif automatiquement après déploiement.**
4. Appliquer les droits de profil (section 3) manuellement.
5. **Tester manuellement la nouvelle version en Draft dans Setup → Flows** (Debug) sur au moins une publication SIMAP réelle en prod avant activation.
6. Une fois validé, activer la nouvelle version du flow (Setup → Flows → `Fl_ScrenConvertirEnProjet_DRAFT` → sélectionner la version déployée → Activate).

## 7. Rollback

- Champs et classes Apex : additifs, aucun impact sur l'existant si on ne les utilise pas — pas de rollback nécessaire en cas de problème mineur.
- Flow : si la nouvelle version pose problème après activation, réactiver l'ancienne version depuis Setup → Flows → onglet Versions (aucune donnée n'est perdue, les deux versions coexistent).

## 8. Remarque hors-scope

Le flow s'appelle `Fl_ScrenConvertirEnProjet_DRAFT` (suffixe "_DRAFT" dans le nom d'API) alors qu'il s'agit du flow réellement utilisé. Un renommage n'est pas recommandé ici (recréerait le flow avec un nouvel Id et perdrait l'historique de versions) mais mérite d'être signalé pour clarification côté métier.
