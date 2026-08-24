@isTest
public class SimapPublicationDetailServiceTest {
    
    @TestSetup
    public static void setUpTestEnv() {
        TestDataFactory.createTestData();
    }

    @isTest
    public static void testSavePublicationHeader_NewPub() {

        Test.startTest();
            String newPub = SimapPublicationDetailService.savePublicationHeader(TestDataFactory.SIMAP_HEADER_RESPONSE_1);
        Test.stopTest();

        Publication_Simap__c pub = (Publication_Simap__c)JSON.deserialize(newPub, Publication_Simap__c.class);

        System.assertEquals(pub.Numero_de_publication__c, TestDataFactory.INCOMING_PUBLICATION_NUMBER, 'testSavePublicationHeader : wrong Publication number');
        System.assertEquals(pub.Type_de_publication__c, TestDataFactory.PUBLICATION_TYPE_TENDER, 'testSavePublicationHeader: wrong Publication type');
        System.assertEquals(pub.Type_de_process__c, TestDataFactory.PUBLICATION_PROCESS_TYPE_OPEN, 'testSavePublicationHeader : wrong Publication process type');
        System.assertEquals(pub.Id_publication_page__c, TestDataFactory.INCOMING_PUBLICATION_PAGE_ID, 'testSavePublicationHeader : wrong Publication page id');
        System.assertEquals(pub.Titre_de_publication__c, TestDataFactory.FR, 'testSavePublicationHeader : wrong Publication title');
        System.assertEquals(pub.Bureau_d_achat__c, TestDataFactory.FR, 'testSavePublicationHeader : wrong Procurement office name');
        System.assertEquals(pub.Date_de_publication__c, Date.valueOf(TestDataFactory.INCOMING_PUBLICATION_DATE), 'testSavePublicationHeader : wrong Publication date');
        System.assertEquals(pub.Deadline_Offre__c, Date.valueOf(TestDataFactory.INCOMING_PUBLICATION_OFFER_DEADLINE), 'testSavePublicationHeader : wrong Offer deadline');
        System.assertEquals(pub.Corrige__c, false, 'testSavePublicationHeader : wrong Corrected');
        System.assertEquals(pub.Name, PublicationSimap.PUBLICATION_PREFIX + TestDataFactory.INCOMING_PUBLICATION_NUMBER, 'testSavePublicationHeader : wrong Publication name');
        System.assertEquals(pub.Id_publication_detail__c, TestDataFactory.INCOMING_PUBLICATION_DETAIL_ID, 'testSavePublicationHeader : wrong Publication detail id');
        System.assertEquals(2, [SELECT count() FROM Publication_Simap__c], 'testSavePublicationHeader : wrong number of publications');
    }

    @isTest
    public static void testSavePublicationHeader_ExistingPub() {

        Test.startTest();
            String existingPub = SimapPublicationDetailService.savePublicationHeader(TestDataFactory.SIMAP_HEADER_RESPONSE_2);
        Test.stopTest();

        Publication_Simap__c pub = (Publication_Simap__c)JSON.deserialize(existingPub, Publication_Simap__c.class);

        System.assertEquals(pub.Id_publication_detail__c, TestDataFactory.EXISTING_PUBLICATION_DETAIL_ID, 'testSavePublicationHeader : wrong Publication detail id');
        System.assertEquals(1, [SELECT count() FROM Publication_Simap__c], 'testSavePublicationHeader : wrong number of publications');
    }

    @isTest
    public static void testGetPublicationDetail() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponseDetail());

        Publication_Simap__c existingPub = [
            SELECT
                Id
            FROM
                Publication_Simap__c
            LIMIT 1
        ];

        Test.startTest();
            String updatedPub = SimapPublicationDetailService.getPublicationDetail(existingPub.Id);
            System.debug(updatedPub);
        Test.stopTest();

        Publication_Simap__c pub = (Publication_Simap__c)JSON.deserialize(updatedPub, Publication_Simap__c.class);

        System.debug(pub);

        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_TED_STATUS, pub.statut__c, 'testGetPublicationDetail : wrong TED status');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_TED_URL, pub.Url__c, 'testGetPublicationDetail : wrong TED url');
        System.assertEquals(TestDataFactory.FR, pub.Denomination_CPV__c, 'testGetPublicationDetail : wrong CPV label');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_BASE_TYPE, pub.Type_de_l_offre__c, 'testGetPublicationDetail : wrong Offer type');
        System.assertEquals(TestDataFactory.CPV_CODE1_CODE, pub.Code_CPV__c, 'testGetPublicationDetail : wrong CPV code');
        System.assertEquals(TestDataFactory.FR, pub.Nom_de_l_offre__c, 'testGetPublicationDetail : wrong Offer name');
        System.assertEquals(TestDataFactory.FR, pub.Adresse_bureau_d_achat_formatee__City__s, 'testGetPublicationDetail : wrong Procurement office city');
        System.assertEquals(TestDataFactory.COUNTRY_CODE, pub.Adresse_bureau_d_achat_formatee__CountryCode__s, 'testGetPublicationDetail : wrong Procurement office country');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_POSTAL_CODE, pub.Adresse_bureau_d_achat_formatee__PostalCode__s, 'testGetPublicationDetail : wrong Procurement office postal code');
        System.assertEquals(TestDataFactory.FR, pub.Adresse_bureau_d_achat_formatee__Street__s, 'testGetPublicationDetail : wrong Procurement office postal code');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_PHONE, pub.Telephone_bureau_d_achat__c, 'testGetPublicationDetail : wrong Telephone_bureau_d_achat__c');
        System.assertEquals(TestDataFactory.INCOMING_PUBLICATION_DETAIL_EMAIL, pub.Email_bureau_d_achat__c, 'testGetPublicationDetail : wrong Email_bureau_d_achat__c');
        System.assertEquals(TestDataFactory.FR, pub.Info_generale__c, 'testGetPublicationDetail : wrong Info_generale__c');
        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, pub.offre_canton__c, 'testGetPublicationDetail : wrong offre_canton__c');
        System.assertEquals(TestDataFactory.FR, pub.order_description__c, 'testGetPublicationDetail : wrong order_description__c');
    }

    @isTest
    public static void testFetchPublicationDetail() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MockHttpSimapResponseDetail());

        Test.startTest();
            SimapPublicationDetailService.SimapPublicationDetailResponse simapDetailResponse = SimapPublicationDetailService.fetchPublicationDetail(TestDataFactory.INCOMING_PUBLICATION_PAGE_ID, TestDataFactory.INCOMING_PUBLICATION_DETAIL_ID);
        Test.stopTest();

        System.assertNotEquals(null, simapDetailResponse.base, 'testFetchPublicationDetail : base cannot be null');
        System.assertNotEquals(null, simapDetailResponse.procurement, 'testFetchPublicationDetail : procurement cannot be null');
        System.assertNotEquals(null, simapDetailResponse.projectInfo, 'testFetchPublicationDetail : projectInfo cannot be null');
        System.assertNotEquals(null, simapDetailResponse.ted, 'testFetchPublicationDetail : ted cannot be null');
    }
}