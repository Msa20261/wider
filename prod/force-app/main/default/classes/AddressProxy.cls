public class AddressProxy {
    
    public static List<Proxy_Address__c> buildProxyAddresses(List<AddressProxyRecord> records) {
        System.debug('TRIVISO_LOG: Building Proxy_Address__c objects from ' + records.size() + ' records');
        
        List<Proxy_Address__c> addresses = new List<Proxy_Address__c>();
        
        for (AddressProxyRecord record : records) {
            Proxy_Address__c address = AddressProxyMapper.mapToProxyAddress(record);
            addresses.add(address);
            System.debug('TRIVISO_LOG: Mapped record to Proxy_Address__c: ' + JSON.serialize(address));
        }
        
        System.debug('TRIVISO_LOG: Built ' + addresses.size() + ' Proxy_Address__c objects');
        return addresses;
    }
    
    public static Database.SaveResult[] insertAddresses(List<Proxy_Address__c> addresses) {
        System.debug('TRIVISO_LOG: Inserting ' + addresses.size() + ' Proxy_Address__c records');
        
        Database.SaveResult[] results = Database.insert(addresses, false);
        
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
    
    public static List<Proxy_Address__c> upsertAddresses(List<Proxy_Address__c> addresses) {
        System.debug('TRIVISO_LOG: Upserting ' + addresses.size() + ' Proxy_Address__c records');
        
        Schema.SObjectField externalIdField = Proxy_Address__c.ADRES_ID__c.getDescribe().getSObjectField();
        
        Database.UpsertResult[] results = Database.upsert(addresses, externalIdField, false);
        
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
        return addresses;
    }
}