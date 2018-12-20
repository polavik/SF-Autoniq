//****************************************************************************************************//
//        THIS TRIGGER IS USED BY CORP-BUYER App only
//****************************************************************************************************//

/*
    Name - ConatctAccountTrigger
    
    Purpose -   Contact records will be created via data loader. 
                This trigger reads Buyer ID and ASAP Tower ID from contact, searches account for Buyer Id and ASAP Tower ID then 
                sets the account ID on the Contact record.
                
        
Version     Author              Date            Details 
-----------------------------------------------------------------------------------------------------------------------------------------
1.0         Offshore            05/14/2015      Created the trigger
1.1         Offshore            07/13/2016      Created the trigger
********************************************************************************************************************
*/

trigger ConatctAccountTrigger on Contact (before update, before insert) {
    
    for(Contact cntc : trigger.new){
        
        //Proceed if accountID is null      
        if(cntc.accountId == null){
            try{
            //Proceed if Buyer ID available
            if(cntc.Buyer_ID__c != null){
                
                //BEGIN : S-444339, T-566816 - Include Account IAARecordTypes__c='IAA Buyer Services'
                List<Account> accnts = [Select Id 
                                        from Account 
                                        where Buyer_ID__c=:cntc.Buyer_ID__c 
                                        and IAARecordTypes__c='IAA Remarketing'];
                
                //Proceed only if one Account is found
                //If more than one Account records are found, skip Contact record
                //If no Account record is found,  skip Contact record               
                if(accnts.size() == 1){
                    
                    cntc.accountId = accnts[0].Id;
                    
                }               
            }
            //Proceed if ASAP Tower ID available
            if(cntc.ASAP_Tower_ID__c!= null){
                
                //BEGIN : S-444339, T-566816 - Include Account IAARecordTypes__c='IAA Buyer Services'
                List<Account> accnts = [Select Id 
                                        from Account 
                                        where ASAP_Tower_ID__c=:cntc.ASAP_Tower_ID__c 
                                        and IAARecordTypes__c='IAA Remarketing' ];
                
                //Proceed only if one Account is found
                //If more than one Account records are found, skip Contact record
                //If no Account record is found,  skip Contact record               
                if(accnts.size() == 1){
                    
                    cntc.accountId = accnts[0].Id;
                    
                }               
              }
            }
            catch(Exception e){
           system.debug ('Error Relating contact to Account');
        }       
     }
  }
}