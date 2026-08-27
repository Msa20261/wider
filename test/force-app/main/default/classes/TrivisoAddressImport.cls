@RestResource(urlMapping='/triviso/addresse/import')
global class TrivisoAddressImport {
    
    @HttpPost
    global static void handleImport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            System.debug('TRIVISO_LOG: Request body received: ' + requestBody);
            
            // Récupérer tous les Proxy_Address__c records
            List<Proxy_Address__c> addresses = [
                SELECT 
                    ADRES_Tag__c,
                    ADRES_ID__c,
                    ADRES_Organisation_Identif__c,
                    ADRES_Identification__c,
                    ADRES_Date_creation__c,
                    ADRES_Date_modif__c,
                    ADRES_Date_inactive__c,
                    ADRES_Nom__c,
                    ADRES_Prenom__c,
                    ADRES_Supplement__c,
                    ADRES_Case_postale__c,
                    ADRES_Rue__c,
                    ADRES_Telephone1__c,
                    ADRES_Telephone2__c,
                    ADRES_Telephone3__c,
                    ADRES_Natel1__c,
                    ADRES_Natel2__c,
                    ADRES_Email__c,
                    ADRES_Email2__c,
                    ADRES_Site_Web__c,
                    ADRES_entete__c,
                    ADRES_TVA_intracom__c,
                    ADRES_No_registre_commerce__c,
                    ADRES_NPL__c,
                    ADRES_Lieu__c,
                    ADRES_PAYS_Description__c,
                    ADRES_PAYS_Identification__c,
                    ADRES_Titre__c,
                    ADRES_Departement__c,
                    ADRES_Langue__c,
                    ADRES_No_EORI__c
                FROM Proxy_Address__c
                ORDER BY CreatedDate DESC
            ];
            
            System.debug('TRIVISO_LOG: Found ' + addresses.size() + ' Proxy_Address__c records');
            
            // Mapper vers format CSV
            List<Map<String, String>> csvRecords = new List<Map<String, String>>();
            for (Proxy_Address__c address : addresses) {
                Map<String, String> csvRecord = AddressProxyMapper.mapToCsvRecord(address);
                csvRecords.add(csvRecord);
            }
            
            System.debug('TRIVISO_LOG: Mapped ' + csvRecords.size() + ' records to CSV format');
            
            // Créer la réponse JSON
            ImportResponse response = new ImportResponse();
            response.status = 'success';
            response.recordCount = csvRecords.size();
            response.records = csvRecords;
            
            String responseBody = JSON.serialize(response);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(responseBody);
            System.debug('TRIVISO_LOG: Response body sent with ' + csvRecords.size() + ' records');
        } catch (Exception e) {
            System.debug('TRIVISO_LOG: Exception occurred: ' + e.getMessage() + ' | Stack trace: ' + e.getStackTraceString());
            res.statusCode = 500;
            ImportResponse errorResponse = new ImportResponse();
            errorResponse.status = 'error';
            errorResponse.message = e.getMessage();
            String errorResponseBody = JSON.serialize(errorResponse);
            res.responseBody = Blob.valueOf(errorResponseBody);
            System.debug('TRIVISO_LOG: Error response body sent: ' + errorResponseBody);
        }
    }
    
    global class ImportResponse {
        global String status;
        global Integer recordCount;
        global List<Map<String, String>> records;
        global String message;
    }
}