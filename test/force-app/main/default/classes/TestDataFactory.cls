@isTest
public class TestDataFactory {

    // Mock HTTP response for OpenStreetMap API calls
    public class MockHttpOpenStreetMapResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('street=bbbbbbbbbbbbb')) {
                res.setStatusCode(200);
                res.setBody('[]');
            } else {
                res.setStatusCode(200);
                res.setBody('[{"lat": "48.866667", "lon": "2.333333"}]');
            }

            return res;
        }
    }


    public class MockHttpSimapResponse implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
    
            if (req.getEndpoint().contains(TestDataFactory.NON_EXISTING_KEYWORD)) {
                res.setStatusCode(200);
                res.setBody('{"projects": []}');
            }
            else if (
                req.getEndpoint().contains(SimapHeadersService.SEARCH_BY_KEYWORD_PARAM)
                && req.getEndpoint().contains(TestDataFactory.INCOMING_PUBLICATION_DETAIL_REFERENCE)
            ) {
                res.setStatusCode(200);
                res.setBody(oneProjectBody);
            } else if(req.getEndpoint().contains('&lastItem=' + SimapHeadersServiceTest.ONE_PROJECT_LAST_ITEM)) {
                res.setStatusCode(200);
                res.setBody(oneProjectBody);
            } else if (req.getEndpoint().contains('&lastItem=' + SimapHeadersServiceTest.TWO_PROJECTS_LAST_ITEM)) {
                res.setStatusCode(200);
                res.setBody(twoProjectsBody);
            } else if (req.getEndpoint().contains(SimapHeadersService.CODE_CFC_BKP_PARAM)) {
                res.setStatusCode(200);
                res.setBody(oneProjectBody);
            } else {
                res.setStatusCode(200);
                res.setBody(oneProjectBody);
            }
    
            return res;
        }
    }

    public class MockHttpSimapResponseDetail implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
    
            if(req.getEndpoint().contains('/publication-details/')) {
                res.setBody(TestDataFactory.SIMAP_DETAIL_RESPONSE_1);
            }
    
            return res;
        }
    }

    // Create test Account
    public static Account createTestAccount(String name) {
        Account acc = new Account(
            Name = name,
            BillingStreet = '123 Test Street',
            BillingCity = 'Paris',
            BillingPostalCode = '75001',
            BillingCountry = 'France'
        );
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.allowSave = true;
        Database.insert(acc, dmo);
        return acc;
    }

    // Create test Projet__c with address
    public static Projet__c createTestProjet(String name, Id accountId) {
        Projet__c projet = new Projet__c();
        projet.Name = name;
        projet.Nom_du_compte__c = accountId;
        projet.Etape__c = 'Qualification';
        projet.Etat__c = 'Terminé';
        projet.Adresse_Facturation__City__s = 'Lyon';
        projet.Adresse_Facturation__PostalCode__s = '69001';
        projet.Adresse_Facturation__CountryCode__s = 'FR';
        projet.Adresse_Facturation__Street__s = '456 Project Street';
        projet.latitude__c = '45.7640';
        projet.longitude__c = '4.8357';
        insert projet;
        return projet;
    }

    // Create test Projet__c without address
    public static Projet__c createTestProjetWithoutAddress(String name, Id accountId) {
        Projet__c projet = new Projet__c();
        projet.Name = name;
        projet.Nom_du_compte__c = accountId;
        projet.Etape__c = 'Identification';
        projet.Etat__c = 'Ouvert';
        insert projet;
        return projet;
    }

    // Create test Projet__c with invalid address
    public static Projet__c createTestProjetWithInvalidAddress(String name, Id accountId) {
        Projet__c projet = new Projet__c();
        projet.Name = name;
        projet.Nom_du_compte__c = accountId;
        projet.Etape__c = 'Chiffrage';
        projet.Etat__c = 'En préparation';
        projet.Adresse_Facturation__City__s = 'InvalidCity';
        projet.Adresse_Facturation__PostalCode__s = '00000';
        projet.Adresse_Facturation__CountryCode__s = 'US'; // Using valid country code
        projet.Adresse_Facturation__Street__s = 'bbbbbbbbbbbbb';
        insert projet;
        return projet;
    }

    public static final String VAUD_CANTON_NAME = 'Vaud';
    public static final String VAUD_CANTON_ID = 'id_of_Vaud_canton';
    public static final Boolean VAUD_CANTON_IN_API_SIMAP = true;
    public static final String VAUD_CANTON_ABBREVIATION = 'VD';
    public static final String GENEVE_CANTON_NAME = 'Geneve';
    public static final String GENEVE_CANTON_ID = 'id_of_Geneve_canton';
    public static final Boolean GENEVE_CANTON_IN_API_SIMAP = false;
    public static final String GENEVE_CANTON_ABBREVIATION = 'GE';

    public static final String CPV_CODE1_NAME = 'CPV_Code_1';
    public static final String CPV_CODE1_SECTOR = 'Construction';
    public static final String CPV_CODE1_CODE = '123';
    public static final Boolean CPV_CODE1_APPLY_CANTONAL_SEARCH = true;
    public static final Boolean CPV_CODE1_APPLY_FEDERAL_SEARCH = true;
    public static final String CPV_CODE2_NAME = 'CPV_Code_2';
    public static final String CPV_CODE2_SECTOR = 'non pertinent';
    public static final String CPV_CODE2_CODE = '456';
    public static final Boolean CPV_CODE2_APPLY_CANTONAL_SEARCH = false;
    public static final Boolean CPV_CODE2_APPLY_FEDERAL_SEARCH = false;

    public static final String PROJECT_SUBTYPE1_NAME = 'ProjectSubType1';
    public static final String PROJECT_SUBTYPE1_API_PARAM = 'api_param_1';
    public static final Boolean PROJECT_SUBTYPE1_IN_API_SIMAP = true;
    public static final String PROJECT_SUBTYPE2_NAME = 'ProjectSubType2';
    public static final String PROJECT_SUBTYPE2_API_PARAM = 'api_param_2';
    public static final Boolean PROJECT_SUBTYPE2_IN_API_SIMAP = false;

    public static final String FR = 'fr';
    public static final String DE = 'de';
    public static final String IT = 'it';
    public static final String EN = 'en';

    public static final String COUNTRY_CODE = 'CH';
    public static final String POSTAL_CODE = '1234';
    public static final String CANTON_ID = 'CT';

    public static final String PUBLICATION_TYPE_TENDER = 'tender';
    public static final String PUBLICATION_PROCESS_TYPE_OPEN = 'open';

    public static final String INCOMING_PUBLICATION_NUMBER = '100';
    public static final String INCOMING_PUBLICATION_PAGE_ID = '101';
    public static final String INCOMING_PUBLICATION_PROJECT_NUMBER = '102';
    public static final String INCOMING_PUBLICATION_DATE = '2024-08-23';
    public static final String INCOMING_PUBLICATION_DETAIL_ID = '103';
    public static final String INCOMING_PUBLICATION_OFFER_DEADLINE = '2024-10-07T11:00:00+02:00';

    public static final String EXISTING_PUBLICATION_NUMBER = '200';
    public static final String EXISTING_PUBLICATION_PAGE_ID = '201';
    public static final String EXISTING_PUBLICATION_PROJECT_NUMBER = '202';
    public static final String EXISTING_PUBLICATION_DATE = '2024-08-24';
    public static final String EXISTING_PUBLICATION_DETAIL_ID = '203';
    public static final String EXISTING_PUBLICATION_OFFER_DEADLINE = '2024-10-08';

    public static final String NON_EXISTING_KEYWORD = 'non_existing_keyword';

    public static final String SIMAP_HEADER_RESPONSE_1 = String.join(new List<String>{
        '{"projectType":' + '"' + PUBLICATION_TYPE_TENDER + '"' + ',',
        '"processType":' + '"' + PUBLICATION_PROCESS_TYPE_OPEN + '"' + ',',
        '"publicationNumber":' + '"' + INCOMING_PUBLICATION_NUMBER + '"' + ',',
        '"pubType":' + '"' + PUBLICATION_TYPE_TENDER + '"' + ',',
        '"corrected":false,',
        '"id":' + '"' + INCOMING_PUBLICATION_PAGE_ID + '"' + ',',
        '"projectNumber":' + '"' + INCOMING_PUBLICATION_PROJECT_NUMBER + '"' + ',',
        '"title":{"de":null,"en":null,"fr":' + '"' + FR + '"' + ',"it":""},',
        '"publicationDate":' + '"' + INCOMING_PUBLICATION_DATE + '"' + ',',
        '"publicationId":' + '"' + INCOMING_PUBLICATION_DETAIL_ID + '"' + ',',
        '"procOfficeName":{"de":null,"en":null,"fr":' + '"' + FR + '"' + ',"it":null},',
        '"orderAddress":{"countryId":' + '"' + COUNTRY_CODE + '"' + ',"cantonId":' + '"' + CANTON_ID + '"' + ',',
        '"postalCode":' + '"' + POSTAL_CODE + '"' + ',"city":{"de":null,"en":null,"fr":' + '"' + FR + '"' + ',"it":null}},',
        '"offerDeadline":' + '"' + INCOMING_PUBLICATION_OFFER_DEADLINE + '"' + '}'
    }, '\n');

    // no orderAddress here on purpose : covers the publications whose search payload has none
    public static final String SIMAP_HEADER_RESPONSE_2 = String.join(new List<String>{
        '{"projectType":' + '"' + PUBLICATION_TYPE_TENDER + '"' + ',',
        '"processType":' + '"' + PUBLICATION_PROCESS_TYPE_OPEN + '"' + ',',
        '"publicationNumber":' + '"' + EXISTING_PUBLICATION_NUMBER + '"' + ',',
        '"pubType":' + '"' + PUBLICATION_TYPE_TENDER + '"' + ',',
        '"corrected":false,',
        '"id":' + '"' + EXISTING_PUBLICATION_PAGE_ID + '"' + ',',
        '"projectNumber":' + '"' + EXISTING_PUBLICATION_PROJECT_NUMBER + '"' + ',',
        '"title":{"de":null,"en":null,"fr":' + '"' + FR + '"' + ',"it":""},',
        '"publicationDate":' + '"' + EXISTING_PUBLICATION_DATE + '"' + ',',
        '"publicationId":' + '"' + EXISTING_PUBLICATION_DETAIL_ID + '"' + ',',
        '"procOfficeName":{"de":null,"en":null,"fr":' + '"' + FR + '"' + ',"it":null},',
        '"offerDeadline":' + '"' + EXISTING_PUBLICATION_OFFER_DEADLINE + '"' + '}'
    }, '\n');

    // declarations importantes à cet endroit pour les tests
    // respecter l'ordre des declarations des variables statiques
    // doit être après SIMAP_HEADER_RESPONSE_1
     // data for MockHttpSimapResponse
    public static String oneProjectBody = '{"projects": [' + TestDataFactory.SIMAP_HEADER_RESPONSE_1 + ']}';
    public static String twoProjectsBody = '{"projects": [' + TestDataFactory.SIMAP_HEADER_RESPONSE_1 + ',' + TestDataFactory.SIMAP_HEADER_RESPONSE_2 + ']}';

    public static final String INCOMING_PUBLICATION_DETAIL_POSTAL_CODE = '3000';
    public static final String INCOMING_PUBLICATION_DETAIL_PHONE = '031 123 45 67';
    public static final String INCOMING_PUBLICATION_DETAIL_EMAIL = 'office@simap.ch';
    public static final String INCOMING_PUBLICATION_DETAIL_REFERENCE = '12345';
    public static final String INCOMING_PUBLICATION_DETAIL_TED_STATUS = 'Publié';
    public static final String INCOMING_PUBLICATION_DETAIL_TED_URL = 'http://ted.europa.eu';
    public static final String INCOMING_PUBLICATION_DETAIL_BASE_TYPE = 'Avis de marché';
    public static final String INCOMING_PUBLICATION_DETAIL_BASE_PROCESS_TYPE = 'Procédure ouverte';

    public static final String SIMAP_DETAIL_RESPONSE_1 = String.join(new List<String>{
        '{',
        '  "procurement": {',
        '    "orderDescription": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '  },',
        '  "project-info": {',
        '    "procOfficeAddress": {',
        '      "postalCode": "' + INCOMING_PUBLICATION_DETAIL_POSTAL_CODE + '",',
        '      "cantonId": "' + VAUD_CANTON_ABBREVIATION + '",',
        '      "countryId": "' + COUNTRY_CODE + '",',
        '      "phone": "' + INCOMING_PUBLICATION_DETAIL_PHONE + '",',
        '      "email": "' + INCOMING_PUBLICATION_DETAIL_EMAIL + '",',
        '      "reference": "' + INCOMING_PUBLICATION_DETAIL_REFERENCE + '",',
        '      "name": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "url": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "street": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "city": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '    },',
        '    "procurementRecipientAddress": null,',
        '    "offerAddress": null,',
        '    "offerSpecificNote": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '    "documentsSourceNote": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '  },',
        '  "projectInfo": {',
        '    "procOfficeAddress": {',
        '      "postalCode": "' + INCOMING_PUBLICATION_DETAIL_POSTAL_CODE + '",',
        '      "cantonId": "' + VAUD_CANTON_ABBREVIATION + '",',
        '      "countryId": "' + COUNTRY_CODE + '",',
        '      "phone": "' + INCOMING_PUBLICATION_DETAIL_PHONE + '",',
        '      "email": "' + INCOMING_PUBLICATION_DETAIL_EMAIL + '",',
        '      "reference": "' + INCOMING_PUBLICATION_DETAIL_REFERENCE + '",',
        '      "name": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "url": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "street": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '      "city": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '    },',
        '    "procurementRecipientAddress": null,',
        '    "offerAddress": null,',
        '    "offerSpecificNote": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '    "documentsSourceNote": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '  },',
        '  "base": {',
        '    "cpvCode": {',
        '      "code": "' + CPV_CODE1_CODE + '",',
        '      "label": {"de":null,"en":null,"fr":"' + FR + '","it":""}',
        '    },',
        '    "title": {"de":null,"en":null,"fr":"' + FR + '","it":""},',
        '    "publicationNumber": "' + EXISTING_PUBLICATION_NUMBER + '",',
        '    "type": "' + INCOMING_PUBLICATION_DETAIL_BASE_TYPE + '",',
        '    "processType": "' + INCOMING_PUBLICATION_DETAIL_BASE_PROCESS_TYPE + '"',
        '  },',
        '  "dates": {',
        '    "offerDeadline": "' + EXISTING_PUBLICATION_OFFER_DEADLINE + '",',
        '    "publicationDate": "' + EXISTING_PUBLICATION_DATE + '"',
        '  },',
        '  "ted": {',
        '    "status": "' + INCOMING_PUBLICATION_DETAIL_TED_STATUS + '",',
        '    "url": "' + INCOMING_PUBLICATION_DETAIL_TED_URL + '"',
        '  }',
        '}'
    }, '\n');
    
    // Publication types for tests
    public static final String PUBLICATION_TYPE1_NAME = 'Type Publication 1';
    public static final String PUBLICATION_TYPE1_SIMAP_VALUE = 'tender';
    public static final Boolean PUBLICATION_TYPE1_IN_API_SIMAP = true;
    public static final String PUBLICATION_TYPE2_NAME = 'Type Publication 2';
    public static final String PUBLICATION_TYPE2_SIMAP_VALUE = 'result';
    public static final Boolean PUBLICATION_TYPE2_IN_API_SIMAP = false;

    public static void createTestData() {
        createCantons();
        createCodesCPV();
        createProjectSubTypes();
        createPublicationTypes();
        insertPublicationHeader();
        insertProjet();
        createCodeCfcBkp('BKP-DEFAULT', true);
    }

    public static void createCantons () {
        Simap_Cantons__c vaud = new Simap_Cantons__c();
        Simap_Cantons__c geneve = new Simap_Cantons__c();

        vaud.Name = VAUD_CANTON_NAME;
        vaud.simap_id__c = VAUD_CANTON_ID;
        vaud.inclus_dans_API_SIMAP__c = VAUD_CANTON_IN_API_SIMAP;
        vaud.Abbreviation__c = VAUD_CANTON_ABBREVIATION;

        geneve.Name = GENEVE_CANTON_NAME;
        geneve.simap_id__c	= GENEVE_CANTON_ID;
        geneve.inclus_dans_API_SIMAP__c = GENEVE_CANTON_IN_API_SIMAP;
        geneve.Abbreviation__c = GENEVE_CANTON_ABBREVIATION;

        insert vaud;
        insert geneve;
    }

    public static void createCodesCPV() {
        Simap_Code_CPV__c activeCPVCode = new Simap_Code_CPV__c();
        Simap_Code_CPV__c inactiveCPVCode = new Simap_Code_CPV__c();

        activeCPVCode.Name = CPV_CODE1_NAME;
        activeCPVCode.Secteur_d_activite__c = CPV_CODE1_SECTOR;
        activeCPVCode.Code_CPV__c = CPV_CODE1_CODE;
        activeCPVCode.inclus_dans_API_SIMAP__c = true;

        inactiveCPVCode.Name = CPV_CODE2_NAME;
        inactiveCPVCode.Secteur_d_activite__c = CPV_CODE2_SECTOR;
        inactiveCPVCode.Code_CPV__c = CPV_CODE2_CODE;
        inactiveCPVCode.inclus_dans_API_SIMAP__c = false;

        insert activeCPVCode;
        insert inactiveCPVCode;
    }

    public static void createProjectSubTypes() {
        Simap_Type_de_Contrat__c activeProjectSubType = new Simap_Type_de_Contrat__c();
        Simap_Type_de_Contrat__c inactiveProjectSubType = new Simap_Type_de_Contrat__c();

        activeProjectSubType.Name = PROJECT_SUBTYPE1_NAME;
        activeProjectSubType.Nom_API_param__c = PROJECT_SUBTYPE1_API_PARAM;
        activeProjectSubType.inclus_dans_API_SIMAP__c = PROJECT_SUBTYPE1_IN_API_SIMAP;

        inactiveProjectSubType.Name = PROJECT_SUBTYPE2_NAME;
        inactiveProjectSubType.Nom_API_param__c = PROJECT_SUBTYPE2_API_PARAM;
        inactiveProjectSubType.inclus_dans_API_SIMAP__c = PROJECT_SUBTYPE2_IN_API_SIMAP;

        insert activeProjectSubType;
        insert inactiveProjectSubType;
    }

    public static void createPublicationTypes() {
        Simap_Type_de_Publication__c activeType = new Simap_Type_de_Publication__c();
        Simap_Type_de_Publication__c inactiveType = new Simap_Type_de_Publication__c();

        activeType.Name = PUBLICATION_TYPE1_NAME;
        activeType.simap_value__c = PUBLICATION_TYPE1_SIMAP_VALUE;
        activeType.inclus_dans_API_SIMAP__c = PUBLICATION_TYPE1_IN_API_SIMAP;

        inactiveType.Name = PUBLICATION_TYPE2_NAME;
        inactiveType.simap_value__c = PUBLICATION_TYPE2_SIMAP_VALUE;
        inactiveType.inclus_dans_API_SIMAP__c = PUBLICATION_TYPE2_IN_API_SIMAP;

        insert activeType;
        insert inactiveType;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static SimapHeadersService.SimapSwissLangSet createSwissLangset(String francais, String deutsch, String italiano, String english) {
        SimapHeadersService.SimapSwissLangSet langSet = new SimapHeadersService.SimapSwissLangSet();
    
        langSet.fr = francais;
        langSet.de = deutsch;
        langSet.it = italiano;
        langSet.en = english;

        return langSet;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static SimapPublicationDetailService.SimapAdress createAddress(
        SimapHeadersService.SimapSwissLangSet city,
        SimapHeadersService.SimapSwissLangSet street,
        String countryId,
        String postalCode,
        String cantonId
    ) {
        SimapPublicationDetailService.SimapAdress addr = new SimapPublicationDetailService.SimapAdress();

        addr.city = city;
        addr.street = street;
        addr.countryId = countryId;
        addr.postalCode = postalCode;
        addr.cantonId = cantonId;

        return addr;
    }

    public static SimapHeadersService.SimapOrderAddress createOrderAddress(
        SimapHeadersService.SimapSwissLangSet city,
        String countryId,
        String postalCode,
        String cantonId
    ) {
        SimapHeadersService.SimapOrderAddress addr = new SimapHeadersService.SimapOrderAddress();

        addr.city = city;
        addr.countryId = countryId;
        addr.postalCode = postalCode;
        addr.cantonId = cantonId;

        return addr;
    }

    public static void insertPublicationHeader() {
        Publication_Simap__c existingPubHeader = new Publication_Simap__c();

        existingPubHeader.Name = PublicationSimap.PUBLICATION_PREFIX + EXISTING_PUBLICATION_NUMBER;
        existingPubHeader.Numero_de_publication__c = EXISTING_PUBLICATION_NUMBER;
        existingPubHeader.Id_publication_page__c = EXISTING_PUBLICATION_PAGE_ID;
        existingPubHeader.Numero_de_projet__c = EXISTING_PUBLICATION_PROJECT_NUMBER;
        existingPubHeader.Date_de_publication__c = Date.valueOf(EXISTING_PUBLICATION_DATE);
        existingPubHeader.Id_publication_detail__c = EXISTING_PUBLICATION_DETAIL_ID;
        existingPubHeader.Deadline_Offre__c = Date.valueOf(EXISTING_PUBLICATION_OFFER_DEADLINE);
        existingPubHeader.Type_de_projet__c = PUBLICATION_TYPE_TENDER;
        existingPubHeader.Type_de_process__c = PUBLICATION_PROCESS_TYPE_OPEN;
        existingPubHeader.Corrige__c = false;

        insert existingPubHeader;
    }

    public static void insertProjet() {
        TriggerHandler.bypassProjetTrigger = true;

        Projet__c proj = new Projet__c();
        proj.Name = 'Test Projet';
        proj.Etat__c = 'En préparation';
        proj.Adresse_Facturation__City__s = 'Lyon';
        proj.Adresse_Facturation__PostalCode__s = '69001';
        proj.Adresse_Facturation__CountryCode__s = 'FR';
        proj.Adresse_Facturation__Street__s = '456 Project Street';
        proj.latitude__c = '45.7640';
        proj.longitude__c = '4.8357';

        insert proj;
    }

    public static Simap_Code_CFC_BKP__c createCodeCfcBkp(String code, Boolean includedInApi) {
        Simap_Code_CFC_BKP__c rec = new Simap_Code_CFC_BKP__c();
        rec.Code_CFC_BKP__c = code;
        rec.inclus_dans_API_SIMAP__c = includedInApi;
        insert rec;
        return rec;
    }
}