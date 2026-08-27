# État des lieux — `wider-test` vs `wider-prod`

> Document vivant, régénéré à chaque nouvel état des lieux (pas un rapport daté figé — le
> même fichier est mis à jour en place). Dernière génération : **2026-08-27**.
>
> **Ceci est un document de constat, pas un plan d'action.** Aucune correction n'a été
> appliquée sur les deux orgs à l'occasion de ce travail — c'est une photo de l'état réel,
> pour servir de référence avant les prochains développements.

## Méthode

- Retrieve complet (`sf project retrieve start`) depuis les deux orgs, alias `wider-test` et
  `wider-prod`, manifeste généré automatiquement (`sf project generate manifest --from-org`)
  puis filtré pour exclure le contenu pur sans intérêt pour le développement (Reports,
  Dashboards, Documents, ContentAsset, Translations, StandardValueSetTranslation,
  CustomObjectTranslation, WaveAnalyticAssetCollection, ManagedContentType, ReportType).
- `test/force-app` et `prod/force-app` reflètent maintenant chacun l'état **réellement en
  ligne** de leur org au 2026-08-27, composant par composant — plus une accumulation
  incrémentale des seules demandes traitées jusqu'ici.
- **Point de vigilance technique rencontré et corrigé pendant ce travail** : un premier essai
  de retrieve `wider-test` sans `--output-dir` a écrasé par erreur des fichiers dans
  `prod/force-app` (le CLI Salesforce, quand un composant a le même chemin relatif dans les
  deux `packageDirectories` du projet, réécrit les deux copies) — repéré immédiatement,
  `prod/force-app` restauré au dernier commit avant toute contamination, puis la prod a été
  retirée séparément dans un dossier isolé et fusionnée manuellement. Vérifié après coup :
  aucune contamination croisée résiduelle.
- Comparaison faite fichier par fichier (chemin relatif à `main/default/`), contenu binaire
  strict. Un fichier identique octet pour octet = "identique" ; sinon = "divergent". Pas de
  normalisation du bruit cosmétique connu (réordonnancement XML nondéterministe de l'API
  Metadata, balises `areMetricsLoggedToDataCloud`/`externalId` qui apparaissent ou disparaissent
  sans impact) — en cas de doute sur un diff, mieux vaut le lister que le masquer à tort.

## Chiffres clés

| | `wider-test` | `wider-prod` |
|---|---|---|
| Composants retirés (fichiers) | 3385 | 3279 |

| Catégorie | Nombre |
|---|---|
| **Identiques** (les deux orgs sont alignés) | **3040** |
| **Uniquement en test** | **161** |
| **Uniquement en prod** | **55** |
| **Présents des deux côtés mais différents** | **184** |

Autrement dit : environ **89 %** du périmètre retiré est déjà parfaitement aligné entre les
deux environnements. Le reste (400 composants sur 3385) se répartit comme détaillé ci-dessous.

## Cas particulier — tracké dans le repo mais pas (encore) en ligne en prod

Avant ce retrieve, `prod/force-app` ne contenait que 92 fichiers (suivi incrémental demande
par demande). En comparant avec le retrieve frais, **2 fichiers restent trackés dans le repo
sans exister réellement en prod** :

- `objects/Account/fields/ADRES_ID_entete_TECH__c.field-meta.xml`
- `objects/Contact/fields/ADRES_ID_entete_TECH__c.field-meta.xml`

