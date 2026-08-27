@isTest
private class TrivisoAccountMapper_TEST {

    @testSetup
    static void setUpTestData() {
        TrivisoDataFactory.createAccountForTrivisoMapper(true);
    }

    @isTest
    static void testMapFromAccount_AllFields() {
        Account queried = [
            SELECT Id, Name, Genre_de_client__c, Identification__c, ParentId, Parent.Identification__c,
                   ADRES_ID__c, ADRES_ID__pc,
                   Prenom__c, Supplement_adresse__c, Case_postale__c,
                   Adresse_compte__Street__s, Adresse_compte__City__s, Adresse_compte__PostalCode__s, Adresse_compte__CountryCode__s,
                   BillingStreet, BillingCity, BillingPostalCode, BillingCountry,
                   Telephone_1__c, Telephone_2__c, Telephone_3__c,
                   Phone, Phone_2__c,
                   Email_1__c, Email_2__c,
                   Website, Ent_te__c, Salutation, ADRES_ID_entete_c__c, ADRES_ID_entete_c__pc,
                   No_TVA_EU__c, Numero_TVA__c, Registre_commerce__c,
                   Langue__c, Langue__pc, No_EORI__c, Compte_Actif__c, CreatedDate, LastModifiedDate,
                   PersonMobilePhone, Mobile_2__pc, PersonTitle, PersonDepartment
            FROM Account
            WHERE Name = 'TRIVISO_ACCOUNT_MAPPER'
        ];
        Test.startTest();
        TrivisoAccountRecord record = TrivisoAccountMapper.mapFromAccount(queried);
        Test.stopTest();
        System.assertEquals(queried.Genre_de_client__c, record.adresTag, 'adresTag');
        String expectedAdresId = String.isNotBlank(queried.ADRES_ID__pc) ? queried.ADRES_ID__pc : queried.ADRES_ID__c;
        System.assertEquals(expectedAdresId, record.adresId, 'adresId');
        String genre = queried.Genre_de_client__c != null ? queried.Genre_de_client__c.trim().toLowerCase() : null;
        String expectedOrgIdent =
            (genre == 'fournisseur' || genre == 'filiale' || genre == 'entreprise')
                ? (queried.Parent != null && String.isNotBlank(queried.Parent.Identification__c)
                    ? queried.Parent.Identification__c
                    : null)
                : null;
        System.assertEquals(expectedOrgIdent, record.adresOrganisationIdentif, 'adresOrganisationIdentif');
        System.assertEquals(queried.Identification__c, record.adresIdentification, 'adresIdentification');
        System.assertEquals(queried.Name, record.adresNom, 'adresNom');
        System.assertEquals(queried.Prenom__c, record.adresPrenom, 'adresPrenom');
        System.assertEquals(queried.Supplement_adresse__c, record.adresSupplement, 'adresSupplement');
        System.assertEquals(queried.Case_postale__c, record.adresCasePostale, 'adresCasePostale');
        String expectedRue = String.isNotBlank(queried.Adresse_compte__Street__s) ? queried.Adresse_compte__Street__s : queried.BillingStreet;
        System.assertEquals(expectedRue, record.adresRue, 'adresRue');
        System.assertEquals(queried.Telephone_1__c, record.adresTelephone1, 'adresTelephone1');
        System.assertEquals(queried.Telephone_2__c, record.adresTelephone2, 'adresTelephone2');
        System.assertEquals(queried.Telephone_3__c, record.adresTelephone3, 'adresTelephone3');
        System.assertEquals(queried.Phone, record.adresNatel1, 'adresNatel1');
        System.assertEquals(queried.Phone_2__c, record.adresNatel2, 'adresNatel2');
        System.assertEquals(queried.Email_1__c, record.adresEmail, 'adresEmail');
        System.assertEquals(queried.Email_2__c, record.adresEmail2, 'adresEmail2');
        System.assertEquals(queried.Website, record.adresSiteWeb, 'adresSiteWeb');
        System.assertEquals(queried.Ent_te__c, record.adresEntete, 'adresEntete');
        String expectedIdEntete = String.isNotBlank(queried.ADRES_ID_entete_c__pc) ? queried.ADRES_ID_entete_c__pc : queried.ADRES_ID_entete_c__c;
        System.assertEquals(expectedIdEntete, record.adresIdEntete, 'adresIdEntete');
        String expectedTva = String.isNotBlank(queried.No_TVA_EU__c) ? queried.No_TVA_EU__c : queried.Numero_TVA__c;
        System.assertEquals(expectedTva, record.adresTvaIntracom, 'adresTvaIntracom');
        System.assertEquals(queried.Registre_commerce__c, record.adresNoRegistreCommerce, 'adresNoRegistreCommerce');
        String expectedNpl = String.isNotBlank(queried.Adresse_compte__PostalCode__s) ? queried.Adresse_compte__PostalCode__s : queried.BillingPostalCode;
        System.assertEquals(expectedNpl, record.adresNpl, 'adresNpl');
        String expectedLieu = String.isNotBlank(queried.Adresse_compte__City__s) ? queried.Adresse_compte__City__s : queried.BillingCity;
        System.assertEquals(expectedLieu, record.adresLieu, 'adresLieu');
        String expectedPays = String.isNotBlank(queried.Adresse_compte__CountryCode__s) ? queried.Adresse_compte__CountryCode__s : queried.BillingCountry;
        System.assertEquals(expectedPays, record.adresPaysDescription, 'adresPaysDescription');
        System.assertEquals(expectedPays, record.adresPaysIdentification, 'adresPaysIdentification');
        System.assertEquals(queried.Langue__c, record.adresLangue, 'adresLangue');
        System.assertEquals(queried.No_EORI__c, record.adresNoEori, 'adresNoEori');
        System.assertEquals(queried.Id, record.adresSalesforceId, 'adresSalesforceId');
    }

