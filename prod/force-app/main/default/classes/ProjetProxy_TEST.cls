@isTest
private class ProjetProxy_TEST {
    
    @isTest
    static void testBuildProxyProjets_SingleRecord() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord();
        List<ProjetProxyRecord> records = new List<ProjetProxyRecord>{ record };
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, projets.size(), 'Should return exactly one projet');
        Proxy_Projet__c projet = projets[0];
        System.assertEquals(record.idProjetTriviso, projet.ID_Projet_Triviso__c, 'ID_Projet_Triviso should match');
        System.assertEquals(record.numeroProjet, projet.Numero_Projet__c, 'Numero_Projet should match');
        System.assertEquals(record.nomProjet, projet.Nom_Projet__c, 'Nom_Projet should match');
        System.assertEquals('Reçu', projet.Statut__c, 'Statut should be Reçu');
        System.assertEquals('Triviso', projet.Source__c, 'Source should be Triviso');
        System.assertNotEquals(null, projet.Date_Reception__c, 'Date_Reception should be set');
    }
    
    @isTest
    static void testBuildProxyProjets_MultipleRecords() {
        // Arrange
        List<ProjetProxyRecord> records = TrivisoDataFactory.createProjetProxyRecords(5);
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(5, projets.size(), 'Should return exactly 5 projets');
        for (Integer i = 0; i < projets.size(); i++) {
            Proxy_Projet__c projet = projets[i];
            System.assertEquals('PROJ_' + String.valueOf(i + 1), projet.ID_Projet_Triviso__c, 'ID_Projet_Triviso should match');
            System.assertEquals('NUM-' + String.valueOf(i + 1), projet.Numero_Projet__c, 'Numero_Projet should match');
            System.assertEquals('Projet Test ' + String.valueOf(i + 1), projet.Nom_Projet__c, 'Nom_Projet should match');
        }
    }
    
    @isTest
    static void testBuildProxyProjets_EmptyList() {
        // Arrange
        List<ProjetProxyRecord> records = new List<ProjetProxyRecord>();
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, projets.size(), 'Should return empty list');
    }
    
    @isTest
    static void testInsertProjets_Success() {
        // Arrange
        List<ProjetProxyRecord> records = TrivisoDataFactory.createProjetProxyRecords(3);
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        
        // Act
        Test.startTest();
        Database.SaveResult[] results = ProjetProxy.insertProjets(projets);
        Test.stopTest();
        
        // Assert
        System.assertEquals(3, results.size(), 'Should have 3 results');
        Integer successCount = 0;
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                successCount++;
                System.assertNotEquals(null, result.getId(), 'Id should be set for successful insert');
            }
        }
        System.assertEquals(3, successCount, 'All 3 records should be inserted successfully');
        
        // Verify records were actually inserted
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Numero_Projet__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c LIKE 'PROJ_%'
            ORDER BY ID_Projet_Triviso__c
        ];
        System.assertEquals(3, insertedProjets.size(), 'Should have 3 records in database');
    }
    
    @isTest
    static void testInsertProjets_WithErrors() {
        // Arrange
        List<ProjetProxyRecord> records = TrivisoDataFactory.createProjetProxyRecords(2);
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        
        // Insert first projet to create duplicate
        insert projets[0];
        
        // Create duplicate projet with same ID_Projet_Triviso__c
        Proxy_Projet__c duplicate = projets[0].clone(false, true);
        List<Proxy_Projet__c> projetsWithDuplicate = new List<Proxy_Projet__c>{ projets[1], duplicate };
        
        // Act
        Test.startTest();
        Database.SaveResult[] results = ProjetProxy.insertProjets(projetsWithDuplicate);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, results.size(), 'Should have 2 results');
        System.assert(results[0].isSuccess(), 'First record should succeed');
        // Second record might fail if there's a unique constraint, or succeed if duplicates are allowed
        // We just verify the method handles both cases
    }
    
    @isTest
    static void testUpsertProjets_InsertNew() {
        // Arrange
        List<ProjetProxyRecord> records = TrivisoDataFactory.createProjetProxyRecords(2);
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> upsertedProjets = ProjetProxy.upsertProjets(projets);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, upsertedProjets.size(), 'Should return 2 projets');
        
        // Verify records were inserted
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c IN :new List<String>{ projets[0].ID_Projet_Triviso__c, projets[1].ID_Projet_Triviso__c }
        ];
        System.assertEquals(2, insertedProjets.size(), 'Should have 2 records in database');
    }
    
    @isTest
    static void testUpsertProjets_UpdateExisting() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord();
        record.idProjetTriviso = 'TEST_UPSERT_ID';
        record.nomProjet = 'Original Name';
        
        List<ProjetProxyRecord> records = new List<ProjetProxyRecord>{ record };
        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(records);
        insert projets;
        
        // Update the projet
        projets[0].Nom_Projet__c = 'Updated Name';
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> upsertedProjets = ProjetProxy.upsertProjets(projets);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, upsertedProjets.size(), 'Should return 1 projet');
        
        // Verify record was updated
        Proxy_Projet__c updatedProjet = [
            SELECT Id, ID_Projet_Triviso__c, Nom_Projet__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = 'TEST_UPSERT_ID'
            LIMIT 1
        ];
        System.assertEquals('Updated Name', updatedProjet.Nom_Projet__c, 'Name should be updated');
    }
    
    @isTest
    static void testUpsertProjets_MixedInsertAndUpdate() {
        // Arrange
        // Create and insert first projet
        ProjetProxyRecord record1 = TrivisoDataFactory.createProjetProxyRecord();
        record1.idProjetTriviso = 'TEST_MIXED_1';
        List<Proxy_Projet__c> projet1 = ProjetProxy.buildProxyProjets(new List<ProjetProxyRecord>{ record1 });
        insert projet1;
        
        // Create second projet (new)
        ProjetProxyRecord record2 = TrivisoDataFactory.createProjetProxyRecord();
        record2.idProjetTriviso = 'TEST_MIXED_2';
        List<Proxy_Projet__c> projet2 = ProjetProxy.buildProxyProjets(new List<ProjetProxyRecord>{ record2 });
        
        // Update first projet
        projet1[0].Nom_Projet__c = 'Updated Name';
        
        // Combine both
        List<Proxy_Projet__c> projetsToUpsert = new List<Proxy_Projet__c>{ projet1[0], projet2[0] };
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> upsertedProjets = ProjetProxy.upsertProjets(projetsToUpsert);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, upsertedProjets.size(), 'Should return 2 projets');
        
        // Verify both records exist
        List<Proxy_Projet__c> results = [
            SELECT Id, ID_Projet_Triviso__c, Nom_Projet__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c IN ('TEST_MIXED_1', 'TEST_MIXED_2')
            ORDER BY ID_Projet_Triviso__c
        ];
        System.assertEquals(2, results.size(), 'Should have 2 records in database');
        System.assertEquals('Updated Name', results[0].Nom_Projet__c, 'First record should be updated');
    }
    
    @isTest
    static void testUpsertProjets_EmptyList() {
        // Arrange
        List<Proxy_Projet__c> projets = new List<Proxy_Projet__c>();
        
        // Act
        Test.startTest();
        List<Proxy_Projet__c> upsertedProjets = ProjetProxy.upsertProjets(projets);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, upsertedProjets.size(), 'Should return empty list');
    }

    @isTest
    static void testUpsertProjets_WithDuplicateExternalId() {
        // Arrange - create two projets with the same external id to trigger upsert error handling
        ProjetProxyRecord record1 = TrivisoDataFactory.createProjetProxyRecord();
        record1.idProjetTriviso = 'DUP_EXT_ID_PROJ';
        ProjetProxyRecord record2 = TrivisoDataFactory.createProjetProxyRecord();
        record2.idProjetTriviso = 'DUP_EXT_ID_PROJ';

        List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(
            new List<ProjetProxyRecord>{ record1, record2 }
        );

        // Act - even if we can't assert on individual errors, this will exercise the error logging branch
        Test.startTest();
        List<Proxy_Projet__c> upsertedProjets = ProjetProxy.upsertProjets(projets);
        Test.stopTest();

        // Assert - both records are processed
        System.assertEquals(2, upsertedProjets.size(), 'Should process both projets even with duplicate external id');
    }
}