@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {
    @HttpGet
    global static String getProducts() {

        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;

        String countryCode = req.headers.get('CountryCode');
        String productCode = req.params.get('ProductCode');
        System.debug('countryCode: ' + countryCode);
        System.debug('productCode: ' + productCode);

        if(String.isBlank(countryCode)){
            countryCode = 'US';
        }

        if(String.isBlank(productCode)) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        List<Product2> products = [SELECT Id, Family, ProductCode
                                    FROM Product2
                                    WHERE ProductCode =: productCode
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1];

        System.debug('Products: ' + products);

        if(products.size() == 0) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        List<Product_Geo_Mapping__mdt> productsGeoMapping = [SELECT Country_Code__c, Permissible_Fly_Zone__c, Product_Family__c
                                                             FROM Product_Geo_Mapping__mdt
                                                             WHERE Country_Code__c =: countryCode
                                                             AND Product_Family__c =: products[0].Family
                                                             WITH SECURITY_ENFORCED];

        if(productsGeoMapping.size() > 0){
            return productsGeoMapping[0].Permissible_Fly_Zone__c;
        }else{
            return 'Confirm with the local authorities';
        }
        
    }
}