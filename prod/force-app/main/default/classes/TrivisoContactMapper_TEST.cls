@isTest
private class TrivisoContactMapper_TEST {

    @testSetup
    static void setUpTestData() {
        TrivisoDataFactory.createContactForTrivisoMapper(true);
    }

    @isTest
    static void testMapFromContact_AllFields() {
        Contact queried = [
            SELECT Id, FirstName, LastName, Salutation, Email, Email_2__c,
                   Telephone_1__c, Telephone_2__c, Telephone_3__c,
                   MobilePhone, Mobile_2__c,
                   Adresse_Contact__Street__s, Adresse_Contact__City__s, Adresse_Contact__PostalCode__s, Adresse_Contact__CountryCode__s,
                   MailingStreet, MailingCity, MailingPostalCode, MailingCountry,
                   Title, Department,
                   Identification__c, Langue__c, Genre_contact__c, ADRES_ID__c,
                   SiteWeb__c, Supplement__c, Case_postale__c, AccountId,
                   Account.Identification__c, CreatedDate, LastModifiedDate, Contact_actif__c, ADRES_ID_entete_c__c
            FROM Contact
            WHERE Identification__c = 'TRIVISO_CONTACT_ID'
        ];
        Test.startTest();
        TrivisoContactRecord record = TrivisoContactMapper.mapFromContact(queried);
        Test.stopTest();
        System.assertEquals(queried.Genre_contact__c, record.adresTag, 'adresTag');
        System.assertEquals(queried.ADRES_ID__c, record.adresId, 'adresId');
        String expectedOrgIdent = queried.Account != null && String.isNotBlank(queried.Account.Identification__c)
            ? queried.Account.Identification__c
            : null;
        System.assertEquals(expectedOrgIdent, record.adresOrganisationIdentif, 'adresOrganisationIdentif');
        System.assertEquals(queried.Identification__c, record.adresIdentification, 'adresIdentification');
        System.assertEquals(queried.LastName, record.adresNom, 'adresNom');
        System.assertEquals(queried.FirstName, record.adresPrenom, 'adresPrenom');
        System.assertEquals(queried.Supplement__c, record.adresSupplement, 'adresSupplement');
        System.assertEquals(queried.Case_postale__c, record.adresCasePostale, 'adresCasePostale');
        String expectedRue = String.isNotBlank(queried.Adresse_Contact__Street__s) ? queried.Adresse_Contact__Street__s : queried.MailingStreet;
        System.assertEquals(expectedRue, record.adresRue, 'adresRue');
        System.assertEquals(queried.Telephone_1__c, record.adresTelephone1, 'adresTelephone1');
        System.assertEquals(queried.Telephone_2__c, record.adresTelephone2, 'adresTelephone2');
        System.assertEquals(queried.Telephone_3__c, record.adresTelephone3, 'adresTelephone3');
        System.assertEquals(queried.MobilePhone, record.adresNatel1, 'adresNatel1');
        System.assertEquals(queried.Mobile_2__c, record.adresNatel2, 'adresNatel2');
        System.assertEquals(queried.Email, record.adresEmail, 'adresEmail');
        System.assertEquals(queried.Email_2__c, record.adresEmail2, 'adresEmail2');
        System.assertEquals(queried.SiteWeb__c, record.adresSiteWeb, 'adresSiteWeb');
        System.assertEquals(queried.Salutation, record.adresEntete, 'adresEntete');
        System.assertEquals(queried.ADRES_ID_entete_c__c, record.adresIdEntete, 'adresIdEntete');
        String expectedNpl = String.isNotBlank(queried.Adresse_Contact__PostalCode__s) ? queried.Adresse_Contact__PostalCode__s : queried.MailingPostalCode;
        System.assertEquals(expectedNpl, record.adresNpl, 'adresNpl');
        String expectedLieu = String.isNotBlank(queried.Adresse_Contact__City__s) ? queried.Adresse_Contact__City__s : queried.MailingCity;
        System.assertEquals(expectedLieu, record.adresLieu, 'adresLieu');
        String expectedPays = String.isNotBlank(queried.Adresse_Contact__CountryCode__s) ? queried.Adresse_Contact__CountryCode__s : queried.MailingCountry;
        System.assertEquals(expectedPays, record.adresPaysDescription, 'adresPaysDescription');
        System.assertEquals(expectedPays, record.adresPaysIdentification, 'adresPaysIdentification');
        System.assertEquals(queried.Title, record.adresTitre, 'adresTitre');
        System.assertEquals(queried.Department, record.adresDepartement, 'adresDepartement');
        System.assertEquals(queried.Langue__c, record.adresLangue, 'adresLangue');
        System.assertEquals(queried.Id, record.adresSalesforceId, 'adresSalesforceId');
        System.assertEquals(queried.AccountId, record.adresOrganSalesforceId, 'adresOrganSalesforceId');
    }

    @isTest
    static void testMapContactsToTrivisoRecords_EmptyAndNull() {
        List<TrivisoContactRecord> fromEmpty = TrivisoContactMapper.mapContactsToTrivisoRecords(new List<Contact>());
        System.assertEquals(0, fromEmpty.size(), 'empty list');
        List<TrivisoContactRecord> fromNull = TrivisoContactMapper.mapContactsToTrivisoRecords(null);
        System.assertEquals(0, fromNull.size(), 'null list');
    }

    @isTest
    static void testMapToExportRecord_AllFields() {
        TrivisoContactRecord record = new TrivisoContactRecord();
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
        record.adresOrganSalesforceId = 'ORGAN_SFID';
        Test.startTest();
        Map<String, String> exportRecord = TrivisoContactMapper.mapToExportRecord(record);
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
        System.assertEquals('ORGAN_SFID', exportRecord.get('ADRES_Organ_salesforce_ID'));
    }
}