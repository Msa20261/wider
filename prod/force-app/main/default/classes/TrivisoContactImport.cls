@RestResource(urlMapping='/triviso/contact/import')
global class TrivisoContactImport {

    @HttpPost
    global static void handleImport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            Map<String, Object> requestMap = TrivisoPaginationHelper.parseRequest(req);
            String lastId = TrivisoPaginationHelper.getLastId(requestMap);
            Integer pageSize = TrivisoPaginationHelper.getPageSize(requestMap);
            DateTime sinceDate = TrivisoPaginationHelper.getSinceDate(requestMap);

            List<Map<String, String>> exportRecords = TrivisoContact.getContactsForExportPage(lastId, pageSize, sinceDate);

            System.debug('TRIVISO_LOG: Found ' + exportRecords.size() + ' records (lastId=' + lastId + ', pageSize=' + pageSize + ')');

            ImportResponse response = new ImportResponse();
            response.status = 'success';
            response.recordCount = exportRecords.size();
            response.records = exportRecords;
            response.hasMore = exportRecords.size() == pageSize;
            response.lastId = exportRecords.isEmpty()
                ? null
                : exportRecords.get(exportRecords.size() - 1).get('ADRES_Salesforce_Id');

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (Exception e) {
            System.debug('TRIVISO_LOG: Exception occurred: ' + e.getMessage() + ' | Stack trace: ' + e.getStackTraceString());
            res.statusCode = 500;
            ImportResponse errorResponse = new ImportResponse();
            errorResponse.status = 'error';
            errorResponse.message = e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }
    }

    global class ImportResponse {
        global String status;
        global Integer recordCount;
        global List<Map<String, String>> records;
        global String message;
        global Boolean hasMore;
        global String lastId;
    }
}