@isTest
public with sharing class ProductZoningServiceTest {
    @TestSetup
    static void setupData(){
        Product2 product = new Product2(Family='Fixed-Wing', 
                                        Name='Test Product', 
                                        ProductCode='GC1060');
        insert product;             
    }

    @isTest
    static void testProductZoningServiceWithValidCountryCode() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/ProductZoning/';
        req.httpMethod = 'GET';
        req.headers.put('CountryCode', 'US');
        req.params.put('ProductCode','GC1060');

        RestContext.request = req;

        String responseBody = ProductZoningService.getProducts();

        System.assertEquals('Regulated', responseBody, 'Permissible Fly Zone is regulated');
        Test.stopTest();
    }

    @isTest
    static void testProductZoningServiceWithNoCountryCode() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/ProductZoning/';
        req.httpMethod = 'GET';
        req.params.put('ProductCode','GC1060');

        RestContext.request = req;

        String responseBody = ProductZoningService.getProducts();

        System.assertEquals('Regulated', responseBody, 'Response should be Regulated as US is the default country code.');
        Test.stopTest();
    }

    @isTest
    static void testProductZoningServiceWithoutProductCode() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/ProductZoning/';
        req.httpMethod = 'GET';
        req.headers.put('CountryCode', 'GBR');

        RestContext.request = req;

        String responseBody = ProductZoningService.getProducts();

        System.assertEquals('ProductCode is missing or doesn\'t exist', responseBody, 'API handles no product code provided gracefully.');
        Test.stopTest();
    }

    @isTest
    static void testProductZoningServiceWithUnregulatedCountryCode() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/ProductZoning/';
        req.httpMethod = 'GET';
        req.headers.put('CountryCode', 'GB');
        req.params.put('ProductCode','GC1060');

        RestContext.request = req;

        String responseBody = ProductZoningService.getProducts();

        System.assertEquals('Confirm with the local authorities', responseBody, 'API handles unregulated country codes gracefully.');
        Test.stopTest();
    }

    @isTest
    static void testProductZoningServiceWithInvalidProductCode() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/ProductZoning/';
        req.httpMethod = 'GET';
        req.headers.put('CountryCode', 'GB');
        req.params.put('ProductCode','GC10601');

        RestContext.request = req;

        String responseBody = ProductZoningService.getProducts();

        System.assertEquals('ProductCode is missing or doesn\'t exist', responseBody, 'API handles invalid product codes gracefully.');
        Test.stopTest();
    }
}