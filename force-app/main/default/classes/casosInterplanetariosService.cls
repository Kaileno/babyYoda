public with sharing class casosInterplanetariosService {
    public static final Integer RECORDS_TO_DISPLAY = 5;

    @AuraEnabled
    public static String getOpenCaseRecords() {
        Id currentUserId  = UserInfo.getUserId();
        List<Case> caseList = [
                                SELECT Id, Subject, Status, SuppliedEmail, contactId
                                FROM Case
                                WHERE
                                    isClosed = false AND
                                    OwnerId =:currentUserId
                                ORDER BY LastModifiedDate ASC
                                LIMIT :RECORDS_TO_DISPLAY];
        List<caseWrapper> cwList = tranformToCaseWrapper(caseList);
        return JSON.serialize(cwList);
    }

    @AuraEnabled
    public static Boolean isGroguOnPlanet(String accessCode) {
        return FindGroguService.getFindGrogu(accessCode);
    }

    private static List<caseWrapper> tranformToCaseWrapper(List<Case> caseList) {
        List<caseWrapper> cwList = new List<caseWrapper>();
        String baseURL = URL.getOrgDomainUrl().toExternalForm();

        for (Case c : caseList) {
            caseWrapper cw = new caseWrapper();
            cw.subject = c.subject;
            cw.status = c.status;
            cw.email = c.SuppliedEmail;
            cw.contactURL = baseURL + '/lightning/r/Case/' + c.contactId + '/view';

            cwList.add(cw);
        }

        return cwList;
    }

    public Class caseWrapper {
        String subject;
        String status;
        String email;
        String contactURL;
    }
}