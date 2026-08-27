@isTest
public class ProjetTriggerTest {

    private static Account livraisonAccount(String name, String city) {
        Account acc = new Account(
            Name = name,
            Adresse_compte__city__s        = city,
            Adresse_compte__street__s      = '5 Avenue de la Gare',
            Adresse_compte__postalCode__s  = '1003',
            Adresse_compte__CountryCode__s = 'CH'
        );
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.allowSave = true;
        Database.insert(acc, dmo);
        return acc;
    }

    private static Projet__c newProjet(String name, Id livraisonId) {
        return new Projet__c(
            Name = name,
            Etape__c = 'Qualification',
            Etat__c  = 'Ouvert',
            Adresse_de_Livraison__c = livraisonId
        );
    }

    private static Boolean needsGeocoding(Id projetId) {
        return [SELECT NeedsGeocoding__c FROM Projet__c WHERE Id = :projetId].NeedsGeocoding__c;
    }

    // ─── BEFORE_INSERT ────────────────────────────────────────────────────────

    @isTest
    static void testInsert_withLivraison_flagsForGeocoding() {
        Account livraison = livraisonAccount('Livraison Insert', 'Lausanne');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            Projet__c projet = newProjet('Projet avec livraison', livraison.Id);
            insert projet;
            Integer futureCalls = Limits.getFutureCalls();
        Test.stopTest();

        // Le trigger ne géocode plus à la création : il pose le flag et laisse
        // ProjetGeocodeBatch faire le travail (voir le commentaire du bloc
        // AFTER_UPDATE du trigger pour la raison — limite des 50 @future).
        Projet__c reloaded = [SELECT NeedsGeocoding__c, latitude__c, longitude__c FROM Projet__c WHERE Id = :projet.Id];
        System.assertEquals(0, futureCalls, 'Aucun @future ne doit partir à la création');
        System.assertEquals(true, reloaded.NeedsGeocoding__c,
            'Le flag doit rester à true pour que ProjetGeocodeBatch reprenne le projet');
        System.assertEquals(null, reloaded.latitude__c,
            'Le géocodage à la création est délégué au batch, pas au trigger');
    }

    // Depuis que NeedsGeocoding__c a `true` comme valeur par defaut (necessaire
    // parce que le flow JobScheduleProjet bypasse le trigger et ne poserait donc
    // jamais le flag), TOUT projet nait marque, meme sans adresse de livraison.
    // C'est ProjetGeocodeBatch qui tranche ensuite : resolveGeocodingAddress
    // renvoie null, aucun callout n'est fait, et le flag repasse a false.
    @isTest
    static void testInsert_withoutLivraison_isFlaggedByDefault() {
        Test.startTest();
            Projet__c projet = newProjet('Projet sans livraison', null);
            insert projet;
            Integer futureCalls = Limits.getFutureCalls();
        Test.stopTest();

        System.assertEquals(true, needsGeocoding(projet.Id),
            'La valeur par defaut du champ marque le projet, meme sans adresse de livraison');
        System.assertEquals(0, futureCalls,
            'Le trigger ne doit declencher aucun @future a la creation');
    }

    // ─── BEFORE_UPDATE ────────────────────────────────────────────────────────

    // Cas du rattachement tardif par les flux Triviso : le compte de livraison est
    // résolu après la création du projet, donc via un update.
    @isTest
    static void testUpdate_attachingLivraison_flagsForGeocoding() {
        Account livraison = livraisonAccount('Livraison Update', 'Lausanne');

        TriggerHandler.bypassProjetTrigger = true;
        Projet__c projet = newProjet('Projet rattaché plus tard', null);
        insert projet;
        TriggerHandler.bypassProjetTrigger = false;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            projet.Adresse_de_Livraison__c = livraison.Id;
            update projet;
        Test.stopTest();

        Projet__c reloaded = [SELECT latitude__c FROM Projet__c WHERE Id = :projet.Id];
        System.assertNotEquals(null, reloaded.latitude__c,
            'Le rattachement tardif du compte de livraison doit déclencher le géocodage');
    }

    @isTest
    static void testUpdate_unrelatedFieldChange_doesNotFlag() {
        Account livraison = livraisonAccount('Livraison Stable', 'Lausanne');

        TriggerHandler.bypassProjetTrigger = true;
        Projet__c projet = newProjet('Projet inchangé', livraison.Id);
        projet.NeedsGeocoding__c = false;
        insert projet;
        TriggerHandler.bypassProjetTrigger = false;

        Test.startTest();
            projet.Etape__c = 'Chiffrage';
            update projet;
        Test.stopTest();

        System.assertEquals(false, needsGeocoding(projet.Id),
            'Un champ sans rapport avec l\'adresse ne doit pas relancer le géocodage');
    }

