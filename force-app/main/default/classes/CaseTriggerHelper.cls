public with sharing class CaseTriggerHelper {
    public static final String VALID_SUBJECT = 'Solicitud de escaneo - ';
    public static final String REGEXP_SUBJECT = '[\\s\\S]*Solicitud de escaneo \\- ';
    public static final String REGEXP_BODY = '[\\s\\S]*Código de acceso al sistema de escaneo interplanetario: ';
    public static final String CASE_CLOSED_STATUS = 'Closed';

    public static List<Case> newCasesFromDin(List<Case> newCases) {
        String planetName;
        List<Case> casesFromDin = new List<Case>();
        List<Planet__c> existingPlanetList = getExistingPlanetList();
        Map<String,Planet__c> existingPlanetsByName = getExistingPlanetsByName(existingPlanetList);
        Map<String,Planet__c> existingPlanetsByCode = getExistingPlanetsByCode(existingPlanetList);

        for (Case c : newCases) {
            if (isCaseFromDin(c)) {
                planetName = validatePlanet(c, existingPlanetsByName);

                if (String.isNotEmpty(planetName)) {
                    validateCaseBody(c, planetName, existingPlanetsByCode);
                }

                if(c.Planet__c != null) {
                    casesFromDin.add(c);
                }
            }
        }

        return casesFromDin;
    }

    public static void allocateContactsFromDinCases(List<Case> caseList){
        Set<String> emails = new Set<String>();
        List<Contact> contactsToInsert = new List<Contact>();
        Map<String, Contact> contactsToAllocateOnCases = new Map<String, Contact>();
        Set<ContactWrapper> contactDataFromCase = getContactDataFromCase(caseList);

        for (ContactWrapper cw : contactDataFromCase) {
            emails.add(cw.email);
        }

        List<Contact> existingContactslist = getContactsByEmail(emails);
        Map<String, Contact> existingContactsByName = getExistingContactsByName(existingContactslist);

        for (Case c : caseList) {
            Contact contactToUse = existingContactsByName.get(c.SuppliedName);

            if (contactToUse != null) {
                c.ContactId = contactToUse.Id;
            }
            else {
                contactToUse = createContact(c.SuppliedName, c.SuppliedEmail);
                contactsToInsert.add(contactToUse);
                contactsToAllocateOnCases.put(c.SuppliedName, contactToUse);
            }
        }

        if (contactsToAllocateOnCases.size() > 0) {
            insert contactsToInsert;

            for (Case c : caseList) {
                if (c.ContactId == null) {
                    c.ContactId = contactsToAllocateOnCases.get(c.SuppliedName).Id;
                }
            }
        }
    }

    public static List<Case> getAcceptedCasesFromDin(List<Case> newCases) {
        List<Case> validCases = new List<Case>();

        for (Case c : newCases) {
            If (c.Id != null && c.Planet__c != null) {
                validCases.add(c);
            }
        }

        return validCases;
    }

    public static void runDinViewUpdate() {
        system.debug('toca actualizar viteh');
    }

    //before insert helper functions
    private static boolean isCaseFromDin(Case c) {
        return (String.isNotEmpty(c.SuppliedName) && c.Origin == 'Email' && c.subject.contains(VALID_SUBJECT));
    }

    private static String validatePlanet(Case caseToCheck, Map<String,Planet__c> existingPlanetsByName) {
        String cleanSubject = '';
        String planetName = caseToCheck.Subject.replaceFirst(REGEXP_SUBJECT, cleanSubject);
        Planet__c existingPlanet = existingPlanetsByName.get(planetName);

        if (existingPlanet == null) {
            caseToCheck.status = CASE_CLOSED_STATUS;
            caseToCheck.IsDinInvalidMailFormat__c = true;
            caseToCheck.ReasonToRejectDinEmail__c = 'The planet: '+planetName+' Doesn\'t exist, perhaps the archives are incomplete';
            planetName = null;
        }

        return planetName;
    }

    private static void validateCaseBody(Case caseToCheck, String planetName, Map<String,Planet__c> existingPlanetsByCode) {
        String cleanBody = '';
        String externalId = caseToCheck.Description.replaceFirst(REGEXP_BODY, cleanBody);
        Planet__c existingPlanet;

        if (externalId.length() > 6) {
            externalId = externalId.substring(0,7);
            existingPlanet = existingPlanetsByCode.get(externalId);

            if (existingPlanet != null) {
                if (existingPlanet.Name == planetName) {
                    caseToCheck.Planet__c = existingPlanet.Id;
                }
            }
            else {
                caseToCheck.status = CASE_CLOSED_STATUS;
                caseToCheck.IsDinInvalidMailFormat__c = true;
                caseToCheck.ReasonToRejectDinEmail__c = 'The planet Code: '+externalId+' Doesn\'t match, with the information of Planet: '+planetName;
            }
        }
    }

    private static List<Planet__c> getExistingPlanetList() {
        return [SELECT Id, Name, Code__c FROM Planet__c];
    }

    private static Map<String, Planet__c> getExistingPlanetsByName(List<Planet__c> existingPlanetList) {
        Map<String, Planet__c> planetsByName = new Map<String, Planet__c>();

        for(Planet__c planet : existingPlanetList) {
            planetsByName.put(planet.Name, planet);
        }
        return planetsByName;
    }

    private static Map<String, Planet__c> getExistingPlanetsByCode(List<Planet__c> existingPlanetList) {
        Map<String, Planet__c> planetsByName = new Map<String, Planet__c>();

        for(Planet__c planet : existingPlanetList) {
            planetsByName.put(planet.Code__c, planet);
        }
        return planetsByName;
    }

    private static List<Contact> getContactsByEmail(Set<String> emails) {
        return [SELECT Id, Name, FirstName, LastName, Email, LastModifiedDate FROM Contact WHERE Email In :emails ORDER BY LastModifiedDate];
    }

    private static Map<String,Contact> getExistingContactsByName(List<Contact> contactList) {
        Map<String,Contact> contactsMap = new Map<String,Contact>();

        for (Contact c : contactList) {
            if (contactsMap.get(c.Name) == null) {
                contactsMap.put(c.Name, c);
            }
        }

        return contactsMap;
    }

    private static Set<ContactWrapper> getContactDataFromCase(List<Case> caseList) {
        Set<ContactWrapper> cwSet = new Set<ContactWrapper>();

        for (Case c : caseList) {
            ContactWrapper cw = new ContactWrapper();
            cw.name = c.SuppliedName;
            cw.email = c.SuppliedEmail;

            cwSet.add(cw);
        }

        return cwSet;
    }

    private static Contact createContact(String name, String email) {
        Contact newContact = new Contact();

        newContact.Email = email;
        newContact.FirstName = name.substringBefore(' ');
        newContact.LastName = name.substringAfter(' ');

        return newContact;
    }

    //after insert helper functions


    //wrappers
    public class ContactWrapper {
        String name;
        String email;
    }
}