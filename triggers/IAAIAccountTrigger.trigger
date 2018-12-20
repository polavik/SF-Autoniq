/*
    This trigger sets the branch and default owner of the account
    based on the zipcode of the BillingPostalCode only.
    
    // THIS IS NOT ACTIVE YET
    //The Distance from Branch calculation is done ONLY if it is called 
    //from the UI and not from a batch process so not to hit the governor limits with API calls.
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////
//By: Neil Bodak Jan.12th-2017
//we need this trigger to run after BI update the Record, because MDM will create
//the record partially  without all need information and BI will update it.
////////////////////////////////////////////////////////////////////////////////////////////////////////
trigger IAAIAccountTrigger on Account (after insert, after update) {
//trigger AccountTrigger on Account (before insert, before update, after insert, after update) 
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){

       list<Account> accounts = new list<Account>();

    //Looks up the branches based on the Account Billing ZipCode
    if(trigger.isInsert){
    
       for(Account acct : trigger.new){
            // BEGIN: S-444338, T-565295 - Added to check ACCOUNT recordtype - IAA Remarketing
            if(acct.IAARecordTypes__c=='IAA Remarketing'){
                // END: S-444338, T-565295 - Added to check ACCOUNT recordtype - IAA Remarketing
                system.debug('BranchID:' + acct.Branch__c);
                system.debug('AcctID:' + acct.Id);
                system.debug('NewZip:' + acct.BillingPostalCode);
                system.debug('isInsert:' + trigger.isInsert);
                system.debug('isUpdate:' + trigger.isUpdate);
                //system.debug('ZipChanged: ' + (acct.BillingPostalCode != trigger.oldMap.get(acct.id).BillingPostalCode));
                
                
                // Do the lookup to the branch ONLY if the account is an insert 
                // OR 
                // if it  is an update AND the branch is blank, which will change the owner to the default of the branch 
                // OR
                // The zip code is changed
                //if(   trigger.isInsert || trigger.isUpdate &&         By: N.B.
                if(trigger.isUpdate && (acct.Branch__c == null &&  acct.OwnerId == trigger.oldMap.get(acct.Id).OwnerId) ||
                    (trigger.isUpdate && acct.OwnerId == trigger.oldMap.get(acct.Id).OwnerId )
                        //acct.BillingPostalCode != trigger.oldMap.get(acct.id).BillingPostalCode &&
                  )      
                   
                {
                   // BEGIN S-444338, T-567768 - When an account in the KAR ORG is updated, where IAA Buyer ID is updated from NULL to a value.(automated BI process)
                   //if ((trigger.oldMap.get(acct.Id).BuyerID__c==null && acct.BuyerID__c !=null) ||  (trigger.oldMap.get(acct.Id).SPID__c==null && acct.SPID__c !=null))
                    // END S-444338, T-567768 - When an account in the KAR ORG is updated, where IAA Buyer ID is updated from NULL to a value.(automated BI process)
                    //{
                    accounts.add(acct);
                    //}
                }
           } 
        }
        

        //Only check the accounts that are in the account list and NOT the full trigger.new list
        if(!accounts.isEmpty()){
            AccountController.GetAccountBranches(accounts); 
        }  
    }
    
//---------------------------------------------------------------------------------------------------------
//  THIS GETS THE DISTANCE FROM BRANCH ONLY IF THE TRIGGER SIZE IS 1 WHICH MEANS IT WAS CALLED FROM THE UI  
//  ALSO IT ONLY RUNS THE CODE ON THE AFTER TRIGGER SO THE ACCOUNT ID IS GENERATED ON THE INSERT
    
    system.debug('Trigger Size:' + trigger.size);
    system.debug('Trigger isAfter:' + trigger.isAfter);
    
    if(trigger.size == 1 && trigger.isAfter){
        
        system.debug('START DISTANCE CALC');
        system.debug('BranchController.isRunning:' + BranchController.isRunningFuture);
        
        
        if(BranchController.isRunningFuture == false){
            system.debug('isRunningFuture:' + BranchController.isRunningFuture);
            
            //NOTE: TO FURTHER THE CHECK TO SEE IF THE CALL OUT SHOULD BE RUN,
            //      ADD AND IF STATEMENT TO COMPARE THE BILLING ADDRESS FIELDS IN trigger.new TO trigger.oldMap(acct.Id);
            
            for(Account acct : trigger.new){
            // BEGIN: S-444338, T-565295 - Added to check ACCOUNT recordtype - IAA Remarketing
            if(acct.IAARecordTypes__c=='IAA Remarketing')
            {
            // END: S-444338, T-565295 - Added to check ACCOUNT recordtype - IAA Remarketing 
            
                //THIS CALL IS TO A METHOD WITH THE @FUTURE ANNOTATION BECAUSE YOU CAN'T
                //MAKE A CALLOUT DIRECTLY FROM A TRIGGER
                if(acct.Branch__c != null){
                    BranchController.CalculateDistance(acct.Branch__c, acct.Id, 'Account'); 
                }
              }      
            }
        }
    }
    
//-------------------------------------------------------------------------------------------------
//  THIS SETS THE DEFAULT OWNER AND BRANCH

/*

    system.debug('===================================== ACCOUNT TRIGGER START');

    set<string> setZips = new set<string>();
    
    //Get all the zip codes to lookup using the Account Billing ZipCode
    for(Account acct : trigger.new){
        setZips.add(acct.BillingPostalCode);
    }

    // Get a list of the Zip Codes and related Branches
    list<ZipCode__c> zips = BranchController.LookupAccountBranchByZip(setZips);
    map<string, ZipCode__c> mapZips = new map<string, ZipCode__c>();
    set<id> branchIds = new set<id>();
    
    //Breakout the list into a map and also get a list of the Branch Id's
    for(ZipCode__c z : zips){
        mapZips.put(z.Name, z);
        branchIds.add(z.Branch__r.Id);  
    }

    //Get a list of branchs with the default team member
    list<Branch__c> branches = BranchController.LookupAccountOwnerByBranch(branchIds);
    map<string, Branch__c> mapBranches = new map<string, Branch__c>();
    map<string, BranchTeamMember__c> mapTeam = new map<string, BranchTeamMember__c>();


    //Breakout the list of Branches and Team Members into maps
    for(Branch__c branch : branches){
        mapBranches.put(branch.Id, branch); 
    
        for(BranchTeamMember__c btm : branch.BranchTeamMembers__r){
            
            //if(btm.Default__c == true){
                mapTeam.put(btm.Branch__r.Id, btm); 
            //}
            
        }   
    }
    
    system.debug('===================================== GET DEFAULT TEAM MEMBER');
    system.debug('===================================== BRANCHES:' + branches);
    //system.debug('===================================== TEAM MEMBERS MAP:' + mapTeam);

    
    //ONLY SET THE FIELDS ON THE BEFORE TRIGGER
    if(trigger.isBefore){
    
        //Set the Branch and default owner of the account.
        //Be sure the acct.Branch is set first since it is the parameter when assigning the Owner
        for(Account acct : trigger.new){
            
            try{
                acct.Branch__c = mapZips.get(acct.BillingPostalCode).Branch__r.Id;  
            }catch(system.NullPointerException np){
                acct.Branch__c = null;
            }
            
            system.debug('===================================== ACCOUNT BRANCH:' + acct.Branch__c);
            
            try{
                acct.OwnerId = mapTeam.get(acct.Branch__c).TeamMember__c;   
            }catch(system.NullPointerException np){
                acct.OwnerId = Userinfo.getUserId();
            }
            
            system.debug('===================================== ACCOUNT OWNER:' + acct.OwnerId);
            
        //system.debug('===================================== ACCT BRANCHE:' + mapZips.get(acct.BillingPostalCode).Branch__r.Id);
        //system.debug('===================================== ACCT OWNER:' + mapTeam.get(acct.Branch__c).TeamMember__c);

        }   
    }
    
*/

