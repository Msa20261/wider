@isTest
private class AddressProxyMapper_TEST {
    
    @isTest
    static void testMapFromCsvRecord_AllFields() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord();
        
        // Act
        Test.startTest();
        AddressProxyRecord record = AddressProxyMapper.mapFromCsvRecord(csvRecord);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, record, 'Record should not be null');
        System.assertEquals(csvRecord.ADRES_Tag, record.adresTag, 'adresTag should match');
        System.assertEquals(csvRecord.ADRES_ID, record.adresId, 'adresId should match');
        System.assertEquals(csvRecord.ADRES_Organisation_Identif, record.adresOrganisationIdentif, 'adresOrganisationIdentif should match');
        System.assertEquals(csvRecord.ADRES_Identification, record.adresIdentification, 'adresIdentification should match');
        System.assertEquals(csvRecord.ADRES_Date_creation, record.adresDateCreation, 'adresDateCreation should match');
        System.assertEquals(csvRecord.ADRES_Date_modif, record.adresDateModif, 'adresDateModif should match');
        System.assertEquals(csvRecord.ADRES_Date_inactive, record.adresDateInactive, 'adresDateInactive should match');
        System.assertEquals(csvRecord.ADRES_Nom, record.adresNom, 'adresNom should match');
        System.assertEquals(csvRecord.ADRES_Prenom, record.adresPrenom, 'adresPrenom should match');
        System.assertEquals(csvRecord.ADRES_Supplement, record.adresSupplement, 'adresSupplement should match');
        System.assertEquals(csvRecord.ADRES_Case_postale, record.adresCasePostale, 'adresCasePostale should match');
        System.assertEquals(csvRecord.ADRES_Rue, record.adresRue, 'adresRue should match');
        System.assertEquals(csvRecord.ADRES_Telephone1, record.adresTelephone1, 'adresTelephone1 should match');
        System.assertEquals(csvRecord.ADRES_Telephone2, record.adresTelephone2, 'adresTelephone2 should match');
        System.assertEquals(csvRecord.ADRES_Telephone3, record.adresTelephone3, 'adresTelephone3 should match');
        System.assertEquals(csvRecord.ADRES_Natel1, record.adresNatel1, 'adresNatel1 should match');
        System.assertEquals(csvRecord.ADRES_Natel2, record.adresNatel2, 'adresNatel2 should match');
        System.assertEquals(csvRecord.ADRES_Email, record.adresEmail, 'adresEmail should match');
        System.assertEquals(csvRecord.ADRES_Email2, record.adresEmail2, 'adresEmail2 should match');
        System.assertEquals(csvRecord.ADRES_Site_Web, record.adresSiteWeb, 'adresSiteWeb should match');
        System.assertEquals(csvRecord.ADRES_entete, record.adresEntete, 'adresEntete should match');
        System.assertEquals(csvRecord.ADRES_ID_entete, record.adresIdEntete, 'adresIdEntete should match');
        System.assertEquals(csvRecord.ADRES_TVA_intracom, record.adresTvaIntracom, 'adresTvaIntracom should match');
        System.assertEquals(csvRecord.ADRES_No_registre_commerce, record.adresNoRegistreCommerce, 'adresNoRegistreCommerce should match');
        System.assertEquals(csvRecord.ADRES_NPL, record.adresNpl, 'adresNpl should match');
        System.assertEquals(csvRecord.ADRES_Lieu, record.adresLieu, 'adresLieu should match');
        System.assertEquals(csvRecord.ADRES_PAYS_Description, record.adresPaysDescription, 'adresPaysDescription should match');
        System.assertEquals(csvRecord.ADRES_Titre, record.adresTitre, 'adresTitre should match');
        System.assertEquals(csvRecord.ADRES_Departement, record.adresDepartement, 'adresDepartement should match');
        System.assertEquals(csvRecord.ADRES_Langue, record.adresLangue, 'adresLangue should match');
        System.assertEquals(csvRecord.ADRES_No_EORI, record.adresNoEori, 'adresNoEori should match');
    }
    
    @isTest
    static void testMapFromCsvRecord_WithNullValues() {
        // Arrange
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord(
            new Map<String, Object>{
                'ADRES_Date_inactive' => null,
                'ADRES_Telephone3' => null,
                'ADRES_Natel2' => null
            }
        );
        
        // Act
        Test.startTest();
        AddressProxyRecord record = AddressProxyMapper.mapFromCsvRecord(csvRecord);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, record, 'Record should not be null');
        System.assertEquals(null, record.adresDateInactive, 'adresDateInactive should be null');
        System.assertEquals(null, record.adresTelephone3, 'adresTelephone3 should be null');
        System.assertEquals(null, record.adresNatel2, 'adresNatel2 should be null');
    }
    
    @isTest
    static void testMapToProxyAddress_AllFields() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord();
        
        // Act
        Test.startTest();
        Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, address, 'Address should not be null');
        System.assertEquals(record.adresTag, address.ADRES_Tag__c, 'ADRES_Tag__c should match');
        System.assertEquals(record.adresId, address.ADRESTriviso_ID__c, 'ADRESTriviso_ID__c should match');
        System.assertEquals(record.adresIdentification, address.ADRES_ID__c, 'ADRES_ID__c should match');
        System.assertEquals(record.adresOrganisationIdentif, address.ADRES_Organisation_Identif__c, 'ADRES_Organisation_Identif__c should match');
        System.assertEquals(record.adresIdentification, address.ADRES_Identification__c, 'ADRES_Identification__c should match');
        System.assertNotEquals(null, address.ADRES_Date_creation__c, 'ADRES_Date_creation__c should be parsed');
        System.assertNotEquals(null, address.ADRES_Date_modif__c, 'ADRES_Date_modif__c should be parsed');
        System.assertEquals(record.adresNom, address.ADRES_Nom__c, 'ADRES_Nom__c should match');
        System.assertEquals(record.adresPrenom, address.ADRES_Prenom__c, 'ADRES_Prenom__c should match');
        System.assertEquals(record.adresSupplement, address.ADRES_Supplement__c, 'ADRES_Supplement__c should match');
        System.assertEquals(record.adresCasePostale, address.ADRES_Case_postale__c, 'ADRES_Case_postale__c should match');
        System.assertEquals(record.adresRue, address.ADRES_Rue__c, 'ADRES_Rue__c should match');
        System.assertEquals(record.adresTelephone1, address.ADRES_Telephone1__c, 'ADRES_Telephone1__c should match');
        System.assertEquals(record.adresTelephone2, address.ADRES_Telephone2__c, 'ADRES_Telephone2__c should match');
        System.assertEquals(record.adresTelephone3, address.ADRES_Telephone3__c, 'ADRES_Telephone3__c should match');
        System.assertEquals(record.adresNatel1, address.ADRES_Natel1__c, 'ADRES_Natel1__c should match');
        System.assertEquals(record.adresNatel2, address.ADRES_Natel2__c, 'ADRES_Natel2__c should match');
        System.assertEquals(record.adresEmail, address.ADRES_Email__c, 'ADRES_Email__c should match');
        System.assertEquals(record.adresEmail2, address.ADRES_Email2__c, 'ADRES_Email2__c should match');
        System.assertEquals(record.adresSiteWeb, address.ADRES_Site_Web__c, 'ADRES_Site_Web__c should match');
        System.assertEquals(record.adresEntete, address.ADRES_entete__c, 'ADRES_entete__c should match');
        System.assertEquals(record.adresIdEntete, address.ADRES_ID_entete__c, 'ADRES_ID_entete__c should match');
        System.assertEquals(record.adresTvaIntracom, address.ADRES_TVA_intracom__c, 'ADRES_TVA_intracom__c should match');
        System.assertEquals(record.adresNoRegistreCommerce, address.ADRES_No_registre_commerce__c, 'ADRES_No_registre_commerce__c should match');
        System.assertEquals(record.adresNpl, address.ADRES_NPL__c, 'ADRES_NPL__c should match');
        System.assertEquals(record.adresLieu, address.ADRES_Lieu__c, 'ADRES_Lieu__c should match');
        System.assertEquals(record.adresPaysDescription, address.ADRES_PAYS_Description__c, 'ADRES_PAYS_Description__c should match');
        System.assertEquals(record.adresTitre, address.ADRES_Titre__c, 'ADRES_Titre__c should match');
        System.assertEquals(record.adresDepartement, address.ADRES_Departement__c, 'ADRES_Departement__c should match');
        System.assertEquals(record.adresLangue, address.ADRES_Langue__c, 'ADRES_Langue__c should match');
        System.assertEquals(record.adresNoEori, address.ADRES_No_EORI__c, 'ADRES_No_EORI__c should match');
        System.assertEquals(true, address.ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be true when no inactive date is provided');
        System.assertEquals('Reçu', address.Statut__c, 'Statut__c should be Reçu');
        System.assertEquals('Triviso', address.Source__c, 'Source__c should be Triviso');
        System.assertNotEquals(null, address.Date_Reception__c, 'Date_Reception__c should be set');
    }
    
    @isTest
    static void testMapToProxyAddress_DateTimeParsing() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord(
            new Map<String, Object>{
                'adresDateCreation' => '15.03.2024 14:30:00',
                'adresDateModif' => '20.06.2024 09:15:30',
                'adresDateInactive' => '01.12.2024 00:00:00'
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, address.ADRES_Date_creation__c, 'ADRES_Date_creation__c should be parsed');
        System.assertEquals(2024, address.ADRES_Date_creation__c.year(), 'Year should be 2024');
        System.assertEquals(3, address.ADRES_Date_creation__c.month(), 'Month should be 3');
        System.assertEquals(15, address.ADRES_Date_creation__c.day(), 'Day should be 15');
        System.assertEquals(14, address.ADRES_Date_creation__c.hour(), 'Hour should be 14');
        System.assertEquals(30, address.ADRES_Date_creation__c.minute(), 'Minute should be 30');
        
        System.assertNotEquals(null, address.ADRES_Date_modif__c, 'ADRES_Date_modif__c should be parsed');
        System.assertEquals(2024, address.ADRES_Date_modif__c.year(), 'Year should be 2024');
        System.assertEquals(6, address.ADRES_Date_modif__c.month(), 'Month should be 6');
        System.assertEquals(20, address.ADRES_Date_modif__c.day(), 'Day should be 20');
        
        System.assertNotEquals(null, address.ADRES_Date_inactive__c, 'ADRES_Date_inactive__c should be parsed');
        System.assertEquals(false, address.ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be false when inactive date is provided');
    }
    
    @isTest
    static void testMapToProxyAddress_WithNullDates() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord(
            new Map<String, Object>{
                'adresDateCreation' => null,
                'adresDateModif' => null,
                'adresDateInactive' => null
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, address.ADRES_Date_creation__c, 'ADRES_Date_creation__c should be null');
        System.assertEquals(null, address.ADRES_Date_modif__c, 'ADRES_Date_modif__c should be null');
        System.assertEquals(null, address.ADRES_Date_inactive__c, 'ADRES_Date_inactive__c should be null');
        System.assertEquals(true, address.ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be true when inactive date is null');
    }
    
    @isTest
    static void testMapToProxyAddress_WithBlankDates() {
        // Arrange
        AddressProxyRecord record = TrivisoDataFactory.createAddressProxyRecord(
            new Map<String, Object>{
                'adresDateCreation' => '',
                'adresDateModif' => '   ',
                'adresDateInactive' => ''
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, address.ADRES_Date_creation__c, 'ADRES_Date_creation__c should be null for blank string');
        System.assertEquals(null, address.ADRES_Date_modif__c, 'ADRES_Date_modif__c should be null for blank string');
        System.assertEquals(null, address.ADRES_Date_inactive__c, 'ADRES_Date_inactive__c should be null for blank string');
        System.assertEquals(true, address.ADRES_Date_inactive_2__c, 'ADRES_Date_inactive_2__c should be true for blank inactive date');
    }
    
    @isTest
    static void testMapToCsvRecord_AllFields() {
        // Arrange
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_Date_creation__c = Datetime.newInstance(2024, 3, 15, 14, 30, 0);
        address.ADRES_Date_modif__c = Datetime.newInstance(2024, 6, 20, 9, 15, 30);
        address.ADRES_Date_inactive__c = Datetime.newInstance(2024, 12, 1, 0, 0, 0);
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = AddressProxyMapper.mapToCsvRecord(address);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, csvRecord, 'CSV record should not be null');
        System.assertEquals(address.ADRES_Tag__c, csvRecord.get('ADRES_Tag'), 'ADRES_Tag should match');
        System.assertEquals(address.ADRES_ID__c, csvRecord.get('ADRES_ID'), 'ADRES_ID should match');
        System.assertEquals(address.ADRES_Organisation_Identif__c, csvRecord.get('ADRES_Organisation_Identif'), 'ADRES_Organisation_Identif should match');
        System.assertEquals(address.ADRES_Identification__c, csvRecord.get('ADRES_Identification'), 'ADRES_Identification should match');
        System.assert(csvRecord.get('ADRES_Date_creation').contains('15.03.2024'), 'ADRES_Date_creation should contain date');
        System.assert(csvRecord.get('ADRES_Date_creation').contains('14:30:00'), 'ADRES_Date_creation should contain time');
        System.assert(csvRecord.get('ADRES_Date_modif').contains('20.06.2024'), 'ADRES_Date_modif should contain date');
        System.assert(csvRecord.get('ADRES_Date_modif').contains('09:15:30'), 'ADRES_Date_modif should contain time');
        System.assertEquals(address.ADRES_Nom__c, csvRecord.get('ADRES_Nom'), 'ADRES_Nom should match');
        System.assertEquals(address.ADRES_Prenom__c, csvRecord.get('ADRES_Prenom'), 'ADRES_Prenom should match');
        System.assertEquals(address.ADRES_Supplement__c, csvRecord.get('ADRES_Supplement'), 'ADRES_Supplement should match');
        System.assertEquals(address.ADRES_Case_postale__c, csvRecord.get('ADRES_Case_postale'), 'ADRES_Case_postale should match');
        System.assertEquals(address.ADRES_Rue__c, csvRecord.get('ADRES_Rue'), 'ADRES_Rue should match');
        System.assertEquals(address.ADRES_Telephone1__c, csvRecord.get('ADRES_Telephone1'), 'ADRES_Telephone1 should match');
        System.assertEquals(address.ADRES_Email__c, csvRecord.get('ADRES_Email'), 'ADRES_Email should match');
        System.assertEquals(address.ADRES_Site_Web__c, csvRecord.get('ADRES_Site_Web'), 'ADRES_Site_Web should match');
        System.assertEquals(address.ADRES_TVA_intracom__c, csvRecord.get('ADRES_TVA_intracom'), 'ADRES_TVA_intracom should match');
        System.assertEquals(address.ADRES_Lieu__c, csvRecord.get('ADRES_Lieu'), 'ADRES_Lieu should match');
        System.assertEquals(address.ADRES_PAYS_Description__c, csvRecord.get('ADRES_PAYS_Description'), 'ADRES_PAYS_Description should match');
    }
    
    @isTest
    static void testMapToCsvRecord_WithNullValues() {
        // Arrange
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_Date_creation__c = null;
        address.ADRES_Date_modif__c = null;
        address.ADRES_Date_inactive__c = null;
        address.ADRES_Telephone3__c = null;
        address.ADRES_Natel2__c = null;
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = AddressProxyMapper.mapToCsvRecord(address);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, csvRecord, 'CSV record should not be null');
        System.assertEquals('', csvRecord.get('ADRES_Date_creation'), 'ADRES_Date_creation should be empty string for null');
        System.assertEquals('', csvRecord.get('ADRES_Date_modif'), 'ADRES_Date_modif should be empty string for null');
        System.assertEquals('', csvRecord.get('ADRES_Date_inactive'), 'ADRES_Date_inactive should be empty string for null');
        System.assertEquals('', csvRecord.get('ADRES_Telephone3'), 'ADRES_Telephone3 should be empty string for null');
        System.assertEquals('', csvRecord.get('ADRES_Natel2'), 'ADRES_Natel2 should be empty string for null');
    }
    
    @isTest
    static void testMapToCsvRecord_DateTimeFormatting() {
        // Arrange
        Proxy_Address__c address = TrivisoDataFactory.createProxyAddress();
        address.ADRES_Date_creation__c = Datetime.newInstance(2024, 1, 5, 8, 3, 7);
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = AddressProxyMapper.mapToCsvRecord(address);
        Test.stopTest();
        
        // Assert
        String dateStr = csvRecord.get('ADRES_Date_creation');
        System.assert(dateStr.contains('05.01.2024'), 'Should contain formatted date');
        System.assert(dateStr.contains('08:03:07'), 'Should contain formatted time');
    }
    
    @isTest
    static void testRoundTripMapping() {
        // Arrange - Start with CSV record
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createAddressCsvRecord();
        
        // Act - Map CSV -> Record -> Address -> CSV
        Test.startTest();
        AddressProxyRecord record = AddressProxyMapper.mapFromCsvRecord(csvRecord);
        Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
        Map<String, String> resultCsvRecord = AddressProxyMapper.mapToCsvRecord(address);
        Test.stopTest();
        
        // Assert - Verify key fields match
        // Après le remap : ADRES_ID__c reçoit ADRES_Identification, donc l'export CSV 'ADRES_ID' = ADRES_Identification
        System.assertEquals(csvRecord.ADRES_Identification, resultCsvRecord.get('ADRES_ID'), 'ADRES_ID in export CSV should match ADRES_Identification after round trip');
        System.assertEquals(csvRecord.ADRES_Nom, resultCsvRecord.get('ADRES_Nom'), 'ADRES_Nom should match after round trip');
        System.assertEquals(csvRecord.ADRES_Prenom, resultCsvRecord.get('ADRES_Prenom'), 'ADRES_Prenom should match after round trip');
        System.assertEquals(csvRecord.ADRES_Email, resultCsvRecord.get('ADRES_Email'), 'ADRES_Email should match after round trip');
        System.assertEquals(csvRecord.ADRES_Rue, resultCsvRecord.get('ADRES_Rue'), 'ADRES_Rue should match after round trip');
    }
}