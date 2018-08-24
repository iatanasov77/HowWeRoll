trigger MaintenanceRequest on Case ( after insert, after update )
{
    MaintenanceRequestHelper.updateWorkOrders( Trigger.new );
}