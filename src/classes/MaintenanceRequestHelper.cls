public class MaintenanceRequestHelper {	
    private static void setRequestStatus(Case maintenanceRequest){       
        maintenanceRequest.Status = 'New';
    }
    
    private static void setRequestType(Case maintenanceRequest){       
        maintenanceRequest.Type = 'Routine Maintenance';
    }
    
    private static void setRequestSubject(Case maintenanceRequest){        
        maintenanceRequest.Subject = maintenanceRequest.Subject;
    }
    
    private static void setRequestDateReported(Case maintenanceRequest){
        maintenanceRequest.Date_Reported__c = System.today();           
    }       
    
    private static void setRequestDueDate(Case maintenanceRequest, AggregateResult aggMinCycle ){        
        if(aggMinCycle != null && aggMinCycle.get('minCycle') != null){            
            integer minCycle = Integer.valueOf(aggMinCycle.get('minCycle'));        
        	maintenanceRequest.Date_Due__c = System.today().addDays(minCycle);        
        }
    }
    
    private static Case createMaintenanceRequest(Case fromMaintenanceRequest, AggregateResult aggMinCycle){       
        //Clone the original request
        Case newMaintenanceRequest = fromMaintenanceRequest.clone(false, true);                   
        
        //Set other fields on the new request
        setRequestStatus(newMaintenanceRequest);
        setRequestType(newMaintenanceRequest);
        setRequestSubject(newMaintenanceRequest);
        setRequestDateReported(newMaintenanceRequest);
       	setRequestDueDate(newMaintenanceRequest, aggMinCycle);               
        
        return newMaintenanceRequest;
    }
    
    public static void updateWorkOrders(List<Case> maintenanceRequests){        
        Map<Id,AggregateResult> results =  new Map<id,AggregateResult>([SELECT Maintenance_Request__r.id, 
                                                                        Min(Equipment__r.Maintenance_Cycle__c)minCycle 
                                     									FROM Work_Part__c 
                                                                        WHERE Maintenance_Request__c in :maintenanceRequests
                                                                        GROUP BY Maintenance_Request__r.id]);                
        
        List<Case> newMaintenanceRequests = new List<Case>();        
        for(Case m : maintenanceRequests){                     
            Case newMaintenanceRequest = createMaintenanceRequest(m, results.get(m.Id));
            if(newMaintenanceRequest != null){
            	newMaintenanceRequests.add(newMaintenanceRequest);
            }              
        }
        
        insert newMaintenanceRequests;
    }            
}