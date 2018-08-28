public class MaintenanceRequestHelper
{
    
    private static Case createMaintenanceRequest( Case fromMaintenanceRequest, AggregateResult aggMinCycle )
    {
        Integer minCycle    = 0;
        if( aggMinCycle != null && aggMinCycle.get( 'minCycle' ) != null )
        {            
            minCycle                = Integer.valueOf( aggMinCycle.get( 'minCycle' ) );
        }
        
        
        Case maintenanceRequest     = new Case(
            Type                = 'Routine Maintenance',
            Origin              = 'Routine Maintenance',
            Subject             = 'Routine Maintenance',
            // RecordTypeId        = '01258000000EG38',     // Field does not exist on Case object
            Status              = 'New',
            
            Vehicle__c          = fromMaintenanceRequest.Vehicle__c,
            Product__c          = fromMaintenanceRequest.Product__c,
            Date_Reported__c    = System.today(),
            Date_Due__c         = System.today().addDays( minCycle )
        );
        
        //System.debug( fromMaintenanceRequest );
        //System.debug( maintenanceRequest );
        return maintenanceRequest;
    }
    
    public static void updateWorkOrders( List<Case> closedMaintenanceRequests )
    {
        Map<Id,AggregateResult> results =  new Map<id,AggregateResult>( [SELECT Maintenance_Request__r.id, 
                                                                        Min(Equipment__r.Maintenance_Cycle__c)minCycle 
                                     									FROM Work_Part__c 
                                                                        WHERE Maintenance_Request__c in :closedMaintenanceRequests
                                                                        GROUP BY Maintenance_Request__r.id] );
        
        List<Case> newMaintenanceRequests   = new List<Case>();
        for( Case mr : closedMaintenanceRequests )
        {                     
            Case newMaintenanceRequest  = createMaintenanceRequest( mr, results.get( mr.Id ) );
            if( newMaintenanceRequest != null )
            {
            	newMaintenanceRequests.add( newMaintenanceRequest );
            }              
        }
        
        Database.insert( newMaintenanceRequests );
    }            
}