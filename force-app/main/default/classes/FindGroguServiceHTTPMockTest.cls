@isTest
public class FindGroguServiceHTTPMockTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"found": true}');
        res.setStatusCode(200);

        return res;
    }
}