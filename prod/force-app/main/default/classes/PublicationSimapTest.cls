@isTest
global class PublicationSimapTest {

    @TestSetup
    public static void setUpTestEnv() {
        TestDataFactory.createTestData();
    }

    @isTest
    public static void testInsertPublicationHeader() {
        List<Publication_Simap__c> publications = new List<Publication_Simap__c>();
        Publication_Simap__c insertedPublication;
        SimapHeadersService.PublicationDeserializer rawPubData = (SimapHeadersService.PublicationDeserializer)JSON.deserialize(TestDataFactory.SIMAP_HEADER_RESPONSE_1, SimapHeadersService.PublicationDeserializer.class);

        Test.startTest();
            insertedPublication = PublicationSimap.insertPublicationHeader(rawPubData);
            publications = [SELECT Id, Bureau_d_achat__c, Numero_de_projet__c, Numero_de_publication__c, Id_publication_detail__c, Id_publication_page__c, Titre_de_publication__c, Name, Date_de_publication__c, Deadline_Offre__c, Type_de_projet__c, Type_de_publication__c, Type_de_process__c, Corrige__c, Lieu_d_execution__c FROM Publication_Simap__c WHERE Id = :insertedPublication.Id];
        Test.stopTest();

        Publication_Simap__c publication = publications[0];

        System.assertEquals(1, publications.size(), 'testInsertPublicationHeader : Expected one publication record to be created.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_NUMBER, publication.Numero_de_publication__c, 'testInsertPublicationHeader : Publication number does not match.');
        System.assertEquals(TestDataFactory.FR, publication.Titre_de_publication__c, 'testInsertPublicationHeader : Publication title does not match.');
        System.assertEquals(TestDataFactory.FR, publication.Bureau_d_achat__c, 'testInsertPublicationHeader : Procurement office name does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PROJECT_NUMBER, publication.Numero_de_projet__c, 'testInsertPublicationHeader : Project number does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_ID, publication.Id_publication_detail__c, 'testInsertPublicationHeader : Publication ID does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_PAGE_ID, publication.Id_publication_page__c, 'testInsertPublicationHeader : Publication page ID does not match.');
        System.assertEquals(PublicationSimap.PUBLICATION_PREFIX + TestDataFactory.INCOMING_PUBLICATION_NUMBER, publication.Name, 'testInsertPublicationHeader : Name does not match.');
        System.assertEquals(Date.valueOf(TestDataFactory.INCOMING_PUBLICATION_DATE), publication.Date_de_publication__c, 'testInsertPublicationHeader : Publication date does not match.');
        System.assertEquals(Date.valueOf(TestDataFactory.INCOMING_PUBLICATION_OFFER_DEADLINE), publication.Deadline_Offre__c, 'testInsertPublicationHeader : Offer deadline does not match.');
        System.assertEquals(TestDataFactory.PUBLICATION_TYPE_TENDER, publication.Type_de_projet__c, 'testInsertPublicationHeader : Project type does not match.');
        System.assertEquals(TestDataFactory.PUBLICATION_PROCESS_TYPE_OPEN, publication.Type_de_process__c, 'testInsertPublicationHeader : Publication type does not match.');
        System.assertEquals(false, publication.Corrige__c, 'testInsertPublicationHeader : Corrected field does not match.');
        System.assertEquals(
            TestDataFactory.POSTAL_CODE + ' ' + TestDataFactory.FR + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.CANTON_ID + SimapUtils.ADDRESS_SEPARATOR + 'Suisse',
            publication.Lieu_d_execution__c,
            'testInsertPublicationHeader : Order address does not match.'
        );
    }

    @isTest
    public static void testUpdatePublicationWithDetails() {
        Publication_Simap__c existingHeader = [
            SELECT
                Id,
                Name,
                Type_de_process__c,
                Date_de_publication__c,
                Deadline_Offre__c,
                Corrige__c,
                offre_canton__c,
                Numero_de_publication__c
            FROM
                Publication_Simap__c
            LIMIT 1
        ];

        SimapPublicationDetailService.SimapPublicationDetailResponse simapDetailResponse = (SimapPublicationDetailService.SimapPublicationDetailResponse)JSON.deserialize(TestDataFactory.SIMAP_DETAIL_RESPONSE_1, SimapPublicationDetailService.SimapPublicationDetailResponse.class);

        Test.startTest();
            Publication_Simap__c updatedPublication = PublicationSimap.updatePublicationWithDetails(existingHeader, simapDetailResponse);
        Test.stopTest();

        System.assertEquals(PublicationSimap.PUBLICATION_PREFIX + TestDataFactory.EXISTING_PUBLICATION_NUMBER, updatedPublication.Name, 'testUpdatePublicationWithDetails : Name does not match.');
        System.assertEquals(TestDataFactory.EXISTING_PUBLICATION_NUMBER, updatedPublication.Numero_de_publication__c, 'testUpdatePublicationWithDetails : Publication number does not match.');
        System.assertEquals(TestDataFactory.PUBLICATION_PROCESS_TYPE_OPEN, updatedPublication.Type_de_process__c, 'testUpdatePublicationWithDetails : Process type does not match.');
        System.assertEquals(TestDataFactory.CPV_CODE1_CODE, updatedPublication.Code_CPV__c, 'testUpdatePublicationWithDetails : CPV code does not match.');
        System.assertEquals(TestDataFactory.FR, updatedPublication.Denomination_CPV__c, 'testUpdatePublicationWithDetails : CPV label does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_BASE_TYPE, updatedPublication.Type_de_l_offre__c, 'testUpdatePublicationWithDetails : Tender type does not match.');
        System.assertEquals(TestDataFactory.FR, updatedPublication.Nom_de_l_offre__c, 'testUpdatePublicationWithDetails : Tender title does not match.');
        System.assertEquals(Date.valueOf(TestDataFactory.EXISTING_PUBLICATION_DATE), updatedPublication.Date_de_publication__c, 'testUpdatePublicationWithDetails : Publication date does not match.');
        System.assertEquals(Date.valueOf(TestDataFactory.EXISTING_PUBLICATION_OFFER_DEADLINE), updatedPublication.Deadline_Offre__c, 'testUpdatePublicationWithDetails : Offer deadline does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_TED_STATUS, updatedPublication.statut__c, 'testUpdatePublicationWithDetails : TED status does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_TED_URL, updatedPublication.Url__c, 'testUpdatePublicationWithDetails : TED URL does not match.');
        System.assertEquals(false, updatedPublication.Corrige__c, 'testUpdatePublicationWithDetails : Corrected field does not match.');
        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, updatedPublication.offre_canton__c, 'testUpdatePublicationWithDetails : Canton abbreviation does not match.');
        System.assertEquals(TestDataFactory.COUNTRY_CODE, updatedPublication.Adresse_bureau_d_achat_formatee__CountryCode__s, 'testUpdatePublicationWithDetails : Country code does not match.');
        System.assertEquals(TestDataFactory.FR, updatedPublication.Adresse_bureau_d_achat_formatee__City__s, 'testUpdatePublicationWithDetails : City name does not match.');
        System.assertEquals(TestDataFactory.FR, updatedPublication.Adresse_bureau_d_achat_formatee__Street__s, 'testUpdatePublicationWithDetails : Street code does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_POSTAL_CODE, updatedPublication.Adresse_bureau_d_achat_formatee__PostalCode__s, 'testUpdatePublicationWithDetails : Canton name does not match.');
        System.assertEquals(TestDataFactory.FR, updatedPublication.Info_generale__c, 'testUpdatePublicationWithDetails : General info does not match.'); 
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_PHONE, updatedPublication.Telephone_bureau_d_achat__c, 'testUpdatePublicationWithDetails : Phone does not match.');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_EMAIL, updatedPublication.Email_bureau_d_achat__c, 'testUpdatePublicationWithDetails : Email does not match.');
    }

    @isTest
    public static void testGetVisitedSimapPublications() {

        Set<String> publicationIds = new Set<String>();
        publicationIds.add(TestDataFactory.EXISTING_PUBLICATION_PAGE_ID);
        publicationIds.add(TestDataFactory.INCOMING_PUBLICATION_PAGE_ID);

        Test.startTest();
            List<Publication_Simap__c> visitedPublications = PublicationSimap.getVisitedSimapPublications(publicationIds);
        Test.stopTest();

        System.assertEquals(1, visitedPublications.size(), 'testGetVisitedSimapPublications : Expected one visited publication record to be returned.');
        System.assertEquals(TestDataFactory.EXISTING_PUBLICATION_PAGE_ID, visitedPublications[0].Id_publication_page__c, 'testGetVisitedSimapPublications : Publication page ID does not match.');
    }

    @isTest
    public static void testGetPublicationSimapByDetailId() {
        List<Publication_Simap__c> existingPublications = PublicationSimap.getPublicationSimapByDetailId(TestDataFactory.EXISTING_PUBLICATION_DETAIL_ID);

        System.assertEquals(1, existingPublications.size(), 'testGetPublicationSimapByDetailId : Expected one publication record to be returned.');
        System.assertEquals(TestDataFactory.EXISTING_PUBLICATION_DETAIL_ID, existingPublications[0].Id_publication_detail__c, 'testGetPublicationSimapByDetailId : Publication detail ID does not match.');
    }

    @isTest
    public static void testGetPublicationById() {
        Publication_Simap__c newPublication = new Publication_Simap__c();

        insert newPublication;

        Test.startTest();
            Publication_Simap__c existingPublication = PublicationSimap.getPublicationById(newPublication.Id);
        Test.stopTest();

        System.assertEquals(newPublication.Id, existingPublication.Id, 'testGetPublicationById : Publication ID does not match.');
    }

}