//---------------------------------------------------------------------------------------------------------
//  THIS GETS THE DISTANCE FROM BRANCH ONLY IF THE TRIGGER SIZE IS 1 WHICH MEANS IT WAS CALLED FROM THE UI  
//  ALSO IT ONLY RUNS THE CODE ON THE AFTER TRIGGER SO THE ACCOUNT ID IS GENERATED ON THE INSERT
    
/*
    if(trigger.size == 1 && trigger.isAfter) 
        //&& trigger.new[0].BillingPostalCode != trigger.oldMap(trigger.new[0].id).BillingPostalCode)
    {
        
        if(BranchController.isRunningFuture == false){
            system.debug('isRunningFuture:' + BranchController.isRunningFuture);
            
            //NOTE: TO FURTHER THE CHECK TO SEE IF THE CALL OUT SHOULD BE RUN,
            //      ADD AND IF STATEMENT TO COMPARE THE BILLING ADDRESS FIELDS IN trigger.new TO trigger.oldMap(acct.Id);
            
            
            for(Account acct : trigger.new){
                
                //THIS CALL IS TO A METHOD WITH THE @FUTURE ANNOTATION BECAUSE YOU CAN'T
                //MAKE A CALLOUT DIRECTLY FROM A TRIGGER
                BranchController.CalculateAccountDistance(acct.Branch__c, acct.Id); 
            }
        }
    }
*/


    }
}