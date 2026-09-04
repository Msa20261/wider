# Dossier de mise en prod — Verrou Étape Projet post-Ouvert (demande #32)

> Testé et validé par msavane sur `wider-test` le 2026-09-04 (test fonctionnel direct dans l'UI par msavane, blocage/déblocage vérifié en CLI par ailleurs).
> Métadonnées uniquement — voir section 4 pour l'étape data (assignation du Permission Set) obligatoire après déploiement.

## 1. Résumé fonctionnel

Besoin : une fois qu'un Projet a atteint l'étape `Ouvert` (ou une étape postérieure), un collaborateur ne doit plus pouvoir changer manuellement `Etape__c` — cette progression est censée être pilotée uniquement par la synchronisation Triviso (flow `JobScheduleProjet`). La plupart des autres champs Triviso (montants, `Numero_projet__c`, etc.) sont déjà en lecture seule statique sur `Projet_Record_Page` ; `Etape__c` restait le seul champ encore librement éditable.

- **`VR_Verrou_Etape_Post_Ouvert`** (Validation Rule sur `Projet__c`) : bloque toute modification de `Etape__c` dès que l'étape *avant* la modification était déjà `Ouvert` ou postérieure (pas de blocage tant que le Projet est encore à `Opportunité` ou `Attribution`, ni sur création).
- **`Bypass_Verrou_Triviso`** (Custom Permission) + **`PS_Bypass_Verrou_Triviso`** (Permission Set) : contournement pour que `JobScheduleProjet` continue de fonctionner (un flow planifié s'exécute avec les droits de l'utilisateur qui l'a activé, donc cet utilisateur doit avoir ce Permission Set).

**Le grisage visuel conditionnel des champs Triviso (2ᵉ partie de la demande initiale) n'est pas inclus ici** — non supporté nativement par Dynamic Forms sans dupliquer les champs sur la page (limitation déjà rencontrée sur le chantier abandonné du 02/09, cf. mémoire projet). Le verrou par Validation Rule couvre le besoin fonctionnel (empêcher la modification), sans risque de retoucher `Projet_Record_Page`.

## 2. Point de vigilance important

**Sans l'étape 4 (assignation data), ce déploiement casse silencieusement la synchronisation Triviso en prod** : dès que `JobScheduleProjet` essaiera de faire progresser `Etape__c` d'un Projet déjà à `Ouvert` ou plus, il se heurtera à la même Validation Rule et échouera avec le message d'erreur destiné aux collaborateurs. Ne pas déployer ce composant sans faire immédiatement l'étape 4.

**Si un jour quelqu'un d'autre active `JobScheduleProjet` en prod** (actuellement `admin.wider@upmind.fr`), cette personne doit impérativement recevoir `PS_Bypass_Verrou_Triviso`, sinon même symptôme.

## 3. Composants à déployer

Manifeste : `prod/manifest/package-verrou-etape-projet.xml`

```
sf project deploy start --manifest prod/manifest/package-verrou-etape-projet.xml --target-org <alias-prod>
```

Contenu :
- `CustomPermission` : `Bypass_Verrou_Triviso` (nouveau)
- `PermissionSet` : `PS_Bypass_Verrou_Triviso` (nouveau)
- `ValidationRule` : `Projet__c.VR_Verrou_Etape_Post_Ouvert` (nouveau)

Aucune FLS séparée nécessaire — le Permission Set ne touche à aucun champ, uniquement la Custom Permission.

## 4. Étapes de déploiement — ordre important

1. Déployer le manifeste (commande ci-dessus).
2. **Assigner immédiatement `PS_Bypass_Verrou_Triviso`** aux comptes admin de prod. Deux comptes System Administrator actifs identifiés en prod à ce jour : `admin.wider@upmind.fr` et `a.leal4@wider-sa.ch`. Recommandé d'assigner aux deux (comme fait en test sur les 2 admins test), sauf si msavane confirme qu'un seul de ces comptes active réellement les flows planifiés :
   ```
   sf org assign permset -o wider-prod -n PS_Bypass_Verrou_Triviso
   ```
   (à répéter pour le second admin via une assignation directe `PermissionSetAssignment` si la commande ci-dessus ne cible que l'utilisateur par défaut de l'alias CLI — cf. mémoire projet, cas déjà rencontré en test).
3. **Vérifier** : `SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name='PS_Bypass_Verrou_Triviso'` → doit renvoyer au moins l'utilisateur qui active `JobScheduleProjet`.
4. **Test de fumée sur un Projet réel en prod déjà à une étape ≥ Ouvert** : tenter un changement d'`Etape__c` sans le Permission Set (avec un compte non-admin ou en retirant temporairement le Permission Set) → doit être bloqué avec le message. Remettre le Permission Set → doit passer. Ne pas laisser de changement résiduel sur le Projet de test.
5. Relancer `JobScheduleProjet` normalement et vérifier qu'aucune nouvelle erreur de type "Cette étape est pilotée automatiquement..." n'apparaît dans `Erreurs__c` des `Proxy_Projet__c` traités.

## 5. Rollback

Chantier purement additif, aucune donnée existante modifiée par le déploiement lui-même.

- Suppression directe suffit : `sf project delete source -m "ValidationRule:Projet__c.VR_Verrou_Etape_Post_Ouvert" -m "PermissionSet:PS_Bypass_Verrou_Triviso" -m "CustomPermission:Bypass_Verrou_Triviso" --target-org <alias-prod>`
- Pas de dépendance ailleurs (aucun autre flow/page ne référence ces composants).

## 6. Portée non traitée

- Grisage visuel conditionnel des champs Triviso selon l'étape (cf. section 1) — écarté pour l'instant, à rouvrir séparément si le blocage seul ne suffit pas côté ressenti utilisateur une fois en usage réel.
