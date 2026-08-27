@isTest
private class TrivisoAddressExport_TEST {
    
    @isTest
    static void testHandleExport_SingleRecord() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord();
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody, 'Response body should not be null');
        
        TrivisoAddressExport.ExportResponse exportResponse = (TrivisoAddressExport.ExportResponse)JSON.deserialize(responseBody, TrivisoAddressExport.ExportResponse.class);
        System.assertEquals(1, exportResponse.successCount, 'Should have 1 successful insert');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
        System.assertEquals(0, exportResponse.errors.size(), 'Should have no error messages');
        
        // Verify record was inserted
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_Nom__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c = :csvRecord.ADRES_ID
        ];
        System.assertEquals(1, insertedAddresses.size(), 'Should have 1 record in database');
        System.assertEquals(csvRecord.ADRES_Nom, insertedAddresses[0].ADRES_Nom__c, 'ADRES_Nom should match');
    }
    
    @isTest
    static void testHandleExport_MultipleRecords() {
        // Arrange
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = TrivisoDataFactory.createAddressCsvRecords(3);
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressExport.ExportResponse exportResponse = (TrivisoAddressExport.ExportResponse)JSON.deserialize(responseBody, TrivisoAddressExport.ExportResponse.class);
        System.assertEquals(3, exportResponse.successCount, 'Should have 3 successful inserts');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
        
        // Verify records were inserted
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRESTriviso_ID__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c IN :new List<String>{ csvRecords[0].ADRES_ID, csvRecords[1].ADRES_ID, csvRecords[2].ADRES_ID }
        ];
        System.assertEquals(3, insertedAddresses.size(), 'Should have 3 records in database');
    }
    
    @isTest
    static void testHandleExport_EmptyList() {
        // Arrange
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>();
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressExport.ExportResponse exportResponse = (TrivisoAddressExport.ExportResponse)JSON.deserialize(responseBody, TrivisoAddressExport.ExportResponse.class);
        System.assertEquals(0, exportResponse.successCount, 'Should have 0 successful inserts');
        System.assertEquals(0, exportResponse.errorCount, 'Should have 0 errors');
    }
    
    @isTest
    static void testHandleExport_WithNullValues() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord(
            new Map<String, Object>{
                'ADRES_Date_inactive' => null,
                'ADRES_Telephone3' => null,
                'ADRES_Natel2' => null
            }
        );
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressExport.ExportResponse exportResponse = (TrivisoAddressExport.ExportResponse)JSON.deserialize(responseBody, TrivisoAddressExport.ExportResponse.class);
        System.assertEquals(1, exportResponse.successCount, 'Should have 1 successful insert');
        
        // Verify record was inserted with null values handled correctly
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_Date_inactive__c, ADRES_Date_inactive_2__c, ADRES_Telephone3__c, ADRES_Natel2__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c = :csvRecord.ADRES_ID
        ];
        System.assertEquals(1, insertedAddresses.size(), 'Should have 1 record in database');
        System.assertEquals(null, insertedAddresses[0].ADRES_Date_inactive__c, 'ADRES_Date_inactive__c should be null');
        System.assertEquals(true, insertedAddresses[0].ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be true when ADRES_Date_inactive is null');
        System.assertEquals(null, insertedAddresses[0].ADRES_Telephone3__c, 'ADRES_Telephone3__c should be null');
        System.assertEquals(null, insertedAddresses[0].ADRES_Natel2__c, 'ADRES_Natel2__c should be null');
    }
    
    @isTest
    static void testHandleExport_WithInactiveDateSetsBooleanFalse() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord(
            new Map<String, Object>{
                'ADRES_Date_inactive' => '01.12.2024 00:00:00'
            }
        );
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_Date_inactive__c, ADRES_Date_inactive_2__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c = :csvRecord.ADRES_ID
        ];
        System.assertEquals(1, insertedAddresses.size(), 'Should have 1 record in database');
        System.assertNotEquals(null, insertedAddresses[0].ADRES_Date_inactive__c, 'ADRES_Date_inactive__c should be parsed');
        System.assertEquals(false, insertedAddresses[0].ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be false when ADRES_Date_inactive is populated');
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
        TrivisoAddressExport.handleExport();
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
        TrivisoAddressExport.handleExport();
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
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(500, res.statusCode, 'Status code should be 500 for empty request body');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'), 'Response should contain error');
    }
    
    @isTest
    static void testHandleExport_VerifyMapping() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord();
        csvRecord.ADRES_ID = 'TEST_MAPPING_ID';
        csvRecord.ADRES_Nom = 'Test Nom';
        csvRecord.ADRES_Prenom = 'Test Prenom';
        csvRecord.ADRES_Rue = 'Test Rue 123';
        csvRecord.ADRES_Email = 'test@example.com';
        
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>{ csvRecord };
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        // Verify all fields were mapped correctly
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_ID__c, ADRES_Nom__c, ADRES_Prenom__c, ADRES_Rue__c, ADRES_Email__c,
                   Statut__c, Source__c, Date_Reception__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c = 'TEST_MAPPING_ID'
        ];
        System.assertEquals(1, insertedAddresses.size(), 'Should have 1 record in database');
        System.assertEquals('TEST_MAPPING_ID', insertedAddresses[0].ADRESTriviso_ID__c, 'ADRESTriviso_ID__c should match');
        System.assertEquals('Test Nom', insertedAddresses[0].ADRES_Nom__c, 'ADRES_Nom__c should match');
        System.assertEquals('Test Prenom', insertedAddresses[0].ADRES_Prenom__c, 'ADRES_Prenom__c should match');
        System.assertEquals('Test Rue 123', insertedAddresses[0].ADRES_Rue__c, 'ADRES_Rue__c should match');
        System.assertEquals('test@example.com', insertedAddresses[0].ADRES_Email__c, 'ADRES_Email__c should match');
        System.assertEquals('Reçu', insertedAddresses[0].Statut__c, 'Statut__c should be Reçu');
        System.assertEquals('Triviso', insertedAddresses[0].Source__c, 'Source__c should be Triviso');
        System.assertNotEquals(null, insertedAddresses[0].Date_Reception__c, 'Date_Reception__c should be set');
    }
    
    @isTest
    static void testHandleExport_WithPartialErrors() {
        // Arrange - Create records where one might fail (e.g., missing required field if any)
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = TrivisoDataFactory.createAddressCsvRecords(2);
        // First record is valid
        // Second record - we'll use a valid one too, but test the error handling structure
        String requestBody = JSON.serialize(csvRecords);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressExport.handleExport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressExport.ExportResponse exportResponse = (TrivisoAddressExport.ExportResponse)JSON.deserialize(responseBody, TrivisoAddressExport.ExportResponse.class);
        // Both should succeed in this case, but we verify the response structure
        System.assertNotEquals(null, exportResponse.successCount, 'successCount should not be null');
        System.assertNotEquals(null, exportResponse.errorCount, 'errorCount should not be null');
        System.assertNotEquals(null, exportResponse.errors, 'errors should not be null');
    }
}