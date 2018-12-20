//IAA Remarketing
public without sharing class AccountController {

//==================================================================================================
    public static void GetAccountBranches(list<Account> accounts){
    
        system.debug('START AcctCtl GETACCOUNTBRANCHES');
        
        set<string> setZips = new set<string>();
        
        for(Account acct : accounts){
            setZips.add(acct.BillingPostalCode);
        }
    
        // Get a list of the Zip Codes and related Branches
        list<ZipCode__c> zips = BranchController.LookupBranchByZip(setZips);
        
        map<string, ZipCode__c> mapZips = new map<string, ZipCode__c>();
        set<id> branchIds = new set<id>();
        
        //Breakout the list into a map and also get a list of the Branch Id's
        for(ZipCode__c z : zips){
            mapZips.put(z.Name, z);
            branchIds.add(z.Branch__r.Id);  
        }
    
        map<string, Branch__c> mapBranches = new map<string, Branch__c>();
        map<string, BranchTeamMember__c> mapTeam = new map<string, BranchTeamMember__c>();
    
        //Get a list of branchs with all team members
        list<Branch__c> branches = BranchController.LookupOwnerByBranch(branchIds);
    
        //Get the DefaultOwnerId from CustomSettings
        string DefaultOwnerId = [Select Name, SettingValue__c 
                                 From IAASettings__c 
                                 Where Name = 'DefaultOwnerId'].SettingValue__c;
        
    
    system.debug('CONTROLLER BRANCHES LIST:' + branches);
        

        //Breakout the list of Branches and Team Members into maps
        for(Branch__c branch : branches){
            
            //MAP THE BRANCH
            mapBranches.put(branch.Id, branch); 
        
            system.debug('======== ' + branch.Name + ' BTMs:' + branch.BranchTeamMembers__r.size());

            
            //MAP THE TEAM MEMBERS
            
            // Check to see if there are any team members.
            // If there are 0 assigned then assign then create the current user 
            // as a member and assign to the map
            if(branch.BranchTeamMembers__r.size()>0){
                
                // Get separate list of team members to loop through checking for default
                // or selecting the 1st one in the list to be the owner
                list<BranchTeamMember__c> members = branch.BranchTeamMembers__r;
                
                boolean hasDefault = false;
                
                //Check for a default member and add to the map
                for(BranchTeamMember__c member : members){
                    if(member.Default__c == true){
                        mapTeam.put(branch.Id, member);
                        hasDefault = true;
                        break;
                    }
                }
                
                //If there is no default member set create a new member using the default owner from custom settings
                if (hasDefault == false){           
                    mapTeam.put(branch.Id, BranchController.CreateNewTeamMember(DefaultOwnerId, branch.Id));
                }
                
            }else{
                
                // If there are 0 Branch Team Members assigned to the branch
                // create a new member using the default owner from custom settings
                mapTeam.put(branch.Id, BranchController.CreateNewTeamMember(DefaultOwnerId, branch.Id));
            }
        }
        
//============================================================================================================
//============================================================================================================
//============================================================================================================
//  CONVERT EVERYTHING ABOVE TO THE BRANCH CONTROLLER SO IT CAN BE USED BY ACCOUNT & LEAD TOGETHER
//  INSTEAD OF HAVING 2 SEPARATE MODULES

        //Set the Branch and default owner of the account.
        //Be sure the acct.Branch is set first since it is the parameter when assigning the Owner
        for(Account acct : accounts){
            
            try{
                acct.Branch__c = mapZips.get(acct.BillingPostalCode).Branch__r.Id;  
            }catch(system.NullPointerException np){
                // If there is no zip found dont assign a branch
                acct.Branch__c = null;
            }
            
            system.debug('===================================== ACCOUNT BRANCH:' + acct.Branch__c);
            
            // NEED ONLY 1 TEAM MEMBER THAT IS THE DEFAULT
            
            try{
                // BEGIN S-444338, T-567768 - When an account in the KAR ORG is updated, where IAA Buyer ID is updated from NULL to a value.(automated BI process)
                                system.debug('acct.BuyerID__c :'+acct.BuyerID__c );
                if (acct.BuyerID__c != null)
                {
                acct.IAABuyerOwner__c =mapTeam.get(acct.Branch__c).TeamMember__c;
                }
                }catch(system.NullPointerException np){
                //If there is an error assigning the branch then set it to the current user
                //acct.OwnerId = Userinfo.getUserId();
                
                // BEGIN S-444338, T-567768
                acct.IAABuyerOwner__c =DefaultOwnerId;
            }
            
            try{
                // BEGIN S-444338, T-567769 -When an account in the KAR ORG is updated, where SPID is updated from NULL to a value.  (automated BI process)
                system.debug('acct.SPID__c:'+acct.SPID__c);
                if (acct.SPID__c != null)
                {
                acct.IAAProviderOwner__c = mapTeam.get(acct.Branch__c).TeamMember__c;
                }
                }catch(system.NullPointerException np){
                //If there is an error assigning the branch then set it to the current user
                //acct.OwnerId = Userinfo.getUserId();
                
                // BEGIN S-444338, 567769
                acct.IAAProviderOwner__c =DefaultOwnerId;
            }
        }
    }
}