**Connu et volontaire** : msavane a explicitement demandé de ne pas déployer ce champ
("ce champ ne sera plus utilisé donc pas besoin de déployer en prod pour l'instant", demande
#22). Pas une anomalie — laissé tel quel dans le repo, aucune action prise.

## Uniquement en test (161 composants)

| Type | Nb |
|---|---|
| `objects` (champs, listViews, recordTypes, validationRules, compactLayouts...) | 91 |
| `flowDefinitions` / `flows` | 12 chacun |
| `flexipages` | 7 |
| `layouts` | 7 |
| `staticresources` | 4 |
| `externalClientApps` + 4 types satellites (OAuth policies/settings) | 3 chacun |
| `pathAssistants` | 3 |
| `animationRules`, `duplicateRules`, `sharingRules`, `tabs` | 2 chacun |
| `globalValueSets`, `topicsForObjects` | 1 chacun |

Points notables :

- **`objects/Type_Adresse_Contact__c/`** (objet complet + 3 champs + 1 listView) : objet
  custom entièrement absent de prod, sans rapport avec une demande de cette session — **non
  investigué, à clarifier**.
- **`objects/MessagingEndUser/`, `objects/MessagingSession/`** (objets standards Messaging,
  ~20 champs) et **`sharingRules/MessagingEndUser`/`MessagingSession`** : la fonctionnalité
  Messaging Salesforce semble activée en test mais pas en prod — probablement un réglage
  d'org (feature toggle), pas un développement au sens strict.
- **`objects/Projet__c/validationRules/`** : `VR_Architecte_EG`, `VR_Facturation`,
  `VR_LivraisonContact`, `VR_Maitre_ouvrage` — 4 règles de validation sur Projet absentes de
  prod. `VR_Maitre_ouvrage` était mentionnée comme "vérifiée compatible" dans la demande #4 —
  à vérifier si son absence en prod bloque un cas d'usage du flow de conversion Simap
  maintenant déployé (demande #21).
- **`objects/Projet__c/recordTypes/`** : `Nouvo_prospect`, `wider_Inc` — absents de prod.
- **`objects/Account/recordTypes/Compte_Entre_Filiale_Fournisseur`** : **connu** (demande
  #15) — en prod, le même RecordType (libellé "Compte Entreprise") a le DeveloperName
  `Entreprise` à la place. Différence de nommage assumée, chaque environnement garde son
  propre DeveloperName par choix explicite de msavane.
- **`flows`/`flowDefinitions` obsolètes** (`FL_MaJProjectProbability`, `FL_MajAdress`,
  `FL_ScheduleProxyToProjetSales`, `FL_UpdateAccountPilotageProjet`,
  `FL_proxyToAccountSchedule`, `Fl_IspersonAccountCompte_personne`,
  `Fl_MajProbabiliteProjet` sans `_DRAFT`, `Fl_ProxyToContactSales`,
  `Fl_ScheduleProjetWithSunflow`, `Fl_ScrenConvertirEnProjet` sans `_DRAFT`, `TestEnv`,
  `TestScheduleProjet`) : vraisemblablement d'anciennes versions/brouillons remplacés par
  leurs équivalents `_DRAFT` ou déjà déployés sous un autre nom — non réévalués un par un,
  candidats probables à un nettoyage futur mais aucune suppression faite ici.
- **`duplicateRules/Contact.Contact_Duplicate_Detection_Standard`,
  `duplicateRules/Projet__c.TestProj`** : règles de doublons présentes en test uniquement,
  non investiguées.
- **`tabs/Simap.tab-meta.xml`** vs prod qui a `tabs/SIMAP.tab-meta.xml` (casse différente,
  potentiellement le même onglet renommé) — voir aussi la section Flexipages ci-dessous, même
  schéma de casse différente sur plusieurs objets Simap.
- **`objects/Publication_Simap__c/listViews/`, `objects/Proxy_Projet__c/listViews/`,
  `objects/Proxy_Address__c/listViews/`, etc.** : listViews `Test*`/`All1` présentes
  uniquement en test — vues de travail probablement créées pendant le développement, jamais
  répliquées en prod (et pas forcément nécessaire de le faire).

## Uniquement en prod (55 composants)

| Type | Nb |
|---|---|
| `objects` (champs, listViews, recordTypes) | 20 |
| `flexipages` | 9 |
| `layouts` | 6 |
| `duplicateRules` | 5 |
| `permissionsets` | 5 |
| `applications` | 3 |
| `sharingRules`, `tabs` | 2 chacun |
| `animationRules`, `pathAssistants`, `topicsForObjects` | 1 chacun |

Points notables :

- **`permissionsets/CRED_Simap`, `CredProxy`, `Read_Proxy_Adresse`, `Read_Simap`,
  `ToDeleteRecord`** : 5 Permission Sets existent en prod sans équivalent en test — probablement
  liés aux intégrations Triviso/Simap (accès technique aux objets Proxy). Sens inverse de ce
  qui est habituel dans cette session (prod en avance sur test) — à clarifier si un
  développement futur en test doit en tenir compte.
- **`objects/Simap_Federal_Entities__c/`** (objet complet + 3 champs + listView) et
  **`tabs/Simap_Federal_Entities__c`, `sharingRules/Simap_Federal_Entities__c`,
  `layouts/Simap_Federal_Entities__c-...`, `flexipages/Simap_Federal_Entity_Record_Page`** :
  **connu** (demande #21) — la logique "Federal Entities" a été proprement retirée du flow
  `Fl_ScreenAffichagePublicationSimap` côté test, mais l'objet Salesforce sous-jacent reste
  présent en prod (pas supprimé, juste plus utilisé par le flow). Cohérent avec ce qui a été
  documenté, pas une anomalie.
- **`objects/Account/recordTypes/Entreprise`** : **connu** (demande #15), pendant du
  `Compte_Entre_Filiale_Fournisseur` côté test — voir plus haut.
- **`duplicateRules/Account.Entreprise_Account`, `Contact.ContactDuplicate`,
  `PersonAccount.Person_Account`, `Projet__c.DupliProjet_2`, `Projet__c.RuleProjet`** :
  **partiellement connu** — `Entreprise_Account`, `DupliProjet_2` et `RuleProjet` sont les
  règles pré-existantes mentionnées dans la demande #7 (sortOrder 1/2 qu'il a fallu éviter lors
  du déploiement des nouvelles règles anti-doublon). `Contact.ContactDuplicate` et
  `PersonAccount.Person_Account` non réévaluées spécifiquement ici.
- **`objects/Account/fields/Statut_du_compte__c.field-meta.xml`** : champ présent en prod,
  absent de test — sens inverse de la tendance habituelle, à clarifier.
- **`layouts/Proxy_Document__c-Proxy Document Layout.layout-meta.xml`** vs test qui a
  **`layouts/Proxy_Document__c-Proxy Projet Layout.layout-meta.xml`** : même objet, layout
  visiblement renommé différemment dans chaque org (pas juste un contenu différent, un nom de
  fichier différent) — à vérifier si c'est le même layout logique ou deux layouts distincts.

## Composants présents des deux côtés mais divergents (184)

| Type | Nb | Nature |
|---|---|---|
| `objects` (fields/object-meta/listViews) | 36 | mixte, voir détail |
| `profiles` | 22 | non détaillé un par un, voir note |
| `applications` | 20 | non détaillé (probablement bruit UI) |
| `tabs` | 17 | non détaillé (probablement bruit UI/icônes) |
| `flexipages` | 15 | non détaillé (probablement mise en page) |
| `layouts` | 15 | voir détail partiel |
| `flowDefinitions` | 12 | **mécanique, non préoccupant** — voir note |
| `settings` | 12 | non détaillé (réglages d'org) |
| `duplicateRules` | 7 | voir détail |
| `flows` | 7 | voir détail |
| `matchingRules` | 4 | voir détail |
| `standardValueSets` | 4 | non détaillé |
| `cspTrustedSites`, autres types à 1 | ~10 | non détaillés, faible enjeu |

### `flowDefinitions` (12) — mécanique, pas une vraie divergence

Chaque fichier ne contient qu'un `<activeVersionNumber>` — le numéro de version active diffère
naturellement entre les deux orgs (chaque déploiement crée sa propre numérotation de version
locale à l'org). Attendu et sans signification en soi ; plusieurs sont liés aux activations
manuelles encore en attente de cette session (`Fl_ScreenAffichagePublicationSimap`,
`Fl_ScrenConvertirEnProjet_DRAFT`, `Task_Attribution_Automatique`, `Projet_Notification_Attribution`).

### `flows` (7) — contenu réellement différent

- **`ScheduleJobAccount`, `ScheduleJobContact`, `JobScheduleProjet`,
  `FL_ProxyRelationPersonAccount`, `Fl_ScheduleProxyDocToGetDocSales`** : dans les 5 cas,
  différence = **horaire planifié** (`startDate`/`startTime`), chaque org garde le sien par
  choix explicite de msavane (demande #15). Pour les 2 derniers (jamais examinés jusqu'ici
  cette session), le diff est minime (10-14 lignes) et se limite au bloc `<schedule>` — même
  schéma, rien d'autre ne diverge.
- **`Task_Attribution_Automatique`** : contenu du flow lui-même identique, la seule différence
  vient de la Queue `Tâches non attribuées` référencée dynamiquement (voir section `queues`)
  — **connu** (demande #16/#19), composition de la Queue volontairement différente par org
  (comptes réellement présents dans chaque org).
- **`Projet_Notification_Attribution`** : à vérifier — déployé récemment en prod (demande
  #20) encore en Draft, la divergence de contenu n'a pas été ré-examinée précisément ici.

### `queues` (1) et `quickActions` (1)

- **`Taches_non_attribuees.queue-meta.xml`** : **connu** (demande #16/#19) — composition
  différente par org (Ana Leal/Alexandre Gilbert/Admin Upmind en prod ; 5 membres incluant
  Toni Cortes et Admin Francois en test), volontaire.
- **`NewTask.quickAction-meta.xml`** : non réévalué précisément ici, probablement lié au champ
  `IsRecurrence` ajouté en test (demande #2) sans être forcément déployé en prod.

### `objects` (36) — détail des cas les plus significatifs

- **`Projet__c/fields/Factur__c.field-meta.xml`** : **corrigé pendant ce travail** — la
  formule (`Facture__c / Confirme__c`) est identique des deux côtés, seule une réécriture de
  format (retours à la ligne dans l'expression) différait suite au retrieve frais ; sans
  impact fonctionnel.
- **`Projet__c/fields/Etape__c`, `Business_Unit__c`, `Famille_commerciale__c`,
  `Secteur_d_activite__c`** : champs picklist, valeurs ou métadonnées de picklist différentes
  entre les deux orgs — **non investigué en détail**, à vérifier si des valeurs picklist
  existent dans un org et pas l'autre.
- **`Account/fields/Statut_compte__c.field-meta.xml`**, **`Contact/fields/Telephone_2__c`,
  `Telephone_3__c`** : non investigués.
- **`*/listViews/All.listView-meta.xml`** (Projet__c, Proxy_Address__c, Proxy_Document__c,
  Simap_Cantons__c, Simap_Code_CPV__c, Simap_Type_de_Publication__c...) : la vue "All"
  standard diffère légèrement entre les deux orgs sur plusieurs objets — probablement des
  colonnes affichées différentes, non détaillé composant par composant.
- **`Account.object-meta.xml`, `Activity.object-meta.xml`, `Contact.object-meta.xml`,
  `Projet__c.object-meta.xml`, etc.** (niveau objet) : divergences probablement liées aux
  `actionOverrides`/Lightning (même famille que ce qui a été vu en demande #17 sur
  `Attribution_Travaux__c`) — non détaillé.

### `duplicateRules` (7) — 2 cas notables

- **`Account.DuplicatAccount_V1`** : `sortOrder` diffère (2 en test, 3 en prod) — **connu**
  (demande #7), renumérotation faite lors du déploiement prod pour éviter un conflit avec les
  règles standards déjà actives.
- **`Account.Standard_Account_Duplicate_Rule`** (règle standard Salesforce, pas une règle
  msavane) : `actionOnInsert` diffère (**Block** en test, **Allow** en prod) et la
  `matchingRule` référencée diffère (`TestAccount` en test — **connu**, demande #7, "nom
  trompeur à clarifier séparément" — vs `Standard_Account_Match_Rule_v1_0` en prod, la vraie
  règle standard). **Écart réel et non anodin** : la règle standard de doublons Compte ne
  bloque pas les mêmes cas dans les deux environnements.
- Les 5 autres (`DupliAccountV2`, `Standard_Contact_Duplicate_Rule`,
  `Standard_Person_Account_Duplicate_Rule`, `DupliProjetV2`, `DupliProjetV3`) : divergences
  non détaillées ici, probablement des `sortOrder` du même type que ci-dessus.

### `matchingRules` (4) — 1 cas notable

- **`Projet__c.matchingRule-meta.xml`** : **prod contient une règle `ProjetMatching`
  (matching sur `Numero_projet__c`) absente de test.** Sens inverse de la tendance habituelle
  de cette session — une règle de rapprochement existe en prod sans équivalent connu côté
  test. À clarifier : est-ce une règle historique jamais répliquée, ou un résidu à nettoyer ?
- `Account.matchingRule-meta.xml`, `Contact.matchingRule-meta.xml`,
  `PersonAccount.matchingRule-meta.xml` : divergences non détaillées.

### `profiles` (22) — non détaillé composant par composant

Les 22 profils qui divergent incluent `Admin` et `Custom Platform Profile` (les deux profils
activement modifiés cette session — écarts probablement dus aux nombreux ajouts de FLS faits
uniquement côté prod au fil des demandes, pas encore répliqués côté test puisque test avait
déjà ces champs nativement) ainsi que 20 profils standards Salesforce (`Standard`,
`Read Only`, `Chatter Free User`, etc.) dont le contenu diverge nativement selon l'historique
propre de chaque org — non analysés un par un, volume trop important pour un examen ligne à
ligne dans cet état des lieux. À réévaluer composant par composant si un profil précis pose
problème lors d'un futur développement.

### Catégories non détaillées (bruit UI/org probable)

`applications` (20), `tabs` (17), `flexipages` (15), `settings` (12), `standardValueSets` (4),
`cspTrustedSites` (2), et les types à occurrence unique (`appMenus`, `brandingSets`,
`cleanDataServices`, `notificationTypeConfig`, `externalClientApps` et satellites OAuth) :
comptés mais pas descendus au niveau du contenu — la plupart de ces types reflètent des
réglages d'affichage ou de sécurité au niveau de l'org plutôt que du développement métier, et
le volume ne permettait pas un examen exhaustif dans le temps de cet état des lieux. À
regarder au cas par cas si un besoin futur touche spécifiquement l'un de ces types.

## Ce qui n'a PAS été fait ici (rappel)

- Aucun déploiement, aucune correction, aucune suppression n'a été effectué sur `wider-test`
  ni `wider-prod` à l'occasion de ce travail.
- Aucun fichier tracké existant n'a été supprimé du repo, y compris les 2 fichiers
  `ADRES_ID_entete_TECH__c` qui n'ont pas de contrepartie live en prod.
- Les catégories "non détaillées" ci-dessus n'ont pas été jugées sans intérêt — simplement pas
  analysées composant par composant faute de temps ; leur simple présence dans les tableaux de
  comptage suffit à savoir qu'elles existent et où chercher.
