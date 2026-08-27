@isTest
private class ProjetProxyMapper_TEST {
    
    @isTest
    static void testMapFromCsvRecord_AllFields() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        
        // Act
        Test.startTest();
        ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRecord(csvRecord);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, record, 'Record should not be null');
        System.assertEquals(csvRecord.SAIS_COM_ID, record.idProjetTriviso, 'idProjetTriviso should match');
        System.assertEquals(csvRecord.SAIS_COM_Identification, record.numeroProjet, 'numeroProjet should match');
        System.assertEquals(csvRecord.SAIS_COM_Description, record.nomProjet, 'nomProjet should match');
        System.assertEquals(csvRecord.SAIS_COM_No_Comm_client, record.referenceClient, 'referenceClient should match');
        System.assertEquals(csvRecord.SAIS_COM_Etat_ID, record.idEtapeProjet, 'idEtapeProjet should match');
        System.assertEquals(csvRecord.SAIS_COM_Genre_projet, record.genreProjet, 'genreProjet should match');
        System.assertEquals(csvRecord.SAIS_COM_Fam_Designation != null ? csvRecord.SAIS_COM_Fam_Designation : '', record.familleCommerciale, 'familleCommerciale should match');
        System.assertEquals(csvRecord.SAIS_COM_Date_ouvert, record.dateOuvertureProjet, 'dateOuvertureProjet should match');
        System.assertEquals(csvRecord.SAIS_COM_Date_Modif, record.dateDerniereModification, 'dateDerniereModification should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_FACT_ID, record.compteFacturationTrivisoId, 'compteFacturationTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_LIVR_ID, record.compteLivraisonTrivisoId, 'compteLivraisonTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_MO_ID, record.compteMaitreOuvrageTrivisoId, 'compteMaitreOuvrageTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_ARCH_ID, record.compteArchitecteTrivisoId, 'compteArchitecteTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_FACT_CONTACT_ID, record.facturationContactId, 'facturationContactId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_LIVR_CONTACT_ID, record.adresseLivraison2ContactId, 'adresseLivraison2ContactId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_MO_CONTACT_ID, record.maitreOuvrageContactId, 'maitreOuvrageContactId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_ARCH_CONTACT_ID, record.architecteEGContactId, 'architecteEGContactId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_RESP_ID, record.compteResponsableCommercialTrivisoId, 'compteResponsableCommercialTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_MAND_ID, record.compteMandantTrivisoId, 'compteMandantTrivisoId should match');
        System.assertEquals(csvRecord.SAIS_COM_ADR_RESP_PROJ_ID, record.compteResponsableProjetTrivisoId, 'compteResponsableProjetTrivisoId should match');
        System.assertNotEquals(null, record.montantNetSansProvision, 'montantNetSansProvision should be parsed');
        System.assertNotEquals(null, record.montantNetAvecProvision, 'montantNetAvecProvision should be parsed');
        System.assertNotEquals(null, record.montantOffert, 'montantOffert should be parsed');
        System.assertNotEquals(null, record.montantConfirme, 'montantConfirme should be parsed');
    }
    
    @isTest
    static void testMapFromCsvRecord_WithNullValues() {
        // Arrange
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord(
            new Map<String, Object>{
                'SAIS_COM_Date_Modif' => null,
                'SAIS_COM_SOM_Prix_revient_sans_provision' => null,
                'SAIS_COM_SOM_Offert' => null
            }
        );
        
        // Act
        Test.startTest();
        ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRecord(csvRecord);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, record, 'Record should not be null');
        System.assertEquals(null, record.dateDerniereModification, 'dateDerniereModification should be null');
        System.assertEquals(null, record.montantNetSansProvision, 'montantNetSansProvision should be null');
        System.assertEquals(null, record.montantOffert, 'montantOffert should be null');
    }
    
    @isTest
    static void testMapToProxyProjet_AllFields() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord();
        
        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, projet, 'Projet should not be null');
        System.assertEquals(record.idProjetTriviso, projet.ID_Projet_Triviso__c, 'ID_Projet_Triviso__c should match');
        System.assertEquals(record.numeroProjet, projet.Numero_Projet__c, 'Numero_Projet__c should match');
        System.assertEquals(record.nomProjet, projet.Nom_Projet__c, 'Nom_Projet__c should match');
        System.assertEquals(record.referenceClient, projet.Reference_Client__c, 'Reference_Client__c should match');
        System.assertEquals(record.idEtapeProjet, projet.ID_Etape_Projet__c, 'ID_Etape_Projet__c should match');
        System.assertEquals(record.genreProjet, projet.Genre_Projet__c, 'Genre_Projet__c should match');
        System.assertEquals(record.familleCommerciale, projet.Famille_Commerciale__c, 'Famille_Commerciale__c should match');
        System.assertNotEquals(null, projet.Date_Ouverture_Projet__c, 'Date_Ouverture_Projet__c should be parsed');
        System.assertNotEquals(null, projet.Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be parsed');
        System.assertEquals(record.compteFacturationTrivisoId, projet.Compte_Facturation_Triviso_ID__c, 'Compte_Facturation_Triviso_ID__c should match');
        System.assertEquals(record.compteLivraisonTrivisoId, projet.Compte_Livraison_Triviso_ID__c, 'Compte_Livraison_Triviso_ID__c should match');
        System.assertEquals(record.compteMaitreOuvrageTrivisoId, projet.Compte_Maitre_Ouvrage_Triviso_ID__c, 'Compte_Maitre_Ouvrage_Triviso_ID__c should match');
        System.assertEquals(record.compteArchitecteTrivisoId, projet.Compte_Architecte_Triviso_ID__c, 'Compte_Architecte_Triviso_ID__c should match');
        System.assertEquals(record.facturationContactId, projet.Facturation_Contact__c, 'Facturation_Contact__c should match');
        System.assertEquals(record.adresseLivraison2ContactId, projet.Adresse_de_Livraison_2__c, 'Adresse_de_Livraison_2__c should match');
        System.assertEquals(record.maitreOuvrageContactId, projet.Maitre_d_ouvrage_Contact__c, 'Maitre_d_ouvrage_Contact__c should match');
        System.assertEquals(record.architecteEGContactId, projet.Architecte_EG_Contact__c, 'Architecte_EG_Contact__c should match');
        System.assertEquals(record.compteResponsableCommercialTrivisoId, projet.Compte_Responsable_Commercial_Triviso_ID__c, 'Compte_Responsable_Commercial_Triviso_ID__c should match');
        System.assertEquals(record.compteMandantTrivisoId, projet.Compte_Mandant_Triviso_ID__c, 'Compte_Mandant_Triviso_ID__c should match');
        System.assertEquals(record.compteResponsableProjetTrivisoId, projet.Compte_Responsable_Projet_Triviso_ID__c, 'Compte_Responsable_Projet_Triviso_ID__c should match');
        System.assertNotEquals(null, projet.Montant_Net_Sans_Provision__c, 'Montant_Net_Sans_Provision__c should be parsed');
        System.assertNotEquals(null, projet.Montant_Net_Avec_Provision__c, 'Montant_Net_Avec_Provision__c should be parsed');
        System.assertNotEquals(null, projet.Montant_Offert__c, 'Montant_Offert__c should be parsed');
        System.assertNotEquals(null, projet.Montant_Confirme__c, 'Montant_Confirme__c should be parsed');
        System.assertEquals('Reçu', projet.Statut__c, 'Statut__c should be Reçu');
        System.assertEquals('Triviso', projet.Source__c, 'Source__c should be Triviso');
        System.assertNotEquals(null, projet.Date_Reception__c, 'Date_Reception__c should be set');
    }
    
    @isTest
    static void testMapToProxyProjet_DateParsing() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord(
            new Map<String, Object>{
                'dateOuvertureProjet' => '15.03.2024',
                'dateDerniereModification' => '20.06.2024'
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, projet.Date_Ouverture_Projet__c, 'Date_Ouverture_Projet__c should be parsed');
        System.assertEquals(2024, projet.Date_Ouverture_Projet__c.year(), 'Year should be 2024');
        System.assertEquals(3, projet.Date_Ouverture_Projet__c.month(), 'Month should be 3');
        System.assertEquals(15, projet.Date_Ouverture_Projet__c.day(), 'Day should be 15');
        
        System.assertNotEquals(null, projet.Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be parsed');
        System.assertEquals(2024, projet.Date_Derniere_Modification__c.year(), 'Year should be 2024');
        System.assertEquals(6, projet.Date_Derniere_Modification__c.month(), 'Month should be 6');
        System.assertEquals(20, projet.Date_Derniere_Modification__c.day(), 'Day should be 20');
    }
    
    @isTest
    static void testMapToProxyProjet_WithNullDates() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord(
            new Map<String, Object>{
                'dateOuvertureProjet' => null,
                'dateDerniereModification' => null
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, projet.Date_Ouverture_Projet__c, 'Date_Ouverture_Projet__c should be null');
        System.assertEquals(null, projet.Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be null');
    }
    
    @isTest
    static void testMapToProxyProjet_WithBlankDates() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord(
            new Map<String, Object>{
                'dateOuvertureProjet' => '',
                'dateDerniereModification' => '   '
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, projet.Date_Ouverture_Projet__c, 'Date_Ouverture_Projet__c should be null for blank string');
        System.assertEquals(null, projet.Date_Derniere_Modification__c, 'Date_Derniere_Modification__c should be null for blank string');
    }
    
    @isTest
    static void testMapToProxyProjet_DecimalParsing() {
        // Arrange
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord(
            new Map<String, Object>{
                'montantNetSansProvision' => '150000.50',
                'montantOffert' => 125000.75,
                'montantConfirme' => null
            }
        );
        
        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();
        
        // Assert
        System.assertEquals(150000.50, projet.Montant_Net_Sans_Provision__c, 'Montant_Net_Sans_Provision__c should be parsed');
        System.assertEquals(125000.75, projet.Montant_Offert__c, 'Montant_Offert__c should be parsed');
        System.assertEquals(null, projet.Montant_Confirme__c, 'Montant_Confirme__c should be null');
    }
    
    @isTest
    static void testMapToCsvRecord_AllFields() {
        // Arrange
        Proxy_Projet__c projet = TrivisoDataFactory.createProxyProjet();
        projet.Date_Ouverture_Projet__c = Date.newInstance(2024, 3, 15);
        projet.Date_Derniere_Modification__c = Date.newInstance(2024, 6, 20);
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = ProjetProxyMapper.mapToCsvRecord(projet);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, csvRecord, 'CSV record should not be null');
        System.assertEquals(projet.ID_Projet_Triviso__c, csvRecord.get('SAIS_COM_ID'), 'SAIS_COM_ID should match');
        System.assertEquals(projet.Numero_Projet__c, csvRecord.get('SAIS_COM_Identification'), 'SAIS_COM_Identification should match');
        System.assertEquals(projet.Nom_Projet__c, csvRecord.get('SAIS_COM_Description'), 'SAIS_COM_Description should match');
        System.assertEquals(projet.Reference_Client__c, csvRecord.get('SAIS_COM_No_Comm_client'), 'SAIS_COM_No_Comm_client should match');
        System.assertEquals(projet.ID_Etape_Projet__c, csvRecord.get('SAIS_COM_Etat_ID'), 'SAIS_COM_Etat_ID should match');
        System.assertEquals(projet.Genre_Projet__c, csvRecord.get('SAIS_COM_Genre_projet'), 'SAIS_COM_Genre_projet should match');
        System.assertEquals(projet.Famille_Commerciale__c, csvRecord.get('SAIS_COM_Fam_Désignation'), 'SAIS_COM_Fam_Désignation should match');
        System.assert(csvRecord.get('SAIS_COM_Date_ouvert').contains('15.03.2024'), 'SAIS_COM_Date_ouvert should contain date');
        System.assert(csvRecord.get('SAIS_COM_Date_Modif').contains('20.06.2024'), 'SAIS_COM_Date_Modif should contain date');
        System.assertEquals(projet.Compte_Facturation_Triviso_ID__c, csvRecord.get('SAIS_COM_ADR_FACT_ID'), 'SAIS_COM_ADR_FACT_ID should match');
        System.assertEquals(String.valueOf(projet.Montant_Net_Sans_Provision__c), csvRecord.get('SAIS_COM_SOM_Prix_revient_sans_provision'), 'SAIS_COM_SOM_Prix_revient_sans_provision should match');
        System.assertEquals(String.valueOf(projet.Montant_Offert__c), csvRecord.get('SAIS_COM_SOM_Offert'), 'SAIS_COM_SOM_Offert should match');
    }
    
    @isTest
    static void testMapToCsvRecord_WithNullValues() {
        // Arrange
        Proxy_Projet__c projet = TrivisoDataFactory.createProxyProjet();
        projet.Date_Ouverture_Projet__c = null;
        projet.Date_Derniere_Modification__c = null;
        projet.Montant_Net_Sans_Provision__c = null;
        projet.Montant_Offert__c = null;
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = ProjetProxyMapper.mapToCsvRecord(projet);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, csvRecord, 'CSV record should not be null');
        System.assertEquals('', csvRecord.get('SAIS_COM_Date_ouvert'), 'SAIS_COM_Date_ouvert should be empty string for null');
        System.assertEquals('', csvRecord.get('SAIS_COM_Date_Modif'), 'SAIS_COM_Date_Modif should be empty string for null');
        System.assertEquals('', csvRecord.get('SAIS_COM_SOM_Prix_revient_sans_provision'), 'SAIS_COM_SOM_Prix_revient_sans_provision should be empty string for null');
        System.assertEquals('', csvRecord.get('SAIS_COM_SOM_Offert'), 'SAIS_COM_SOM_Offert should be empty string for null');
    }
    
    @isTest
    static void testMapToCsvRecord_DateFormatting() {
        // Arrange
        Proxy_Projet__c projet = TrivisoDataFactory.createProxyProjet();
        projet.Date_Ouverture_Projet__c = Date.newInstance(2024, 1, 5);
        
        // Act
        Test.startTest();
        Map<String, String> csvRecord = ProjetProxyMapper.mapToCsvRecord(projet);
        Test.stopTest();
        
        // Assert
        String dateStr = csvRecord.get('SAIS_COM_Date_ouvert');
        System.assert(dateStr.contains('05.01.2024'), 'Should contain formatted date');
        System.assert(dateStr.contains('00:00:00'), 'Should contain time');
    }
    
    @isTest
    static void testRoundTripMapping() {
        // Arrange - Start with CSV record
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = TrivisoDataFactory.createProjetCsvRecord();
        
        // Act - Map CSV -> Record -> Projet -> CSV
        Test.startTest();
        ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRecord(csvRecord);
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Map<String, String> resultCsvRecord = ProjetProxyMapper.mapToCsvRecord(projet);
        Test.stopTest();
        
        // Assert - Verify key fields match
        System.assertEquals(csvRecord.SAIS_COM_ID, resultCsvRecord.get('SAIS_COM_ID'), 'SAIS_COM_ID should match after round trip');
        System.assertEquals(csvRecord.SAIS_COM_Identification, resultCsvRecord.get('SAIS_COM_Identification'), 'SAIS_COM_Identification should match after round trip');
        System.assertEquals(csvRecord.SAIS_COM_Description, resultCsvRecord.get('SAIS_COM_Description'), 'SAIS_COM_Description should match after round trip');
        System.assertEquals(csvRecord.SAIS_COM_No_Comm_client, resultCsvRecord.get('SAIS_COM_No_Comm_client'), 'SAIS_COM_No_Comm_client should match after round trip');
    }

    @isTest
    static void testMapFromCsvRow_AllFields() {
        // Arrange - build a CSV header/row pair
        List<String> headers = new List<String>{
            'SAIS_COM_ID',
            'SAIS_COM_Identification',
            'SAIS_COM_Description',
            'SAIS_COM_No_Comm_client',
            'SAIS_COM_Etat_ID',
            'SAIS_COM_Genre_projet',
            'SAIS_COM_Fam_Désignation',
            'SAIS_COM_Date_ouvert',
            'SAIS_COM_Date_Modif',
            'SAIS_COM_SOM_Prix_revient_sans_provision',
            'SAIS_COM_SOM_Offert',
            'SAIS_COM_ADR_FACT_CONTACT_ID',
            'SAIS_COM_ADR_LIVR_CONTACT_ID',
            'SAIS_COM_ADR_MO_CONTACT_ID',
            'SAIS_COM_ADR_ARCH_CONTACT_ID'
        };
        List<String> row = new List<String>{
            'ROW_ID',
            'ROW_NUM',
            'Row Description',
            'ROW_REF',
            'ETAPE',
            'GENRE',
            'FAMILLE',
            '15.03.2024',
            '20.06.2024',
            '100000.00',
            '120000.00',
            'CONT_FACT_ROW',
            'CONT_LIVR_ROW',
            'CONT_MO_ROW',
            'CONT_ARCH_ROW'
        };

        // Act
        Test.startTest();
        ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRow(headers, row);
        Test.stopTest();

        // Assert
        System.assertEquals('ROW_ID', record.idProjetTriviso, 'idProjetTriviso should map from SAIS_COM_ID');
        System.assertEquals('ROW_NUM', record.numeroProjet, 'numeroProjet should map from SAIS_COM_Identification');
        System.assertEquals('Row Description', record.nomProjet, 'nomProjet should map from SAIS_COM_Description');
        System.assertEquals('ROW_REF', record.referenceClient, 'referenceClient should map from SAIS_COM_No_Comm_client');
        System.assertEquals('ETAPE', record.idEtapeProjet, 'idEtapeProjet should map');
        System.assertEquals('GENRE', record.genreProjet, 'genreProjet should map');
        System.assertEquals('FAMILLE', record.familleCommerciale, 'familleCommerciale should map');
        System.assertEquals('15.03.2024', record.dateOuvertureProjet, 'dateOuvertureProjet should map raw value');
        System.assertEquals('20.06.2024', record.dateDerniereModification, 'dateDerniereModification should map raw value');
        System.assertEquals(100000.00, record.montantNetSansProvision, 'montantNetSansProvision should be parsed from string');
        System.assertEquals(120000.00, record.montantOffert, 'montantOffert should be parsed from string');
        System.assertEquals('CONT_FACT_ROW', record.facturationContactId, 'facturationContactId should map from SAIS_COM_ADR_FACT_CONTACT_ID');
        System.assertEquals('CONT_LIVR_ROW', record.adresseLivraison2ContactId, 'adresseLivraison2ContactId should map from SAIS_COM_ADR_LIVR_CONTACT_ID');
        System.assertEquals('CONT_MO_ROW', record.maitreOuvrageContactId, 'maitreOuvrageContactId should map from SAIS_COM_ADR_MO_CONTACT_ID');
        System.assertEquals('CONT_ARCH_ROW', record.architecteEGContactId, 'architecteEGContactId should map from SAIS_COM_ADR_ARCH_CONTACT_ID');
    }

    @isTest
    static void testMapToProxyProjet_InvalidDateParsing() {
        // Arrange - use invalid date strings to hit the parseDate error handling
        ProjetProxyRecord record = TrivisoDataFactory.createProjetProxyRecord(
            new Map<String, Object>{
                'dateOuvertureProjet' => 'invalid-date',
                'dateDerniereModification' => '32.13.9999'
            }
        );

        // Act
        Test.startTest();
        Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
        Test.stopTest();

        // Assert - invalid dates should be ignored and result in null date fields
        System.assertEquals(null, projet.Date_Ouverture_Projet__c, 'Invalid dateOuvertureProjet should result in null');
        System.assertEquals(null, projet.Date_Derniere_Modification__c, 'Invalid dateDerniereModification should result in null');
    }

    @isTest
    static void testMapFromCsvRow_InvalidDecimal() {
        // Arrange - non numeric decimal strings to hit parseDecimal error handling
        List<String> headers = new List<String>{
            'SAIS_COM_ID',
            'SAIS_COM_SOM_Prix_revient_sans_provision',
            'SAIS_COM_SOM_Offert'
        };
        List<String> row = new List<String>{
            'DEC_ERR',
            'NOT_A_NUMBER',
            'ABC123'
        };

        // Act
        Test.startTest();
        ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRow(headers, row);
        Test.stopTest();

        // Assert - parseDecimal should swallow errors and return null
        System.assertEquals('DEC_ERR', record.idProjetTriviso, 'idProjetTriviso should still map');
        System.assertEquals(null, record.montantNetSansProvision, 'Invalid decimal string should map to null');
        System.assertEquals(null, record.montantOffert, 'Invalid decimal string should map to null');
    }
}