@RestResource(urlMapping='/triviso/addresse/export')
global class TrivisoAddressExport {
    
    @HttpPost
    global static void handleExport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            System.debug('TRIVISO_LOG: Request body received: ' + requestBody);
            
            List<CsvRecordDeserializer> csvRecords = (List<CsvRecordDeserializer>)JSON.deserialize(requestBody, List<CsvRecordDeserializer>.class);
            System.debug('TRIVISO_LOG: Deserialized export request with ' + csvRecords.size() + ' records');
            
            // Debug: Log first record to see what was deserialized
            if (csvRecords.size() > 0) {
                CsvRecordDeserializer firstRecord = csvRecords[0];
                System.debug('TRIVISO_LOG: First record after deserialization:');
                System.debug('TRIVISO_LOG: ADRES_ID = ' + firstRecord.ADRES_ID);
                System.debug('TRIVISO_LOG: ADRES_Tag = ' + firstRecord.ADRES_Tag);
                System.debug('TRIVISO_LOG: ADRES_Nom = ' + firstRecord.ADRES_Nom);
                System.debug('TRIVISO_LOG: ADRES_Rue = ' + firstRecord.ADRES_Rue);
                System.debug('TRIVISO_LOG: ADRES_Organisation_Identif = ' + firstRecord.ADRES_Organisation_Identif);
                System.debug('TRIVISO_LOG: ADRES_Identification = ' + firstRecord.ADRES_Identification);
                System.debug('TRIVISO_LOG: Full first record JSON: ' + JSON.serialize(firstRecord));
            }
            
            List<AddressProxyRecord> addressRecords = new List<AddressProxyRecord>();
            for (CsvRecordDeserializer csvRecord : csvRecords) {
                AddressProxyRecord record = AddressProxyMapper.mapFromCsvRecord(csvRecord);
                addressRecords.add(record);
            }
            System.debug('TRIVISO_LOG: Mapped ' + addressRecords.size() + ' AddressProxyRecord objects');
            
            List<Proxy_Address__c> addresses = AddressProxy.buildProxyAddresses(addressRecords);
            
            System.debug('TRIVISO_LOG: Built ' + addresses.size() + ' Proxy_Address__c objects before insertion');
            if (addresses.size() > 0) {
                System.debug('TRIVISO_LOG: First Proxy_Address__c before insertion: ' + JSON.serialize(addresses[0]));
            }
            
            // Use insert to create new records (external ID is not unique, so duplicates are allowed)
            Database.SaveResult[] results = Database.insert(addresses, false);
            
            Integer successCount = 0;
            Integer errorCount = 0;
            List<String> errors = new List<String>();
            
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                    System.debug('TRIVISO_LOG: Successfully inserted record ' + (i+1) + ' with Id: ' + results[i].getId() + ', ADRES_ID__c: ' + addresses[i].ADRES_ID__c);
                } else {
                    errorCount++;
                    String errorMsg = 'Record ' + (i+1) + ' (ADRES_ID: ' + addresses[i].ADRES_ID__c + '): ';
                    for (Database.Error error : results[i].getErrors()) {
                        errorMsg += error.getMessage() + '; ';
                    }
                    errors.add(errorMsg);
                    System.debug('TRIVISO_LOG: Failed to insert record ' + (i+1) + ': ' + errorMsg);
                }
            }
            
            String responseBody = JSON.serialize(new ExportResponse(successCount, errorCount, errors));
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(responseBody);
            System.debug('TRIVISO_LOG: Response body sent: ' + responseBody);
        } catch (Exception e) {
            System.debug('TRIVISO_LOG: Exception occurred: ' + e.getMessage() + ' | Stack trace: ' + e.getStackTraceString());
            res.statusCode = 500;
            String errorResponse = '{"status": "error", "message": "' + e.getMessage() + '"}';
            res.responseBody = Blob.valueOf(errorResponse);
            System.debug('TRIVISO_LOG: Error response body sent: ' + errorResponse);
        }
    }
    
    global class CsvRecordDeserializer {
        global String ADRES_Tag;
        global String ADRES_ID;
        global String ADRES_Organisation_Identif;
        global String ADRES_Identification;
        global String ADRES_Date_creation;
        global String ADRES_Date_modif;
        global String ADRES_Date_inactive;
        global String ADRES_Nom;
        global String ADRES_Prenom;
        global String ADRES_Supplement;
        global String ADRES_Case_postale;
        global String ADRES_Rue;
        global String ADRES_Telephone1;
        global String ADRES_Telephone2;
        global String ADRES_Telephone3;
        global String ADRES_Natel1;
        global String ADRES_Natel2;
        global String ADRES_Email;
        global String ADRES_Email2;
        global String ADRES_Site_Web;
        global String ADRES_entete;
        global String ADRES_ID_entete;
        global String ADRES_TVA_intracom;
        global String ADRES_No_registre_commerce;
        global String ADRES_NPL;
        global String ADRES_Lieu;
        global String ADRES_PAYS_Description;
        global String ADRES_PAYS_Identification;
        global String ADRES_Titre;
        global String ADRES_Departement;
        global String ADRES_Langue;
        global String ADRES_No_EORI;
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