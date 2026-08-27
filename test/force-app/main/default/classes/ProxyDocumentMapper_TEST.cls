@isTest
private class ProxyDocumentMapper_TEST {

    @isTest
    static void testMapToProxyDocument_AllFields() {
        TrivisoDocumentExport.CsvRecordDeserializer csvRecord = new TrivisoDocumentExport.CsvRecordDeserializer();
        csvRecord.ID_Journal_commande = 'JOURNAL_1';
        csvRecord.ID_Saisie_commande = 'SAISIE_1';
        csvRecord.DOC_Projet_ID = 'PROJET_1';
        csvRecord.DOC_No_ref = 'REF_1';
        csvRecord.DOC_Lien_doc = 'https://example.com/doc1';
        csvRecord.DOC_Date_creation = '15.03.2024';
        csvRecord.DOC_Date_modif = '20.06.2024';
        csvRecord.DOC_Identification = 'IDENT_1';
        csvRecord.DOC_Description = 'Description';
        csvRecord.DOC_Paye_TTC = '100.50';
        csvRecord.DOC_Montant_HT = '80.00';
        csvRecord.DOC_Montant_TTC = '120.00';
        csvRecord.DOC_Brouillon = '0';
        csvRecord.DOC_DEB_Date_creation = '01.01.2024';
        csvRecord.DOC_DEB_Resp_creation = 'User A';
        csvRecord.DOC_DEB_Doc_suppr = '0';
        csvRecord.DOC_DEB_No_ecriture = 'ECR_1';
        csvRecord.DOC_Genre_document = 'Type A';
        csvRecord.DOC_Condition_paiement = '30J';
        csvRecord.DOC_Etat_doc = 'Ouvert';
        csvRecord.DOC_Etat_Pond = '1';
        csvRecord.DOC_DEB_Montant = '200.00';
        csvRecord.DOC_DEB_Monnaie = 'CHF';
        csvRecord.DOC_DEB_Solde_a_paye_CHF = '50.00';
        csvRecord.DOC_DEB_Solde_a_paye_ME = '0.00';
        csvRecord.DOC_DEB_Echeance_adapte = '31.12.2024';
        csvRecord.DOC_ADR_DEST_ID = 'ADR_1';
        csvRecord.DOC_ADR_DEST_Nom_Prenom = 'Nom Prenom';

        Test.startTest();
        Proxy_Document__c document = ProxyDocumentMapper.mapToProxyDocument(csvRecord);
        Test.stopTest();

        System.assertNotEquals(null, document);
        System.assertEquals(csvRecord.ID_Journal_commande, document.ID_Journal_commande__c);
        System.assertEquals(csvRecord.ID_Saisie_commande, document.ID_Saisie_commande__c);
        System.assertEquals(csvRecord.DOC_Projet_ID, document.DOC_Projet_ID__c);
        System.assertEquals(csvRecord.DOC_No_ref, document.DOC_No_ref__c);
        System.assertEquals(csvRecord.DOC_Lien_doc, document.DOC_Lien_doc__c);
        System.assertEquals(Date.newInstance(2024, 3, 15), document.DOC_Date_creation__c);
        System.assertEquals(Date.newInstance(2024, 6, 20), document.DOC_Date_modif__c);
        System.assertEquals(csvRecord.DOC_Identification, document.DOC_Identification__c);
        System.assertEquals(csvRecord.DOC_Description, document.DOC_Description__c);
        System.assertEquals(100.50, document.DOC_Paye_TTC__c);
        System.assertEquals(80.00, document.DOC_Montant_HT__c);
        System.assertEquals(120.00, document.DOC_Montant_TTC__c);
        System.assertEquals(0, document.DOC_Brouillon__c);
        System.assertEquals(Date.newInstance(2024, 1, 1), document.DOC_DEB_Date_creation__c);
        System.assertEquals(csvRecord.DOC_DEB_Resp_creation, document.DOC_DEB_Resp_creation__c);
        System.assertEquals(0, document.DOC_DEB_Doc_suppr__c);
        System.assertEquals(csvRecord.DOC_DEB_No_ecriture, document.DOC_DEB_No_ecriture__c);
        System.assertEquals(csvRecord.DOC_Genre_document, document.DOC_Genre_document__c);
        System.assertEquals(csvRecord.DOC_Condition_paiement, document.DOC_Condition_paiement__c);
        System.assertEquals(csvRecord.DOC_Etat_doc, document.DOC_Etat_doc__c);
        System.assertEquals(1, document.DOC_Etat_Pond__c);
        System.assertEquals(200.00, document.DOC_DEB_Montant__c);
        System.assertEquals(csvRecord.DOC_DEB_Monnaie, document.DOC_DEB_Monnaie__c);
        System.assertEquals(50.00, document.DOC_DEB_Solde_a_paye_CHF__c);
        System.assertEquals(0.00, document.DOC_DEB_Solde_a_paye_ME__c);
        System.assertEquals(Date.newInstance(2024, 12, 31), document.DOC_DEB_Echeance_adapte__c);
        System.assertEquals(csvRecord.DOC_ADR_DEST_Nom_Prenom, document.DOC_ADR_DEST_Nom_Prenom__c);
    }

    @isTest
    static void testMapToProxyDocument_NullAndBlankValues() {
        TrivisoDocumentExport.CsvRecordDeserializer csvRecord = new TrivisoDocumentExport.CsvRecordDeserializer();
        csvRecord.DOC_Date_creation = '';
        csvRecord.DOC_Date_modif = '   ';
        csvRecord.DOC_Paye_TTC = null;
        csvRecord.DOC_Montant_HT = '';
        csvRecord.DOC_Montant_TTC = '   ';
        csvRecord.DOC_Brouillon = null;
        csvRecord.DOC_DEB_Date_creation = null;
        csvRecord.DOC_DEB_Doc_suppr = '';
        csvRecord.DOC_Etat_Pond = null;
        csvRecord.DOC_DEB_Montant = '';
        csvRecord.DOC_DEB_Solde_a_paye_CHF = null;
        csvRecord.DOC_DEB_Solde_a_paye_ME = '';
        csvRecord.DOC_DEB_Echeance_adapte = null;

        Test.startTest();
        Proxy_Document__c document = ProxyDocumentMapper.mapToProxyDocument(csvRecord);
        Test.stopTest();

        System.assertEquals(null, document.DOC_Date_creation__c);
        System.assertEquals(null, document.DOC_Date_modif__c);
        System.assertEquals(null, document.DOC_Paye_TTC__c);
        System.assertEquals(null, document.DOC_Montant_HT__c);
        System.assertEquals(null, document.DOC_Montant_TTC__c);
        System.assertEquals(null, document.DOC_Brouillon__c);
        System.assertEquals(null, document.DOC_DEB_Date_creation__c);
        System.assertEquals(null, document.DOC_DEB_Doc_suppr__c);
        System.assertEquals(null, document.DOC_Etat_Pond__c);
        System.assertEquals(null, document.DOC_DEB_Montant__c);
        System.assertEquals(null, document.DOC_DEB_Solde_a_paye_CHF__c);
        System.assertEquals(null, document.DOC_DEB_Solde_a_paye_ME__c);
        System.assertEquals(null, document.DOC_DEB_Echeance_adapte__c);
    }
}