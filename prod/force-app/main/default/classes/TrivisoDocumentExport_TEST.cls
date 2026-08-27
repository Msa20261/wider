@isTest
private class TrivisoDocumentExport_TEST {

    private static TrivisoDocumentExport.CsvRecordDeserializer createDocumentCsvRecord() {
        TrivisoDocumentExport.CsvRecordDeserializer csv = new TrivisoDocumentExport.CsvRecordDeserializer();
        csv.ID_Journal_commande = 'DOC_JOURNAL_1';
        csv.ID_Saisie_commande = 'DOC_SAISIE_1';
        csv.DOC_Projet_ID = 'DOC_PROJET_1';
        csv.DOC_No_ref = 'DOC_REF_1';
        csv.DOC_Lien_doc = 'https://example.com/doc1';
        csv.DOC_Date_creation = '15.03.2024';
        csv.DOC_Date_modif = '20.06.2024';
        csv.DOC_Identification = 'DOC_IDENT_1';
        csv.DOC_Description = 'Document Test';
        csv.DOC_Paye_TTC = '100.50';
        csv.DOC_Montant_HT = '80.00';
        csv.DOC_Montant_TTC = '120.00';
        csv.DOC_Brouillon = '0';
        csv.DOC_DEB_Date_creation = '01.01.2024';
        csv.DOC_DEB_Resp_creation = 'User A';
        csv.DOC_DEB_Doc_suppr = '0';
        csv.DOC_DEB_No_ecriture = 'ECR_1';
        csv.DOC_Genre_document = 'Type A';
        csv.DOC_Condition_paiement = '30J';
        csv.DOC_Etat_doc = 'Ouvert';
        csv.DOC_Etat_Pond = '1';
        csv.DOC_DEB_Montant = '200.00';
        csv.DOC_DEB_Monnaie = 'CHF';
        csv.DOC_DEB_Solde_a_paye_CHF = '50.00';
        csv.DOC_DEB_Solde_a_paye_ME = '0.00';
        csv.DOC_DEB_Echeance_adapte = '31.12.2024';
        csv.DOC_ADR_DEST_ID = 'ADR_1';
        csv.DOC_ADR_DEST_Nom_Prenom = 'Nom Prenom';
        return csv;
    }

    @isTest
    static void testHandleExport_SingleRecord() {
        TrivisoDocumentExport.CsvRecordDeserializer csv = createDocumentCsvRecord();
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>{ csv };
        String requestBody = JSON.serialize(csvRecords);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoDocumentExport.handleExport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody);

        TrivisoDocumentExport.ExportResponse exportResponse = (TrivisoDocumentExport.ExportResponse)JSON.deserialize(responseBody, TrivisoDocumentExport.ExportResponse.class);
        System.assertEquals(1, exportResponse.successCount);
        System.assertEquals(0, exportResponse.errorCount);

        List<Proxy_Document__c> inserted = [
            SELECT Id, ID_Journal_commande__c, DOC_No_ref__c, DOC_Description__c
            FROM Proxy_Document__c
            WHERE ID_Journal_commande__c = :csv.ID_Journal_commande
        ];
        System.assertEquals(1, inserted.size());
        System.assertEquals(csv.DOC_No_ref, inserted[0].DOC_No_ref__c);
        System.assertEquals(csv.DOC_Description, inserted[0].DOC_Description__c);
    }

    @isTest
    static void testHandleExport_MultipleRecords() {
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>();
        for (Integer i = 1; i <= 3; i++) {
            TrivisoDocumentExport.CsvRecordDeserializer csv = createDocumentCsvRecord();
            csv.ID_Journal_commande = 'DOC_JOURNAL_' + String.valueOf(i);
            csv.DOC_No_ref = 'DOC_REF_' + String.valueOf(i);
            csvRecords.add(csv);
        }
        String requestBody = JSON.serialize(csvRecords);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoDocumentExport.handleExport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();

        TrivisoDocumentExport.ExportResponse exportResponse = (TrivisoDocumentExport.ExportResponse)JSON.deserialize(responseBody, TrivisoDocumentExport.ExportResponse.class);
        System.assertEquals(3, exportResponse.successCount);
        System.assertEquals(0, exportResponse.errorCount);

        List<Proxy_Document__c> inserted = [
            SELECT Id, ID_Journal_commande__c
            FROM Proxy_Document__c
            WHERE ID_Journal_commande__c LIKE 'DOC_JOURNAL_%'
        ];
        System.assertEquals(3, inserted.size());
    }

    @isTest
    static void testHandleExport_EmptyList() {
        List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords = new List<TrivisoDocumentExport.CsvRecordDeserializer>();
        String requestBody = JSON.serialize(csvRecords);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoDocumentExport.handleExport();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();

        TrivisoDocumentExport.ExportResponse exportResponse = (TrivisoDocumentExport.ExportResponse)JSON.deserialize(responseBody, TrivisoDocumentExport.ExportResponse.class);
        System.assertEquals(0, exportResponse.successCount);
        System.assertEquals(0, exportResponse.errorCount);
    }

    @isTest
    static void testHandleExport_InvalidJson() {
        String invalidJson = '{"invalid": "json"';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoDocumentExport.handleExport();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error') || responseBody.contains('message'));
    }

    @isTest
    static void testHandleExport_EmptyRequestBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TrivisoDocumentExport.handleExport();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error') || responseBody.contains('message'));
    }
}