@isTest
public with sharing class CredentifalVerificationServiceTest {
    @isTest
    static void testVerifyCredentialWithValidCredentials() {
        Test.startTest();
        Contact c = new Contact(LastName='Smith');
        insert c;

        Certification__c cert = new Certification__c(Name='Apex Web Services');
        insert cert;

        Date issueDate = System.today();
        Contact_Certification__c contactCert = new Contact_Certification__c(Contact__c = c.Id, 
                                                                            Certification__c=cert.Id, 
                                                                            isActive__c=true,
                                                                            Issue_Date__c=issueDate);
        insert contactCert;

        Contact_Certification__c retrievedContactCert = [SELECT Id, Name, Contact__c FROM Contact_Certification__c WHERE Contact__c =: c.Id];

        String responseBody = CredentialVerificationService.verifyCredential(c.LastName, retrievedContactCert.Name);

        Test.stopTest();

        System.assertEquals('Valid', responseBody, 'Valid should be returned if an active Contact Certification record exists');
    }

    @isTest
    static void testVerifyCredntialsWithInvalidCredentials() {
        Test.startTest();
        Contact c = new Contact(LastName='Smith');
        insert c;

        Certification__c cert = new Certification__c(Name='Apex Web Services');
        insert cert;

        Date issueDate = System.today();
        Contact_Certification__c contactCert = new Contact_Certification__c(Contact__c = c.Id, 
                                                                            Certification__c=cert.Id, 
                                                                            isActive__c=false,
                                                                            Issue_Date__c=issueDate);
        insert contactCert;

        Contact_Certification__c retrievedContactCert = [SELECT Id, Name, Contact__c FROM Contact_Certification__c WHERE Contact__c =: c.Id];

        String responseBody = CredentialVerificationService.verifyCredential(c.LastName, retrievedContactCert.Name);

        Test.stopTest();

        System.assertEquals('Needs Renewal', responseBody, 'Renewal should be returned if the Contact Certification record isn\'t active');
    }

    @isTest
    static void testVerifyCredntialWithInvalidCertification() {
        Test.startTest();
        Contact c = new Contact(LastName='Smith');
        insert c;

        String responseBody = CredentialVerificationService.verifyCredential(c.LastName, 'Test Certificate');

        Test.stopTest();

        System.assertEquals('No record found', responseBody, 'No record found should be returned if no Contact Certification exists.');
    }

    @isTest
    static void testVerifyCredntialWithInvalidContact() {
        Test.startTest();

        String responseBody = CredentialVerificationService.verifyCredential('Smith', 'Test Certificate');

        Test.stopTest();

        System.assertEquals('No record found', responseBody, 'No record found should be returned if no Contact exists.');
    }
}