@isTest
private class TrivisoAccountImport_TEST {

    private static Id getPersonAccountRecordTypeId() {
        Map<String, Schema.RecordTypeInfo> rtByDevName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        if (rtByDevName != null && rtByDevName.containsKey('PersonAccount')) {
            return rtByDevName.get('PersonAccount').getRecordTypeId();
        }
        return null;
    }

    private static Account createComptePersonneAccount(String lastName, String identification, Integer index) {
        Id personRtId = getPersonAccountRecordTypeId();
        System.assertNotEquals(null, personRtId, 'PersonAccount record type is required for this test dataset');

        Account acc = new Account();
        acc.RecordTypeId = personRtId;
        acc.FirstName = 'Prenom_' + index;
        acc.LastName = lastName;
        // 'Privé' est pose explicitement : aucun flow ne normalise
        // Genre_de_client__c en production, contrairement a la sandbox, et
        // TrivisoAccountMapper ne bascule sur LastName/FirstName que pour
        // cette valeur.
        acc.Genre_de_client__c = 'Privé';
        acc.Prenom__c = 'Prenom_' + index;
        acc.Supplement_adresse__c = 'Suppl_' + index;
        acc.BillingCity = 'City_' + index;
        acc.BillingCountry = 'Country_' + index;
        acc.BillingPostalCode = 'PC_' + index;
        acc.BillingStreet = 'Street_' + index;
        acc.Case_postale__c = 'CP_' + index;
        acc.Email_1__c = 'email1_' + index + '@test.com';
        acc.Email_2__c = 'email2_' + index + '@test.com';
        acc.No_EORI__c = 'EORI_' + index;
        acc.Numero_TVA__c = 'TVA_' + index;
        acc.Telephone_1__c = '+41 21 000 00 ' + String.valueOf(index);
        acc.PersonMobilePhone = '+41 79 111 11 ' + String.valueOf(index);
        acc.Mobile_2__pc = '+41 79 222 22 ' + String.valueOf(index);
        acc.Phone_2__c = '+41 79 222 22 ' + String.valueOf(index);
        acc.Registre_commerce__c = 'RC_' + index;
        acc.Telephone_2__c = '+41 21 111 11 ' + String.valueOf(index);
        acc.Telephone_3__c = '+41 21 333 33 ' + String.valueOf(index);
        acc.Ent_te__c = 'Entete_' + index;
        acc.ADRES_ID_entete_c__c = 'IdEntete_' + index;
        acc.Website = 'https://site' + index + '.test';
        acc.Identification__c = identification;
        return acc;
    }

    private static Account createNullFieldsComptePersonne(String lastName) {
        Id personRtId = getPersonAccountRecordTypeId();
        System.assertNotEquals(null, personRtId, 'PersonAccount record type is required for this test dataset');

        Account acc = new Account();
        acc.RecordTypeId = personRtId;
        acc.LastName = lastName;
        acc.Genre_de_client__c = 'Privé';
        acc.BillingCity = null;
        acc.BillingCountry = null;
        acc.BillingPostalCode = null;
        acc.BillingStreet = null;
        acc.Case_postale__c = null;
        acc.Email_1__c = null;
        acc.Email_2__c = null;
        acc.No_EORI__c = null;
        acc.Numero_TVA__c = null;
        acc.PersonMobilePhone = null;
        acc.Mobile_2__pc = null;
        acc.Registre_commerce__c = null;
        acc.Telephone_1__c = null;
        acc.Telephone_2__c = null;
        acc.Telephone_3__c = null;
        acc.Website = null;
        acc.Identification__c = null;
        return acc;
    }

