# Dossier de mise en prod — Suppression de la création auto de Compte/Contact (conversion Simap → Projet)

> Testé et validé par msavane sur `wider-test` le 2026-08-26 (parcours réel dans
> l'UI, 4 écrans de recherche confirmés fonctionnels sur la publication
> "CPC 273.0 Portes coupe-feu en bois", n° 34256-02).

## 1. Résumé fonctionnel

Le flow `Fl_ScrenConvertirEnProjet_DRAFT` (conversion d'une Publication Simap en Projet) créait automatiquement un Compte/Contact quand la recherche automatique (par Nom/LastName) ne trouvait rien. Les utilisateurs connaissant bien les offres auxquelles ils répondent, msavane a demandé de supprimer toute création automatique et d'imposer une recherche manuelle obligatoire, avec un écran dédié et une indication de recherche pour chacun des 4 cas :

- **Service Achat** → **Client/MO** (compte)
- **Contact du Service Achat** → **Contact Client/MO**
- **Service demandeur** → **Direction des travaux** (compte)
- **Contact du Service demandeur** → **Contact Direction des travaux**

Chaque écran affiche la donnée brute Simap correspondante en indication, et le composant de recherche est lié directement au champ cible sur `Projet__c` (`Maitre_d_ouvrage__c`, `Maitre_d_ouvrage_Contact__c`, `Direction_des_travaux_Compte__c`, `Direction_des_travaux__c`), avec le même mécanisme que le lookup "Nom du compte" déjà existant. Un écran ne s'affiche que si le champ Simap correspondant (Bureau d'achat ou Service demandeur) est renseigné — comportement de saut inchangé par rapport à avant.

**Important** : `wider-prod` est actuellement sur la **version 1** de ce flow (créée à l'origine, avec création automatique), alors que `wider-test` a accumulé plusieurs évolutions depuis (fluidification du parcours, re-rattachement d'un contact existant, puis cette suppression de création auto). Ce déploiement pousse donc **toutes ces évolutions accumulées d'un coup**, pas seulement le changement de cette demande.

## 2. Composants à déployer

Manifeste : `prod/manifest/package-conversion-simap-sans-creation-auto.xml`
Fichier source : `prod/force-app/main/default/flows/Fl_ScrenConvertirEnProjet_DRAFT.flow-meta.xml` (statut `Active`, s'activera immédiatement au déploiement)

**Pré-requis** : ce flow utilise `styleProperties` sur les champs d'écran, qui nécessite `sourceApiVersion >= 64.0`. Le fichier `sfdx-project.json` a été mis à jour en conséquence (`sourceApiVersion: 64.0`) — s'assurer que le déploiement utilise bien ce fichier de config (ou déployer avec `--api-version 64.0` en secours si besoin).

## 3. Étapes de déploiement

1. Déployer :
   ```
   sf project deploy start --manifest prod/manifest/package-conversion-simap-sans-creation-auto.xml --target-org <alias-prod>
   ```
2. Test de validation en prod (recommandé) : lancer la conversion depuis une vraie Publication Simap ayant un Bureau d'achat ET un Service demandeur renseignés, confirmer les 4 écrans de recherche et l'absence de toute création automatique de Compte/Contact.

## 4. Rollback — si non validé

- **Archive de la version prod actuelle (v1, avec création automatique)** : `prod/pret-a-deployer/rollback/Fl_ScrenConvertirEnProjet_DRAFT_avant_suppression_creation_auto_PROD.flow-meta.xml` — redéployer ce fichier tel quel pour revenir au comportement d'origine.
- **Rollback natif Salesforce** : Setup → Flows → `Fl_ScrenConvertirEnProjet_DRAFT` → onglet Versions → réactiver la version 1.
- Aucune donnée existante n'est affectée par un rollback : ce flow ne modifie que le comportement de l'écran de conversion, pas les Comptes/Contacts/Projets déjà créés.
