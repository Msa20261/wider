# Dossier de mise en prod — Liaison Société du groupe ↔ Compte (demande #29)

> Testé et validé par msavane sur `wider-test` le 2026-09-02.
> Métadonnées uniquement — aucune donnée n'a été déployée en prod pour ce chantier, voir section 4.

## 1. Résumé fonctionnel

`Soci_t_du_groupe__c` était quasi vide (6 enregistrements : Wider Inc, Wider Bussigny, Wider Clarens, PLS, Wider Genève, bois4u — seul `Name` rempli). Objectif : les lier à leur compte respectif et récupérer automatiquement les informations utiles.

- **Nouveau champ** `Compte_Associe__c` (Lookup → Account).
- **Rapprochement** via `IdentifiantSoci_t_grpupe__c` (Texte, sur Société du groupe) = `Account.Identification__c` — confirmé 1:1 exact sur les 6 (le nom seul n'aurait pas suffi : doublons sur Wider Inc/PLS/bois4u, aucun match sur Bussigny/Clarens/Genève).
- **`TVA__c` corrigé** : c'était une liste de choix de *taux* de TVA (mapping initial erroné malgré le nom identique), convertie en Texte pour recevoir le vrai numéro de TVA (`Account.Numero_TVA__c`).
- **Nouveau champ `Pays__c`**, alimenté depuis l'adresse du compte.
- **Synchronisation continue** : flow `Fl_SyncAccountVersSocieteGroupe` (Record-Triggered sur `Account`) — toute modification ultérieure sur le compte (adresse, TVA, téléphone, email, site web) se répercute automatiquement sur la Société du groupe liée.
- Champs synchronisés au final : `TVA__c` (← `Numero_TVA__c`), `TVA_intra_communautaire__c` (← `No_TVA_EU__c`), `T_l_phone__c` (← `Telephone_1__c`, repli `Phone`), `Email__c` (← `Email_1__c`), `Site_web__c` (← `Website`), `Complement_d_adresse__c` (← `Supplement_adresse__c`), `Rue__c`/`Code_postal__c`/`Ville__c`/`Pays__c` (← `Adresse_compte__c` composé, repli Billing puis Shipping).

## 2. Protection contre la reprise en masse (important)

`ScheduleJobAccount` écrit `Website`/`Adresse_compte__c`/`Supplement_adresse__c` sur **chaque** création/mise à jour de compte — confirmé par lecture directe du flow. Sans garde-fou, `Fl_SyncAccountVersSocieteGroupe` se déclencherait sur une grande partie des dizaines de milliers de comptes traités par la reprise.

**Protection ajoutée** : liste blanche sur `Account.Identification__c` (les 6 identifiants actuellement liés : `1000`/`2000`/`3000`/`4000`/`7000`/`9000`), évaluée en tout premier dans le `filterFormula` du flow — quasi gratuite (filtre d'entrée natif Salesforce, aucune requête déclenchée pour un compte non concerné).

**⚠️ À ne pas oublier** : si de nouvelles Sociétés du groupe sont liées à l'avenir, cette liste doit être mise à jour manuellement dans le flow (`Fl_SyncAccountVersSocieteGroupe`, élément de démarrage, `filterFormula`).

## 3. Composants à déployer

Manifeste : `prod/manifest/package-societe-groupe.xml`

```
sf project deploy start --manifest prod/manifest/package-societe-groupe.xml --target-org <alias-prod>
```

Contenu :
- `CustomField` : `Soci_t_du_groupe__c.Compte_Associe__c` (nouveau), `TVA__c` (type modifié Picklist→Texte), `Pays__c` (nouveau)
- `Flow` : `Fl_SyncAccountVersSocieteGroupe` (nouveau, sera actif immédiatement après déploiement — c'est voulu, cf. section 2 pour la protection)
- `FlexiPage` : `Soci_t_du_groupe_Record_Page` (ajout du champ Pays à côté de Ville — **seule page existante pour cet objet en prod**, contrairement à test qui en a deux)
- `Profile` (FLS) : `Admin`, `Sys Admin Plateform`, `Custom Platform Profile` — lecture/édition sur les 3 nouveaux champs. Pattern déjà utilisé sans incident sur ce projet (contrairement à un déploiement `Profile:System Administrator` — mauvais nom d'API, à éviter, cf. mémoire projet).

## 4. Étapes de déploiement — ordre important

1. **Vérifier avant de déployer** : `TVA__c` est actuellement vide sur les 6 enregistrements en prod (à reconfirmer juste avant, la conversion Picklist→Texte est sûre à 0 donnée mais mérite une double vérification).
2. Déployer le manifeste (commande ci-dessus).
3. **Peupler manuellement les 6 enregistrements** — script Apex, à exécuter en Anonymous Apex après le déploiement :
   ```apex
   Map<String, Account> comptesParId = new Map<String, Account>();
   for (Account a : [SELECT Id, Identification__c, Numero_TVA__c, No_TVA_EU__c, Phone, Website,
                             Email_1__c, Telephone_1__c, Supplement_adresse__c,
                             Adresse_compte__Street__s, Adresse_compte__City__s, Adresse_compte__PostalCode__s, Adresse_compte__CountryCode__s,
                             BillingStreet, BillingPostalCode, BillingCity, BillingCountry,
                             ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry
                      FROM Account WHERE Identification__c IN ('1000','2000','3000','4000','7000','9000')]) {
       comptesParId.put(a.Identification__c, a);
   }
   List<Soci_t_du_groupe__c> societes = [SELECT Id, Name, IdentifiantSoci_t_grpupe__c FROM Soci_t_du_groupe__c WHERE IdentifiantSoci_t_grpupe__c != null];
   List<Soci_t_du_groupe__c> aMettreAJour = new List<Soci_t_du_groupe__c>();
   for (Soci_t_du_groupe__c s : societes) {
       Account a = comptesParId.get(s.IdentifiantSoci_t_grpupe__c);
       if (a == null) { System.debug('Aucun compte pour ' + s.Name); continue; }
       Soci_t_du_groupe__c maj = new Soci_t_du_groupe__c(Id = s.Id);
       maj.Compte_Associe__c = a.Id;
       maj.TVA__c = a.Numero_TVA__c;
       maj.TVA_intra_communautaire__c = a.No_TVA_EU__c;
       maj.T_l_phone__c = String.isNotBlank(a.Telephone_1__c) ? a.Telephone_1__c : a.Phone;
       maj.Email__c = a.Email_1__c;
       maj.Site_web__c = a.Website;
       maj.Complement_d_adresse__c = a.Supplement_adresse__c;
       maj.Rue__c = String.isNotBlank(a.Adresse_compte__Street__s) ? a.Adresse_compte__Street__s : (String.isNotBlank(a.BillingStreet) ? a.BillingStreet : a.ShippingStreet);
       maj.Code_postal__c = String.isNotBlank(a.Adresse_compte__PostalCode__s) ? a.Adresse_compte__PostalCode__s : (String.isNotBlank(a.BillingPostalCode) ? a.BillingPostalCode : a.ShippingPostalCode);
       maj.Ville__c = String.isNotBlank(a.Adresse_compte__City__s) ? a.Adresse_compte__City__s : (String.isNotBlank(a.BillingCity) ? a.BillingCity : a.ShippingCity);
       maj.Pays__c = String.isNotBlank(a.Adresse_compte__CountryCode__s) ? a.Adresse_compte__CountryCode__s : (String.isNotBlank(a.BillingCountry) ? a.BillingCountry : a.ShippingCountry);
       aMettreAJour.add(maj);
   }
   update aMettreAJour;
   System.debug(aMettreAJour.size() + ' societes mises a jour');
   ```
4. Vérifier sur un enregistrement réel que le compte associé et les champs sont bien renseignés.

**⚠️ Résultat attendu à l'étape 3, vérifié le 2026-09-02** : **aucun des 6 comptes n'existe encore en prod** (recherche par `Identification__c` et par `Name` toutes les deux vides — la reprise Compte n'y est pas encore arrivée pour ces entités). Le script ci-dessus ne trouvera donc probablement **aucun compte à lier pour l'instant** — ce n'est pas une erreur, c'est attendu. Dès que ces comptes existeront en prod (reprise en cours), soit relancer ce script manuellement, soit une simple mise à jour de ces comptes déclenchera automatiquement le flow (à condition que `Compte_Associe__c` ait été renseigné au préalable une fois le compte créé — le flow ne fait que *synchroniser*, pas *lier* automatiquement une nouvelle Société du groupe).

## 5. Rollback

Aucun fichier d'archive nécessaire : chantier purement additif à une exception près.

- **Nouveaux champs/flow/page** : suppression directe suffit (`sf project delete source -m "Flow:Fl_SyncAccountVersSocieteGroupe" -m "CustomField:Soci_t_du_groupe__c.Compte_Associe__c" -m "CustomField:Soci_t_du_groupe__c.Pays__c"` etc.) — pas de dépendance ailleurs.
- **`TVA__c`** : seul champ existant modifié (type Picklist→Texte). Pour revenir en arrière, redéployer l'ancienne définition (liste de choix restreinte : Exoneration, 5,50%, 10%, 20%, Communauté économique européenne, Export, 19.6%, 18%, 13%) — sans risque de perte tant que `TVA__c` reste vide en prod au moment du rollback (à vérifier avant, comme pour tout rollback de type de champ).
- **FLS** : redéployer les fragments de profil sans les 3 `fieldPermissions` ajoutés, ou laisser en l'état (accès en trop, pas un risque de sécurité significatif pour 3 champs internes).

## 6. Portée non traitée

Aucune — demande complète (liaison, mapping, synchronisation continue, TVA/Pays/Email/Téléphone) livrée intégralement en test.
