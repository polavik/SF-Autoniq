trigger UserinformationAfterInsertUpdate on User (after insert, after update) 
{
    // Added Condition for PPM#100551 
    if(system.isBatch() || system.isFuture())
    {   
         // do not call future method
    }
    else
    {    
        // Call future method to complete User information update on Portal_User_Info custom object
        If  (Trigger.isInsert)
        {
           UpdateUserInfo.InfoAdd(Trigger.newMap.keySet());
        }
    
        If  (Trigger.isupdate)
        {
           UpdateUserInfo.InfoUpdate(Trigger.newMap.keySet());
        }
    }
}