@isTest
private class ProxyDocument_TEST {

    private static TrivisoDocumentExport.CsvRecordDeserializer createCsvRecord(Integer index) {
        TrivisoDocumentExport.CsvRecordDeserializer csv = new TrivisoDocumentExport.CsvRecordDeserializer();
        csv.ID_Journal_commande = 'JOURNAL_' + String.valueOf(index);
        csv.ID_Saisie_commande = 'SAISIE_' + String.valueOf(index);
        csv.DOC_Projet_ID = 'PROJET_' + String.valueOf(index);
        csv.DOC_No_ref = 'REF_' + String.valueOf(index);
        csv.DOC_Lien_doc = 'https://example.com/doc' + String.valueOf(index);
        csv.DOC_Date_creation = '01.01.2024';
        csv.DOC_Date_modif = '02.01.2024';
        csv.DOC_Identification = 'IDENT_' + String.valueOf(index);
        csv.DOC_Description = 'Description ' + String.valueOf(index);
        csv.DOC_Paye_TTC = '10' + String.valueOf(index) + '.00';
        csv.DOC_Montant_HT = '5' + String.valueOf(index) + '.00';
        csv.DOC_Montant_TTC = '15' + String.valueOf(index) + '.00';
        csv.DOC_Brouillon = '0';
        csv.DOC_DEB_Date_creation = '03.01.2024';
        csv.DOC_DEB_Resp_creation = 'User_' + String.valueOf(index);
        csv.DOC_DEB_Doc_suppr = '0';
        csv.DOC_DEB_No_ecriture = 'ECR_' + String.valueOf(index);
        csv.DOC_Genre_document = 'Type_' + String.valueOf(index);
        csv.DOC_Condition_paiement = '30J';
        csv.DOC_Etat_doc = 'Ouvert';
        csv.DOC_Etat_Pond = '1';
        csv.DOC_DEB_Montant = '20' + String.valueOf(index) + '.00';
        csv.DOC_DEB_Monnaie = 'CHF';
        csv.DOC_DEB_Solde_a_paye_CHF = '5' + String.valueOf(index) + '.00';
        csv.DOC_DEB_Solde_a_paye_ME = '0.00';
        csv.DOC_DEB_Echeance_adapte = '31.12.2024';
        csv.DOC_ADR_DEST_ID = 'ADR_' + String.valueOf(index);
        csv.DOC_ADR_DEST_Nom_Prenom = 'Nom Prenom ' + String.valueOf(index);
        return csv;
    }

    @isTest
    static void testBuildProxyDocuments_SingleRecord() {
        TrivisoDocumentExport.CsvRecordDeserializer csv = createCsvRecord(1);
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>{ csv };

        Test.startTest();
        List<Proxy_Document__c> documents = ProxyDocument.buildProxyDocuments(csvRecords);
        Test.stopTest();

        System.assertEquals(1, documents.size());
        Proxy_Document__c doc = documents[0];
        System.assertEquals(csv.ID_Journal_commande, doc.ID_Journal_commande__c);
        System.assertEquals(csv.DOC_No_ref, doc.DOC_No_ref__c);
        System.assertEquals(csv.DOC_Description, doc.DOC_Description__c);
    }

    @isTest
    static void testBuildProxyDocuments_MultipleRecords() {
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>();
        for (Integer i = 1; i <= 3; i++) {
            csvRecords.add(createCsvRecord(i));
        }

        Test.startTest();
        List<Proxy_Document__c> documents = ProxyDocument.buildProxyDocuments(csvRecords);
        Test.stopTest();

        System.assertEquals(3, documents.size());
        for (Integer i = 0; i < documents.size(); i++) {
            System.assertEquals('JOURNAL_' + String.valueOf(i + 1), documents[i].ID_Journal_commande__c);
        }
    }

    @isTest
    static void testBuildProxyDocuments_EmptyList() {
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>();

        Test.startTest();
        List<Proxy_Document__c> documents = ProxyDocument.buildProxyDocuments(csvRecords);
        Test.stopTest();

        System.assertEquals(0, documents.size());
    }

    @isTest
    static void testInsertDocuments_Success() {
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>();
        for (Integer i = 1; i <= 3; i++) {
            csvRecords.add(createCsvRecord(i));
        }
        List<Proxy_Document__c> documents = ProxyDocument.buildProxyDocuments(csvRecords);

        Test.startTest();
        Database.SaveResult[] results = ProxyDocument.insertDocuments(documents);
        Test.stopTest();

        System.assertEquals(3, results.size());
        Integer successCount = 0;
        for (Database.SaveResult r : results) {
            if (r.isSuccess()) {
                successCount++;
            }
        }
        System.assertEquals(3, successCount);

        List<Proxy_Document__c> inserted = [
            SELECT Id, ID_Journal_commande__c
            FROM Proxy_Document__c
            WHERE ID_Journal_commande__c LIKE 'JOURNAL_%'
            ORDER BY ID_Journal_commande__c
        ];
        System.assertEquals(3, inserted.size());
    }
}