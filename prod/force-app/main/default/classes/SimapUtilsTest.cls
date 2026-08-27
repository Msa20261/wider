@isTest
global class SimapUtilsTest {

    private static final String SWITZERLAND_LABEL = 'Suisse';
    private static final String UNKNOWN_COUNTRY_CODE = 'XX';

    @TestSetup
    public static void setUpTestEnv() {
        TestDataFactory.createTestData();
    }

    @isTest
    public static void testGetSelectedCantonalEntities() {
        List<Simap_Cantons__c> selectedCantons = new List<Simap_Cantons__c>();

        Test.startTest();
            selectedCantons = (List<Simap_Cantons__c>) SimapUtils.getSelectedCantonalEntities();
        Test.stopTest();

        System.assertEquals(1, selectedCantons.size(), 'testGetSelectedCantonalEntities : there should have been only one canton retrieved');
        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, selectedCantons[0].Name, 'testGetSelectedCantonalEntities : the canton name is wrong');
        System.assertEquals(TestDataFactory.VAUD_CANTON_ID, selectedCantons[0].simap_id__c, 'testGetSelectedCantonalEntities : the canton id is wrong');
        System.assertEquals(TestDataFactory.VAUD_CANTON_IN_API_SIMAP, selectedCantons[0].inclus_dans_API_SIMAP__c, 'testGetSelectedCantonalEntities : the canton inclusion in API SIMAP is wrong');
        System.assertEquals(TestDataFactory.VAUD_CANTON_ABBREVIATION, selectedCantons[0].Abbreviation__c, 'testGetSelectedCantonalEntities : the canton abbreviation is wrong');
    }

    @isTest
    public static void testGetSelectedProjectSubTypes() {
        List<Simap_Type_de_Contrat__c> selectedProjectSubTypes = new List<Simap_Type_de_Contrat__c>();

        Test.startTest();
            selectedProjectSubTypes = (List<Simap_Type_de_Contrat__c>) SimapUtils.getSelectedProjectSubTypes();
        Test.stopTest();

        System.assertEquals(1, selectedProjectSubTypes.size(), 'testGetSelectedProjectSubTypes : there should have been only one project subtype retrieved');
        System.assertEquals(TestDataFactory.PROJECT_SUBTYPE1_NAME, selectedProjectSubTypes[0].Name, 'testGetSelectedProjectSubTypes : the project subtype name is wrong');
        System.assertEquals(TestDataFactory.PROJECT_SUBTYPE1_API_PARAM, selectedProjectSubTypes[0].Nom_API_param__c, 'testGetSelectedProjectSubTypes : the project subtype API param is wrong');
        System.assertEquals(TestDataFactory.PROJECT_SUBTYPE1_IN_API_SIMAP, selectedProjectSubTypes[0].inclus_dans_API_SIMAP__c, 'testGetSelectedProjectSubTypes : the project subtype inclusion in API SIMAP is wrong');
    }

    @isTest
    public static void testGetSelectedSimapCodesCPV() {
        List<Simap_Code_CPV__c> activeCPVCodes = [
            SELECT
                Id,
                inclus_dans_API_SIMAP__c
            FROM
                Simap_Code_CPV__c
        ];

        Simap_Code_CPV__c activeCPVCode = activeCPVCodes[0];
        activeCPVCode.inclus_dans_API_SIMAP__c = true;
        update activeCPVCode;

        List<Simap_Code_CPV__c> selectedSimapCodesCPV = new List<Simap_Code_CPV__c>();

        Test.startTest();
            selectedSimapCodesCPV = SimapUtils.getSelectedSimapCodesCPV();
        Test.stopTest();

        System.assertEquals(1, selectedSimapCodesCPV.size(), 'testGetSelectedSimapCodesCPV : there should have been only one CPV code retrieved');
        System.assertEquals(TestDataFactory.CPV_CODE1_NAME, selectedSimapCodesCPV[0].Name, 'testGetSelectedSimapCodesCPV : the CPV name is wrong');
        System.assertEquals(TestDataFactory.CPV_CODE1_CODE, selectedSimapCodesCPV[0].Code_CPV__c, 'testGetSelectedSimapCodesCPV : the CPV code is wrong');
    }

    @isTest
    public static void testCheckAndTrimLength() {
        String testValue = '1234567890';

        String basicValue = testValue;
        String valueToTrim = '  ' + testValue + '  ';
        String longValue = 'a'.repeat(SimapUtils.CUSTOM_FIELD_MAX_LENGTH);
        String tooLongValue = 'a'.repeat(SimapUtils.CUSTOM_FIELD_MAX_LENGTH + 1);
        String nullValue = null;

        Test.startTest();
            basicValue = SimapUtils.checkAndTrimLength(basicValue);
            valueToTrim = SimapUtils.checkAndTrimLength(valueToTrim);
            longValue = SimapUtils.checkAndTrimLength(longValue);
            tooLongValue = SimapUtils.checkAndTrimLength(tooLongValue);
            nullValue = SimapUtils.checkAndTrimLength(nullValue);
        Test.stopTest();

        System.assertEquals('1234567890', basicValue, 'testCheckAndTrimLength : the basic value should not have been trimmed');
        System.assertEquals('1234567890', valueToTrim, 'testCheckAndTrimLength : the value to trim should have been trimmed');
        System.assertEquals(longValue, longValue, 'testCheckAndTrimLength : the long value should not have been trimmed');
        System.assertEquals(longValue, tooLongValue, 'testCheckAndTrimLength : the too long value should have been trimmed');
        System.assertEquals(null, nullValue, 'testCheckAndTrimLength : the null value should have been returned as null');
    }

    @isTest
    public static void testGetValidField() {
        String frOutput;
        String deOutput;
        String itOutput;
        String enOutput;
        String emptyOutput;
        String frDeOutput;

        SimapHeadersService.SimapSwissLangSet frLangSet = TestDataFactory.createSwissLangset(TestDataFactory.FR, null, null, null);
        SimapHeadersService.SimapSwissLangSet deLangSet = TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null);
        SimapHeadersService.SimapSwissLangSet itLangSet = TestDataFactory.createSwissLangset(null, null, TestDataFactory.IT, null);
        SimapHeadersService.SimapSwissLangSet enLangSet = TestDataFactory.createSwissLangset(null, null, null, TestDataFactory.EN);
        SimapHeadersService.SimapSwissLangSet frDeLangSet = TestDataFactory.createSwissLangset(TestDataFactory.FR, TestDataFactory.DE, null, null);
        SimapHeadersService.SimapSwissLangSet emptyLangSet = TestDataFactory.createSwissLangset(null, null, null, null);

        Test.startTest();
            frOutput = SimapUtils.getValidField(frLangSet);
            deOutput = SimapUtils.getValidField(deLangSet);
            itOutput = SimapUtils.getValidField(itLangSet);
            enOutput = SimapUtils.getValidField(enLangSet);
            emptyOutput = SimapUtils.getValidField(emptyLangSet);
            frDeOutput = SimapUtils.getValidField(frDeLangSet);
        Test.stopTest();

        System.assertEquals(TestDataFactory.FR, frOutput, 'testGetValidField : the fr value should have been returned');
        System.assertEquals(TestDataFactory.DE, deOutput, 'testGetValidField : the de value should have been returned');
        System.assertEquals(TestDataFactory.IT, itOutput, 'testGetValidField : the it value should have been returned');
        System.assertEquals(TestDataFactory.EN, enOutput, 'testGetValidField : the en value should have been returned');
        System.assertEquals(null, emptyOutput, 'testGetValidField : the empty value should have been returned as null');
        System.assertEquals(TestDataFactory.FR, frDeOutput, 'testGetValidField : the fr value should have been returned'); 
    }

    @isTest
    public static void testAddressConverter() {
        SimapPublicationDetailService.SimapAdress nullAddress = TestDataFactory.createAddress(
            TestDataFactory.createSwissLangset(null, null, null, null),
            TestDataFactory.createSwissLangset(null, null, null, null),
            null,
            null,
            null
        );

        SimapPublicationDetailService.SimapAdress frAddress = TestDataFactory.createAddress(
            TestDataFactory.createSwissLangset(TestDataFactory.FR, null, null, null),
            TestDataFactory.createSwissLangset(TestDataFactory.FR, null, null, null),
            TestDataFactory.COUNTRY_CODE,
            TestDataFactory.POSTAL_CODE,
            TestDataFactory.CANTON_ID
        );

        SimapPublicationDetailService.SimapAdress deAddress = TestDataFactory.createAddress(
            TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null),
            TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null),
            TestDataFactory.COUNTRY_CODE,
            TestDataFactory.POSTAL_CODE,
            TestDataFactory.CANTON_ID
        );

        SimapPublicationDetailService.SimapAdress invalidAddress = TestDataFactory.createAddress(
            TestDataFactory.createSwissLangset(null, null, null, null),
            TestDataFactory.createSwissLangset(null, null, null, null),
            TestDataFactory.COUNTRY_CODE,
            null,
            TestDataFactory.CANTON_ID
        );

        SimapPublicationDetailService.SimapAdress validAddressWithMissingFields = TestDataFactory.createAddress(
            TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null),
            TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null),
            null,
            TestDataFactory.POSTAL_CODE,
            null
        );

        String nullAddressOutput;
        String frAddressOutput;
        String deAddressOutput;
        String invalidAddressOutput;
        String validAddressWithMissingFieldsOutput;

        Test.startTest();
            nullAddressOutput = SimapUtils.addressConverter(nullAddress);
            frAddressOutput = SimapUtils.addressConverter(frAddress);
            deAddressOutput = SimapUtils.addressConverter(deAddress);
            invalidAddressOutput = SimapUtils.addressConverter(invalidAddress);
            validAddressWithMissingFieldsOutput = SimapUtils.addressConverter(validAddressWithMissingFields);
        Test.stopTest();

        System.assertEquals(null, nullAddressOutput, 'testAddressConverter : the null address should have been returned as null');
        System.assertEquals((TestDataFactory.FR + SimapUtils.ADDRESS_SEPARATOR).repeat(2) + TestDataFactory.CANTON_ID + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.COUNTRY_CODE + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.POSTAL_CODE, frAddressOutput, 'testAddressConverter : the fr address should have been correctly formatted');
        System.assertEquals((TestDataFactory.DE + SimapUtils.ADDRESS_SEPARATOR).repeat(2) + TestDataFactory.CANTON_ID + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.COUNTRY_CODE + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.POSTAL_CODE, deAddressOutput, 'testAddressConverter : the de address should have been correctly formatted');
        System.assertEquals(null, invalidAddressOutput, 'testAddressConverter : the invalid address should have been returned as null');
        System.assertEquals((TestDataFactory.DE + SimapUtils.ADDRESS_SEPARATOR).repeat(2) + TestDataFactory.POSTAL_CODE, validAddressWithMissingFieldsOutput, 'testAddressConverter : the valid address with missing fields should have been correctly formatted');
    }

    @isTest
    public static void testOrderAddressConverter() {
        SimapHeadersService.SimapOrderAddress frAddress = TestDataFactory.createOrderAddress(
            TestDataFactory.createSwissLangset(TestDataFactory.FR, null, null, null),
            TestDataFactory.COUNTRY_CODE,
            TestDataFactory.POSTAL_CODE,
            TestDataFactory.CANTON_ID
        );

        SimapHeadersService.SimapOrderAddress deAddress = TestDataFactory.createOrderAddress(
            TestDataFactory.createSwissLangset(null, TestDataFactory.DE, null, null),
            TestDataFactory.COUNTRY_CODE,
            TestDataFactory.POSTAL_CODE,
            TestDataFactory.CANTON_ID
        );

        // seen on real SIMAP publications : only the country is known
        SimapHeadersService.SimapOrderAddress countryOnlyAddress = TestDataFactory.createOrderAddress(
            TestDataFactory.createSwissLangset(null, null, null, null),
            TestDataFactory.COUNTRY_CODE,
            null,
            null
        );

        SimapHeadersService.SimapOrderAddress unknownCountryAddress = TestDataFactory.createOrderAddress(
            TestDataFactory.createSwissLangset(TestDataFactory.FR, null, null, null),
            UNKNOWN_COUNTRY_CODE,
            TestDataFactory.POSTAL_CODE,
            TestDataFactory.CANTON_ID
        );

        String nullAddressOutput;
        String frAddressOutput;
        String deAddressOutput;
        String countryOnlyAddressOutput;
        String unknownCountryAddressOutput;

        Test.startTest();
            nullAddressOutput = SimapUtils.orderAddressConverter(null);
            frAddressOutput = SimapUtils.orderAddressConverter(frAddress);
            deAddressOutput = SimapUtils.orderAddressConverter(deAddress);
            countryOnlyAddressOutput = SimapUtils.orderAddressConverter(countryOnlyAddress);
            unknownCountryAddressOutput = SimapUtils.orderAddressConverter(unknownCountryAddress);
        Test.stopTest();

        System.assertEquals(null, nullAddressOutput, 'testOrderAddressConverter : the null address should have been returned as null');
        System.assertEquals(expectedOrderAddress(TestDataFactory.FR, SWITZERLAND_LABEL), frAddressOutput, 'testOrderAddressConverter : the fr address should have been correctly formatted');
        System.assertEquals(expectedOrderAddress(TestDataFactory.DE, SWITZERLAND_LABEL), deAddressOutput, 'testOrderAddressConverter : the de address should have been correctly formatted');
        System.assertEquals(SWITZERLAND_LABEL, countryOnlyAddressOutput, 'testOrderAddressConverter : the country only address should have been reduced to the country');
        System.assertEquals(expectedOrderAddress(TestDataFactory.FR, UNKNOWN_COUNTRY_CODE), unknownCountryAddressOutput, 'testOrderAddressConverter : the unmapped country should have been kept as its raw code');
    }

    private static String expectedOrderAddress(String city, String country) {
        return TestDataFactory.POSTAL_CODE + ' ' + city
            + SimapUtils.ADDRESS_SEPARATOR + TestDataFactory.CANTON_ID
            + SimapUtils.ADDRESS_SEPARATOR + country;
    }

    @isTest
    public static void testGetValidPublicationTitle() {
        SimapHeadersService.PublicationDeserializer publication = (SimapHeadersService.PublicationDeserializer)JSON.deserialize(TestDataFactory.SIMAP_HEADER_RESPONSE_1, SimapHeadersService.PublicationDeserializer.class);
        String publicationTitleOutput;

        Test.startTest();
            publicationTitleOutput = SimapUtils.getValidPublicationTitle(publication);
        Test.stopTest();

        System.assertEquals(TestDataFactory.FR, publicationTitleOutput, 'testGetValidPublicationTitle : the publication title should have been correctly formatted');
    }

    @isTest
    public static void testGetValidPublicationProcOfficeName() {
        SimapHeadersService.PublicationDeserializer publication = (SimapHeadersService.PublicationDeserializer)JSON.deserialize(TestDataFactory.SIMAP_HEADER_RESPONSE_1, SimapHeadersService.PublicationDeserializer.class);
        String publicationProdOfficeNameOutput;

        Test.startTest();
            publicationProdOfficeNameOutput = SimapUtils.getValidPublicationProcOfficeName(publication);
        Test.stopTest();

        System.assertEquals(TestDataFactory.FR, publicationProdOfficeNameOutput, 'testGetValidPublicationTitle : the publication title should have been correctly formatted');
    }

    @isTest
    public static void testGetCantonNameByAbbreviation() {
        String cantonName;
        
        Test.startTest();
            cantonName = SimapUtils.getCantonNameByAbbreviation(TestDataFactory.VAUD_CANTON_ABBREVIATION);
        Test.stopTest();
        
        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, cantonName, 'testGetCantonNameByAbbreviation : the canton name should have been correctly retrieved');
    }

    @isTest
    public static void testGetValidCantonValue() {
        String cantonAbbreviation;
        SimapPublicationDetailService.SimapPublicationDetailResponse detailResponse = (SimapPublicationDetailService.SimapPublicationDetailResponse) JSON.deserialize(TestDataFactory.SIMAP_DETAIL_RESPONSE_1, SimapPublicationDetailService.SimapPublicationDetailResponse.class);
        Test.startTest();
            cantonAbbreviation = SimapUtils.getValidCantonValue(detailResponse.projectInfo);
        Test.stopTest();

        System.assertEquals(TestDataFactory.VAUD_CANTON_NAME, cantonAbbreviation, 'testGetValidCantonValue : the canton id should have been correctly retrieved');
    }

    @isTest
    public static void testGetDefaultCodeCfcBkp_NoRecord() {
        delete [SELECT Id FROM Simap_Code_CFC_BKP__c];
        SimapUtils.SimapUtilsException expectedException;
        try {
            Test.startTest();
                SimapUtils.getDefaultCodeCfcBkp();
            Test.stopTest();
        } catch (SimapUtils.SimapUtilsException e) {
            expectedException = e;
        }

        System.assertNotEquals(null, expectedException, 'testGetDefaultCodeCfcBkp_NoRecord : an exception should have been thrown');
    }

    @isTest
    public static void testGetDefaultCodeCfcBkp_OneRecord() {

        Simap_Code_CFC_BKP__c result;
        Test.startTest();
            result = SimapUtils.getDefaultCodeCfcBkp();
        Test.stopTest();

        System.assertNotEquals(null, result, 'testGetDefaultCodeCfcBkp_OneRecord : result should not be null');
        System.assertEquals('BKP-DEFAULT', result.Code_CFC_BKP__c, 'testGetDefaultCodeCfcBkp_OneRecord : code should match');
    }

    @isTest
    public static void testGetDefaultCodeCfcBkp_MultipleRecords() {
        TestDataFactory.createCodeCfcBkp('BKP-001', true);
        TestDataFactory.createCodeCfcBkp('BKP-002', false);

        SimapUtils.SimapUtilsException expectedException;

        try {
            Test.startTest();
                SimapUtils.getDefaultCodeCfcBkp();
            Test.stopTest();
        } catch (SimapUtils.SimapUtilsException e) {
            expectedException = e;
        }

        System.assertNotEquals(null, expectedException, 'testGetDefaultCodeCfcBkp_MultipleRecords : an exception should have been thrown');
    }
}