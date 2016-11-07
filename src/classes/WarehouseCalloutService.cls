public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public class WarehouseEquipment{
        String id;
        boolean replacement;
        integer quantity;
        String name;
        integer maintenanceperiod;
        integer lifespan;
        decimal cost;
        String sku;
    }
    
    public static List<Product2> getEquipments(Set<String> SKUs){
         return [SELECT id, Name, Cost__c, Current_Inventory__c, 
                                          Lifespan_Months__c, Maintenance_Cycle__c,
                                          Replacement_Part__c, Warehouse_SKU__c
                                          FROM Product2 WHERE Warehouse_SKU__c in :SKUs
                                         ]; 
    }
    
    public static Map<String, WarehouseEquipment> getWarehouseEquipments(String JSONString){
        List<WarehouseEquipment> equipments = 
            (List<WarehouseEquipment>)JSON.deserialize(JSONString, 
                                                       List<WarehouseEquipment>.class);
        Map<String, WarehouseEquipment> equipmentsMap = new Map<String, WarehouseEquipment>();
        
        for (WarehouseEquipment equipment: equipments) {                   
            equipmentsMap.put(equipment.sku, equipment);                
        }
        
        return equipmentsMap;
    }
    
    public static void updateEquipment(Product2 equipment, WarehouseEquipment wEquipment){
        equipment.Replacement_Part__c = true;
        equipment.Current_Inventory__c = wEquipment.quantity;
        equipment.Lifespan_Months__c = wEquipment.lifespan;
        equipment.Maintenance_Cycle__c = wEquipment.maintenanceperiod; 
    }
    
    public static Product2 createEquipement(WarehouseEquipment wEquipment){
        Product2 equipment = new Product2();
        equipment.IsActive = true;
        equipment.Name = wEquipment.name; 
        equipment.Warehouse_SKU__c = wEquipment.sku;
        updateEquipment(equipment, wEquipment);
        
        return equipment;
    }
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){                
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {     
            String JSONString = response.getBody();
            Map<String, WarehouseEquipment> wEquipments = getWarehouseEquipments(JSONString); 
            System.debug(wEquipments);
            
            List<Product2> equipments = getEquipments(wEquipments.keySet());
            
            for(Product2 equipment : equipments){
                WarehouseEquipment wEquipment = wEquipments.get(equipment.Warehouse_SKU__c);
                updateEquipment(equipment, wEquipment);                				
                wEquipments.remove(equipment.Warehouse_SKU__c);
            } 
            
            for(WarehouseEquipment wEquipment : wEquipments.values() ){
                Product2 equipment = createEquipement(wEquipment);
                if(equipment != null){
                    equipments.add(equipment);
                }
            }
            
            upsert equipments;
        }        
    }
}