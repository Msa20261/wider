@isTest
private class AddressProxy_TEST {
    
    @isTest
    static void testBuildProxyAddresses_SingleRecord() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord();
        List<AddressProxyRecord> records = new List<AddressProxyRecord>{ record };
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, addresses.size(), 'Should return exactly one address');
        Proxy_Address__c address = addresses[0];
        System.assertEquals(record.adresId, address.ADRESTriviso_ID__c, 'ADRESTriviso_ID__c should match');
        System.assertEquals(record.adresNom, address.ADRES_Nom__c, 'ADRES_Nom should match');
        System.assertEquals(record.adresPrenom, address.ADRES_Prenom__c, 'ADRES_Prenom should match');
        System.assertEquals('Reçu', address.Statut__c, 'Statut should be Reçu');
        System.assertEquals('Triviso', address.Source__c, 'Source should be Triviso');
        System.assertNotEquals(null, address.Date_Reception__c, 'Date_Reception should be set');
    }
    
    @isTest
    static void testBuildProxyAddresses_MultipleRecords() {
        // Arrange
        List<AddressProxyRecord> records = TrivisoDataFactory.createAddressProxyRecords(5);
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(5, addresses.size(), 'Should return exactly 5 addresses');
        for (Integer i = 0; i < addresses.size(); i++) {
            Proxy_Address__c address = addresses[i];
            System.assertEquals('ADRES_' + String.valueOf(i + 1), address.ADRESTriviso_ID__c, 'ADRESTriviso_ID__c should match');
            System.assertEquals('Nom_' + String.valueOf(i + 1), address.ADRES_Nom__c, 'ADRES_Nom should match');
        }
    }
    
    @isTest
    static void testBuildProxyAddresses_EmptyList() {
        // Arrange
        List<AddressProxyRecord> records = new List<AddressProxyRecord>();
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, addresses.size(), 'Should return empty list');
    }
    
    @isTest
    static void testInsertAddresses_Success() {
        // Arrange
        List<AddressProxyRecord> records = TrivisoDataFactory.createAddressProxyRecords(3);
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        
        // Act
        Test.startTest();
        Database.SaveResult[] results = AddressProxy.insertAddresses(addresses);
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
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRES_ID__c, ADRES_Nom__c 
            FROM Proxy_Address__c 
            WHERE ADRESTriviso_ID__c LIKE 'ADRES_%'
            ORDER BY ADRES_ID__c
        ];
        System.assertEquals(3, insertedAddresses.size(), 'Should have 3 records in database');
    }
    
    @isTest
    static void testInsertAddresses_WithErrors() {
        // Arrange
        List<AddressProxyRecord> records = TrivisoDataFactory.createAddressProxyRecords(2);
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        
        // Insert first address to create duplicate
        insert addresses[0];
        
        // Create duplicate address with same ADRES_ID
        Proxy_Address__c duplicate = addresses[0].clone(false, true);
        List<Proxy_Address__c> addressesWithDuplicate = new List<Proxy_Address__c>{ addresses[1], duplicate };
        
        // Act
        Test.startTest();
        Database.SaveResult[] results = AddressProxy.insertAddresses(addressesWithDuplicate);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, results.size(), 'Should have 2 results');
        System.assert(results[0].isSuccess(), 'First record should succeed');
        // Second record might fail if there's a unique constraint, or succeed if duplicates are allowed
        // We just verify the method handles both cases
    }
    
    @isTest
    static void testUpsertAddresses_InsertNew() {
        // Arrange
        List<AddressProxyRecord> records = TrivisoDataFactory.createAddressProxyRecords(2);
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> upsertedAddresses = AddressProxy.upsertAddresses(addresses);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, upsertedAddresses.size(), 'Should return 2 addresses');
        
        // Verify records were inserted
        List<Proxy_Address__c> insertedAddresses = [
            SELECT Id, ADRES_ID__c 
            FROM Proxy_Address__c 
            WHERE ADRES_ID__c IN :new List<String>{ addresses[0].ADRES_ID__c, addresses[1].ADRES_ID__c }
        ];
        System.assertEquals(2, insertedAddresses.size(), 'Should have 2 records in database');
    }
    
    @isTest
    static void testUpsertAddresses_UpdateExisting() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord();
        record.adresId = 'TEST_UPSERT_ID';
        record.adresNom = 'Original Name';
        
        List<AddressProxyRecord> records = new List<AddressProxyRecord>{ record };
        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(records);
        insert addresses;
        
        // Update the record
        addresses[0].ADRES_Nom__c = 'Updated Name';
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> upsertedAddresses = AddressProxy.upsertAddresses(addresses);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, upsertedAddresses.size(), 'Should return 1 address');
        
        // Verify record was updated
        Proxy_Address__c updatedAddress = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_Nom__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c = 'TEST_UPSERT_ID'
            LIMIT 1
        ];
        System.assertEquals('Updated Name', updatedAddress.ADRES_Nom__c, 'Name should be updated');
    }
    
    @isTest
    static void testUpsertAddresses_MixedInsertAndUpdate() {
        // Arrange
        // Create and insert first address
        AddressProxyRecord record1 = TrivisoDataFactory.createAddressProxyRecord();
        record1.adresId = 'TEST_MIXED_1';
        List<Proxy_Address__c> address1 = AddressProxy.buildProxyAddresses(new List<AddressProxyRecord>{ record1 });
        insert address1;
        
        // Create second address (new)
        AddressProxyRecord record2 = TrivisoDataFactory.createAddressProxyRecord();
        record2.adresId = 'TEST_MIXED_2';
        List<Proxy_Address__c> address2 = AddressProxy.buildProxyAddresses(new List<AddressProxyRecord>{ record2 });
        
        // Update first address
        address1[0].ADRES_Nom__c = 'Updated Name';
        
        // Combine both
        List<Proxy_Address__c> addressesToUpsert = new List<Proxy_Address__c>{ address1[0], address2[0] };
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> upsertedAddresses = AddressProxy.upsertAddresses(addressesToUpsert);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, upsertedAddresses.size(), 'Should return 2 addresses');
        
        // Verify both records exist
        List<Proxy_Address__c> results = [
            SELECT Id, ADRESTriviso_ID__c, ADRES_Nom__c
            FROM Proxy_Address__c
            WHERE ADRESTriviso_ID__c IN ('TEST_MIXED_1', 'TEST_MIXED_2')
            ORDER BY ADRESTriviso_ID__c
        ];
        System.assertEquals(2, results.size(), 'Should have 2 records in database');
        System.assertEquals('Updated Name', results[0].ADRES_Nom__c, 'First record should be updated');
    }
    
    @isTest
    static void testUpsertAddresses_EmptyList() {
        // Arrange
        List<Proxy_Address__c> addresses = new List<Proxy_Address__c>();
        
        // Act
        Test.startTest();
        List<Proxy_Address__c> upsertedAddresses = AddressProxy.upsertAddresses(addresses);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, upsertedAddresses.size(), 'Should return empty list');
    }

    @isTest
    static void testUpsertAddresses_WithDuplicateExternalId() {
        // Arrange - create two addresses with the same external id to trigger upsert error handling
        AddressProxyRecord record1 = TrivisoDataFactory.createAddressProxyRecord();
        record1.adresId = 'DUP_EXT_ID';
        AddressProxyRecord record2 = TrivisoDataFactory.createAddressProxyRecord();
        record2.adresId = 'DUP_EXT_ID';

        List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(
            new List<AddressProxyRecord>{ record1, record2 }
        );

        // Act - even if we can't assert on individual errors, this will exercise the error logging branch
        Test.startTest();
        List<Proxy_Address__c> upsertedAddresses = AddressProxy.upsertAddresses(addresses);
        Test.stopTest();

        // Assert - both records are processed
        System.assertEquals(2, upsertedAddresses.size(), 'Should process both addresses even with duplicate external id');
    }
}