public class SimapHeadersService {

    public class SimapHeadersServiceException extends Exception {}

    // public static List<String> projectSubTypes = new List<String>{'construction'};
    public static final String BASE_SIMAP_HEADERS_URL = 'https://www.simap.ch/rest/publications/v2/project/project-search?';
    public static final String FORMATTED_DATE = 'yyyy-MM-dd';

    public static final String PROJECT_SUBTYPE_PARAM = 'projectSubTypes=';
    public static final String ISSUED_BY_ORGANIZATIONS_PARAM = 'issuedByOrganizations=';
    public static final String CPV_CODES_PARAM = 'cpvCodes=';
    public static final String CODE_CFC_BKP_PARAM = 'bkpCodes=';
    public static final String LAST_ITEM_PARAM = '&lastItem=';
    public static final String SEARCH_BY_KEYWORD_PARAM = 'search=';
    public static final String KEYWORD_PHRASE_DELIMITER = '"';
    public static final String TYPE_DE_PUBLICATION_PARAM = 'newestPubTypes=';

    public static final String CONVERTED_STATUS = 'Converted';
    public static final String VISITED_STATUS = 'Visited';
    public static final String NEW_STATUS = 'New';

    public static final Integer SIMAP_MINIMUM_KEYWORD_LENGTH = 3;
    public static final Integer SIMAP_MINIMUM_CODE_CFCBKP_LENGTH = 3;

    public class SimapResponse {
        public List<PublicationDeserializer> projects;
        public Pagination pagination;
        public Filters filters;
    }
    
    public class Pagination {
        public String lastItem;
        public Integer itemsPerPage;
    }
    
    // filters applied by user on main SIMAP search page, 
    // used by frontend LWC to track changes in user's search criteria
    public class Filters {
        public List<SObject> cantonalEntities;
        public List<SObject> projectSubTypes;
        public List<Simap_Code_CPV__c> simapCodesCPV;

        public Filters(List<SObject> cantonalEntities, List<SObject> projectSubTypes, List<Simap_Code_CPV__c> simapCodesCPV) {
            this.cantonalEntities = cantonalEntities;
            this.projectSubTypes = projectSubTypes;
            this.simapCodesCPV = simapCodesCPV;
        }
    }
    
    public class SimapSwissLangSet {
        public String fr;
        public String de;
        public String it;
        public String en;
    }
    
    public class SimapOrderAddress {
        public String countryId;
        public String cantonId;
        public String postalCode;
        public SimapSwissLangSet city;
    }

    public class PublicationDeserializer {
        public String publicationNumber;
        public String publicationId;
        public String id;
        public String projectNumber;
        public SimapOrderAddress orderAddress;
        public String projectType;
        public String pubType;
        public String processType;
        public SimapSwissLangSet title;
        public SimapSwissLangSet procOfficeName;

        public String offerDeadline;
        public String publicationDate;
        public Boolean corrected;
        public String actionStatus;
        public String projetUrl;
        public String creationUser;
        public String creationDate;
        
        public PublicationDeserializer(Map<String, Object> json) {
            this.publicationNumber = (String)json.get('publicationNumber');
            this.publicationId = (String)json.get('publicationId'); // id to display publication's details on route https://www.simap.ch/rest/publications/v1/project/ {id} /publication-details/ {publicationId}
            this.id = (String)json.get('id'); // real publication's id
            this.projectNumber = (String)json.get('projectNumber');
            this.title = new SimapSwissLangSet();
            this.procOfficeName = new SimapSwissLangSet();

            Datetime offerDeadline = (Datetime)json.get('offerDeadline');
            this.offerDeadline = offerDeadline.format(FORMATTED_DATE);
            Datetime publicationDate = (Datetime)json.get('offerDeadline');
            this.publicationDate = publicationDate.format(FORMATTED_DATE);
        }
    }

