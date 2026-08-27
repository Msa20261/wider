@isTest
private class TrivisoAccount_TEST {

    private static Account createAccount(String name, String identification, Integer index) {
        Account acc = new Account();
        acc.Name = name;
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
        acc.No_TVA_EU__c = null;  // fallback to Numero_TVA__c
        acc.Telephone_1__c = '+41 21 000 00 ' + String.valueOf(index);
        acc.Phone = '+41 79 111 11 ' + String.valueOf(index);
        acc.Phone_2__c = '+41 79 222 22 ' + String.valueOf(index);
        acc.Registre_commerce__c = 'RC_' + index;
        acc.Telephone_2__c = '+41 21 111 11 ' + String.valueOf(index);
        acc.Telephone_3__c = '+41 21 333 33 ' + String.valueOf(index);
        acc.Ent_te__c = 'Entete_' + index;
        acc.ADRES_ID_entete_c__c = 'IdEntete_' + index;
        // acc.Lettre_Ent_te__c = 'Lettre_' + index;
        acc.Website = 'https://site' + index + '.test';
        acc.Identification__c = identification;
        return acc;
    }

    @isTest
    static void testGetAccounts() {
        // Arrange
        List<Account> accounts = new List<Account>();
        accounts.add(createAccount('A_NoId_1', null, 1));
        accounts.add(createAccount('A_NoId_2', null, 2));
        accounts.add(createAccount('A_WithId_1', 'TRV_1', 3));
        insert accounts;

        // Act
        Test.startTest();
        List<Account> result = TrivisoAccount.getAccounts();
        Test.stopTest();

        // Assert
        System.assertEquals(3, result.size(), 'Should return all accounts regardless of Identification__c');
        Set<String> names = new Set<String>();
        for (Account a : result) {
            names.add(a.Name);
        }
        System.assert(names.contains('A_NoId_1'), 'Result should contain A_NoId_1');
        System.assert(names.contains('A_NoId_2'), 'Result should contain A_NoId_2');
        System.assert(names.contains('A_WithId_1'), 'Result should contain A_WithId_1');
    }

    @isTest
    static void testGetAccountsAsTrivisoRecordsAndMapping() {
        // Arrange
        Account acc = createAccount('Mapped_Account', null, 1);
        insert acc;
        Account insertedAcc = [
            SELECT BillingCountry, Adresse_compte__CountryCode__s
            FROM Account
            WHERE Id = :acc.Id
        ];
        String expectedCountry = String.isNotBlank(insertedAcc.Adresse_compte__CountryCode__s)
            ? insertedAcc.Adresse_compte__CountryCode__s
            : insertedAcc.BillingCountry;

        // Act
        Test.startTest();
        List<TrivisoAccountRecord> records = TrivisoAccount.getAccountsAsTrivisoRecords();
        Test.stopTest();

        // Assert
        System.assertEquals(1, records.size(), 'Should return one TrivisoAccountRecord');
        TrivisoAccountRecord rec = records[0];
        System.assertEquals('Mapped_Account', rec.adresNom, 'Name should map to ADRES_Nom');
        System.assertEquals('Prenom_1', rec.adresPrenom, 'Prenom__c should map to ADRES_Prenom');
        System.assertEquals('Suppl_1', rec.adresSupplement, 'Supplement_adresse__c should map to ADRES_Supplement');
        System.assertEquals('City_1', rec.adresLieu, 'BillingCity should map to ADRES_Lieu');
        System.assertEquals(expectedCountry, rec.adresPaysDescription, 'Country should map using account country priority');
        System.assertEquals('PC_1', rec.adresNpl, 'BillingPostalCode should map');
        System.assertEquals('Street_1', rec.adresRue, 'BillingStreet should map');
        System.assertEquals('CP_1', rec.adresCasePostale, 'Case_postale__c should map');
        System.assertEquals('email1_1@test.com', rec.adresEmail, 'Email_1__c should map');
        System.assertEquals('email2_1@test.com', rec.adresEmail2, 'Email_2__c should map');
        System.assertEquals('EORI_1', rec.adresNoEori, 'No_EORI__c should map');
        System.assertEquals('TVA_1', rec.adresTvaIntracom, 'Numero_TVA__c should map');
        System.assertEquals('+41 21 000 00 1', rec.adresTelephone1, 'Phone should map');
        System.assertEquals('RC_1', rec.adresNoRegistreCommerce, 'Registre_commerce__c should map');
        System.assertEquals('+41 21 111 11 1', rec.adresTelephone2, 'Telephone_2__c should map');
        System.assertEquals('https://site1.test', rec.adresSiteWeb, 'Website should map');
    }

    @isTest
    static void testGetAccountsForExportPage() {
        List<Account> accounts = new List<Account>();
        accounts.add(createAccount('Page_Account_1', null, 1));
        accounts.add(createAccount('Page_Account_2', 'TRV_2', 2));
        insert accounts;

        Test.startTest();
        List<Map<String, String>> page1 = TrivisoAccount.getAccountsForExportPage(null, 10, null);
        List<Map<String, String>> page2 = TrivisoAccount.getAccountsForExportPage(accounts[0].Id, 10, null);
        Test.stopTest();

        System.assertEquals(2, page1.size(), 'First page should return all accounts');
        System.assertEquals(1, page2.size(), 'Second page should return accounts after first Id');
    }

