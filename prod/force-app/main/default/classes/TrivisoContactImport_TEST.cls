@isTest
private class TrivisoContactImport_TEST {

    private static Contact createContact(String firstName, String lastName, String identification, Integer index, Boolean withNulls) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Salutation = withNulls ? null : 'M.';
        c.Email = withNulls ? null : 'contact' + index + '@test.com';
        c.Email_2__c = withNulls ? null : 'contact2_' + index + '@test.com';
        c.Telephone_1__c = withNulls ? null : 'Tel1_' + index;
        c.Telephone_2__c = withNulls ? null : 'Tel2_' + index;
        c.Telephone_3__c = withNulls ? null : 'Tel3_' + index;
        c.MobilePhone = withNulls ? null : '+41 79 111 ' + index;
        c.Mobile_2__c = withNulls ? null : '+41 79 222 ' + index;
        c.MailingStreet = withNulls ? null : 'Street_' + index;
        c.MailingCity = withNulls ? null : 'City_' + index;
        c.MailingPostalCode = withNulls ? null : 'PC_' + index;
        c.MailingCountry = withNulls ? null : 'Country_' + index;
        c.Title = withNulls ? null : 'Title_' + index;
        c.Department = withNulls ? null : 'Dept_' + index;
        if (identification != null) {
            c.Identification__c = identification;
        }
        c.Langue__c = withNulls ? null : 'FR';
        c.Genre_contact__c = withNulls ? null : 'TAG_' + index;
        return c;
    }

    @isTest
    static void testHandleImport_WithContacts() {
        // Arrange - contacts to export (Identification__c = null)
        List<Contact> contactsToExport = new List<Contact>();
        for (Integer i = 1; i <= 3; i++) {
            contactsToExport.add(createContact('FN_' + i, 'LN_' + i, null, i, false));
        }
        // Re-read first contact after insert to compute expected country using same priority as mapper

        // Contacts to ignore (Identification__c NOT null)
        List<Contact> contactsToIgnore = new List<Contact>();
        for (Integer i = 1; i <= 2; i++) {
            contactsToIgnore.add(createContact('FN_I_' + i, 'LN_I_' + i, 'TRV_' + i, 100 + i, false));
        }

        insert contactsToExport;
        Contact firstExportContact = [
            SELECT MailingCountry, Adresse_Contact__CountryCode__s
            FROM Contact
            WHERE Id = :contactsToExport[0].Id
        ];
        String expectedCountry = String.isNotBlank(firstExportContact.Adresse_Contact__CountryCode__s)
            ? firstExportContact.Adresse_Contact__CountryCode__s
            : firstExportContact.MailingCountry;
        insert contactsToIgnore;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;
        System.assertNotEquals(null, responseBody, 'Response body should not be null');

        TrivisoContactImport.ImportResponse importResponse =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                responseBody,
                TrivisoContactImport.ImportResponse.class
            );

        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assert(importResponse.recordCount >= 3, 'Should have at least 3 exported contacts');
        System.assertNotEquals(null, importResponse.records, 'Records should not be null');
        System.assert(importResponse.records.size() >= 3, 'Should have at least 3 records');

        // Find and verify mapping for first contact
        Boolean found = false;
        for (Map<String, String> rec : importResponse.records) {
            if (rec.get('ADRES_Nom') == 'LN_1' && rec.get('ADRES_Prenom') == 'FN_1') {
                found = true;
                System.assertEquals('M.', rec.get('ADRES_entete'), 'Salutation should map to ADRES_entete');
                System.assertEquals('contact1@test.com', rec.get('ADRES_Email'), 'Email should map');
                System.assertEquals('Tel1_1', rec.get('ADRES_Telephone1'), 'Telephone_1__c should map');
                System.assertEquals('Tel2_1', rec.get('ADRES_Telephone2'), 'Telephone_2__c should map to ADRES_Telephone2');
                System.assertEquals('Tel3_1', rec.get('ADRES_Telephone3'), 'Telephone_3__c should map to ADRES_Telephone3');
                System.assertEquals('Street_1', rec.get('ADRES_Rue'), 'MailingStreet should map to ADRES_Rue');
                System.assertEquals('PC_1', rec.get('ADRES_NPL'), 'MailingPostalCode should map');
                System.assertEquals(expectedCountry, rec.get('ADRES_PAYS_Description'), 'Country should map using contact country priority');
                System.assertEquals('Title_1', rec.get('ADRES_Titre'), 'Title should map');
                System.assertEquals('Dept_1', rec.get('ADRES_Departement'), 'Department should map');
                System.assertEquals('FR', rec.get('ADRES_Langue'), 'Langue__c should map');
                System.assertEquals('TAG_1', rec.get('ADRES_Tag'), 'Genre_contact__c should map');
                System.assertNotEquals(null, rec.get('ADRES_Salesforce_Id'), 'Salesforce Id should be present');
                break;
            }
        }
        System.assert(found, 'Export records should contain FN_1 / LN_1');
        System.assertEquals(false, importResponse.hasMore, 'hasMore should be false for fewer than pageSize records');
        System.assertNotEquals(null, importResponse.lastId, 'lastId should be set when records are returned');
    }

    @isTest
    static void testHandleImport_NoContactsToExport() {
        // Arrange - l'eligibilite a l'export se base sur la date de modification (sinceDate),
        // pas sur Identification__c. On simule "rien de recent" en passant un sinceDate futur :
        // les contacts crees "maintenant" ont un CreatedDate/LastModifiedDate anterieur a ce cutoff.
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 2; i++) {
            contacts.add(createContact('FN_I_' + i, 'LN_I_' + i, 'TRV_' + i, i, false));
        }
        insert contacts;

        Date futureSinceDate = Date.today().addDays(1);
        String sinceDateParam = String.valueOf(futureSinceDate.day()) + '/' + String.valueOf(futureSinceDate.month()) + '/' + String.valueOf(futureSinceDate.year());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"sinceDate": "' + sinceDateParam + '"}');
        RestContext.request = req;
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;

        TrivisoContactImport.ImportResponse importResponse =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                responseBody,
                TrivisoContactImport.ImportResponse.class
            );

        System.assertEquals('success', importResponse.status, 'Status should be success');
        System.assertEquals(0, importResponse.recordCount, 'No contacts should be exported');
        System.assertNotEquals(null, importResponse.records, 'Records list should not be null');
        System.assertEquals(0, importResponse.records.size(), 'Records list should be empty');
        System.assertEquals(false, importResponse.hasMore, 'hasMore should be false when no records');
        System.assertEquals(null, importResponse.lastId, 'lastId should be null when no records');
    }

    @isTest
    static void testHandleImport_NullFieldsMapping() {
        // Arrange - a contact with many nulls
        Contact c = createContact('NullFN', 'NullLN', null, 1, true);
        insert c;
        Contact insertedContact = [
            SELECT MailingCountry, Adresse_Contact__CountryCode__s
            FROM Contact
            WHERE Id = :c.Id
        ];
        String expectedCountry = String.isNotBlank(insertedContact.Adresse_Contact__CountryCode__s)
            ? insertedContact.Adresse_Contact__CountryCode__s
            : insertedContact.MailingCountry;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;

        // Act
        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        // Assert
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;

        TrivisoContactImport.ImportResponse importResponse =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                responseBody,
                TrivisoContactImport.ImportResponse.class
            );

        Map<String, String> testRecord = null;
        for (Map<String, String> rec : importResponse.records) {
            if (rec.get('ADRES_Nom') == 'NullLN' && rec.get('ADRES_Prenom') == 'NullFN') {
                testRecord = rec;
                break;
            }
        }

        System.assertNotEquals(null, testRecord, 'Should find NullFN / NullLN record');
        // All optional mapped fields should be empty strings when source is null
        System.assertEquals('', testRecord.get('ADRES_entete'), 'ADRES_entete should be empty');
        System.assertEquals('', testRecord.get('ADRES_ID_entete'), 'ADRES_ID_entete should be empty');
        System.assertEquals('', testRecord.get('ADRES_Email'), 'ADRES_Email should be empty');
        System.assertEquals('', testRecord.get('ADRES_Telephone1'), 'ADRES_Telephone1 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Telephone2'), 'ADRES_Telephone2 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Telephone3'), 'ADRES_Telephone3 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Natel1'), 'ADRES_Natel1 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Natel2'), 'ADRES_Natel2 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Email2'), 'ADRES_Email2 should be empty');
        System.assertEquals('', testRecord.get('ADRES_Rue'), 'ADRES_Rue should be empty');
        System.assertEquals('', testRecord.get('ADRES_Lieu'), 'ADRES_Lieu should be empty');
        System.assertEquals('', testRecord.get('ADRES_Organisation_Identif'), 'ADRES_Organisation_Identif should be empty');
        System.assertEquals('', testRecord.get('ADRES_NPL'), 'ADRES_NPL should be empty');
        System.assertEquals(expectedCountry != null ? expectedCountry : '', testRecord.get('ADRES_PAYS_Description'), 'ADRES_PAYS_Description should respect contact country priority');
        System.assertEquals('', testRecord.get('ADRES_Titre'), 'ADRES_Titre should be empty');
        System.assertEquals('', testRecord.get('ADRES_Departement'), 'ADRES_Departement should be empty');
        System.assertEquals('', testRecord.get('ADRES_Identification'), 'ADRES_Identification should be empty when Identification__c is null');
        System.assertEquals('', testRecord.get('ADRES_Langue'), 'ADRES_Langue should be empty');
        System.assertEquals('', testRecord.get('ADRES_Tag'), 'ADRES_Tag should be empty');
    }

    @isTest
    static void testHandleImport_ExcludesContactEmploye() {
        Contact employe = createContact('Jean', 'Employe', null, 1, false);
        employe.Genre_contact__c = 'contact_employe';
        insert employe;

        Contact regular = createContact('Jean', 'Regular', null, 2, false);
        regular.Genre_contact__c = 'Privé';
        insert regular;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        TrivisoContactImport.ImportResponse importResponse =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                res.responseBody.toString(), TrivisoContactImport.ImportResponse.class);

        Boolean foundEmploye = false;
        Boolean foundRegular = false;
        for (Map<String, String> rec : importResponse.records) {
            if (rec.get('ADRES_Nom') == 'Employe') foundEmploye = true;
            if (rec.get('ADRES_Nom') == 'Regular') foundRegular = true;
        }
        System.assert(!foundEmploye, 'contact_employe should not appear in export');
        System.assert(foundRegular, 'Regular contact should appear in export');
    }

    @isTest
    static void testHandleImport_PaginationWithLastId() {
        // 3 contacts, pageSize=2 → page 1 has 2 records (hasMore=true), page 2 has 1 (hasMore=false)
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 3; i++) {
            contacts.add(createContact('FN_' + i, 'LN_' + i, null, i, false));
        }
        insert contacts;

        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestBody = Blob.valueOf('{"pageSize": 2}');
        RestContext.request = req1;
        RestContext.response = res1;

        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        TrivisoContactImport.ImportResponse page1 =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                res1.responseBody.toString(), TrivisoContactImport.ImportResponse.class);

        System.assertEquals(2, page1.recordCount, 'Page 1 should return 2 records');
        System.assertEquals(true, page1.hasMore, 'Page 1 should indicate more records exist');
        System.assertNotEquals(null, page1.lastId, 'Page 1 lastId should be set');

        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestBody = Blob.valueOf('{"pageSize": 2, "lastId": "' + page1.lastId + '"}');
        RestContext.request = req2;
        RestContext.response = res2;

        TrivisoContactImport.handleImport();

        TrivisoContactImport.ImportResponse page2 =
            (TrivisoContactImport.ImportResponse) JSON.deserialize(
                res2.responseBody.toString(), TrivisoContactImport.ImportResponse.class);

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
        TrivisoContactImport.handleImport();
        Test.stopTest();

        // Assert - we should hit the catch block and return a 500 with an error payload
        System.assertEquals(500, res.statusCode, 'Status code should be 500 on error');
        String responseBody = res.responseBody != null ? res.responseBody.toString() : null;
        System.assertNotEquals(null, responseBody, 'Error response body should not be null');
        System.assert(responseBody.contains('"status":"error"'), 'Error response should contain status=error');
    }
}