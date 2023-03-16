@isTest
public with sharing class CaseTriggerTest {
    // this testClass cover CaseTrigger, CaseTriggerHandler, and CaseTriggerHelper

    @isTest(SeeAllData=true)
    private static void createValidCaseExistingContactTest() {
        Case c = new Case();
        c.Subject = 'Test Solicitud de escaneo - Alderaan';
        c.Description = 'Código de acceso al sistema de escaneo interplanetario: A-00001';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'txileno@gmail.com';
        c.SuppliedName = 'Angel Salas Olórtegui';
        List<Contact> currentContactList = [SELECT Id FROM Contact];

        Test.startTest();
        insert c;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Planet__c, ContactId FROM Case WHERE Subject = :c.Subject][0];
        List<Contact> updatedContactList = [SELECT Id FROM Contact];

        Assert.isNotNull(updatedCase.Planet__c);
        Assert.areEqual(0,updatedContactList.size() - currentContactList.size(),'no new Contact has to be created');
    }

    @isTest(SeeAllData=true)
    private static void createValidCaseNoExistingContactTest() {
        Case c = new Case();
        c.Subject = 'Test Solicitud de escaneo - Alderaan';
        c.Description = 'Código de acceso al sistema de escaneo interplanetario: A-00001';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedName = 'Angel Salas';
        List<Contact> currentContactList = [SELECT Id FROM Contact];

        Test.startTest();
        insert c;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Planet__c, ContactId FROM Case WHERE Subject = :c.Subject][0];
        List<Contact> updatedContactList = [SELECT Id FROM Contact];

        Assert.isNotNull(updatedCase.Planet__c);
        Assert.areEqual(1,updatedContactList.size() - currentContactList.size(),'a new Contact has to be created');
    }

    @isTest(SeeAllData=true)
    private static void createInvalidCaseNoPlanetTest() {
        Case c = new Case();
        c.Subject = 'Test Solicitud de escaneo - PAderaan';
        c.Description = 'Código de acceso al sistema de escaneo interplanetario: A-00002';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedName = 'Angel Salas';

        Test.startTest();
        insert c;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Planet__c, ContactId, IsClosed FROM Case WHERE Subject = :c.Subject][0];

        Assert.isNull(updatedCase.Planet__c);
        Assert.isTrue(updatedCase.IsClosed);
    }

    @isTest(SeeAllData=true)
    private static void createInvalidCaseValidPlanetInvalidCodeTest() {
        Case c = new Case();
        c.Subject = 'Test Solicitud de escaneo - Alderaan';
        c.Description = 'Código de acceso al sistema de escaneo interplanetario: A-00002';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedName = 'Angel Salas';

        Test.startTest();
        insert c;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Planet__c, ContactId, IsClosed FROM Case WHERE Subject = :c.Subject][0];

        Assert.isNull(updatedCase.Planet__c);
        Assert.isTrue(updatedCase.IsClosed);
    }

    /* This is the correct way
    @TestSetup
    static void makeData(){

    }*/
}