    @isTest
    static void testGetAccountsForExportPageWithSinceDate() {
        // Noms volontairement distincts : deux noms trop proches (ex. suffixe numerique) declenchent
        // la regle de doublon custom "Entreprise_Account" (fuzzy match sur le nom), qui bloque
        // l'insertion meme avec DuplicateRuleHeader.allowSave=true (celui-ci ne couvre pas les
        // regles actionOnInsert=Block declenchees par correspondance de nom).
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.allowSave = true;
        Database.insert(createAccount('Compte_Historique_Alpha', null, 10), dmo);
        Database.insert(createAccount('Compte_Facturation_Beta', 'TRV_10', 11), dmo);

        Test.startTest();
        List<Map<String, String>> resultAll  = TrivisoAccount.getAccountsForExportPage(null, 10, DateTime.now().addDays(-1));
        List<Map<String, String>> resultNone = TrivisoAccount.getAccountsForExportPage(null, 10, DateTime.now().addDays(1));
        Test.stopTest();

        System.assertEquals(2, resultAll.size(),  'All accounts should be returned when sinceDate is in the past');
        System.assertEquals(0, resultNone.size(), 'No accounts should be returned when sinceDate is in the future');
    }

    @isTest
    static void testPaginationHelperGetSinceDate() {
        Map<String, Object> withDate  = new Map<String, Object>{'sinceDate' => '15/06/2025'};
        Map<String, Object> withoutDate = new Map<String, Object>();
        Map<String, Object> badFormat  = new Map<String, Object>{'sinceDate' => 'invalid'};

        DateTime result = TrivisoPaginationHelper.getSinceDate(withDate);
        System.assertNotEquals(null, result, 'Should parse a valid date');
        System.assertEquals(2025, result.year(),  'Year should be 2025');
        System.assertEquals(6,    result.month(), 'Month should be 6');
        System.assertEquals(15,   result.day(),   'Day should be 15');

        System.assertEquals(null, TrivisoPaginationHelper.getSinceDate(withoutDate), 'Should return null when not provided');
        System.assertEquals(null, TrivisoPaginationHelper.getSinceDate(badFormat),   'Should return null on bad format');
    }

    @isTest
    static void testAccountImportHandleImport() {
        insert createAccount('Import_Account', null, 20);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"pageSize": 10}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Should return 200');
    }

    @isTest
    static void testAccountImportHandleImportError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('INVALID_JSON');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Should return 500 on malformed request');
    }

    @isTest
    static void testAccountImportHandleImportWithSinceDate() {
        insert createAccount('Import_Account_Since', null, 21);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"pageSize": 10, "sinceDate": "01/01/2000"}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoAccountImport.handleImport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Should return 200 with sinceDate param');
    }

    @isTest
    static void testGetAccountsForExportStructure() {
        // Arrange
        insert createAccount('Export_Account', null, 1);

        // Act
        Test.startTest();
        List<Map<String, String>> exportRecords = TrivisoAccount.getAccountsForExport();
        Test.stopTest();

        // Assert
        System.assertEquals(1, exportRecords.size(), 'Should have one export record');
        Map<String, String> record = exportRecords[0];

        // Basic structure checks
        System.assert(record.containsKey('ADRES_Nom'), 'Should contain ADRES_Nom');
        System.assert(record.containsKey('ADRES_Lieu'), 'Should contain ADRES_Lieu');
        System.assert(record.containsKey('ADRES_PAYS_Description'), 'Should contain ADRES_PAYS_Description');
        System.assert(record.containsKey('ADRES_NPL'), 'Should contain ADRES_NPL');
        System.assert(record.containsKey('ADRES_Rue'), 'Should contain ADRES_Rue');
        System.assert(record.containsKey('ADRES_Case_postale'), 'Should contain ADRES_Case_postale');
        System.assert(record.containsKey('ADRES_Email'), 'Should contain ADRES_Email');
        System.assert(record.containsKey('ADRES_Email2'), 'Should contain ADRES_Email2');
        System.assert(record.containsKey('ADRES_No_EORI'), 'Should contain ADRES_No_EORI');
        System.assert(record.containsKey('ADRES_TVA_intracom'), 'Should contain ADRES_TVA_intracom');
        System.assert(record.containsKey('ADRES_Telephone1'), 'Should contain ADRES_Telephone1');
        System.assert(record.containsKey('ADRES_No_registre_commerce'), 'Should contain ADRES_No_registre_commerce');
        System.assert(record.containsKey('ADRES_Telephone2'), 'Should contain ADRES_Telephone2');
        System.assert(record.containsKey('ADRES_Telephone3'), 'Should contain ADRES_Telephone3');
        System.assert(record.containsKey('ADRES_Natel1'), 'Should contain ADRES_Natel1');
        System.assert(record.containsKey('ADRES_Natel2'), 'Should contain ADRES_Natel2');
        System.assert(record.containsKey('ADRES_Prenom'), 'Should contain ADRES_Prenom');
        System.assert(record.containsKey('ADRES_Supplement'), 'Should contain ADRES_Supplement');
        System.assert(record.containsKey('ADRES_entete'), 'Should contain ADRES_entete');
        System.assert(record.containsKey('ADRES_ID_entete'), 'Should contain ADRES_ID_entete');
        System.assert(record.containsKey('ADRES_Organisation_Identif'), 'Should contain ADRES_Organisation_Identif');
        System.assert(record.containsKey('ADRES_Site_Web'), 'Should contain ADRES_Site_Web');
    }
}