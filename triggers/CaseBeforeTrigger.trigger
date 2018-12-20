//===================================================================================================
//                     THIS CODE IS USED BY CORP - BUYER APP only
//===================================================================================================
/*
    Name - CaseBeforeTrigger
    
    Purpose -   Not to allow to close the Case if it has open related activities.                
        
Version     Author              Date            Details 
-----------------------------------------------------------------------------------------------------------------------------------------
1.0         Offshore            10/21/2015      Created the trigger
********************************************************************************************************************
*/
trigger CaseBeforeTrigger on Case (before update) {
    
    // BEGIN: S-444999, T-566608 : Include CASE recordtype= IAA Buyer Services
    Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
    
    for(Case cse : trigger.new){
     // BEGIN: S-444999, T-566608 : Include CASE recordtype= IAA Buyer Services
      if(rt_map.get(cse.recordTypeID).getName().containsIgnoreCase('IAA Buyer Services'))
      {
        if(cse.status == 'Closed'){
            
            // BEGIN: S-444999, T-566608 : Include CASE recordtype= IAA Buyer Services &
            Case dbCse = [SELECT id , (SELECT Status, subject FROM OpenActivities) FROM Case where id=:cse.id and recordtype.name='IAA Buyer Services'];
            
            List<OpenActivity> cseOpenActivities = dbCse.OpenActivities;
            System.debug ('cseOpenActivities size :'+cseOpenActivities.size());
             
            if(cseOpenActivities != null && cseOpenActivities.size() > 0){
                cse.adderror('Close all open Activities/Tasks and then you will be able to close this case.');             
            }     
        }   
    }
   }
}