@isTest
public class ProjectService_TEST {

    // Test setup method that runs once for all tests
    @testSetup
    static void setUpTestData() {
        // Initialize test data using TestDataFactory
        TestDataFactory.createTestData();

        // Additional data for geocoding-related tests.
        // Le géocodage part uniquement du compte rattaché en adresse de livraison :
        // acc = compte "client" du projet (Nom_du_compte__c), jamais géocodé ;
        // accLivraison = compte porteur de l'adresse de livraison, seule source des coordonnées.
        Account acc = new Account(
            Name = 'Geocoding_Setup_Account',
            Adresse_compte__city__s       = 'Paris',
            Adresse_compte__street__s     = '10 Rue de Rivoli',
            Adresse_compte__postalCode__s = '75001'
        );
        Account accLivraison = new Account(
            Name = 'Geocoding_Setup_Livraison',
            Adresse_compte__city__s        = 'Lausanne',
            Adresse_compte__street__s      = '5 Avenue de la Gare',
            Adresse_compte__postalCode__s  = '1003',
            Adresse_compte__CountryCode__s = 'CH'
        );
        Account accLivraisonIncomplete = new Account(
            Name = 'Geocoding_Setup_Livraison_Incomplete',
            Adresse_compte__city__s       = 'Genève',
            Adresse_compte__postalCode__s = '1201'
            // rue absente -> adresse invalide
        );
        insert new List<Account>{ acc, accLivraison, accLivraisonIncomplete };

        TriggerHandler.bypassProjetTrigger = true;
        insert new List<Projet__c>{
            new Projet__c(
                Name = 'Projet Livraison Valid',
                Nom_du_compte__c = acc.Id,
                Adresse_de_Livraison__c = accLivraison.Id,
                Etape__c = 'Qualification',
                Etat__c  = 'Ouvert'
            ),
            // Adresse de facturation ET compte client valides, mais aucune adresse de
            // livraison : doit rester non géocodable (preuve de l'absence de repli).
            new Projet__c(
                Name = 'Projet Sans Livraison',
                Nom_du_compte__c = acc.Id,
                Etape__c = 'Qualification',
                Etat__c  = 'Ouvert',
                Adresse_Facturation__City__s        = 'Lyon',
                Adresse_Facturation__Street__s      = '456 Rue Test',
                Adresse_Facturation__PostalCode__s  = '69001',
                Adresse_Facturation__CountryCode__s = 'FR'
            ),
            new Projet__c(
                Name = 'Projet Livraison Incomplete',
                Adresse_de_Livraison__c = accLivraisonIncomplete.Id,
                Etape__c = 'Qualification',
                Etat__c  = 'Ouvert'
            ),
            new Projet__c(
                Name = 'Projet NeedsGeocoding',
                Nom_du_compte__c = acc.Id,
                Adresse_de_Livraison__c = accLivraison.Id,
                Etape__c = 'Qualification',
                Etat__c  = 'Ouvert',
                NeedsGeocoding__c = true
            )
        };

        // NeedsGeocoding__c a desormais `true` comme valeur par defaut (le flow
        // JobScheduleProjet bypasse le trigger et ne poserait jamais le flag).
        // Les fixtures qui doivent representer un projet DEJA traite doivent donc
        // le remettre a false explicitement, sinon 'Projet NeedsGeocoding' n'est
        // plus le seul enregistrement marque et les assertions de comptage sautent.
        // Le balayage couvre aussi les projets crees par TestDataFactory.
        List<Projet__c> dejaTraites = [
            SELECT Id FROM Projet__c WHERE Name != 'Projet NeedsGeocoding'
        ];
        for (Projet__c p : dejaTraites) {
            p.NeedsGeocoding__c = false;
        }
        update dejaTraites;

        TriggerHandler.bypassProjetTrigger = false;
    }

    // Test getProjetsWithAccount - Success case
    @isTest
    static void testGetProjetsWithAccount_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        Projet__c testProjet = TestDataFactory.createTestProjet('Test Project', testAccount.Id);

