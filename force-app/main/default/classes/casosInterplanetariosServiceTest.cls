@isTest
public with sharing class casosInterplanetariosServiceTest {
    // this testClass cover CaseTrigger, CaseTriggerHandler, and CaseTriggerHelper

    @isTest(SeeAllData=true)
    private static void getOpenCaseRecordsTest() {
        List<Case> caseList = new List<Case>();
        String jsonText;

        Test.startTest();
        jsonText = casosInterplanetariosService.getOpenCaseRecords();
        Test.stopTest();

        caseList = (List<Case>)JSON.deserialize(jsonText, List<Case>.class);

        Assert.areEqual(5, caseList.size());
    }

    @isTest
    private static void isGroguOnPlanetTest() {
        String code= 'jPnR5625';
        Boolean isGroguThere = false;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FindGroguServiceHTTPMockTest());

        isGroguThere = casosInterplanetariosService.isGroguOnPlanet(code);
        Test.stopTest();

        Assert.isTrue(isGroguThere, 'grogu has to be on that planet');
    }
}