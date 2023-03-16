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
    public static Boolean isGroguOnPlanet(Id caseId, String accessCode) {
        Boolean isGroguThere = FindGroguService.getFindGrogu(accessCode);
        RefreshCaseList__e event = new RefreshCaseList__e();

        Case c = [SELECT Id, Status, Sucessful_Scan__c FROM Case WHERE Id = :caseId];

        c.Sucessful_Scan__c = false;
        c.Status = 'Closed';

        if (isGroguThere) {
            c.Sucessful_Scan__c = true;
        }

        update c;
        Database.SaveResult result = EventBus.publish(event);

        return isGroguThere;
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