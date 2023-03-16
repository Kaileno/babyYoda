public with sharing class FindGroguService {
    public static Boolean getFindGrogu(String accessCode) {
        //user y pass estarias en una custom setting /Custom metadata
        String username = 'mando';
        String password = '12345';

        Boolean isGroguOnThePlanet = false;
        HttpResponse response = new HttpResponse();
        HttpRequest request = new HttpRequest();

        try{
            Http http = new Http();
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);            

            request.setEndpoint('callout:FindGrogu/request-yoda-location/' + accessCode);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);

            response = http.send(request);
            system.debug(response.getStatusCode());
            system.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                isGroguOnThePlanet = getGroguValidation(response.getBody());
            }
            else {
                //handler later if error is different from 403 or 500 schedule process or a future function
            }
        }catch(Exception exp){
            throw new IntegrationException('Error Getting Information About Grogu => '+exp.getMessage());
        }
        return isGroguOnThePlanet;
    }

    private static Boolean getGroguValidation(String body) {
        Boolean response = false;
        ResponseWrapper rw = (ResponseWrapper)JSON.deserialize(body, ResponseWrapper.class);

        if (rw.found) {
            response = true;
        }

        return response;
    }

    public Class ResponseWrapper {
        Boolean found;
    }

    public class IntegrationException extends Exception {}
}