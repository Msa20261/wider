@RestResource(urlMapping='/triviso/document/export')
global class TrivisoDocumentExport {
    
    @HttpPost
    global static void handleExport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            
            List<CsvRecordDeserializer> csvRecords = (List<CsvRecordDeserializer>)JSON.deserialize(requestBody, List<CsvRecordDeserializer>.class);
            
            List<Proxy_Document__c> documents = ProxyDocument.buildProxyDocuments(csvRecords);
            
            Database.SaveResult[] results = Database.insert(documents, false);
            
            Integer successCount = 0;
            Integer errorCount = 0;
            List<String> errors = new List<String>();
            
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                } else {
                    errorCount++;
                    String errorMsg = 'Record ' + (i+1) + ': ';
                    for (Database.Error error : results[i].getErrors()) {
                        errorMsg += error.getMessage() + '; ';
                    }
                    errors.add(errorMsg);
                }
            }
            
            String responseBody = JSON.serialize(new ExportResponse(successCount, errorCount, errors));
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(responseBody);
        } catch (Exception e) {
            res.statusCode = 500;
            String errorResponse = '{"status": "error", "message": "' + e.getMessage() + '"}';
            res.responseBody = Blob.valueOf(errorResponse);
        }
    }
    
    global class CsvRecordDeserializer {
        global String ID_Journal_commande;
        global String ID_Saisie_commande;
        global String DOC_Projet_ID;
        global String DOC_No_ref;
        global String DOC_Lien_doc;
        global String DOC_Date_creation;
        global String DOC_Date_modif;
        global String DOC_Identification;
        global String DOC_Description;
        global String DOC_Paye_TTC;
        global String DOC_Montant_HT;
        global String DOC_Montant_TTC;
        global String DOC_Brouillon;
        global String DOC_DEB_Date_creation;
        global String DOC_DEB_Resp_creation;
        global String DOC_DEB_Doc_suppr;
        global String DOC_DEB_No_ecriture;
        global String DOC_Genre_document;
        global String DOC_Condition_paiement;
        global String DOC_Etat_doc;
        global String DOC_Etat_Pond;
        global String DOC_DEB_Montant;
        global String DOC_DEB_Monnaie;
        global String DOC_DEB_Solde_a_paye_CHF;
        global String DOC_DEB_Solde_a_paye_ME;
        global String DOC_DEB_Echeance_adapte;
        global String DOC_ADR_DEST_ID;
        global String DOC_ADR_DEST_Nom_Prenom;
    }
    
    global class ExportResponse {
        global Integer successCount;
        global Integer errorCount;
        global List<String> errors;
        
        global ExportResponse(Integer successCount, Integer errorCount, List<String> errors) {
            this.successCount = successCount;
            this.errorCount = errorCount;
            this.errors = errors;
        }
    }
}