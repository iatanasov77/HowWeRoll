@isTest
public class MaintenanceRequestTest {

    public static Product2 createProduct(String name, String sku){
        Product2 product = new Product2(Name=name);
        product.Cost__c = Integer.valueOf(Math.random());
        product.Warehouse_SKU__c = sku;
        product.Replacement_Part__c = true;
        product.Lifespan_Months__c = 12;
        product.Maintenance_Cycle__c = 2;
        
        return product;
    }
    
    public static Vehicle__c createVehicle(String vehicleName){
        return new Vehicle__c(Name=vehicleName);
    }
    
    public static List<Work_Part__c> createWorkParts(Case maintenanceRequest, List<Product2> equipements){
        List<Work_Part__c> parts = new List<Work_Part__c>();
        
        for(Product2 equipement : equipements){
            Work_Part__c part = new Work_Part__c();
            part.Quantity__c = Integer.valueOf(Math.random());
            part.Maintenance_Request__c = maintenanceRequest.Id;
            part.Equipment__c = equipement.Id;
            
            parts.add(part);            
        }
        
        return parts;
    }
    
    public static Case createMaintenanceRequest(Vehicle__c vehicle, String requestType){
        Case request = new Case();
        request.Vehicle__c = vehicle.id;
        request.Type = requestType;
        
        return request;
    }
    
    @isTest static  void testCreateRepairRequest() {  
        Test.startTest();
        
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
		List<Case> requests = new List<Case>();
        
        Set<Id> vehicleIds = new Set<Id>();       
        
        //Create vehicles
        for(integer i=0; i < 100; i++){
            vehicles.add(createVehicle('Vehicle' + i));
        }
        
        insert vehicles;
        
        //Create requests
        for(Vehicle__c vehicle : vehicles){           
            Case maintenanceRequest = createMaintenanceRequest(vehicle, 'Repair');
            requests.add(maintenanceRequest);            
            vehicleIds.add(vehicle.id);
        }
        
        insert requests;
		
		List<Case> results = [SELECT Id, CaseNumber FROM Case 
                              WHERE Vehicle__c in :vehicleIds];
        
        System.assertEquals(vehicleIds.size(), results.size());        
         
        Test.stopTest();        
    }

    @isTest static  void testCreateAndCloseRepairRequest() {  
        Test.startTest();
        
        List<Vehicle__c> vehicles = new List<Vehicle__c>();        
		List<Case> requests = new List<Case>();        
        Set<Id> vehicleIds = new Set<Id>();      
        
        //Create vehicles 
        for(integer i=0; i < 100; i++){
            vehicles.add(createVehicle('Vehicle' + i));
        }
        
        Database.insert( vehicles );
        
        //Create requests
        for(Vehicle__c vehicle: vehicles){           
            Case maintenanceRequest = createMaintenanceRequest(vehicle, 'Repair');
            maintenanceRequest.Status = 'Closed';
            requests.add(maintenanceRequest);            
            vehicleIds.add(vehicle.id);
        }
        
        Database.insert( requests );
		
		List<Case> results = [SELECT Id, CaseNumber FROM Case 
                              WHERE Vehicle__c in :vehicleIds];
        
        System.assertEquals( vehicleIds.size()*2, results.size() );        
        
        Test.stopTest();
    }        
    
    @isTest static  void testUpdateMaintenanceRequest() {
        Test.startTest();
        
        List<Product2> products = new List<Product2>();        
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Work_Part__c> parts = new List<Work_Part__c>();
		List<Case> requests = new List<Case>();
        
        Set<Id> vehicleIds = new Set<Id>();              
        //Create products
        for(integer i=0; i < 2; i++){
            products.add(createProduct('Product' + i, '9999'+i));
        }
        
        //Create vehicles
        for(integer i=0; i < 1; i++){
            vehicles.add(createVehicle('Vehicle' + i));
        }
        
        insert products;
        insert vehicles;
        
        //Create requests
        for(Vehicle__c vehicle: vehicles){           
            Case maintenanceRequest = createMaintenanceRequest(vehicle, 'Routine Maintenance');             
            requests.add(maintenanceRequest);            
            vehicleIds.add(vehicle.id);
        }
        
        insert requests;
		
		List<Case> results = [SELECT Id, CaseNumber FROM Case 
                              WHERE Vehicle__c in :vehicleIds];
        
        System.assertEquals(vehicleIds.size(), results.size()); 
        
        //Update requests
        for(Case maintenanceRequest : requests){
            parts.addAll(createWorkParts(maintenanceRequest, products));           
            maintenanceRequest.Status = 'Closed';
        }  
        
        insert parts;
        update requests;
        
        results = [SELECT Id, CaseNumber FROM Case 
                   WHERE Vehicle__c in :vehicleIds];
        System.assertEquals(vehicleIds.size()*2, results.size());   
        
        Test.stopTest();        
    }    
}