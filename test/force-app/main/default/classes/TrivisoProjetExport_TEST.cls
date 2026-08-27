@isTest
private class TrivisoProjetExport_TEST {
    
    @isTest
    static void testHandleExport_SingleRecord() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody, 'Response body should not be null');
        
        TrivisoProjetExport.ExportResponse exportResponse = (TrivisoProjetExport.ExportResponse)JSON.deserialize(responseBody, TrivisoProjetExport.ExportResponse.class);
        System.assertEquals(1, exportResponse.successCount, 'Should have 1 successful insert');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
        System.assertEquals(0, exportResponse.errors.size(), 'Should have no error messages');
        
        // Verify record was inserted
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Numero_Projet__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = :csvRecord.SAIS_COM_ID
        ];
        System.assertEquals(1, insertedProjets.size(), 'Should have 1 record in database');
        System.assertEquals(csvRecord.SAIS_COM_Identification, insertedProjets[0].Numero_Projet__c, 'Numero_Projet should match');
    }
    
    @isTest
    static void testHandleExport_MultipleRecords() {
        // Arrange
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = TrivisoDataFactory.createProjetCsvRecords(3);
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoProjetExport.ExportResponse exportResponse = (TrivisoProjetExport.ExportResponse)JSON.deserialize(responseBody, TrivisoProjetExport.ExportResponse.class);
        System.assertEquals(3, exportResponse.successCount, 'Should have 3 successful inserts');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
        
        // Verify records were inserted
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c IN :new List<String>{ csvRecords[0].SAIS_COM_ID, csvRecords[1].SAIS_COM_ID, csvRecords[2].SAIS_COM_ID }
        ];
        System.assertEquals(3, insertedProjets.size(), 'Should have 3 records in database');
    }
    
    @isTest
    static void testHandleExport_EmptyList() {
        // Arrange
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>();
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoProjetExport.ExportResponse exportResponse = (TrivisoProjetExport.ExportResponse)JSON.deserialize(responseBody, TrivisoProjetExport.ExportResponse.class);
        System.assertEquals(0, exportResponse.successCount, 'Should have 0 successful inserts');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
    }
    
    @isTest
    static void testHandleExport_WithNullValues() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord(
            new Map<String, Object>{
                'SAIS_COM_Date_Modif' => null,
                'SAIS_COM_SOM_Prix_revient_sans_provision' => null,
                'SAIS_COM_SOM_Offert' => null
            }
        );
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoProjetExport.ExportResponse exportResponse = (TrivisoProjetExport.ExportResponse)JSON.deserialize(responseBody, TrivisoProjetExport.ExportResponse.class);
        System.assertEquals(1, exportResponse.successCount, 'Should have 1 successful insert');
        
        // Verify record was inserted with null values handled correctly
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Date_Derniere_Modification__c, Montant_Net_Sans_Provision__c, Montant_Offert__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = :csvRecord.SAIS_COM_ID
        ];
        System.assertEquals(1, insertedProjets.size(), 'Should have 1 record in database');
        System.assertEquals(null, insertedProjets[0].Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be null');
        System.assertEquals(null, insertedProjets[0].Montant_Net_Sans_Provision__c, 'Montant_Net_Sans_Provision__c should be null');
        System.assertEquals(null, insertedProjets[0].Montant_Offert__c, 'Montant_Offert__c should be null');
    }
    
    @isTest
    static void testHandleExport_InvalidJson() {
        // Arrange
        String invalidJson = '{"invalid": "json"';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(500, res.statusCode, 'Status code should be 500 for invalid JSON');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'), 'Response should contain error');
        System.assert(responseBody.contains('message'), 'Response should contain message');
    }
    
    @isTest
    static void testHandleExport_InvalidJsonStructure() {
        // Arrange
        String invalidJson = '{"notAnArray": "value"}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(500, res.statusCode, 'Status code should be 500 for invalid JSON structure');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'), 'Response should contain error');
    }
    
    @isTest
    static void testHandleExport_EmptyRequestBody() {
        // Arrange
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(500, res.statusCode, 'Status code should be 500 for empty request body');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'), 'Response should contain error');
    }
    
    @isTest
    static void testHandleExport_VerifyMapping() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        csvRecord.SAIS_COM_ID = 'TEST_MAPPING_ID';
        csvRecord.SAIS_COM_Identification = 'TEST_NUM';
        csvRecord.SAIS_COM_Description = 'Test Projet';
        csvRecord.SAIS_COM_No_Comm_client = 'REF_TEST';
        csvRecord.SAIS_COM_Genre_projet = 'Test Genre';
        
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        // Verify all fields were mapped correctly
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Numero_Projet__c, Nom_Projet__c, Reference_Client__c, 
                   Genre_Projet__c, Statut__c, Source__c, Date_Reception__c
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = 'TEST_MAPPING_ID'
        ];
        System.assertEquals(1, insertedProjets.size(), 'Should have 1 record in database');
        System.assertEquals('TEST_MAPPING_ID', insertedProjets[0].ID_Projet_Triviso__c, 'ID_Projet_Triviso__c should match');
        System.assertEquals('TEST_NUM', insertedProjets[0].Numero_Projet__c, 'Numero_Projet__c should match');
        System.assertEquals('Test Projet', insertedProjets[0].Nom_Projet__c, 'Nom_Projet__c should match');
        System.assertEquals('REF_TEST', insertedProjets[0].Reference_Client__c, 'Reference_Client__c should match');
        System.assertEquals('Test Genre', insertedProjets[0].Genre_Projet__c, 'Genre_Projet__c should match');
        System.assertEquals('Reçu', insertedProjets[0].Statut__c, 'Statut__c should be Reçu');
        System.assertEquals('Triviso', insertedProjets[0].Source__c, 'Source__c should be Triviso');
        System.assertNotEquals(null, insertedProjets[0].Date_Reception__c, 'Date_Reception__c should be set');
    }
    
    @isTest
    static void testHandleExport_WithDecimalParsing() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        csvRecord.SAIS_COM_ID = 'TEST_DECIMAL';
        csvRecord.SAIS_COM_SOM_Prix_revient_sans_provision = '150000.50';
        csvRecord.SAIS_COM_SOM_Prix_revient = '160000.75';
        csvRecord.SAIS_COM_SOM_Offert = '155000.25';
        
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        // Verify decimal values were parsed correctly
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Montant_Net_Sans_Provision__c, Montant_Net_Avec_Provision__c, Montant_Offert__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = 'TEST_DECIMAL'
        ];
        System.assertEquals(1, insertedProjets.size(), 'Should have 1 record in database');
        System.assertEquals(150000.50, insertedProjets[0].Montant_Net_Sans_Provision__c, 'Montant_Net_Sans_Provision__c should match');
        System.assertEquals(160000.75, insertedProjets[0].Montant_Net_Avec_Provision__c, 'Montant_Net_Avec_Provision__c should match');
        System.assertEquals(155000.25, insertedProjets[0].Montant_Offert__c, 'Montant_Offert__c should match');
    }
    
    @isTest
    static void testHandleExport_WithDateParsing() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        csvRecord.SAIS_COM_ID = 'TEST_DATE';
        csvRecord.SAIS_COM_Date_ouvert = '15.03.2024';
        csvRecord.SAIS_COM_Date_Modif = '20.06.2024';
        
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        // Verify dates were parsed correctly
        List<Proxy_Projet__c> insertedProjets = [
            SELECT Id, ID_Projet_Triviso__c, Date_Ouverture_Projet__c, Date_Derniere_Modification__c 
            FROM Proxy_Projet__c 
            WHERE ID_Projet_Triviso__c = 'TEST_DATE'
        ];
        System.assertEquals(1, insertedProjets.size(), 'Should have 1 record in database');
        System.assertNotEquals(null, insertedProjets[0].Date_Ouverture_Projet__c, 'Date_Ouverture_Projet__c should be parsed');
        System.assertEquals(2024, insertedProjets[0].Date_Ouverture_Projet__c.year(), 'Year should be 2024');
        System.assertEquals(3, insertedProjets[0].Date_Ouverture_Projet__c.month(), 'Month should be 3');
        System.assertEquals(15, insertedProjets[0].Date_Ouverture_Projet__c.day(), 'Day should be 15');
        
        System.assertNotEquals(null, insertedProjets[0].Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be parsed');
        System.assertEquals(2024, insertedProjets[0].Date_Derniere_Modification__c.year(), 'Year should be 2024');
        System.assertEquals(6, insertedProjets[0].Date_Derniere_Modification__c.month(), 'Month should be 6');
        System.assertEquals(20, insertedProjets[0].Date_Derniere_Modification__c.day(), 'Day should be 20');
    }
    
    @isTest
    static void testHandleExport_WithPartialErrors() {
        // Arrange - Create records where one might fail (e.g., missing required field if any)
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = TrivisoDataFactory.createProjetCsvRecords(2);
        // Both records should be valid, but we test the error handling structure
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoProjetExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoProjetExport.ExportResponse exportResponse = (TrivisoProjetExport.ExportResponse)JSON.deserialize(responseBody, TrivisoProjetExport.ExportResponse.class);
        // Both should succeed in this case, but we verify the response structure
        System.assertNotEquals(null, exportResponse.successCount, 'successCount should not be null');
        System.assertNotEquals(null, exportResponse.errorCount, 'errorCount should not be null');
        System.assertNotEquals(null, exportResponse.errors, 'errors should not be null');
    }
}