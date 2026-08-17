public class SimapPublicationDetailService {

    public static final String BASE_SIMAP_DETAIL_URL = 'https://www.simap.ch/rest/publications/v1/project/';
    public static final String SIMAP_DETAIL_PATH = '/publication-details/';

    public class SimapPublicationDetailResponse {
        public ProjectInfo projectInfo;
        public Procurement procurement;
        public Base base;
        public Dates dates;
        public Ted ted;

        public SimapPublicationDetailResponse(Map<String, Object> jsonMap) {
            if (jsonMap.containsKey('project-info') || jsonMap.containsKey('projectInfo')) {
                this.projectInfo = (ProjectInfo) JSON.deserialize(JSON.serialize(jsonMap.get('project-info')), ProjectInfo.class);
            }
            if (jsonMap.containsKey('base')) {
                this.base = (Base) JSON.deserialize(JSON.serialize(jsonMap.get('base')), Base.class);
            }
            if (jsonMap.containsKey('dates')) {
                this.dates = (Dates) JSON.deserialize(JSON.serialize(jsonMap.get('dates')), Dates.class);
            }
            if (jsonMap.containsKey('ted')) {
                this.ted = (Ted) JSON.deserialize(JSON.serialize(jsonMap.get('ted')), Ted.class);
            }
            if(jsonMap.containsKey('procurement')) {
                this.procurement = (Procurement) JSON.deserialize(JSON.serialize(jsonMap.get('procurement')), Procurement.class);
            }
        }
    }

    public class Procurement {
        public SimapHeadersService.SimapSwissLangSet orderDescription;
    }

    public class ProjectInfo {
        public SimapAdress procOfficeAddress;
        public SimapAdress procurementRecipientAddress;
        public SimapAdress offerAddress;
        public SimapHeadersService.SimapSwissLangSet offerSpecificNote;
        public SimapHeadersService.SimapSwissLangSet documentsSourceNote;
    }

    public class Base {
        public CPVCode cpvCode;
        public SimapHeadersService.SimapSwissLangSet title; 
        public String publicationNumber;
        public String type;
        public String processType;
    }

    public class Dates {
        public Datetime offerDeadline;
        public Datetime publicationDate;
    }

    public class Ted {
        public String status;
        public String url;
    }

    // second level classes

    public class CPVCode {
        public String code;
        public SimapHeadersService.SimapSwissLangSet label;
    }

    public class SimapAdress {
        public String postalCode;
        public String cantonId;
        public String countryId;
        public String phone;
        public String email;
        public String reference;
        public SimapHeadersService.SimapSwissLangSet name;
        public SimapHeadersService.SimapSwissLangSet contactPerson;
        public SimapHeadersService.SimapSwissLangSet url;
        public SimapHeadersService.SimapSwissLangSet street;
        public SimapHeadersService.SimapSwissLangSet city;
    }

    // HTTP response class

    public class PublicationDetailResponse {
        public Publication_Simap_Detail__c publicationSimapDetail;
        public Boolean isNew;
    }

    @AuraEnabled
    public static String savePublicationHeader(String jsonPub) {
        SimapHeadersService.PublicationDeserializer rawPubData = (SimapHeadersService.PublicationDeserializer)JSON.deserialize(jsonPub, SimapHeadersService.PublicationDeserializer.class);
        List<Publication_Simap__c> existingPub = PublicationSimap.getPublicationSimapByDetailId(rawPubData.publicationId);

        if (existingPub.size() == 0) {
            Publication_Simap__c insertedPublication = PublicationSimap.insertPublicationHeader(rawPubData);
            
            return JSON.serialize(insertedPublication);
        }

        Publication_Simap__c publication = existingPub[0];

        return JSON.serialize(publication);
    }

    @AuraEnabled
    public static String getPublicationDetail(Id publicationSimapId) {
        Publication_Simap__c insertedPub = PublicationSimap.getPublicationById(publicationSimapId);
        SimapPublicationDetailResponse simapDetailResponse = fetchPublicationDetail(insertedPub.Id_publication_page__c, insertedPub.Id_publication_detail__c);
        Publication_Simap__c updatedPub = PublicationSimap.updatePublicationWithDetails(insertedPub, simapDetailResponse);

        return JSON.serialize(updatedPub);
    }

    public static SimapPublicationDetailResponse fetchPublicationDetail(String publicationPageId, String publicationDetailId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String url = BASE_SIMAP_DETAIL_URL + publicationPageId + SIMAP_DETAIL_PATH + publicationDetailId;
        System.debug('Publication Detail URL : ' + url);
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        HttpResponse response = http.send(req);

        String jsonString = response.getBody();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        SimapPublicationDetailResponse simapDetailResponse = new SimapPublicationDetailResponse(jsonMap);

        return simapDetailResponse;
    }

}