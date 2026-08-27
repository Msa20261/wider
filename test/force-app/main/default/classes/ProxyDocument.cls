public class ProxyDocument {
    
    public static List<Proxy_Document__c> buildProxyDocuments(List<TrivisoDocumentExport.CsvRecordDeserializer> csvRecords) {
        List<Proxy_Document__c> documents = new List<Proxy_Document__c>();
        
        for (TrivisoDocumentExport.CsvRecordDeserializer csvRecord : csvRecords) {
            Proxy_Document__c document = ProxyDocumentMapper.mapToProxyDocument(csvRecord);
            documents.add(document);
        }
        
        return documents;
    }
    
    public static Database.SaveResult[] insertDocuments(List<Proxy_Document__c> documents) {
        Database.SaveResult[] results = Database.insert(documents, false);
        
        Integer successCount = 0;
        Integer errorCount = 0;
        
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                successCount++;
            } else {
                errorCount++;
                String errors = '';
                for (Database.Error error : results[i].getErrors()) {
                    errors += error.getMessage() + '; ';
                }
            }
        }
        
        return results;
    }
}