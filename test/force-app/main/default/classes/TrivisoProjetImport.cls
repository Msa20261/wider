@RestResource(urlMapping='/triviso/projet/import')
global class TrivisoProjetImport {

    @HttpPost
    global static void handleImport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            Map<String, Object> requestMap = TrivisoPaginationHelper.parseRequest(req);
            String lastId = TrivisoPaginationHelper.getLastId(requestMap);
            Integer pageSize = TrivisoPaginationHelper.getPageSize(requestMap);
            DateTime sinceDate = TrivisoPaginationHelper.getSinceDate(requestMap);

            List<Projet__c> projets = ProjetService.getProjetPageForExport(lastId, pageSize, sinceDate);

            System.debug('TRIVISO_LOG: Found ' + projets.size() + ' Projet__c records (lastId=' + lastId + ', pageSize=' + pageSize + ')');

            List<TrivisoProjetRecord> trivisoRecords = TrivisoProjetMapper.mapProjetsToTrivisoRecords(projets);
            List<Map<String, String>> xmlRecords = new List<Map<String, String>>();
            for (TrivisoProjetRecord record : trivisoRecords) {
                xmlRecords.add(TrivisoProjetMapper.mapToExportRecord(record));
            }

            ImportResponse response = new ImportResponse();
            response.status = 'success';
            response.recordCount = xmlRecords.size();
            response.records = xmlRecords;
            response.hasMore = xmlRecords.size() == pageSize;
            response.lastId = projets.isEmpty() ? null : projets.get(projets.size() - 1).Id;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

            if (!projets.isEmpty()) {
                ProjetService.updateTrivisoExportDate(projets);
            }

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