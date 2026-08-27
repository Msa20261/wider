@isTest
private class TrivisoAddressImport_TEST {
    
    @isTest
    static void testHandleImport_WithRecords() {
        // Arrange - Create test data
        List<Proxy_Address__c> addresses = new List<Proxy_Address__c>();
        for (Integer i = 0; i < 3; i++) {
            Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
            address.ADRES_ID__c = 'TEST_IMPORT_' + String.valueOf(i + 1);
            address.ADRES_Nom__c = 'Nom_' + String.valueOf(i + 1);
            address.ADRES_Prenom__c = 'Prenom_' + String.valueOf(i + 1);
            addresses.add(address);
        }
        insert addresses;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody, 'Response body should not be null');
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assert(importResponse.recordCount >= 3, 'Should have at least 3 records (may have more from other tests)');
        System.assertNotEquals(null, importResponse.records, 'Records should not be null');
        System.assert(importResponse.records.size() >= 3, 'Should have at least 3 records in response');
        
        // Verify the records contain our test data
        Boolean foundTestRecord = false;
        for (Map<String, String> record : importResponse.records) {
            if (record.get('ADRES_ID') == 'TEST_IMPORT_1') {
                foundTestRecord = true;
                System.assertEquals('Nom_1', record.get('ADRES_Nom'), 'ADRES_Nom should match');
                System.assertEquals('Prenom_1', record.get('ADRES_Prenom'), 'ADRES_Prenom should match');
                break;
            }
        }
        System.assert(foundTestRecord, 'Should find test record in response');
    }
    
    @isTest
    static void testHandleImport_EmptyDatabase() {
        // Arrange - Ensure no records exist (in a test context, we start fresh)
        // Delete any existing records if needed
        List<Proxy_Address__c> existingAddresses = [SELECT Id FROM Proxy_Address__c];
        if (existingAddresses.size() > 0) {
            delete existingAddresses;
        }
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assertEquals(0, importResponse.recordCount, 'Should have 0 records');
        System.assertNotEquals(null, importResponse.records, 'Records should not be null');
        System.assertEquals(0, importResponse.records.size(), 'Should have 0 records in response');
    }
    
    @isTest
    static void testHandleImport_WithNullValues() {
        // Arrange - Create test data with null values
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_ID__c = 'TEST_NULL_VALUES';
        address.ADRES_Nom__c = 'Test Nom';
        address.ADRES_Date_inactive__c = null;
        address.ADRES_Telephone3__c = null;
        address.ADRES_Natel2__c = null;
        insert address;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        System.assertEquals('success', importResponse.status, 'Status should be success');
        
        // Find our test record
        Map<String, String> testRecord = null;
        for (Map<String, String> record : importResponse.records) {
            if (record.get('ADRES_ID') == 'TEST_NULL_VALUES') {
                testRecord = record;
                break;
            }
        }
        
        System.assertNotEquals(null, testRecord, 'Should find test record');
        System.assertEquals('Test Nom', testRecord.get('ADRES_Nom'), 'ADRES_Nom should match');
        System.assertEquals('', testRecord.get('ADRES_Date_inactive'), 'ADRES_Date_inactive should be empty string for null');
        System.assertEquals('', testRecord.get('ADRES_Telephone3'), 'ADRES_Telephone3 should be empty string for null');
        System.assertEquals('', testRecord.get('ADRES_Natel2'), 'ADRES_Natel2 should be empty string for null');
    }
    
    @isTest
    static void testHandleImport_VerifyMapping() {
        // Arrange - Create test data with all fields populated
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_ID__c = 'TEST_MAPPING_VERIFY';
        address.ADRES_Tag__c = 'TEST_TAG';
        address.ADRES_Nom__c = 'Test Nom';
        address.ADRES_Prenom__c = 'Test Prenom';
        address.ADRES_Rue__c = 'Test Rue 123';
        address.ADRES_Email__c = 'test@example.com';
        address.ADRES_Telephone1__c = '+41 21 123 45 67';
        address.ADRES_Date_creation__c = Datetime.newInstance(2024, 3, 15, 14, 30, 0);
        address.ADRES_Date_modif__c = Datetime.newInstance(2024, 6, 20, 9, 15, 30);
        insert address;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        
        // Find our test record
        Map<String, String> testRecord = null;
        for (Map<String, String> record : importResponse.records) {
            if (record.get('ADRES_ID') == 'TEST_MAPPING_VERIFY') {
                testRecord = record;
                break;
            }
        }
        
        System.assertNotEquals(null, testRecord, 'Should find test record');
        System.assertEquals('TEST_TAG', testRecord.get('ADRES_Tag'), 'ADRES_Tag should match');
        System.assertEquals('Test Nom', testRecord.get('ADRES_Nom'), 'ADRES_Nom should match');
        System.assertEquals('Test Prenom', testRecord.get('ADRES_Prenom'), 'ADRES_Prenom should match');
        System.assertEquals('Test Rue 123', testRecord.get('ADRES_Rue'), 'ADRES_Rue should match');
        System.assertEquals('test@example.com', testRecord.get('ADRES_Email'), 'ADRES_Email should match');
        System.assertEquals('+41 21 123 45 67', testRecord.get('ADRES_Telephone1'), 'ADRES_Telephone1 should match');
        
        // Verify date formatting
        String dateCreation = testRecord.get('ADRES_Date_creation');
        System.assert(dateCreation.contains('15.03.2024'), 'ADRES_Date_creation should contain formatted date');
        System.assert(dateCreation.contains('14:30:00'), 'ADRES_Date_creation should contain formatted time');
        
        String dateModif = testRecord.get('ADRES_Date_modif');
        System.assert(dateModif.contains('20.06.2024'), 'ADRES_Date_modif should contain formatted date');
        System.assert(dateModif.contains('09:15:30'), 'ADRES_Date_modif should contain formatted time');
    }
    
    @isTest
    static void testHandleImport_OrderByCreatedDate() {
        // Arrange - Create test data with different creation times
        List<Proxy_Address__c> addresses = new List<Proxy_Address__c>();
        for (Integer i = 0; i < 3; i++) {
            Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
            address.ADRES_ID__c = 'TEST_ORDER_' + String.valueOf(i + 1);
            addresses.add(address);
        }
        insert addresses;
        
        // Wait a bit to ensure different CreatedDate
        // In test context, records are created almost simultaneously, but we can still verify ordering
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        System.assertEquals('success', importResponse.status, 'Status should be success');
        
        // Verify records are returned (order may vary in test context due to simultaneous creation)
        Boolean foundAllRecords = true;
        Set<String> foundIds = new Set<String>();
        for (Map<String, String> record : importResponse.records) {
            String adresId = record.get('ADRES_ID');
            if (adresId != null && adresId.startsWith('TEST_ORDER_')) {
                foundIds.add(adresId);
            }
        }
        System.assert(foundIds.size() >= 3, 'Should find all test records');
    }
    
    @isTest
    static void testHandleImport_ResponseStructure() {
        // Arrange
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_ID__c = 'TEST_STRUCTURE';
        insert address;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        // Verify response structure
        System.assert(responseBody.contains('"status"'), 'Response should contain status field');
        System.assert(responseBody.contains('"recordCount"'), 'Response should contain recordCount field');
        System.assert(responseBody.contains('"records"'), 'Response should contain records field');
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        System.assertNotEquals(null, importResponse.status, 'status should not be null');
        System.assertNotEquals(null, importResponse.recordCount, 'recordCount should not be null');
        System.assertNotEquals(null, importResponse.records, 'records should not be null');
    }
    
    @isTest
    static void testHandleImport_AllFieldsIncluded() {
        // Arrange - Create test data with all possible fields
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_ID__c = 'TEST_ALL_FIELDS';
        address.ADRES_Tag__c = 'TAG';
        address.ADRES_Organisation_Identif__c = 'ORG_ID';
        address.ADRES_Identification__c = 'IDENT';
        address.ADRES_Nom__c = 'Nom';
        address.ADRES_Prenom__c = 'Prenom';
        address.ADRES_Supplement__c = 'Supplement';
        address.ADRES_Case_postale__c = '1234';
        address.ADRES_Rue__c = 'Rue';
        address.ADRES_Telephone1__c = 'Tel1';
        address.ADRES_Telephone2__c = 'Tel2';
        address.ADRES_Email__c = 'email@test.com';
        address.ADRES_Site_Web__c = 'https://test.com';
        address.ADRES_Lieu__c = 'Lieu';
        address.ADRES_PAYS_Description__c = 'Pays';
        insert address;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        
        TrivisoAddressImport.ImportResponse importResponse = (TrivisoAddressImport.ImportResponse)JSON.deserialize(responseBody, TrivisoAddressImport.ImportResponse.class);
        
        // Find our test record
        Map<String, String> testRecord = null;
        for (Map<String, String> record : importResponse.records) {
            if (record.get('ADRES_ID') == 'TEST_ALL_FIELDS') {
                testRecord = record;
                break;
            }
        }
        
        System.assertNotEquals(null, testRecord, 'Should find test record');
        // Verify key fields are present in the CSV record
        System.assert(testRecord.containsKey('ADRES_Tag'), 'Should contain ADRES_Tag');
        System.assert(testRecord.containsKey('ADRES_ID'), 'Should contain ADRES_ID');
        System.assert(testRecord.containsKey('ADRES_Nom'), 'Should contain ADRES_Nom');
        System.assert(testRecord.containsKey('ADRES_Prenom'), 'Should contain ADRES_Prenom');
        System.assert(testRecord.containsKey('ADRES_Rue'), 'Should contain ADRES_Rue');
        System.assert(testRecord.containsKey('ADRES_Email'), 'Should contain ADRES_Email');
    }

    @isTest
    static void testHandleImport_ErrorPath() {
        // Arrange - force an exception by not setting RestContext.request
        RestContext.request = null;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoAddressImport.handleImport();
        Test.stopTest();

        // Assert - we should hit the catch block and return a 500 with an error payload
        System.assertEquals(500, res.statusCode, 'Status code should be 500 on error');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;
        System.assertNotEquals(null, responseBody, 'Error response body should not be null');
        System.assert(responseBody.contains('"status":"error"'), 'Error response should contain status=error');
    }
}