trigger ApplicationAccountTrigger on Application_Account_Role__c (before insert, before update, after delete) 
{

	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
	{
		ApplicationServices.detectAndApplyAppAccountChanges(Trigger.new, Trigger.oldMap, Trigger.isInsert);
	}
	else if(Trigger.isBefore && (Trigger.isDelete))
	{
		ApplicationServices.clearprimaryApplicationAccountsfield(Trigger.new, Trigger.oldMap, Trigger.isDelete);
	}
}

/*************************************************************************************
* Name          :    ApplicationAccountTrigger
* Description   :    ApplicationAccount Trigger Template.. all real stuff done inside ApplicationAccountTriggerManager class.
* Author        :    Sushant Bhasin, 09/24/2013
**************************************************************************************/
/*
trigger ApplicationAccountTrigger on Application_Account_Role__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	ApplicationAccountTriggerManager triggerManager = new ApplicationAccountTriggerManager(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            triggerManager.processBeforeInsert();
        }
        else if(Trigger.isUpdate)
        {
            triggerManager.processBeforeUpdate();
        }
        else if(Trigger.isDelete)
        {
            triggerManager.processBeforeDelete();
        }
    }
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
          triggerManager.processAfterInsert();
        }    
        else if(Trigger.isUpdate)
        {
          triggerManager.processAfterUpdate();
        }    
        else if(Trigger.isDelete)
        {
          //After Delete Logic
        }    
        else if(Trigger.isUndelete)
        {
          //After Undelete Logic
        }        
    }
}
*/