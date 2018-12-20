trigger ContactAfterInsertUpdate on Contact (after insert, after update) {
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        List<Contact> conts = new List<Contact>();
        for(Contact c: Trigger.new){
            if(c.Last_Login_Time_to_PL__c != null){
                if(c.Last_Login_PL_Update__c)
                    conts.add(c);
            }
        }
        
        //associate accounts with updated contacts
        List<Related_Contact__c> rco = 
        [
            SELECT Account__c, Contact__c
            FROM Related_Contact__c
            WHERE Contact__c IN :conts
        ];       
        
        List<Id> acctIds = new List<Id>();
        for(Related_Contact__c relCont:rco){
            acctIds.add(relCont.Account__c);
        }

        List<Account> accts =
        [
             SELECT Id
            FROM Account
            WHERE Id IN :acctIds
        ];
        
        
        // Salesforce Gateway Code
        if(Trigger.isInsert){
            if(Data_Gateway_Users__c.getAll().keySet().contains(UserInfo.getUserName())){
                DataGatewayManager.updateContactsFromMdm(Trigger.New);
            }
        }        
    }
}