    @isTest
    static void testMapFromAccount_ComptePersonne_UsesFirstNameAndLastName() {
        Account acc = new Account(
            LastName = 'Gilbert',
            FirstName = 'Alexandre',
            Genre_de_client__c = 'Privé',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id
        );
        insert acc;

        Account queried = [
            SELECT Id, Name, FirstName, LastName, Prenom__c, Genre_de_client__c, ADRES_ID__c, ADRES_ID__pc, Identification__c,
                   ParentId, Parent.Identification__c,
                   Supplement_adresse__c, Case_postale__c,
                   Adresse_compte__Street__s, Adresse_compte__City__s, Adresse_compte__PostalCode__s, Adresse_compte__CountryCode__s,
                   BillingStreet, BillingCity, BillingPostalCode, BillingCountry,
                   Telephone_1__c, Telephone_2__c, Telephone_3__c,
                   Phone, Phone_2__c,
                   Email_1__c, Email_2__c,
                   Website, Ent_te__c, Salutation, ADRES_ID_entete_c__c, ADRES_ID_entete_c__pc,
                   No_TVA_EU__c, Numero_TVA__c, Registre_commerce__c,
                   Langue__c, Langue__pc, No_EORI__c, Compte_Actif__c, CreatedDate, LastModifiedDate,
                   PersonMobilePhone, Mobile_2__pc, PersonTitle, PersonDepartment
            FROM Account
            WHERE Id = :acc.Id
        ];

        Test.startTest();
        TrivisoAccountRecord record = TrivisoAccountMapper.mapFromAccount(queried);
        Test.stopTest();

        System.assertEquals(queried.LastName, record.adresNom, 'adresNom should be LastName for Privé');
        System.assertEquals(queried.FirstName, record.adresPrenom, 'adresPrenom should be FirstName for Privé');
    }

    @isTest
    static void testMapAccountsToTrivisoRecords_EmptyAndNull() {
        List<TrivisoAccountRecord> fromEmpty = TrivisoAccountMapper.mapAccountsToTrivisoRecords(new List<Account>());
        System.assertEquals(0, fromEmpty.size(), 'empty list');
        List<TrivisoAccountRecord> fromNull = TrivisoAccountMapper.mapAccountsToTrivisoRecords(null);
        System.assertEquals(0, fromNull.size(), 'null list');
    }