        // Act
        Test.startTest();
        String result = ProjetService.getProjetsWithAccount();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        List<Projet__c> projets = (List<Projet__c>) JSON.deserialize(result, List<Projet__c>.class);
        System.assertEquals(1, projets.size(), 'Should return 1 projet');
        System.assertEquals(testProjet.Id, projets[0].Id, 'Should return the correct projet');
    }

    // Test getProjetsWithAccount - No projects case
    @isTest
    static void testGetProjetsWithAccount_NoProjects() {
        // Act
        Test.startTest();
        String result = ProjetService.getProjetsWithAccount();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        List<Projet__c> projets = (List<Projet__c>) JSON.deserialize(result, List<Projet__c>.class);
        System.assertEquals(0, projets.size(), 'Should return 0 projets');
    }

    // Test getProjet - Success case
    @isTest
    static void testGetProjet_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        Projet__c testProjet = TestDataFactory.createTestProjet('Test Project', testAccount.Id);

        // Act
        Test.startTest();
        String result = ProjetService.getProjet(testProjet.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        List<Projet__c> projets = (List<Projet__c>) JSON.deserialize(result, List<Projet__c>.class);
        System.assertEquals(1, projets.size(), 'Should return 1 projet');
        System.assertEquals(testProjet.Id, projets[0].Id, 'Should return the correct projet');
    }

    // Test getProjet - Invalid ID case
    @isTest
    static void testGetProjet_InvalidId() {
        // Arrange
        String invalidId = 'a0X000000000000';
        ProjetService.ProjetException exceptionThrown;
        
        // Act & Assert
        Test.startTest();
        try {
            String result = ProjetService.getProjet(invalidId);
        } catch (ProjetService.ProjetException e) {
            exceptionThrown = e;
        }
        Test.stopTest();

        // Assert
        System.assert(exceptionThrown != null, 'An exception should have been thrown');
    }

    // Test fetchProjetCoords - Success case with valid address
    // @isTest
    // static void testFetchProjetCoords_Success() {
    //     // Arrange
    //     Account testAccount = TestDataFactory.createTestAccount('Test Account');
    //     Projet__c testProjet = TestDataFactory.createTestProjet('Test Project', testAccount.Id);
        
    //     // Set up mock
    //     Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
        
    //     // Act
    //     Test.startTest();
    //     ProjetService.fetchProjetCoords(testProjet.Id);
    //     Test.stopTest();
        
    //     // Assert
    //     Projet__c updatedProjet = [SELECT Id, latitude__c, longitude__c FROM Projet__c WHERE Id = :testProjet.Id];
    //     System.assertEquals('48.866667', updatedProjet.latitude__c, 'Latitude should be updated');
    //     System.assertEquals('2.333333', updatedProjet.longitude__c, 'Longitude should be updated');
    // }

    // Test fetchProjetCoords - Projet not found case
    @isTest
    static void testFetchProjetCoords_ProjetNotFound() {
        // Arrange
        String invalidId = 'a0X000000000000';
        ProjetService.ProjetException exceptionThrown;
        
        // Act & Assert
        Test.startTest();
        try {
            ProjetService.fetchProjetCoords(invalidId);
        } catch (ProjetService.ProjetException e) {
            exceptionThrown = e;
        }
        Test.stopTest();

        // Assert
        System.assert(exceptionThrown != null, 'An exception should have been thrown');
        System.assertEquals('No projet found', exceptionThrown.getMessage(), 'Should throw correct error message');
    }

    // Test fetchProjetCoords - Projet without address case
    @isTest
    static void testFetchProjetCoords_ProjetWithoutAddress() {
        // Arrange
        TriggerHandler.bypassProjetTrigger = true; // Disable trigger to avoid interference
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        Projet__c testProjet = TestDataFactory.createTestProjetWithoutAddress('Test Project', testAccount.Id);
        ProjetService.ProjetException exceptionThrown;
        
        // Set up mock (required even though we expect exception before callout)
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
        
        // Act & Assert
        Test.startTest();
        try {
            ProjetService.fetchProjetCoords(testProjet.Id);
        } catch (ProjetService.ProjetException e) {
            exceptionThrown = e;
        }
        Test.stopTest();

        // Assert
        System.assert(exceptionThrown != null, 'An exception should have been thrown');
        System.assert(exceptionThrown.getMessage().contains('No address found'), 'Should throw correct error message');
    }

    // Test fetchProjetCoords - HTTP error case
    @isTest
    static void testFetchProjetCoords_HttpError() {
        // Arrange — bypass trigger so the @future geocoding call isn't queued before the mock is set
        TriggerHandler.bypassProjetTrigger = true;
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        Projet__c testProjet = TestDataFactory.createTestProjet('Test Project', testAccount.Id);
        TriggerHandler.bypassProjetTrigger = false;
        ProjetService.ProjetException exceptionThrown;

        // Set up mock that returns error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        // Act & Assert
        Test.startTest();
        try {
            ProjetService.fetchProjetCoords(testProjet.Id);
        } catch (ProjetService.ProjetException e) {
            exceptionThrown = e;
        }
        Test.stopTest();

        // Assert
        System.assert(exceptionThrown != null, 'An exception should have been thrown');
        System.assert(exceptionThrown.getMessage().contains('HTTP error'), 'Should throw correct error message');
    }

    // Test fetchProjetCoords - No coordinates found case
    @isTest
    static void testFetchProjetCoords_NoCoordinatesFound() {
        // Arrange
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        Projet__c testProjet = TestDataFactory.createTestProjetWithInvalidAddress('Test Project', testAccount.Id);
        ProjetService.ProjetException exceptionThrown;
        
        // Set up mock
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
        
        // Act & Assert
        Test.startTest();
        try {
            ProjetService.fetchProjetCoords(testProjet.Id);
        } catch (ProjetService.ProjetException e) {
            exceptionThrown = e;
        }
        Test.stopTest();

        // Assert
        System.assert(exceptionThrown != null, 'An exception should have been thrown');
        System.assert(exceptionThrown.getMessage().contains('No coordinates found'), 'Should throw correct error message');
    }

    // Test buildOpenStreetMapRequest - Valid parameters
    @isTest
    static void testBuildOpenStreetMapRequest_ValidParameters() {
        // Act
        Test.startTest();
        HttpRequest req = ProjetService.buildOpenStreetMapRequest('&city=Paris&country=France&street=Test Street&postalCode=75001&state=Ile-de-France');
        Test.stopTest();
        
        // Assert
        System.assertEquals('GET', req.getMethod(), 'Method should be GET');
        System.assert(req.getEndpoint().contains('nominatim.openstreetmap.org'), 'Endpoint should contain OpenStreetMap URL');
        System.assert(req.getEndpoint().contains('city=Paris'), 'Endpoint should contain city parameter');
        System.assert(req.getEndpoint().contains('country=France'), 'Endpoint should contain country parameter');
    }

    // Test getUrlParams - All parameters provided
    @isTest
    static void testGetUrlParams_AllParameters() {
        // Act
        Test.startTest();
        String result = ProjetService.getUrlParams('Paris', 'France', 'Test Street', '75001', 'Ile-de-France');
        Test.stopTest();
        
        // Assert
        System.assert(result.contains('city=Paris'), 'Should contain city parameter');
        System.assert(result.contains('country=France'), 'Should contain country parameter');
        System.assert(result.contains('street=Test+Street'), 'Should contain street parameter');
        System.assert(result.contains('postalcode=75001'), 'Should contain postalcode parameter (lowercase, as Nominatim expects)');
        System.assert(result.contains('state=Ile-de-France'), 'Should contain state parameter');
    }

    // Test getUrlParams - un code pays ISO doit passer par countrycodes, pas country
    @isTest
    static void testGetUrlParams_IsoCountryCodeUsesCountrycodes() {
        // Act
        Test.startTest();
        String result = ProjetService.getUrlParams('Lausanne', 'CH', '5 Avenue de la Gare', '1003', null);
        Test.stopTest();

        // Assert
        System.assert(result.contains('countrycodes=ch'), 'An ISO code should be sent lowercased as countrycodes');
        System.assert(!result.contains('&country='), 'An ISO code should not be sent as the country parameter');
    }

    // Test getUrlParams - Some parameters null
    @isTest
    static void testGetUrlParams_SomeParametersNull() {
        // Act
        Test.startTest();
        String result = ProjetService.getUrlParams('Paris', null, 'Test Street', null, 'Ile-de-France');
        Test.stopTest();
        
        // Assert
        System.assert(result.contains('city=Paris'), 'Should contain city parameter');
        System.assert(!result.contains('country='), 'Should not contain country parameter');
        System.assert(result.contains('street=Test+Street'), 'Should contain street parameter');
        System.assert(!result.contains('postalcode='), 'Should not contain postalcode parameter');
        System.assert(result.contains('state=Ile-de-France'), 'Should contain state parameter');
    }

    // Test getProjetWithoutTrivisoId - Success case with projects without Numero_projet__c
    @isTest
    static void testGetProjetWithoutTrivisoId_Success() {
        // Arrange
        TriggerHandler.bypassProjetTrigger = true; // Disable trigger to avoid interference
        
        // Clean up projects from testSetup that might have Numero_projet__c = null
        List<Projet__c> existingProjets = [SELECT Id FROM Projet__c WHERE Numero_projet__c = null];
        if (!existingProjets.isEmpty()) {
            for (Projet__c p : existingProjets) {
                p.Numero_projet__c = 'SETUP_PROJET';
            }
            update existingProjets;
        }
        
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        
        // Create projects without Numero_projet__c (should be returned)
        Projet__c projet1 = TestDataFactory.createTestProjet('Projet 1', testAccount.Id);
        projet1.Numero_projet__c = null;
        update projet1;
        
        Projet__c projet2 = TestDataFactory.createTestProjet('Projet 2', testAccount.Id);
        projet2.Numero_projet__c = null;
        update projet2;
        
        // Create project with Numero_projet__c (should NOT be returned)
        Projet__c projet3 = TestDataFactory.createTestProjet('Projet 3', testAccount.Id);
        projet3.Numero_projet__c = 'TRIVISO_123';
        update projet3;
        
        // Act
        Test.startTest();
        List<Projet__c> result = ProjetService.getProjetWithoutTrivisoId();
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, result.size(), 'Should return 2 projets without Numero_projet__c');
        Set<Id> resultIds = new Set<Id>();
        for (Projet__c p : result) {
            resultIds.add(p.Id);
            System.assertEquals(null, p.Numero_projet__c, 'Numero_projet__c should be null');
        }
        System.assert(resultIds.contains(projet1.Id), 'Should contain projet1');
        System.assert(resultIds.contains(projet2.Id), 'Should contain projet2');
        System.assert(!resultIds.contains(projet3.Id), 'Should NOT contain projet3');
    }

    // Test getProjetWithoutTrivisoId - No projects case
    @isTest
    static void testGetProjetWithoutTrivisoId_NoProjects() {
        // Arrange - Clean up projects from testSetup and create projects but all have Numero_projet__c
        TriggerHandler.bypassProjetTrigger = true;
        
        // Clean up projects from testSetup that might have Numero_projet__c = null
        List<Projet__c> existingProjets = [SELECT Id FROM Projet__c WHERE Numero_projet__c = null];
        if (!existingProjets.isEmpty()) {
            for (Projet__c p : existingProjets) {
                p.Numero_projet__c = 'SETUP_PROJET';
            }
            update existingProjets;
        }
        
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        
        Projet__c projet1 = TestDataFactory.createTestProjet('Projet 1', testAccount.Id);
        projet1.Numero_projet__c = 'TRIVISO_123';
        update projet1;
        
        // Final cleanup: ensure no projects have Numero_projet__c = null before testing
        List<Projet__c> finalCleanup = [SELECT Id FROM Projet__c WHERE Numero_projet__c = null];
        if (!finalCleanup.isEmpty()) {
            for (Projet__c p : finalCleanup) {
                p.Numero_projet__c = 'FINAL_CLEANUP';
            }
            update finalCleanup;
        }
        
        // Act
        Test.startTest();
        List<Projet__c> result = ProjetService.getProjetWithoutTrivisoId();
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Should return 0 projets when all have Numero_projet__c');
    }

    // Test getProjetWithoutTrivisoId - Empty result when no projects exist
    @isTest
    static void testGetProjetWithoutTrivisoId_EmptyDatabase() {
        // Arrange - Clean up projects from testSetup that might have Numero_projet__c = null
        TriggerHandler.bypassProjetTrigger = true;
        List<Projet__c> existingProjets = [SELECT Id FROM Projet__c WHERE Numero_projet__c = null];
        if (!existingProjets.isEmpty()) {
            for (Projet__c p : existingProjets) {
                p.Numero_projet__c = 'SETUP_PROJET';
            }
            update existingProjets;
        }
        
        // Act
        Test.startTest();
        List<Projet__c> result = ProjetService.getProjetWithoutTrivisoId();
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Should return empty list when no projects have Numero_projet__c = null');
    }

    // Test updateTrivisoExportDate - Success case
    @isTest
    static void testUpdateTrivisoExportDate_Success() {
        // Arrange
        TriggerHandler.bypassProjetTrigger = true;
        Account testAccount = TestDataFactory.createTestAccount('Test Account');
        
        List<Projet__c> projets = new List<Projet__c>();
        for (Integer i = 0; i < 3; i++) {
            Projet__c projet = TestDataFactory.createTestProjet('Projet ' + i, testAccount.Id);
            projet.Triviso_export_date__c = null;
            projets.add(projet);
        }
        update projets;
        
        Date expectedDate = Date.today();
        
        // Act
        Test.startTest();
        ProjetService.updateTrivisoExportDate(projets);
        Test.stopTest();
        
        // Assert
        List<Projet__c> updatedProjets = [
            SELECT Id, Triviso_export_date__c 
            FROM Projet__c 
            WHERE Id IN :projets
        ];
        
        System.assertEquals(3, updatedProjets.size(), 'Should have 3 projets');
        for (Projet__c projet : updatedProjets) {
            System.assertEquals(expectedDate, projet.Triviso_export_date__c, 'Triviso_export_date__c should be set to today');
        }
    }

    // Test updateTrivisoExportDate - Empty list case
    @isTest
    static void testUpdateTrivisoExportDate_EmptyList() {
        // Arrange
        List<Projet__c> emptyList = new List<Projet__c>();
        
        // Act & Assert - Should not throw exception
        Test.startTest();
        ProjetService.updateTrivisoExportDate(emptyList);
        Test.stopTest();
        
        // No assertion needed - method should return without error
    }

    // Test updateTrivisoExportDate - Null list case
    @isTest
    static void testUpdateTrivisoExportDate_NullList() {
        // Act & Assert - Should not throw exception
        Test.startTest();
        ProjetService.updateTrivisoExportDate(null);
        Test.stopTest();
        
        // No assertion needed - method should return without error
    }

    // Mock for HTTP error response (500) — used by legacy fetchProjetCoords tests
    public class MockHttpErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('[]');
            return res;
        }
    }

    // Mock for rate-limit response (429) — used by geocodeFromAddress tests
    public class MockHttpError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(429);
            res.setBody('Too Many Requests');
            return res;
        }
    }

    // ─── hasValidAddress(String, String, String) ──────────────────────────────

    @isTest
    static void testHasValidAddress_strings_allFilled() {
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress('Paris', '10 Rue de Rivoli', '75001');
        Test.stopTest();
        System.assertEquals(true, result, 'hasValidAddress strings : should be true when all fields are filled');
    }

    @isTest
    static void testHasValidAddress_strings_cityBlank() {
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress('', '10 Rue de Rivoli', '75001');
        Test.stopTest();
        System.assertEquals(false, result, 'hasValidAddress strings : should be false when city is blank');
    }

    @isTest
    static void testHasValidAddress_strings_streetNull() {
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress('Paris', null, '75001');
        Test.stopTest();
        System.assertEquals(false, result, 'hasValidAddress strings : should be false when street is null');
    }

    @isTest
    static void testHasValidAddress_strings_postalCodeBlank() {
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress('Paris', '10 Rue de Rivoli', '   ');
        Test.stopTest();
        System.assertEquals(false, result, 'hasValidAddress strings : should be false when postalCode is whitespace');
    }

    // ─── hasValidAddress(Account) ─────────────────────────────────────────────

    @isTest
    static void testHasValidAddress_account_valid() {
        Account acc = [SELECT Id, Adresse_compte__city__s, Adresse_compte__street__s, Adresse_compte__postalCode__s
                       FROM Account WHERE Name = 'Geocoding_Setup_Account' LIMIT 1];
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress(acc);
        Test.stopTest();
        System.assertEquals(true, result, 'hasValidAddress account : should be true for a valid account address');
    }

    @isTest
    static void testHasValidAddress_account_null() {
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress((Account) null);
        Test.stopTest();
        System.assertEquals(false, result, 'hasValidAddress account : should be false when account is null');
    }

    @isTest
    static void testHasValidAddress_account_missingStreet() {
        Account acc = new Account(
            Adresse_compte__city__s       = 'Paris',
            Adresse_compte__postalCode__s = '75001'
        );
        Test.startTest();
            Boolean result = ProjetService.hasValidAddress(acc);
        Test.stopTest();
        System.assertEquals(false, result, 'hasValidAddress account : should be false when street is missing');
    }

    // ─── resolveGeocodingAddress ──────────────────────────────────────────────

    private static Projet__c queryForGeocoding(String projetName) {
        return [
            SELECT Id,
                   Adresse_de_Livraison__r.Adresse_compte__city__s,
                   Adresse_de_Livraison__r.Adresse_compte__street__s,
                   Adresse_de_Livraison__r.Adresse_compte__postalCode__s,
                   Adresse_de_Livraison__r.Adresse_compte__CountryCode__s
            FROM Projet__c WHERE Name = :projetName LIMIT 1
        ];
    }

    @isTest
    static void testResolveGeocodingAddress_livraisonValid() {
        Projet__c projet = queryForGeocoding('Projet Livraison Valid');
        Test.startTest();
            ProjetService.ResolvedAddress addr = ProjetService.resolveGeocodingAddress(projet);
        Test.stopTest();
        System.assertNotEquals(null, addr, 'resolveGeocodingAddress : should return an address when the delivery account is valid');
        System.assertEquals('livraison', addr.source, 'resolveGeocodingAddress : source should be livraison');
        System.assertEquals('Lausanne', addr.city, 'resolveGeocodingAddress : city should match the delivery account city');
        System.assertEquals('5 Avenue de la Gare', addr.street, 'resolveGeocodingAddress : street should match the delivery account street');
        System.assertEquals('CH', addr.country, 'resolveGeocodingAddress : country should come from the delivery account country code');
    }

    // Garde-fou de la suppression du repli : facturation et compte client valides,
    // mais pas d'adresse de livraison -> aucune coordonnée.
    @isTest
    static void testResolveGeocodingAddress_noFallbackOnBillingOrAccount() {
        Projet__c projet = queryForGeocoding('Projet Sans Livraison');
        Test.startTest();
            ProjetService.ResolvedAddress addr = ProjetService.resolveGeocodingAddress(projet);
        Test.stopTest();
        System.assertEquals(null, addr, 'resolveGeocodingAddress : billing address must never be used as a fallback');
    }

    @isTest
    static void testResolveGeocodingAddress_livraisonIncomplete() {
        Projet__c projet = queryForGeocoding('Projet Livraison Incomplete');
        Test.startTest();
            ProjetService.ResolvedAddress addr = ProjetService.resolveGeocodingAddress(projet);
        Test.stopTest();
        System.assertEquals(null, addr, 'resolveGeocodingAddress : should return null when the delivery address has no street');
    }

    // ─── geocodeFromAddress ───────────────────────────────────────────────────

    @isTest
    static void testGeocodeFromAddress_found() {
        Id projetId = [SELECT Id FROM Projet__c WHERE Name = 'Projet Livraison Valid' LIMIT 1].Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            Projet__c result = ProjetService.geocodeFromAddress(projetId, 'Lyon', 'FR', '456 Rue Test', '69001', null);
        Test.stopTest();
        System.assertNotEquals(null, result, 'geocodeFromAddress : should return a projet with coordinates');
        System.assertNotEquals(null, result.latitude__c,  'geocodeFromAddress : latitude should be set');
        System.assertNotEquals(null, result.longitude__c, 'geocodeFromAddress : longitude should be set');
    }

    @isTest
    static void testGeocodeFromAddress_notFound() {
        Id projetId = [SELECT Id FROM Projet__c WHERE Name = 'Projet Livraison Valid' LIMIT 1].Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            Projet__c result = ProjetService.geocodeFromAddress(projetId, 'Nowhere', null, 'bbbbbbbbbbbbb', '00000', null);
        Test.stopTest();
        System.assertEquals(null, result, 'geocodeFromAddress : should return null when OSM finds no result');
    }

    @isTest
    static void testGeocodeFromAddress_httpError() {
        Id projetId = [SELECT Id FROM Projet__c WHERE Name = 'Projet Livraison Valid' LIMIT 1].Id;
        ProjetService.ProjetException caught;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpError());
            try {
                ProjetService.geocodeFromAddress(projetId, 'Lyon', 'FR', '456 Rue Test', '69001', null);
            } catch (ProjetService.ProjetException e) {
                caught = e;
            }
        Test.stopTest();
        System.assertNotEquals(null, caught, 'geocodeFromAddress : should throw ProjetException on HTTP error');
        System.assert(caught.getMessage().contains('429'), 'geocodeFromAddress : exception message should contain the HTTP status code');
    }

    // ─── getNeedsGeocodingQueryLocator ────────────────────────────────────────

    @isTest
    static void testGetNeedsGeocodingQueryLocator() {
        Test.startTest();
            Database.QueryLocator ql = ProjetService.getNeedsGeocodingQueryLocator();
        Test.stopTest();
        System.assertNotEquals(null, ql, 'getNeedsGeocodingQueryLocator : should return a non-null QueryLocator');
        Integer count = [SELECT COUNT() FROM Projet__c WHERE NeedsGeocoding__c = true];
        System.assertEquals(1, count, 'getNeedsGeocodingQueryLocator : should target only records with NeedsGeocoding__c = true');
    }

    // ─── geocodeSingleProjetAsync ─────────────────────────────────────────────

    @isTest
    static void testGeocodeSingleProjetAsync_geocodesAndClearsFlag() {
        Id projetId = [SELECT Id FROM Projet__c WHERE Name = 'Projet NeedsGeocoding' LIMIT 1].Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            ProjetService.geocodeSingleProjetAsync(projetId);
        Test.stopTest();
        Projet__c updated = [SELECT NeedsGeocoding__c, latitude__c, longitude__c FROM Projet__c WHERE Id = :projetId];
        System.assertEquals(false, updated.NeedsGeocoding__c, 'geocodeSingleProjetAsync : NeedsGeocoding__c should be cleared after geocoding');
        System.assertNotEquals(null, updated.latitude__c,  'geocodeSingleProjetAsync : latitude should be set');
        System.assertNotEquals(null, updated.longitude__c, 'geocodeSingleProjetAsync : longitude should be set');
    }

    @isTest
    static void testGeocodeSingleProjetAsync_skipsWhenNotNeeded() {
        Id projetId = [SELECT Id FROM Projet__c WHERE Name = 'Projet Livraison Valid' LIMIT 1].Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpOpenStreetMapResponse());
            ProjetService.geocodeSingleProjetAsync(projetId);
        Test.stopTest();
        Projet__c unchanged = [SELECT latitude__c FROM Projet__c WHERE Id = :projetId];
        System.assertEquals(null, unchanged.latitude__c, 'geocodeSingleProjetAsync : should not geocode when NeedsGeocoding__c is false');
    }
}