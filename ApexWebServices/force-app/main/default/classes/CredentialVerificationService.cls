global with sharing class CredentialVerificationService {
    webservice static String verifyCredential (String contactName, String certificationName) {

        List<Contact> c = [SELECT Id, LastName 
                     FROM Contact 
                     WHERE LastName =: contactName 
                     WITH SECURITY_ENFORCED 
                     LIMIT 1];

        if(c.size() == 0) {
            return 'No record found';
        }

        List<Contact_Certification__c> certifications = [SELECT Id, Name, isActive__c 
                                                  FROM Contact_Certification__c 
                                                  WHERE Name =: certificationName 
                                                  WITH SECURITY_ENFORCED 
                                                  LIMIT 1];

        if(certifications.size() == 0) {
            return 'No record found';
        }else {
            if(certifications[0].isActive__c) {
                return 'Valid';
            }else {
                return 'Needs Renewal';
            }
        }
    }
}