public class ProjetProxy {
    
    public static List<Proxy_Projet__c> buildProxyProjets(List<ProjetProxyRecord> records) {
        System.debug('TRIVISO_LOG: Building Proxy_Projet__c objects from ' + records.size() + ' records');
        
        List<Proxy_Projet__c> projets = new List<Proxy_Projet__c>();
        
        for (ProjetProxyRecord record : records) {
            Proxy_Projet__c projet = ProjetProxyMapper.mapToProxyProjet(record);
            projets.add(projet);
            System.debug('TRIVISO_LOG: Mapped record to Proxy_Projet__c: ' + JSON.serialize(projet));
        }
        
        System.debug('TRIVISO_LOG: Built ' + projets.size() + ' Proxy_Projet__c objects');
        return projets;
    }
    
    public static Database.SaveResult[] insertProjets(List<Proxy_Projet__c> projets) {
        System.debug('TRIVISO_LOG: Inserting ' + projets.size() + ' Proxy_Projet__c records');
        
        Database.SaveResult[] results = Database.insert(projets, false);
        
        Integer successCount = 0;
        Integer errorCount = 0;
        
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                successCount++;
                System.debug('TRIVISO_LOG: Successfully inserted record ' + (i+1) + ' with Id: ' + results[i].getId());
            } else {
                errorCount++;
                String errors = '';
                for (Database.Error error : results[i].getErrors()) {
                    errors += error.getMessage() + '; ';
                }
                System.debug('TRIVISO_LOG: Failed to insert record ' + (i+1) + ': ' + errors);
            }
        }
        
        System.debug('TRIVISO_LOG: Insert completed - Success: ' + successCount + ', Errors: ' + errorCount);
        return results;
    }
    
    public static List<Proxy_Projet__c> upsertProjets(List<Proxy_Projet__c> projets) {
        System.debug('TRIVISO_LOG: Upserting ' + projets.size() + ' Proxy_Projet__c records');
        
        Schema.SObjectField externalIdField = Proxy_Projet__c.ID_Projet_Triviso__c.getDescribe().getSObjectField();
        
        Database.UpsertResult[] results = Database.upsert(projets, externalIdField, false);
        
        Integer successCount = 0;
        Integer errorCount = 0;
        
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                successCount++;
                System.debug('TRIVISO_LOG: Successfully upserted record ' + (i+1) + ' with Id: ' + results[i].getId());
            } else {
                errorCount++;
                String errors = '';
                for (Database.Error error : results[i].getErrors()) {
                    errors += error.getMessage() + '; ';
                }
                System.debug('TRIVISO_LOG: Failed to upsert record ' + (i+1) + ': ' + errors);
            }
        }
        
        System.debug('TRIVISO_LOG: Upsert completed - Success: ' + successCount + ', Errors: ' + errorCount);
        return projets;
    }
}