    private static RestResponse prepareRestContext() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        return res;
    }

    private static TrivisoAccountImport.ImportResponse deserializeResponse(RestResponse res) {
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;
        return (TrivisoAccountImport.ImportResponse) JSON.deserialize(
            responseBody,
            TrivisoAccountImport.ImportResponse.class
        );
    }

    private static Map<String, String> findRecordByName(List<Map<String, String>> records, String expectedName) {
        for (Map<String, String> record : records) {
            if (record.get('ADRES_Nom') == expectedName) {
                return record;
            }
        }
        return null;
    }

    @isTest
    static void testHandleImport_WithAccounts() {
        // Arrange - dataset "Privé" to match mapper branching
        List<Account> accountsToExport = new List<Account>();
        for (Integer i = 1; i <= 3; i++) {
            accountsToExport.add(createComptePersonneAccount('Account_Export_' + i, null, i));
        }

        // And some accounts with Identification__c set (must NOT be exported)
        List<Account> accountsToIgnore = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
            accountsToIgnore.add(createComptePersonneAccount('Account_Ignore_' + i, 'TRV_' + i, 100 + i));
        }

        insert accountsToExport;
        insert accountsToIgnore;
        Account accountExport1 = [
            SELECT Name, LastName, BillingCountry, Adresse_compte__CountryCode__s
            FROM Account
            WHERE Id = :accountsToExport[0].Id
        ];
        // Pour Privé, TrivisoAccountMapper exporte ADRES_Nom = LastName (pas Name)
        String expectedName = accountExport1.LastName;
        String expectedCountry = String.isNotBlank(accountExport1.Adresse_compte__CountryCode__s)
            ? accountExport1.Adresse_compte__CountryCode__s
            : accountExport1.BillingCountry;

        RestResponse res = prepareRestContext();

        // Act
        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        TrivisoAccountImport.ImportResponse importResponse = deserializeResponse(res);

        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assert(importResponse.recordCount >= 3, 'Should have at least 3 exported records');
        System.assertNotEquals(null, importResponse.records, 'Records should not be null');
        System.assert(importResponse.records.size() >= 3, 'Should have at least 3 records in response');

        Map<String, String> testRecord = findRecordByName(importResponse.records, expectedName);
        System.assertNotEquals(null, testRecord, 'Exported records should contain the expected account');
        System.assertEquals('City_1', testRecord.get('ADRES_Lieu'), 'ADRES_Lieu should match BillingCity');
        System.assertEquals(expectedCountry, testRecord.get('ADRES_PAYS_Description'), 'Country should map using account country priority');
        System.assertEquals('PC_1', testRecord.get('ADRES_NPL'), 'Postal code mapping should match');
        System.assertEquals('Street_1', testRecord.get('ADRES_Rue'), 'Street mapping should match');
        System.assertEquals('email1_1@test.com', testRecord.get('ADRES_Email'), 'Primary email should match');
        System.assertEquals('email2_1@test.com', testRecord.get('ADRES_Email2'), 'Secondary email should match');
        System.assertEquals('+41 21 000 00 1', testRecord.get('ADRES_Telephone1'), 'Telephone_1__c should match');
        System.assertEquals('+41 21 111 11 1', testRecord.get('ADRES_Telephone2'), 'Telephone_2__c should match');
        System.assertEquals('+41 21 333 33 1', testRecord.get('ADRES_Telephone3'), 'Telephone_3__c should match');
        System.assertEquals('+41 79 111 11 1', testRecord.get('ADRES_Natel1'), 'PersonMobilePhone should match');
        System.assertEquals('+41 79 222 22 1', testRecord.get('ADRES_Natel2'), 'Mobile_2__pc should match');
        System.assertEquals('Prenom_1', testRecord.get('ADRES_Prenom'), 'Prenom__c should match');
        System.assertEquals('Suppl_1', testRecord.get('ADRES_Supplement'), 'Supplement_adresse__c should match');
        System.assertEquals('Entete_1', testRecord.get('ADRES_entete'), 'Ent_te__c should match');
        System.assertEquals('IdEntete_1', testRecord.get('ADRES_ID_entete'), 'ADRES_ID_entete_c__c should match');
        System.assertEquals('https://site1.test', testRecord.get('ADRES_Site_Web'), 'Website should match');
        System.assertEquals(false, importResponse.hasMore, 'hasMore should be false for fewer than pageSize records');
        System.assertNotEquals(null, importResponse.lastId, 'lastId should be set when records are returned');
    }

    @isTest
    static void testHandleImport_NoAccountsToExport() {
        // Arrange - l'eligibilite a l'export se base sur la date de modification (sinceDate),
        // pas sur Identification__c. On simule "rien de recent" en passant un sinceDate futur :
        // les comptes crees "maintenant" ont un CreatedDate/LastModifiedDate anterieur a ce cutoff.
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
            accounts.add(createComptePersonneAccount('Account_Ignore_' + i, 'TRV_' + i, i));
        }
        insert accounts;

        Date futureSinceDate = Date.today().addDays(1);
        String sinceDateParam = String.valueOf(futureSinceDate.day()) + '/' + String.valueOf(futureSinceDate.month()) + '/' + String.valueOf(futureSinceDate.year());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"sinceDate": "' + sinceDateParam + '"}');
        RestContext.request = req;
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        TrivisoAccountImport.ImportResponse importResponse = deserializeResponse(res);

        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assertEquals(0, importResponse.recordCount, 'recordCount should be 0 when no accounts match');
        System.assertNotEquals(null, importResponse.records, 'Records list should not be null');
        System.assertEquals(0, importResponse.records.size(), 'Records list should be empty');
        System.assertEquals(false, importResponse.hasMore, 'hasMore should be false when no records');
        System.assertEquals(null, importResponse.lastId, 'lastId should be null when no records');
    }

    @isTest
    static void testHandleImport_NullFieldMapping() {
        // Arrange - dedicated null-fields dataset for Privé
        Account acc = createNullFieldsComptePersonne('Account_NullFields');
        insert acc;
        Account insertedAcc = [
            SELECT Name, BillingCountry, Adresse_compte__CountryCode__s
            FROM Account
            WHERE Id = :acc.Id
        ];
        String expectedName = insertedAcc.Name;
        String expectedCountry = String.isNotBlank(insertedAcc.Adresse_compte__CountryCode__s)
            ? insertedAcc.Adresse_compte__CountryCode__s
            : insertedAcc.BillingCountry;

        RestResponse res = prepareRestContext();

        // Act
        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        TrivisoAccountImport.ImportResponse importResponse = deserializeResponse(res);

        // Find our test record
        Map<String, String> testRecord = findRecordByName(importResponse.records, expectedName);

        System.assertNotEquals(null, testRecord, 'Should find test record for Account_NullFields');
        // All unmapped fields should be empty strings
        System.assertEquals('', testRecord.get('ADRES_Lieu'), 'ADRES_Lieu should be empty for null BillingCity');
        System.assertEquals(expectedCountry != null ? expectedCountry : '', testRecord.get('ADRES_PAYS_Description'), 'Country should map using account country priority');
        System.assertEquals('', testRecord.get('ADRES_NPL'), 'Postal code should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Rue'), 'Street should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Case_postale'), 'Case postale should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Email'), 'Email should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Email2'), 'Email2 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_No_EORI'), 'No EORI should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_TVA_intracom'), 'TVA should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Telephone1'), 'Telephone1 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_No_registre_commerce'), 'RC should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Telephone2'), 'Telephone2 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Telephone3'), 'Telephone3 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Natel1'), 'Natel1 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Natel2'), 'Natel2 should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Prenom'), 'Prenom should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Supplement'), 'Supplement should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_entete'), 'Entete should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_ID_entete'), 'ADRES_ID_entete should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Organisation_Identif'), 'Organisation Identif should be empty for null');
        System.assertEquals('', testRecord.get('ADRES_Site_Web'), 'Site Web should be empty for null');
    }

    @isTest
    static void testHandleImport_PaginationWithLastId() {
        // 3 accounts, pageSize=2 → page 1 has 2 records (hasMore=true), page 2 has 1 (hasMore=false)
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 3; i++) {
            accounts.add(createComptePersonneAccount('Paginated_' + i, null, i));
        }
        insert accounts;

        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestBody = Blob.valueOf('{"pageSize": 2}');
        RestContext.request = req1;
        RestContext.response = res1;

        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        TrivisoAccountImport.ImportResponse page1 = deserializeResponse(res1);

        System.assertEquals(2, page1.recordCount, 'Page 1 should return 2 records');
        System.assertEquals(true, page1.hasMore, 'Page 1 should indicate more records exist');
        System.assertNotEquals(null, page1.lastId, 'Page 1 lastId should be set');

        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestBody = Blob.valueOf('{"pageSize": 2, "lastId": "' + page1.lastId + '"}');
        RestContext.request = req2;
        RestContext.response = res2;

        TrivisoAccountImport.handleImport();

        TrivisoAccountImport.ImportResponse page2 = deserializeResponse(res2);

        System.assertEquals(1, page2.recordCount, 'Page 2 should return the remaining 1 record');
        System.assertEquals(false, page2.hasMore, 'Page 2 should have no more records');
    }

    @isTest
    static void testHandleImport_ErrorPath() {
        // Arrange - force an exception by not setting RestContext.request
        RestContext.request = null;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        // Assert - we should hit the catch block and return a 500 with an error payload
        System.assertEquals(500, res.statusCode, 'Status code should be 500 on error');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;
        System.assertNotEquals(null, responseBody, 'Error response body should not be null');
        System.assert(responseBody.contains('"status":"error"'), 'Error response should contain status=error');
    }
}