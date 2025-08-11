@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {
    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {
        // RestRequest req = RestContext.request;
        // Map<String, String> params = req.params;

        List<Asset> asset = [SELECT Id, Asset_Identifier__c, Status 
                       FROM Asset 
                       WHERE Asset_Identifier__c =:assetIdentifier
                       WITH SECURITY_ENFORCED];

        if(asset.size() == 0) {
            return 'No device found';
        }else {
            asset[0].Status = 'Lost';
            upsert asset[0];
        }

        List<Insurance__c> insurance = [SELECT Id, Asset__c, Active__c, Coverage__c
                               FROM Insurance__c
                               WHERE Asset__c =: asset[0].Id
                               AND Active__c = TRUE
                               WITH SECURITY_ENFORCED];

        if(insurance.size() > 0 && insurance[0].Active__c == true && insurance[0].Coverage__c == 'Comprehensive'){
            List<Claim__c> existingClaim = [SELECT Id, Asset__c, Type__c, Name FROM Claim__c WHERE Asset__c =: asset[0].Id AND Type__c = 'Loss' WITH SECURITY_ENFORCED];
            if(existingClaim.size() > 0){
                return existingClaim[0].Name + ' already filed.';
            }

            Claim__c claim = new Claim__c();
            claim.Type__c = 'Loss';
            claim.Asset__c = asset[0].Id;
            claim.Insurance__c = insurance[0].Id;
            insert claim;

            List<Claim__c> reportedClaim = [SELECT Id, Asset__c, Type__c, Name FROM Claim__c WHERE Asset__c =: asset[0].Id AND Type__c = 'Loss' WITH SECURITY_ENFORCED];
            return reportedClaim[0].Name;
        }else{
            return 'No coverage. Asset status adjusted to Lost.';
        }
    }
}