    @AuraEnabled
    public static String searchByCriteria(String lastItem) {
        SimapResponse response = fetchSimapByCriteria(lastItem);

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static String searchByKeyWord(String keyWord, String lastItem) {
        if (!isKeyWordAuthorized(keyWord)) {
            throw new SimapHeadersServiceException('Keyword is too short');
        }
        SimapResponse response = fetchSimapByKeyWord(keyWord, lastItem);

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static String searchByCodeCfcBkp(String codeCfcBkp, String lastItem) {
        if (!isCodeCfcBkpAuthorized(codeCfcBkp)) {
            throw new SimapHeadersServiceException('Code CFC / BKP is too short');
        }
        SimapResponse response = fetchSimapByCodeCfcBkp(codeCfcBkp, lastItem);

        return JSON.serialize(response);
    }

    public static SimapResponse fetchSimapByCodeCfcBkp(String codeCfcBkp, String lastItem) {
        String urlParameters = CODE_CFC_BKP_PARAM + EncodingUtil.urlEncode(codeCfcBkp, 'UTF-8');
        if (lastItem != null && lastItem != '') {
            lastItem = LAST_ITEM_PARAM + EncodingUtil.urlEncode(lastItem, 'UTF-8');
            urlParameters = urlParameters + lastItem;
        }
        SimapResponse response = getSimapResponse(urlParameters);
        addPublicationVisitedStatus(response);
        addSelectedSearchFilters(response);
        
        return response;
    }

    public static Boolean isCodeCfcBkpAuthorized(String codeCfcBkp) {
        return codeCfcBkp.length() >= SIMAP_MINIMUM_CODE_CFCBKP_LENGTH;
    }

    public static Boolean isKeyWordAuthorized(String keyword) {
        return cleanKeyWord(keyword).length() >= SIMAP_MINIMUM_KEYWORD_LENGTH;
    }

    public static String cleanKeyWord(String keyWord) {
        if (String.isBlank(keyWord)) {
            return '';
        }

        return keyWord.trim().replace(KEYWORD_PHRASE_DELIMITER, '');
    }

    // SIMAP splits a multi word search on spaces and matches with an OR, sorted by publication date :
    // 'LA PERCHE II' returns the most recent publications of Switzerland instead of the expected project.
    // Wrapping the keyword in double quotes forces an exact phrase search.
    public static String buildKeyWordPhrase(String keyWord) {
        return KEYWORD_PHRASE_DELIMITER + cleanKeyWord(keyWord) + KEYWORD_PHRASE_DELIMITER;
    }

    public static SimapResponse fetchSimapByCriteria(String lastItem) {
        String params = getUrlParams(lastItem);
        SimapResponse response = getSimapResponse(params);
        addPublicationVisitedStatus(response);
        addSelectedSearchFilters(response);
        
        return response;
    }

    public static SimapResponse fetchSimapByKeyWord(String keyWord, String lastItem) {
        String urlParameters = SEARCH_BY_KEYWORD_PARAM + EncodingUtil.urlEncode(buildKeyWordPhrase(keyWord), 'UTF-8');
        if (lastItem != null && lastItem != '') {
            lastItem = LAST_ITEM_PARAM + EncodingUtil.urlEncode(lastItem, 'UTF-8');
            urlParameters = urlParameters + lastItem;
        }
        SimapResponse response = getSimapResponse(urlParameters);
        addPublicationVisitedStatus(response);
        
        return response;
    }

    public static SimapResponse getSimapResponse(String params) {
        String jsonResponse = fetchNewPublications(params);
        try {
            SimapResponse simapResponse = (SimapResponse)JSON.deserialize(jsonResponse, SimapResponse.class);

            return simapResponse;
        } catch (Exception e) {
            throw e;
        }
    }

    public static String fetchNewPublications(String params) {
        HttpRequest req = buildSimapRequest(params);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new SimapHeadersServiceException(res.getBody());
        }
        String jsonResponse = res.getBody();

        return jsonResponse;
    }

    public static HttpRequest buildSimapRequest(String urlParameters) {
        HttpRequest req = new HttpRequest();
        String url = BASE_SIMAP_HEADERS_URL + urlParameters;
        req.setEndpoint(urlParameters);
        req.setEndpoint(url);
        System.debug('Publication\'s headers URL : ' + url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json, text/plain, */*'); // !importzant
        
        return req; 
    }

    public static String getUrlParams(String lastItem) {
        String urlParameters = '';
        List<SObject> simapCantonalEntities = SimapUtils.getSelectedCantonalEntities();
        List<SObject> projectSubTypes = SimapUtils.getSelectedProjectSubTypes();
        Simap_Code_CFC_BKP__c codeCfcBkp = SimapUtils.getDefaultCodeCfcBkp();
        List<Simap_Type_de_Publication__c> typesDePublication = SimapUtils.getDefaultTypeDePublication();

        List<Simap_Code_CPV__c> simapCodesCPV = SimapUtils.getSelectedSimapCodesCPV();

        for (SObject projectSubType : projectSubTypes) {
            urlParameters += PROJECT_SUBTYPE_PARAM + projectSubType.get('Nom_API_param__c') + '&';
        }

        for (SObject entity : simapCantonalEntities) {
            urlParameters += ISSUED_BY_ORGANIZATIONS_PARAM + EncodingUtil.urlEncode((String)entity.get('simap_id__c'), 'UTF-8') + '&';
        }

        if (codeCfcBkp.inclus_dans_API_SIMAP__c) {
            urlParameters += CODE_CFC_BKP_PARAM + EncodingUtil.urlEncode(codeCfcBkp.Code_CFC_BKP__c, 'UTF-8') + '&';
        }

        for (Simap_Code_CPV__c simapCodeCPV : simapCodesCPV) {
            urlParameters += CPV_CODES_PARAM + EncodingUtil.urlEncode(simapCodeCPV.Code_CPV__c, 'UTF-8') + '&';
        }

        for (Simap_Type_de_Publication__c typeDePublication : typesDePublication) {
            urlParameters += TYPE_DE_PUBLICATION_PARAM + EncodingUtil.urlEncode(typeDePublication.simap_value__c, 'UTF-8') + '&';
        }

        urlParameters = urlParameters.removeEnd('&');

        if(lastItem != null && lastItem != '') {
            lastItem = LAST_ITEM_PARAM + EncodingUtil.urlEncode(lastItem, 'UTF-8');
            urlParameters = urlParameters + lastItem;
        }

        System.debug(urlParameters);

        return urlParameters;
    }

    public static SimapResponse addPublicationVisitedStatus(SimapResponse response) {
        Set<String> publicationIds = new Set<String>();

        for (PublicationDeserializer project : response.projects) {
            publicationIds.add(project.id);
        }

        Map<String, Publication_Simap__c> existingRecordsMap = new Map<String, Publication_Simap__c>();
        List<Publication_Simap__c> visitedPublications = PublicationSimap.getVisitedSimapPublications(publicationIds);
        for (Publication_Simap__c record : visitedPublications) {
            existingRecordsMap.put(record.Id_publication_page__c, record);
        }

        for (PublicationDeserializer project : response.projects) {
            if (existingRecordsMap.containsKey(project.id)) {
                Id oppId = existingRecordsMap.get(project.id).Projet__c;
                if (oppId != null) {
                    project.actionStatus = CONVERTED_STATUS; // projet existing
                    project.projetUrl = URL.getOrgDomainURL().toExternalForm() + '/' + oppId;
                    continue;
                }
                project.actionStatus = VISITED_STATUS; // publication has been opened
                project.creationUser = existingRecordsMap.get(project.id).CreatedBy.Name;
                project.creationDate = existingRecordsMap.get(project.id).CreatedDate.format(FORMATTED_DATE);
                continue;
            }
            project.actionStatus = NEW_STATUS;
        }

        return response;
    }

    public static SimapResponse addSelectedSearchFilters(SimapResponse response) {
        List<SObject> simapCantonalEntities = SimapUtils.getSelectedCantonalEntities();
        List<SObject> projectSubTypes = SimapUtils.getSelectedProjectSubTypes();
        List<Simap_Code_CPV__c> simapCodesCPV = SimapUtils.getSelectedSimapCodesCPV();

        response.filters = new Filters(simapCantonalEntities, projectSubTypes, simapCodesCPV);
    
        return response;
    }
}