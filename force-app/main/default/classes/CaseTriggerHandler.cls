public with sharing class CaseTriggerHandler {
    public static void beforeInsert(List<Case> newCases) {
        List<Case> dinCasesList = CaseTriggerHelper.newCasesFromDin(newCases);

        if (dinCasesList.size() > 0) {
            CaseTriggerHelper.allocateContactsFromDinCases(dinCasesList);
        }
    }

    public static void beforeUpdate(List<Case> oldCases, List<Case> newCases, Map<ID, Case> oldCaseMap, Map<ID, Case> newCaseMap) {

    }

    public static void afterInsert(List<Case> newCases, Map<ID, Case> newCaseMap) {
        List<Case> dinCasesList = CaseTriggerHelper.getAcceptedCasesFromDin(newCases);
        RefreshCaseList__e event = new RefreshCaseList__e();

        if (dinCasesList.size() > 0) {
            Database.SaveResult result = EventBus.publish(event);
        }
    }
}