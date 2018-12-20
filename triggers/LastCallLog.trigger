trigger LastCallLog on Task (after insert, after update) {
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
            boolean IsMigrationRuning = false;   
        IsMigrationRuning = Utils.getIsMigrationRuning('is.migration.running');

        List<Account> accts = new List<Account>();
        Map<Id, Task> taskSets = new Map<Id, Task>();
        Map<Id, String> userSets = new Map<Id, String>();
        Map<Id, String> profileSets = new Map<Id, String>();
        string status;
        for(Task newTask: Trigger.new){
        // Added Condition for Task Records Migration (PPM#97274) (By djpatel - ADESA Canada Salesforce Team)
        if(!(IsMigrationRuning && newTask.Openlane_Task_SF_ID__c!=null && newTask.Openlane_Task_SF_ID__c!=''))
        {
            status = newTask.Status;
            if(status.equals('Completed')){
                taskSets.put(newTask.AccountId, newTask);
                userSets.put(newTask.OwnerId,'');
            }
        }   
        }
        if(taskSets.size()>0){
            accts =
            [
                SELECT Id, Last_DST_Contact_By__c, Last_DST_Contact_Date__c
                FROM Account
                WHERE Id IN: taskSets.keySet() 
            ];
            if(userSets.size()>0){ 
               List<User> users = [SELECT Id, Name, profile.Name, ProfileId FROM User WHERE Id IN :userSets.keySet() AND IsActive = true];                              
                for (Integer i=0; i<users.size(); i++)
                {
                    userSets.put(users[i].Id, users[i].Name);
                    profileSets.put(users[i].Id, users[i].profile.Name);
                }          
            }
        }  
        
        for(Account acct: accts){
            String profileName = profileSets.get(taskSets.get(acct.Id).OwnerId);
            if(profileName == 'ADESA Dealer Sales Team' || profileName == 'ADESA Canada Dealer Sales Team'){
                acct.Last_DST_Contact_By__c = userSets.get(taskSets.get(acct.Id).OwnerId);
                acct.Last_DST_Contact_Date__c = taskSets.get(acct.Id).LastModifiedDate;
            }
            if(profileName == 'Openlane Sales Rep US' || profileName == 'Openlane Sales Rep Canada'){
                acct.Last_OL_Inside_Sales_Contact_By__c = userSets.get(taskSets.get(acct.Id).OwnerId);
                acct.Last_OL_Inside_Sales_Contact_Date__c = taskSets.get(acct.Id).LastModifiedDate;
            }
            if(profileName == 'Transportation Coordinator'){
                acct.Last_Transport_Sales_Contact_By__c = userSets.get(taskSets.get(acct.Id).OwnerId);
                acct.Last_Transport_Sales_Contact_Date__c = taskSets.get(acct.Id).LastModifiedDate;
            }
            if(profileName == 'ADESA Dealer Relations - District Mgr' || profileName == 'ADESA Dealer Relations - Regional Mgr' || 
            profileName == 'ADESA Dealer Relations Rep' || profileName == 'ADESA Dealer Relations Rep - Lead'){
                acct.Last_Auction_Inside_Sales_Contact_By__c = userSets.get(taskSets.get(acct.Id).OwnerId);
                acct.Last_Auction_Inside_Sales_Contact_Date__c = taskSets.get(acct.Id).LastModifiedDate;
            }
        }
        try{
            update(accts);
        }catch(DmlException e){
        }
    }

    
}