    // Garde-fou de la suppression du repli : l'adresse de facturation ne pilote plus rien.
    @isTest
    static void testUpdate_billingAddressChange_doesNotFlag() {
        TriggerHandler.bypassProjetTrigger = true;
        Projet__c projet = newProjet('Projet facturation seule', null);
        projet.NeedsGeocoding__c = false;   // neutralise la valeur par defaut du champ
        insert projet;
        TriggerHandler.bypassProjetTrigger = false;

        Test.startTest();
            projet.Adresse_Facturation__City__s       = 'Lyon';
            projet.Adresse_Facturation__Street__s     = '456 Rue Test';
            projet.Adresse_Facturation__PostalCode__s = '69001';
            update projet;
        Test.stopTest();

        System.assertEquals(false, needsGeocoding(projet.Id),
            'Un changement d\'adresse de facturation ne doit plus déclencher de géocodage');
    }

    // ─── Limite des appels @future (régression du dump de production) ─────────

    // Volontairement supérieur à la limite de 50 appels @future par transaction.
    private static final Integer OVER_FUTURE_LIMIT = 55;

    /**
     * Reproduit le dump remonté par les utilisateurs : le flow planifié
     * FL_ScheduleProxyToProjetSales insère les Projet__c un par un (variable
     * unitaire VarNewProjet) et exécute ses interviews par lots de 200 dans UNE
     * SEULE transaction. Trigger.new.size() == 1 était donc vrai 200 fois de
     * suite ; au 51e insert la transaction levait
     * System.LimitException: Too many future calls, remontée à l'utilisateur en
     * CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: Too many retries of batch save.
     */
    @isTest
    static void testRepeatedSingleInserts_neverEnqueueFutures() {
        Account livraison = livraisonAccount('Livraison Serie Insert', 'Lausanne');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            for (Integer i = 0; i < OVER_FUTURE_LIMIT; i++) {
                insert newProjet('Projet Serie Insert ' + i, livraison.Id);
            }
            Integer futureCalls = Limits.getFutureCalls();
        Test.stopTest();

        System.assertEquals(0, futureCalls,
            'Aucun @future ne doit partir, quel que soit le nombre d\'inserts unitaires');
        System.assertEquals(OVER_FUTURE_LIMIT,
            [SELECT COUNT() FROM Projet__c WHERE Name LIKE 'Projet Serie Insert%'],
            'Les ' + OVER_FUTURE_LIMIT + ' projets doivent être créés sans échec de sauvegarde');
        System.assertEquals(OVER_FUTURE_LIMIT,
            [SELECT COUNT() FROM Projet__c
             WHERE Name LIKE 'Projet Serie Insert%' AND NeedsGeocoding__c = true],
            'Tous doivent rester marqués pour le batch de géocodage');
    }

    // ─── Bypass ───────────────────────────────────────────────────────────────

    // Le trigger n'ecoute plus la creation : le seul endroit ou le bypass a
    // encore quelque chose a court-circuiter est le BEFORE_UPDATE, qui remet
    // NeedsGeocoding__c a true quand le compte de livraison change.
    @isTest
    static void testBypass_skipsAllLogic() {
        Account livraison    = livraisonAccount('Livraison Bypass', 'Lausanne');
        Account livraisonBis = livraisonAccount('Livraison Bypass Bis', 'Genève');

        TriggerHandler.bypassProjetTrigger = true;
        Projet__c projet = newProjet('Projet bypassé', livraison.Id);
        projet.NeedsGeocoding__c = false;
        insert projet;

        Test.startTest();
            TriggerHandler.setBypassProjetTrigger();   // point d entree @InvocableMethod
            projet.Adresse_de_Livraison__c = livraisonBis.Id;
            update projet;
            Integer futureCalls = Limits.getFutureCalls();
        Test.stopTest();
        TriggerHandler.bypassProjetTrigger = false;

        System.assertEquals(false, needsGeocoding(projet.Id),
            'Avec le bypass, le BEFORE_UPDATE ne doit pas repositionner le flag a true');
        System.assertEquals(0, futureCalls,
            'Avec le bypass, aucun @future ne doit partir');
    }
}