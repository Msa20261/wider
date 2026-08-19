# Dossier de mise en prod — Mapping civilité Triviso (ADRES_ID_entete)

> Testé et activé par msavane sur `wider-test` le 2026-08-19
> (ScheduleJobAccount v24, ScheduleJobContact v10).

## 1. Résumé fonctionnel

Le champ `ADRES_ID_entete__c` de `Proxy_Address__c` (code civilité Triviso : mo, ma, archi...) est désormais traduit et propagé sur Compte et Contact via deux champs :

- **`ADRES_ID_entete_c__c`** (déjà existant avant cette évolution) : reçoit le libellé complet traduit (ex: "Architecte"), via la formule `FrmlMapEntete` (CASE, 65 correspondances, table complète fournie par msavane).
- **`ADRES_ID_entete_TECH__c`** (nouveau champ, ajouté par msavane directement en cours de test) : reçoit le code brut Triviso tel quel (ex: "archi"), pour conserver une référence technique/traçabilité en plus du libellé lisible.

Les deux champs sont alimentés sur les 4 chemins de `ScheduleJobAccount` (création/mise à jour Compte business `__c`, création/mise à jour Compte personne `__pc`) et les 2 chemins de `ScheduleJobContact` (création/mise à jour Contact). Si un code Triviso ne correspond à aucune entrée de la table, la valeur brute d'origine est conservée sur `ADRES_ID_entete_c__c` (pas de perte de donnée).

## 2. Composants à déployer

Manifeste : `prod/manifest/package-adres-entete.xml`

| Composant | Type | Détail |
|---|---|---|
| `Account.ADRES_ID_entete_TECH__c` | CustomField | Code brut Triviso (nouveau) |
| `Contact.ADRES_ID_entete_TECH__c` | CustomField | Code brut Triviso (nouveau) |
| `ScheduleJobAccount` | Flow | v24, Active |
| `ScheduleJobContact` | Flow | v10, Active |

Note : `Account.ADRES_ID_entete_TECH__pc` (variante Compte personne) n'a pas de composant `CustomField` séparé à déployer — c'est un champ miroir automatique de la fonctionnalité Person Account, disponible dès que `ADRES_ID_entete_TECH__c` existe sur Account.

**Déployé avec `<status>Active</status>`** — contrairement aux autres dossiers de ce repo, ces flows sont déjà pleinement testés et activés par msavane en test ; le déploiement en prod les active donc immédiatement, sans étape de validation Draft intermédiaire.

## 3. Droits de profil

Déjà vérifiés en lecture/édition sur **Admin** et **Custom Platform Profile** pour `ADRES_ID_entete_TECH__c` (Account et Contact) sur `wider-test` — msavane les a correctement accordés à la création du champ. À vérifier/reproduire en prod pour les profils équivalents (édition activée sur les deux profils testés).

## 4. Étapes de déploiement

1. Déployer les champs + les 2 flows via le manifeste :
   ```
   sf project deploy start --manifest prod/manifest/package-adres-entete.xml --target-org <alias-prod>
   ```
2. Vérifier/accorder le FLS (lecture + édition) sur `ADRES_ID_entete_TECH__c` pour les profils concernés en prod.
3. Comme les flows se déploient déjà `Active`, l'effet est immédiat sur la prochaine synchronisation Proxy Address → Compte/Contact. Vérifier après déploiement qu'un enregistrement fraîchement synchronisé a bien les deux champs (`ADRES_ID_entete_c__c` et `ADRES_ID_entete_TECH__c`) correctement renseignés.

## 5. Rollback — ce qui existait avant

Dans `prod/pret-a-deployer/rollback/` :
- **`ScheduleJobAccount_avant_ADRES_ID_entete.json`** / **`ScheduleJobContact_avant_ADRES_ID_entete.json`** : export Tooling API des versions actives avant le début de cette évolution (v17 pour Account, v8 pour Contact — aucun mapping ADRES_ID_entete du tout). Ces versions restent nativement conservées dans Salesforce (statut "Obsolete") — pour revenir en arrière, réactiver la version correspondante depuis Setup → Flows → Versions, pas besoin de redéployer le JSON.
- Le champ `ADRES_ID_entete_TECH__c` est additif (nouveau champ) : en cas de rollback du flow, il suffit de ne plus l'alimenter, pas nécessaire de le supprimer.