    @isTest
    static void testMapToExportRecord_AllFields() {
        TrivisoAccountRecord record = new TrivisoAccountRecord();
        record.adresSalesforceId = 'SFID';
        record.adresTag = 'TAG';
        record.adresId = 'ID';
        record.adresOrganisationIdentif = 'ORG';
        record.adresIdentification = 'IDENT';
        record.adresDateCreation = '01.01.2024 10:00:00';
        record.adresDateModif = '02.01.2024 11:00:00';
        record.adresDateInactive = '03.01.2024 12:00:00';
        record.adresNom = 'Nom';
        record.adresPrenom = 'Prenom';
        record.adresSupplement = 'Suppl';
        record.adresCasePostale = 'CP';
        record.adresRue = 'Rue';
        record.adresTelephone1 = 'T1';
        record.adresTelephone2 = 'T2';
        record.adresTelephone3 = 'T3';
        record.adresNatel1 = 'N1';
        record.adresNatel2 = 'N2';
        record.adresEmail = 'a@test.com';
        record.adresEmail2 = 'b@test.com';
        record.adresSiteWeb = 'https://test.com';
        record.adresEntete = 'Ent';
        record.adresIdEntete = 'IDENT-ENT';
        record.adresTvaIntracom = 'TVA';
        record.adresNoRegistreCommerce = 'RC';
        record.adresNpl = '1000';
        record.adresLieu = 'Ville';
        record.adresPaysDescription = 'CH';
        record.adresPaysIdentification = 'CH';
        record.adresTitre = 'Titre';
        record.adresDepartement = 'Dep';
        record.adresLangue = 'FR';
        record.adresNoEori = 'EORI';
        Test.startTest();
        Map<String, String> exportRecord = TrivisoAccountMapper.mapToExportRecord(record);
        Test.stopTest();
        System.assertEquals('SFID', exportRecord.get('ADRES_Salesforce_Id'));
        System.assertEquals('TAG', exportRecord.get('ADRES_Tag'));
        System.assertEquals('ID', exportRecord.get('ADRES_ID'));
        System.assertEquals('ORG', exportRecord.get('ADRES_Organisation_Identif'));
        System.assertEquals('IDENT', exportRecord.get('ADRES_Identification'));
        System.assertEquals('01.01.2024 10:00:00', exportRecord.get('ADRES_Date_creation'));
        System.assertEquals('02.01.2024 11:00:00', exportRecord.get('ADRES_Date_modif'));
        System.assertEquals('03.01.2024 12:00:00', exportRecord.get('ADRES_Date_inactive'));
        System.assertEquals('Nom', exportRecord.get('ADRES_Nom'));
        System.assertEquals('Prenom', exportRecord.get('ADRES_Prenom'));
        System.assertEquals('Suppl', exportRecord.get('ADRES_Supplement'));
        System.assertEquals('CP', exportRecord.get('ADRES_Case_postale'));
        System.assertEquals('Rue', exportRecord.get('ADRES_Rue'));
        System.assertEquals('T1', exportRecord.get('ADRES_Telephone1'));
        System.assertEquals('T2', exportRecord.get('ADRES_Telephone2'));
        System.assertEquals('T3', exportRecord.get('ADRES_Telephone3'));
        System.assertEquals('N1', exportRecord.get('ADRES_Natel1'));
        System.assertEquals('N2', exportRecord.get('ADRES_Natel2'));
        System.assertEquals('a@test.com', exportRecord.get('ADRES_Email'));
        System.assertEquals('b@test.com', exportRecord.get('ADRES_Email2'));
        System.assertEquals('https://test.com', exportRecord.get('ADRES_Site_Web'));
        System.assertEquals('Ent', exportRecord.get('ADRES_entete'));
        System.assertEquals('IDENT-ENT', exportRecord.get('ADRES_ID_entete'));
        System.assertEquals('TVA', exportRecord.get('ADRES_TVA_intracom'));
        System.assertEquals('RC', exportRecord.get('ADRES_No_registre_commerce'));
        System.assertEquals('1000', exportRecord.get('ADRES_NPL'));
        System.assertEquals('Ville', exportRecord.get('ADRES_Lieu'));
        System.assertEquals('CH', exportRecord.get('ADRES_PAYS_Description'));
        System.assertEquals('CH', exportRecord.get('ADRES_PAYS_Identification'));
        System.assertEquals('Titre', exportRecord.get('ADRES_Titre'));
        System.assertEquals('Dep', exportRecord.get('ADRES_Departement'));
        System.assertEquals('FR', exportRecord.get('ADRES_Langue'));
        System.assertEquals('EORI', exportRecord.get('ADRES_No_EORI'));
    }
}