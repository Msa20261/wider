@RestResource(urlMapping='/triviso/projet/export')
global class TrivisoProjetExport {
    
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
                System.debug('TRIVISO_LOG: SAIS_COM_ID = ' + firstRecord.SAIS_COM_ID);
                System.debug('TRIVISO_LOG: SAIS_COM_Identification = ' + firstRecord.SAIS_COM_Identification);
                System.debug('TRIVISO_LOG: SAIS_COM_Description = ' + firstRecord.SAIS_COM_Description);
                System.debug('TRIVISO_LOG: SAIS_COM_Fam_Designation = ' + firstRecord.SAIS_COM_Fam_Designation);
                System.debug('TRIVISO_LOG: SAIS_COM_SOM_Prix_revient = ' + firstRecord.SAIS_COM_SOM_Prix_revient);
                System.debug('TRIVISO_LOG: SAIS_COM_SOM_Prix_revient_sans_provision = ' + firstRecord.SAIS_COM_SOM_Prix_revient_sans_provision);
                System.debug('TRIVISO_LOG: SAIS_COM_SOM_Offert = ' + firstRecord.SAIS_COM_SOM_Offert);
                System.debug('TRIVISO_LOG: SAIS_COM_SOM_Confirme = ' + firstRecord.SAIS_COM_SOM_Confirme);
                System.debug('TRIVISO_LOG: SAIS_COM_Date_ouvert = ' + firstRecord.SAIS_COM_Date_ouvert);
                System.debug('TRIVISO_LOG: SAIS_COM_Date_Modif = ' + firstRecord.SAIS_COM_Date_Modif);
                System.debug('TRIVISO_LOG: Full first record JSON: ' + JSON.serialize(firstRecord));
            }
            
            List<ProjetProxyRecord> projetRecords = new List<ProjetProxyRecord>();
            for (CsvRecordDeserializer csvRecord : csvRecords) {
                ProjetProxyRecord record = ProjetProxyMapper.mapFromCsvRecord(csvRecord);
                projetRecords.add(record);
            }
            System.debug('TRIVISO_LOG: Mapped ' + projetRecords.size() + ' ProjetProxyRecord objects');
            
            List<Proxy_Projet__c> projets = ProjetProxy.buildProxyProjets(projetRecords);
            
            System.debug('TRIVISO_LOG: Built ' + projets.size() + ' Proxy_Projet__c objects before insertion');
            if (projets.size() > 0) {
                System.debug('TRIVISO_LOG: First Proxy_Projet__c before insertion: ' + JSON.serialize(projets[0]));
            }
            
            // Use insert to create new records (external ID is not unique, so duplicates are allowed)
            Database.SaveResult[] results = Database.insert(projets, false);
            
            Integer successCount = 0;
            Integer errorCount = 0;
            List<String> errors = new List<String>();
            
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                    System.debug('TRIVISO_LOG: Successfully inserted record ' + (i+1) + ' with Id: ' + results[i].getId() + ', ID_Projet_Triviso__c: ' + projets[i].ID_Projet_Triviso__c);
                } else {
                    errorCount++;
                    String errorMsg = 'Record ' + (i+1) + ' (ID_Projet_Triviso: ' + projets[i].ID_Projet_Triviso__c + '): ';
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
        global String SAIS_COM_ID;
        global String SAIS_COM_Identification;
        global String SAIS_COM_Description;
        global String SAIS_COM_No_Comm_client;
        global String SAIS_COM_Etat_ID;
        global String SAIS_COM_Genre_projet;
        global String SAIS_COM_Fam_Designation;
        global String SAIS_COM_Date_ouvert;
        global String SAIS_COM_Date_Modif;
        global String SAIS_COM_ADR_FACT_ID;
        global String SAIS_COM_ADR_LIVR_ID;
        global String SAIS_COM_ADR_MO_ID;
        global String SAIS_COM_ADR_ARCH_ID;
        global String SAIS_COM_ADR_RESP_ID;
        global String SAIS_COM_ADR_MAND_ID;
        global String SAIS_COM_ADR_RESP_PROJ_ID;
        global String SAIS_COM_ADR_FACT_CONTACT_ID;
        global String SAIS_COM_ADR_LIVR_CONTACT_ID;
        global String SAIS_COM_ADR_MO_CONTACT_ID;
        global String SAIS_COM_ADR_ARCH_CONTACT_ID;
        global String SAIS_COM_ADR_COMPTE_ID;
        global String SAIS_COM_SOM_Prix_revient_sans_provision;
        global String SAIS_COM_SOM_Prix_revient;
        global String SAIS_COM_SOM_Offert;
        global String SAIS_COM_SOM_Confirme;
        global String SAIS_COM_SOM_Correction_Confirme;
        global String SAIS_COM_SOM_Facture;
        global String SAIS_COM_SOM_Paye;
        global String SAIS_COM_SOM_DAC;
        global String SAIS_COM_SOM_potentiel_facturation;
        global String SAIS_COM_SOM_avance_client;
        global String SAIS_COM_SOM_Solde_a_paye_CHF;
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