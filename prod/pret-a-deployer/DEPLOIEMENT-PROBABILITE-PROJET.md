# Dossier de mise en prod — Correction du calcul de probabilité des Projets

> Testé et validé par msavane sur `wider-test` le 2026-08-19 (flow activé en version 2).
> Contient aussi l'archive de ce qui existait avant, pour rollback si besoin.

## 1. Résumé fonctionnel

Le flow `Fl_MajProbabiliteProjet_DRAFT` (recalcule `Probabilit__c` sur `Projet__c` à partir de la table `Probabilit_par_tape__c`) avait deux défauts corrigés ici :

1. **Il se déclenchait à chaque sauvegarde du Projet**, pas seulement quand l'étape changeait — toute saisie manuelle de probabilité pouvait être écrasée par une modification sans rapport. Corrigé via une condition d'entrée par formule (`ISCHANGED`/`ISNEW` sur `Etape__c` et `Mandant__c`).
2. **Aucun repli si le couple Mandant+Étape n'avait pas de règle définie** — le Projet gardait son ancienne probabilité silencieusement. Corrigé : retombe désormais sur la recherche par Étape seule.

En parallèle, les valeurs de probabilité ont été révisées suite à la demande métier :

| Étape | Ancienne valeur | Nouvelle valeur |
|---|---|---|
| Opportunité | 10% | **0%** |
| Ouvert | 30% | **0%** |
| Offre envoyée (nom technique `Ouvert (Offre envoyée)`) | 40% | **50%** |
| En préparation | 60% | **50%** |
| Confirmé | 75% | **100%** |

Attribution, Chiffrage, Exécuté, Facturé, Terminé, Pas exécuté : **non modifiés** (non concernés par la demande).

## 2. Composants à déployer

Manifeste : `prod/manifest/package-probabilite-projet.xml`
Fichier source : `prod/force-app/main/default/flows/Fl_MajProbabiliteProjet_DRAFT.flow-meta.xml`

Déployé avec `<status>Draft</status>` — **ne s'active pas automatiquement**.

## 3. Étapes de déploiement

1. Vérifier l'état actuel du flow en prod avant de déployer (version active actuelle) — non vérifiable depuis cette session, aucun org prod Wider connecté en CLI ici.
2. Déployer le flow :
   ```
   sf project deploy start --manifest prod/manifest/package-probabilite-projet.xml --target-org <alias-prod>
   ```
3. Exécuter dans l'ordre, via Setup → Apex anonyme, les 2 scripts de `prod/pret-a-deployer/rollback/` :
   - `01_appliquer_nouvelles_probabilites.apex` (corrige la table de référence)
   - `02_backfill_projets_existants.apex` (recalcule les Projets déjà sur une étape concernée — retourne le nombre de lignes mises à jour, à comparer avec l'effectif attendu en prod)
4. Tester manuellement en Draft (Setup → Flows → Debug) sur un vrai changement d'étape.
5. Activer la nouvelle version du flow (Setup → Flows → sélectionner la version déployée → Activate).

## 4. Rollback — ce qui existait avant (mémoire pour annulation)

Tout le contenu utile à un rollback est dans `prod/pret-a-deployer/rollback/` :

- **`Fl_MajProbabiliteProjet_DRAFT_v1_avant_correction.json`** : export brut (Tooling API) de la version 1 du flow (celle sans le correctif, "Obsolete" sur `wider-test` depuis l'activation de la v2). Sert de trace si jamais la définition du flow venait à être perdue.
- **Rollback rapide côté flow** : Salesforce conserve nativement toutes les versions. Pour revenir à l'ancien comportement, il suffit de réactiver la version précédente depuis Setup → Flows → onglet Versions → Activate sur l'ancienne version — pas besoin de redéployer le JSON archivé pour ça.
- **`ROLLBACK_restaurer_anciennes_probabilites.apex`** : restaure les anciennes valeurs (10/30/40/60/75%) sur la table de référence, puis sur les Projets dont la probabilité correspond encore exactement à la nouvelle valeur (ne touche pas aux valeurs modifiées manuellement entre-temps par un utilisateur).
- **`01_appliquer_nouvelles_probabilites.apex` / `02_backfill_projets_existants.apex`** : à l'inverse, servent à ré-appliquer le correctif si jamais on annule puis qu'on souhaite le remettre.

## 5. Portée non traitée

La demande initiale incluait aussi "déclenchement création projet dans Triviso dès Attribution" — **explicitement mis de côté**, aucun mécanisme Salesforce→Triviso n'existe aujourd'hui pour créer un projet côté Triviso (seul le sens Triviso→Salesforce existe via `FL_ScheduleProxyToProjetSales`). À cadrer séparément avec l'équipe Triviso avant toute implémentation.
