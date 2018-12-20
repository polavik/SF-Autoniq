trigger AFCContractsBeforeInsertUpdate on AFC_Contracts__c (before insert, before update) {

    // (Story B-42786) check restricted User ID those not allow to update account field 
    if (Trigger.isUpdate)
    {       
        String CurrentUser = UserInfo.getUserId();
        Boolean IsRestrictedUser = Utils.IsUserExist('afccontract.restrictupdate.account.userid', CurrentUser); 
        
        // Roll back to Account__c field's original value
        if(IsRestrictedUser)
        {
            for(AFC_Contracts__c ac: Trigger.new) {
                if(ac.Account__c != Trigger.oldMap.get(ac.Id).Account__c)
                {
                    ac.Account__c = Trigger.oldMap.get(ac.Id).Account__c;
                }
            }
        }
    }

}