@isTest
public class MockHttpSimapResponse implements HttpCalloutMock {

    public static String oneProjectBody = '{"projects": [' + TestDataFactory.SIMAP_HEADER_RESPONSE_1 + ']}';
    public static String twoProjectsBody = '{"projects": [' + TestDataFactory.SIMAP_HEADER_RESPONSE_1 + ',' + TestDataFactory.SIMAP_HEADER_RESPONSE_2 + ']}';
    
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
        }

        return res;
    }
}