@isTest
private class TrivisoContact_TEST {

    private static Contact createContact(String firstName, String lastName, String identification, Integer index) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Salutation = 'M.';
        c.Email = 'contact' + index + '@test.com';
        c.Email_2__c = 'contact2_' + index + '@test.com';
        c.Telephone_1__c = 'Tel1_' + index;
        c.Telephone_2__c = 'Tel2_' + index;
        c.Telephone_3__c = 'Tel3_' + index;
        c.MobilePhone = '+41 79 111 ' + index;
        c.Mobile_2__c = '+41 79 222 ' + index;
        c.MailingStreet = 'Street_' + index;
        c.MailingCity = 'City_' + index;
        c.MailingPostalCode = 'PC_' + index;
        c.MailingCountry = 'Country_' + index;
        c.Title = 'Title_' + index;
        c.Department = 'Dept_' + index;
        if (identification != null) {
            c.Identification__c = identification;
        }
        c.Langue__c = 'FR';
        c.Genre_contact__c = 'TAG_' + index;
        return c;
    }

    @isTest
    static void testGetContacts() {
        // Arrange
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact('FN_NoId_1', 'LN_NoId_1', null, 1));
        contacts.add(createContact('FN_NoId_2', 'LN_NoId_2', null, 2));
        contacts.add(createContact('FN_WithId_1', 'LN_WithId_1', 'TRV_1', 3));
        insert contacts;

        // Act
        Test.startTest();
        List<Contact> result = TrivisoContact.getContacts();
        Test.stopTest();

        // Assert
        System.assertEquals(3, result.size(), 'Should return all contacts regardless of Identification__c');
        Set<String> names = new Set<String>();
        for (Contact c : result) {
            names.add(c.FirstName + ' ' + c.LastName);
        }
        System.assert(names.contains('FN_NoId_1 LN_NoId_1'), 'Result should contain FN_NoId_1 LN_NoId_1');
        System.assert(names.contains('FN_NoId_2 LN_NoId_2'), 'Result should contain FN_NoId_2 LN_NoId_2');
        System.assert(names.contains('FN_WithId_1 LN_WithId_1'), 'Result should contain FN_WithId_1 LN_WithId_1');
    }

    @isTest
    static void testGetContactsAsTrivisoRecordsAndMapping() {
        // Arrange
        Contact c = createContact('MappedFN', 'MappedLN', null, 1);
        insert c;
        Contact insertedContact = [
            SELECT MailingCountry, Adresse_Contact__CountryCode__s
            FROM Contact
            WHERE Id = :c.Id
        ];
        String expectedCountry = String.isNotBlank(insertedContact.Adresse_Contact__CountryCode__s)
            ? insertedContact.Adresse_Contact__CountryCode__s
            : insertedContact.MailingCountry;

        // Act
        Test.startTest();
        List<TrivisoContactRecord> records = TrivisoContact.getContactsAsTrivisoRecords();
        Test.stopTest();

        // Assert
        System.assertEquals(1, records.size(), 'Should have one TrivisoContactRecord');
        TrivisoContactRecord rec = records[0];
        System.assertEquals('MappedLN', rec.adresNom, 'LastName should map to ADRES_Nom');
        System.assertEquals('MappedFN', rec.adresPrenom, 'FirstName should map to ADRES_Prenom');
        System.assertEquals('M.', rec.adresEntete, 'Salutation should map to ADRES_entete');
        System.assertEquals('contact1@test.com', rec.adresEmail, 'Email should map');
        System.assertEquals('Tel1_1', rec.adresTelephone1, 'Telephone_1__c should map');
        System.assertEquals('Tel2_1', rec.adresTelephone2, 'Telephone_2__c should map to ADRES_Telephone2');
        System.assertEquals('Tel3_1', rec.adresTelephone3, 'Telephone_3__c should map to ADRES_Telephone3');
        System.assertEquals('Street_1', rec.adresRue, 'MailingStreet should map to ADRES_Rue');
        System.assertEquals('PC_1', rec.adresNpl, 'MailingPostalCode should map');
        System.assertEquals(expectedCountry, rec.adresPaysDescription, 'Country should map using contact country priority');
        System.assertEquals('Title_1', rec.adresTitre, 'Title should map');
        System.assertEquals('Dept_1', rec.adresDepartement, 'Department should map');
        System.assertEquals('FR', rec.adresLangue, 'Langue__c should map');
        System.assertEquals('TAG_1', rec.adresTag, 'Genre_contact__c should map');
        System.assertNotEquals(null, rec.adresSalesforceId, 'Salesforce Id should map');
    }

    @isTest
    static void testGetContacts_ExcludesContactEmploye() {
        // Arrange
        Contact employe = new Contact();
        employe.FirstName = 'Jean';
        employe.LastName = 'Employe';
        employe.Genre_contact__c = 'contact_employe';
        insert employe;

        Contact regular = new Contact();
        regular.FirstName = 'Jean';
        regular.LastName = 'Regular';
        regular.Genre_contact__c = 'Privé';
        insert regular;

        // Act
        Test.startTest();
        List<Contact> result = TrivisoContact.getContacts();
        Test.stopTest();

        // Assert
        Set<Id> resultIds = new Set<Id>();
        for (Contact c : result) {
            resultIds.add(c.Id);
        }
        System.assert(!resultIds.contains(employe.Id), 'contact_employe should be excluded');
        System.assert(resultIds.contains(regular.Id), 'Regular contact should be included');
    }

    @isTest
    static void testGetContactsForExportPage() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(createContact('FN_Page_1', 'LN_Page_1', null, 10));
        contacts.add(createContact('FN_Page_2', 'LN_Page_2', 'TRV_2', 11));
        insert contacts;

        Test.startTest();
        List<Map<String, String>> page1 = TrivisoContact.getContactsForExportPage(null, 10, null);
        List<Map<String, String>> page2 = TrivisoContact.getContactsForExportPage(contacts[0].Id, 10, null);
        Test.stopTest();

        System.assertEquals(2, page1.size(), 'First page should return all eligible contacts');
        System.assertEquals(1, page2.size(), 'Second page should return contacts after first Id');
    }

    @isTest
    static void testGetContactsForExportPageWithSinceDate() {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.allowSave = true;

        // Insertion en une seule DML, comme partout ailleurs dans cette classe.
        // En deux DML séparées, le second contact est confronté au premier déjà
        // sauvegardé et se fait rejeter par les règles de duplication bloquantes de
        // l'org : allowSave ne contourne que les règles en mode alerte, jamais celles
        // en mode blocage. L'échec était silencieux (SaveResult ignoré) et ne se
        // manifestait que plus loin, par un décompte inattendu.
        List<Contact> contacts = new List<Contact>{
            createContact('FN_Since_1', 'LN_Since_1', null, 20),
            createContact('FN_Since_2', 'LN_Since_2', null, 21)
        };
        for (Database.SaveResult sr : Database.insert(contacts, dmo)) {
            System.assertEquals(true, sr.isSuccess(),
                'Les contacts de test doivent être insérés : ' + sr.getErrors());
        }

        Test.startTest();
        List<Map<String, String>> resultAll  = TrivisoContact.getContactsForExportPage(null, 10, DateTime.now().addDays(-1));
        List<Map<String, String>> resultNone = TrivisoContact.getContactsForExportPage(null, 10, DateTime.now().addDays(1));
        Test.stopTest();

        System.assertEquals(2, resultAll.size(),  'All contacts should be returned when sinceDate is in the past');
        System.assertEquals(0, resultNone.size(), 'No contacts should be returned when sinceDate is in the future');
    }

    @isTest
    static void testContactImportHandleImport() {
        insert createContact('FN_Import', 'LN_Import', null, 30);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"pageSize": 10}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Should return 200');
    }

    @isTest
    static void testContactImportHandleImportError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('INVALID_JSON');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Should return 500 on malformed request');
    }

    @isTest
    static void testContactImportHandleImportWithSinceDate() {
        insert createContact('FN_Import_Since', 'LN_Import_Since', null, 31);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"pageSize": 10, "sinceDate": "01/01/2000"}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoContactImport.handleImport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Should return 200 with sinceDate param');
    }

    @isTest
    static void testGetContactsForExportStructure() {
        // Arrange
        insert createContact('ExportFN', 'ExportLN', null, 1);

        // Act
        Test.startTest();
        List<Map<String, String>> exportRecords = TrivisoContact.getContactsForExport();
        Test.stopTest();

        // Assert
        System.assertEquals(1, exportRecords.size(), 'Should have one export record');
        Map<String, String> rec = exportRecords[0];

        System.assert(rec.containsKey('ADRES_Tag'), 'Should contain ADRES_Tag');
        System.assert(rec.containsKey('ADRES_Nom'), 'Should contain ADRES_Nom');
        System.assert(rec.containsKey('ADRES_Prenom'), 'Should contain ADRES_Prenom');
        System.assert(rec.containsKey('ADRES_entete'), 'Should contain ADRES_entete');
        System.assert(rec.containsKey('ADRES_ID_entete'), 'Should contain ADRES_ID_entete');
        System.assert(rec.containsKey('ADRES_Email'), 'Should contain ADRES_Email');
        System.assert(rec.containsKey('ADRES_Telephone1'), 'Should contain ADRES_Telephone1');
        System.assert(rec.containsKey('ADRES_Telephone2'), 'Should contain ADRES_Telephone2');
        System.assert(rec.containsKey('ADRES_Telephone3'), 'Should contain ADRES_Telephone3');
        System.assert(rec.containsKey('ADRES_Natel1'), 'Should contain ADRES_Natel1');
        System.assert(rec.containsKey('ADRES_Natel2'), 'Should contain ADRES_Natel2');
        System.assert(rec.containsKey('ADRES_Email2'), 'Should contain ADRES_Email2');
        System.assert(rec.containsKey('ADRES_Rue'), 'Should contain ADRES_Rue');
        System.assert(rec.containsKey('ADRES_Lieu'), 'Should contain ADRES_Lieu');
        System.assert(rec.containsKey('ADRES_Organisation_Identif'), 'Should contain ADRES_Organisation_Identif');
        System.assert(rec.containsKey('ADRES_NPL'), 'Should contain ADRES_NPL');
        System.assert(rec.containsKey('ADRES_PAYS_Description'), 'Should contain ADRES_PAYS_Description');
        System.assert(rec.containsKey('ADRES_Titre'), 'Should contain ADRES_Titre');
        System.assert(rec.containsKey('ADRES_Departement'), 'Should contain ADRES_Departement');
        System.assert(rec.containsKey('ADRES_Identification'), 'Should contain ADRES_Identification');
        System.assert(rec.containsKey('ADRES_Langue'), 'Should contain ADRES_Langue');
        System.assert(rec.containsKey('ADRES_Salesforce_Id'), 'Should contain ADRES_Salesforce_Id');
    }
}