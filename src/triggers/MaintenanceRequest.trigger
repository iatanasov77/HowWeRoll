trigger MaintenanceRequest on Case ( after insert, after update )
{
    List<Case> closedMaintenanceRequests   = new List<Case>();
    
    for ( Case mr : Trigger.new )
    {
        if(
            ( mr.type == 'Repair' || mr.type == 'Routine Maintenance' )
            && mr.status == 'Closed'
        ) {
            closedMaintenanceRequests.add( mr );
        }
    }
    
    if ( closedMaintenanceRequests.size() > 0 )
    {
        MaintenanceRequestHelper.updateWorkOrders( closedMaintenanceRequests );
    }
}