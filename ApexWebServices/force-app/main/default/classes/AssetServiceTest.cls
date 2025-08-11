@isTest
public with sharing class AssetServiceTest {
    @TestSetup
    static void setupData(){
        Account acc = new Account(Name='Test Account');
        insert acc;

        Asset shippedAsset = new Asset(Asset_Identifier__c='123', Status='Shipped', Name='Test Asset 1', AccountId=acc.Id);
        insert shippedAsset;

        Asset lostAsset = new Asset(Asset_Identifier__c='1235', Status='Lost', Name='Test Asset 2', AccountId=acc.Id);
        insert lostAsset;

        Asset installedAsset = new Asset(Asset_Identifier__c='1237', Status='Installed', Name='Test Asset 3', AccountId=acc.Id);
        insert installedAsset;

        Insurance__c insurance1 = new Insurance__c(Coverage__c='Comprehensive', Asset__c=shippedAsset.Id, Active__c=true);
        insert insurance1;

        Insurance__c insurance2 = new Insurance__c(Coverage__c='Comprehensive', Asset__c=lostAsset.Id, Active__c=true);
        insert insurance2;

        Insurance__c liabilityInsurance = new Insurance__c(Coverage__c='Liability', Asset__c=installedAsset.Id, Active__c=true);
        insert liabilityInsurance;

        Claim__c existingClaim = new Claim__c(Type__c='Loss', Asset__c=lostAsset.Id, Insurance__c=insurance2.Id);
        insert existingClaim;
    }

    @isTest
    static void testReportLostDeviceForNewDevice() {
        Test.startTest();

        Asset asset = [SELECT Id, Asset_Identifier__c, Status FROM Asset WHERE Asset_Identifier__c='123'];

        RestRequest req = new RestRequest();
        req.requestURI = '/lost/';
        req.httpMethod = 'POST';
        req.RequestBody = Blob.valueOf('{"assetIdentifier": 123}');
        RestContext.request = req;

        String responseBody = AssetService.reportLostDevice(asset.Asset_Identifier__c);

        Claim__c newClaim = [SELECT Id, Name, Asset__c FROM Claim__c WHERE Asset__c =: asset.Id];
        Asset updatedAsset = [SELECT Id, Asset_Identifier__c, Status FROM Asset WHERE Asset_Identifier__c='123'];

        System.assertEquals(newClaim.Name, responseBody, 'Name for new claim should be returned');
        System.assertEquals(updatedAsset.Status, 'Lost', 'Asset statis should be updated to Lost');
        Test.stopTest();
    }

    @isTest
    static void testReportForExistingClaim() {
        Test.startTest();

        Asset asset = [SELECT Id, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c='1235'];

        RestRequest req = new RestRequest();
        req.requestURI = '/lost/';
        req.httpMethod = 'POST';
        req.RequestBody = Blob.valueOf('{"assetIdentifier": 1235}');
        RestContext.request = req;

        String responseBody = AssetService.reportLostDevice(asset.Asset_Identifier__c);

        Claim__c existingClaim = [SELECT Id, Name, Asset__c FROM Claim__c WHERE Asset__c =: asset.Id];

        System.assertEquals(existingClaim.Name + ' already filed.', responseBody, 'Name for existing claim should be returned');
        Test.stopTest();
    }

    @isTest
    static void testReportLostDeviceWithInvalidAssetIdentifier() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/lost/';
        req.httpMethod = 'POST';
        req.RequestBody = Blob.valueOf('{"assetIdentifier": 9876}');
        RestContext.request = req;

        String responseBody = AssetService.reportLostDevice('9876');

        System.assertEquals('No device found', responseBody, 'No device found should be returned for invalid Asset Identifier');
        Test.stopTest();
    }

    @isTest
    static void testReportLostDeviceWithInvalidInsurance() {
        Test.startTest();

        Asset asset = [SELECT Id, Asset_Identifier__c, Status FROM Asset WHERE Asset_Identifier__c='1237'];

        RestRequest req = new RestRequest();
        req.requestURI = '/lost/';
        req.httpMethod = 'POST';
        req.RequestBody = Blob.valueOf('{"assetIdentifier": 1237}');
        RestContext.request = req;

        String responseBody = AssetService.reportLostDevice(asset.Asset_Identifier__c);

        List<Claim__c> newClaims = [SELECT Id, Name, Asset__c FROM Claim__c WHERE Asset__c =: asset.Id];
        Asset updatedAsset = [SELECT Id, Asset_Identifier__c, Status FROM Asset WHERE Asset_Identifier__c='1237'];

        System.assertEquals('No coverage. Asset status adjusted to Lost.', responseBody, 'No claim is created for Asset with invalid Insurance');
        System.assertEquals(updatedAsset.Status, 'Lost', 'Asset statis should be updated to Lost');
        System.assertEquals(newClaims.size(), 0, 'No Claim created for Asset');
        Test.stopTest();
    }

}