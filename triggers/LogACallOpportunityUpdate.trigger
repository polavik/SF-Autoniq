trigger LogACallOpportunityUpdate on Task (after insert) {  

   Id profileId = Userinfo.getProfileId();
   Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
   
   if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
   
    for(Task t : Trigger.New){
        Opportunity opp;
        if(t.whatid != null && t.whatid.getSObjectType().getDescribe().getName() == 'Opportunity' ){
            opp = [select id, NextStep,stagename, Previous_Stage__c from Opportunity where id = :t.whatid];
            if(opp.stagename.toLowerCase() != 'closed won' && opp.stagename.toLowerCase() != 'closed lost') //Don't touch closed oppertunities
            {
            
                    if(t.Next_Step__c != null){
                        opp.nextstep = t.Next_Step__c;
                    }
                    if(t.Next_Contact_Date__c != null){
                        opp.Next_Contact_Date__c = t.Next_Contact_Date__c;
                    }
                    if(t.Update_Opportunity_Stage__c != null){
                        opp.stagename = t.Update_Opportunity_Stage__c;
                    }
                    if(t.Closed_Lost_Reason__c != null){
                        opp.Closed_Lost_Reason__c = t.Closed_Lost_Reason__c;
                    }
                update opp;
            }
        }
    } 
    }  
}