@isTest
public class SimapHeadersServiceTest {

    public static final String ONE_PROJECT_LAST_ITEM = 'one_project_last_item';
    public static final String TWO_PROJECTS_LAST_ITEM = 'two_projects_last_item';

    // records the called endpoint to assert on the built URL
    public class MockEndpointRecorder implements HttpCalloutMock {
        public String calledEndpoint;

        public HTTPResponse respond(HTTPRequest req) {
            this.calledEndpoint = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(TestDataFactory.oneProjectBody);

            return res;
        }
    }

    @TestSetup
    public static void setUpTestEnv() {
        TestDataFactory.createTestData();
    }

    @isTest
    public static void testSearchByCriteria() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            String response = SimapHeadersService.searchByCriteria(ONE_PROJECT_LAST_ITEM);
        Test.stopTest();

        SimapHeadersService.SimapResponse parsedResponse = (SimapHeadersService.SimapResponse)JSON.deserialize(response, SimapHeadersService.SimapResponse.class);
        SimapHeadersService.PublicationDeserializer incomingHeader = parsedResponse.projects[0];

        System.assertEquals(TestDataFactory.PUBLICATION_TYPE_TENDER, incomingHeader.projectType, 'testSearchByCriteria : Project type should be tender');
        System.assertEquals(TestDataFactory.PUBLICATION_PROCESS_TYPE_OPEN, incomingHeader.processType, 'testSearchByCriteria : wrong process type');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_NUMBER, incomingHeader.publicationNumber, 'testSearchByCriteria : wrong publication number');
        System.assertEquals(TestDataFactory.PUBLICATION_TYPE_TENDER, incomingHeader.pubType, 'testSearchByCriteria : wrong publication type');
        System.assertEquals(false, incomingHeader.corrected, 'testSearchByCriteria : wrong corrected status');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PAGE_ID, incomingHeader.id, 'testSearchByCriteria : wrong publication page id');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PROJECT_NUMBER, incomingHeader.projectNumber, 'testSearchByCriteria : wrong project number');
        System.assertEquals(TestDataFactory.FR, incomingHeader.title.fr, 'testSearchByCriteria : wrong title');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DATE, incomingHeader.publicationDate, 'testSearchByCriteria : wrong publication date');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_ID, incomingHeader.publicationId, 'testSearchByCriteria : wrong publication detail id');
        System.assertEquals(TestDataFactory.FR, incomingHeader.procOfficeName.fr, 'testSearchByCriteria : wrong proc office name');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_OFFER_DEADLINE, incomingHeader.offerDeadline, 'testSearchByCriteria : wrong offer deadline');
        System.assertEquals(TestDataFactory.COUNTRY_CODE, incomingHeader.orderAddress.countryId, 'testSearchByCriteria : wrong order address country');
        System.assertEquals(TestDataFactory.CANTON_ID, incomingHeader.orderAddress.cantonId, 'testSearchByCriteria : wrong order address canton');
        System.assertEquals(TestDataFactory.POSTAL_CODE, incomingHeader.orderAddress.postalCode, 'testSearchByCriteria : wrong order address postal code');
        System.assertEquals(TestDataFactory.FR, incomingHeader.orderAddress.city.fr, 'testSearchByCriteria : wrong order address city');
    }

    @isTest
    public static void testfetchSimapByCriteria() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByCriteria(ONE_PROJECT_LAST_ITEM);
        Test.stopTest();

        System.assertNotEquals(null, response, 'testfetchSimapByCriteria : response should not be null');
        System.assertEquals(1, response.projects.size(), 'testfetchSimapByCriteria : wrong number of projects');
    }

    @isTest
    public static void testFetchSimapByKeyWord() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByKeyWord(TestDataFactory.INCOMING_PUBLICATION_DETAIL_REFERENCE, ONE_PROJECT_LAST_ITEM);
        Test.stopTest();

        System.assertNotEquals(null, response, 'testFetchSimapByKeyWord : response should not be null');
        System.assertEquals(1, response.projects.size(), 'testFetchSimapByKeyWord : wrong number of projects');
    }

    @isTest
    public static void testSearchByKeyWord() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());
            
        Test.startTest();
            String response = SimapHeadersService.searchByKeyWord(TestDataFactory.INCOMING_PUBLICATION_DETAIL_REFERENCE, ONE_PROJECT_LAST_ITEM);
        Test.stopTest();

        SimapHeadersService.SimapResponse parsedResponse = (SimapHeadersService.SimapResponse)JSON.deserialize(response, SimapHeadersService.SimapResponse.class);
        SimapHeadersService.PublicationDeserializer incomingHeader = parsedResponse.projects[0];
    
        System.assertEquals(TestDataFactory.PUBLICATION_TYPE_TENDER, incomingHeader.projectType, 'testSearchByCriteria : Project type should be tender');
        System.assertEquals(TestDataFactory.PUBLICATION_PROCESS_TYPE_OPEN, incomingHeader.processType, 'testSearchByCriteria : wrong process type');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_NUMBER, incomingHeader.publicationNumber, 'testSearchByCriteria : wrong publication number');
        System.assertEquals(TestDataFactory.PUBLICATION_TYPE_TENDER, incomingHeader.pubType, 'testSearchByCriteria : wrong publication type');
        System.assertEquals(false, incomingHeader.corrected, 'testSearchByCriteria : wrong corrected status');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PAGE_ID, incomingHeader.id, 'testSearchByCriteria : wrong publication page id');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PROJECT_NUMBER, incomingHeader.projectNumber, 'testSearchByCriteria : wrong project number');
        System.assertEquals(TestDataFactory.FR, incomingHeader.title.fr, 'testSearchByCriteria : wrong title');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DATE, incomingHeader.publicationDate, 'testSearchByCriteria : wrong publication date');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_ID, incomingHeader.publicationId, 'testSearchByCriteria : wrong publication detail id');
        System.assertEquals(TestDataFactory.FR, incomingHeader.procOfficeName.fr, 'testSearchByCriteria : wrong proc office name');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_OFFER_DEADLINE, incomingHeader.offerDeadline, 'testSearchByCriteria : wrong offer deadline');
    }

    @isTest
    public static void testSearchByKeyWordNoResults() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            String response = SimapHeadersService.searchByKeyWord(TestDataFactory.NON_EXISTING_KEYWORD, null);
        Test.stopTest();

        SimapHeadersService.SimapResponse parsedResponse = (SimapHeadersService.SimapResponse)JSON.deserialize(response, SimapHeadersService.SimapResponse.class);

        System.assertEquals(0, parsedResponse.projects.size(), 'testSearchByCriteriaNoResults : wrong number of projects');
    }

    @isTest
    public static void testBuildKeyWordPhrase() {
        System.assertEquals('"LA PERCHE II"', SimapHeadersService.buildKeyWordPhrase('LA PERCHE II'), 'testBuildKeyWordPhrase : keyword should be wrapped in double quotes');
        System.assertEquals('"LA PERCHE II"', SimapHeadersService.buildKeyWordPhrase('  LA PERCHE II  '), 'testBuildKeyWordPhrase : keyword should be trimmed');
        System.assertEquals('"LA PERCHE II"', SimapHeadersService.buildKeyWordPhrase('"LA PERCHE II"'), 'testBuildKeyWordPhrase : quotes typed by the user should not be doubled');
    }

    @isTest
    public static void testFetchSimapByKeyWordUrlCarriesQuotedPhrase() {
        MockEndpointRecorder mock = new MockEndpointRecorder();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            SimapHeadersService.fetchSimapByKeyWord('LA PERCHE II', null);
        Test.stopTest();

        System.assertEquals(
            true,
            mock.calledEndpoint.contains(SimapHeadersService.SEARCH_BY_KEYWORD_PARAM + '%22LA+PERCHE+II%22'),
            'testFetchSimapByKeyWordUrlCarriesQuotedPhrase : search param should hold the url encoded quoted phrase, got ' + mock.calledEndpoint
        );
    }

    @isTest
    public static void testSearchByKeyWordTooShort() {
        try {
            SimapHeadersService.searchByKeyWord('"a"', null);
            System.assert(false, 'testSearchByKeyWordTooShort : exception should have been thrown');
        } catch (SimapHeadersService.SimapHeadersServiceException e) {
            System.assertEquals('Keyword is too short', e.getMessage(), 'testSearchByKeyWordTooShort : wrong exception message');
        }
    }

    @isTest
    public static void testGetSimapResponse() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());
        String params = SimapHeadersService.getUrlParams(ONE_PROJECT_LAST_ITEM);

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.getSimapResponse(params);
        Test.stopTest();

        System.assertNotEquals(null, response, 'testGetSimapResponse : response should not be null');
        System.assertEquals(1, response.projects.size(), 'testGetSimapResponse : wrong number of projects');
    }

    @isTest
    public static void testFetchNewPublications() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());
        String params = SimapHeadersService.getUrlParams(ONE_PROJECT_LAST_ITEM);

        Test.startTest();
            String response = SimapHeadersService.fetchNewPublications(params);
        Test.stopTest();

        System.assertNotEquals(null, response, 'testFetchNewPublications : response should not be null');
        System.assertEquals(TestDataFactory.oneProjectBody, response, 'testFetchNewPublications : wrong response');
    }

    @isTest
    public static void testGetUrlParams() {
        String selectedCantonParam = SimapHeadersService.ISSUED_BY_ORGANIZATIONS_PARAM + TestDataFactory.VAUD_CANTON_ID;
        String selectedCodeCPVParam = SimapHeadersService.CPV_CODES_PARAM + TestDataFactory.CPV_CODE1_CODE;
        String selectedCodeCfcBkpParam = SimapHeadersService.CODE_CFC_BKP_PARAM + 'BKP-DEFAULT';
        String selectedTypeDePublicationParam = SimapHeadersService.TYPE_DE_PUBLICATION_PARAM + TestDataFactory.PUBLICATION_TYPE1_SIMAP_VALUE;
        String excludedTypeDePublicationParam = SimapHeadersService.TYPE_DE_PUBLICATION_PARAM + TestDataFactory.PUBLICATION_TYPE2_SIMAP_VALUE;
        List<SObject> selectedProjectSubTypes = SimapUtils.getSelectedProjectSubTypes();
        String projectSubTypeParam = SimapHeadersService.PROJECT_SUBTYPE_PARAM + selectedProjectSubTypes[0].get('Nom_API_param__c');

        Test.startTest();
            String params = SimapHeadersService.getUrlParams(ONE_PROJECT_LAST_ITEM);
            String paramsWithNullLastItem = SimapHeadersService.getUrlParams(null);
        Test.stopTest();

        System.assertEquals(true, params.contains(selectedCantonParam), 'testGetUrlParams : selected canton param should be present');
        System.assertEquals(true, params.contains(selectedCodeCPVParam), 'testGetUrlParams : selected code CPV param should be present');
        System.assertEquals(true, params.contains(projectSubTypeParam), 'testGetUrlParams : project sub type param should be present');
        System.assertEquals(true, params.contains(selectedCodeCfcBkpParam), 'testGetUrlParams : code CFC/BKP param should be present when included');
        System.assertEquals(true, params.contains(selectedTypeDePublicationParam), 'testGetUrlParams : active type de publication should be present');
        System.assertEquals(false, params.contains(excludedTypeDePublicationParam), 'testGetUrlParams : inactive type de publication should be excluded');
        System.assertEquals(false, paramsWithNullLastItem.contains(SimapHeadersService.LAST_ITEM_PARAM), 'testGetUrlParams : last item param should be present');
    }

    @isTest
    public static void testGetUrlParamsCodeCfcBkpExcludedWhenFlagFalse() {
        delete [SELECT Id FROM Simap_Code_CFC_BKP__c];
        TestDataFactory.createCodeCfcBkp('BKP-EXCLUDED', false);

        Test.startTest();
            String params = SimapHeadersService.getUrlParams(null);
        Test.stopTest();

        System.assertEquals(false, params.contains(SimapHeadersService.CODE_CFC_BKP_PARAM), 'testGetUrlParams_CodeCfcBkpExcludedWhenFlagFalse : code CFC/BKP should be excluded');
    }

    @isTest
    public static void testFetchSimapByCodeCfcBkp() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByCodeCfcBkp('BKP-123', null);
        Test.stopTest();

        System.assertNotEquals(null, response, 'testFetchSimapByCodeCfcBkp : response should not be null');
        System.assertEquals(1, response.projects.size(), 'testFetchSimapByCodeCfcBkp : wrong number of projects');
    }

    @isTest
    public static void testSearchByCodeCfcBkp() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            String response = SimapHeadersService.searchByCodeCfcBkp('BKP-123', null);
        Test.stopTest();

        SimapHeadersService.SimapResponse parsedResponse = (SimapHeadersService.SimapResponse)JSON.deserialize(response, SimapHeadersService.SimapResponse.class);
        System.assertEquals(1, parsedResponse.projects.size(), 'testSearchByCodeCfcBkp : wrong number of projects');
    }

    @isTest
    public static void testSearchByCodeCfcBkpTooShort() {
        try {
            SimapHeadersService.searchByCodeCfcBkp('BK', null);
            System.assert(false, 'testSearchByCodeCfcBkp_TooShort : exception should have been thrown');
        } catch (SimapHeadersService.SimapHeadersServiceException e) {
            System.assertEquals('Code CFC / BKP is too short', e.getMessage(), 'testSearchByCodeCfcBkp_TooShort : wrong exception message');
        }
    }

    @isTest
    public static void testAddPublicationVisitedStatus() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());
        
        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByCriteria(TWO_PROJECTS_LAST_ITEM);
            response = SimapHeadersService.addPublicationVisitedStatus(response);
        Test.stopTest();

        System.assertEquals(2, response.projects.size(), 'testAddPublicationVisitedStatus : wrong number of projects');
        System.assertEquals(SimapHeadersService.NEW_STATUS, response.projects[0].actionStatus, 'testAddPublicationVisitedStatus : first project should be visited');
        System.assertEquals(SimapHeadersService.VISITED_STATUS, response.projects[1].actionStatus, 'testAddPublicationVisitedStatus : second project should be visited');
    }

    @isTest
    public static void testAddPublicationVisitedStatusWithProjet() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());
        TriggerHandler.bypassProjetTrigger = true;
        
        Projet__c proj = [
            SELECT
                Id
            FROM
                Projet__c
            LIMIT 1
        ];

        Publication_Simap__c pubToUpdate = [
            SELECT
                Id,
                Projet__c
            FROM
                Publication_Simap__c
            LIMIT 1
        ];

        pubToUpdate.Projet__c = proj.Id;
        update pubToUpdate;

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByCriteria(TWO_PROJECTS_LAST_ITEM);
            response = SimapHeadersService.addPublicationVisitedStatus(response);
        Test.stopTest();

        System.assertEquals(2, response.projects.size(), 'testAddPublicationVisitedStatus_WithProjet : wrong number of projects');
        System.assertEquals(SimapHeadersService.CONVERTED_STATUS, response.projects[1].actionStatus, 'testAddPublicationVisitedStatus_WithProjet : first project should be converted');
    }

    @isTest
    public static void testAddSelectedSearchFilters() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponse());

        Test.startTest();
            SimapHeadersService.SimapResponse response = SimapHeadersService.fetchSimapByCriteria(TWO_PROJECTS_LAST_ITEM);
            response = SimapHeadersService.addSelectedSearchFilters(response);
        Test.stopTest();

        System.assertEquals(1, response.filters.cantonalEntities.size(), 'testAddSelectedSearchFilters : wrong number of selected canton entities');
        System.assertEquals(1, response.filters.simapCodesCPV.size(), 'testAddSelectedSearchFilters : wrong number of selected CPV codes');
        System.assertEquals(1, response.filters.projectSubTypes.size(), 'testAddSelectedSearchFilters : wrong number of selected project sub types');
        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, response.filters.cantonalEntities[0].get('Name'), 'testAddSelectedSearchFilters : wrong selected canton entity');
        System.assertEquals(TestDataFactory.CPV_CODE1_CODE, response.filters.simapCodesCPV[0].Code_CPV__c, 'testAddSelectedSearchFilters : wrong selected CPV code');
    }

}