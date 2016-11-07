@isTest
private class WarehouseCalloutServiceTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    public static Product2 createProduct(String name, String sku){
        Product2 product = new Product2(Name=name);
        product.Cost__c = Integer.valueOf(Math.random());
        product.Warehouse_SKU__c = sku;
        product.Replacement_Part__c = true;
        product.Lifespan_Months__c = 12;
        product.Maintenance_Cycle__c = 2;
        
        return product;
    }

    
    @isTest static  void testRunWarehouseEquipmentSyncCre() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());        
        //String jobId = System.schedule('WarehouseCalloutService', CRON_EXP, 
        //                               new WarehouseSyncSchedule());  
        WarehouseCalloutService.runWarehouseEquipmentSync();
        
        Test.stopTest();
    }
    
    @isTest static  void testRunWarehouseEquipmentSyncUpd() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());        
        Product2 equipment = createProduct('Product 1', '100003');
        insert equipment;
        
        //String jobId = System.schedule('WarehouseCalloutService', CRON_EXP, 
        //                               new WarehouseSyncSchedule());  
        WarehouseCalloutService.runWarehouseEquipmentSync();
        
        Test.stopTest();
    }
    
}