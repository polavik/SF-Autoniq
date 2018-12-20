public without sharing class LeadController {

//==================================================================================================
	public static void GetLeadBranches(list<Lead> leads){
		
		set<string> setZips = new set<string>();
		
		for(Lead ld : leads){
			setZips.add(ld.PostalCode);
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
		string DefaultOwnerId = [Select Name, SettingValue__c From IAASettings__c Where Name = 'DefaultOwnerId'].SettingValue__c;
		
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
				//	mapTeam.put(branch.Id, members[0]);
				//	//hasDefault = true;
					//BranchTeamMember__c newBTM = new BranchTeamMember__c();
					//newBTM.Branch__c = branch.Id;
					//newBTM.Default__c = true;
					//newBTM.TeamMember__c = DefaultOwnerId;
					//insert newBTM;
					
					mapTeam.put(branch.Id, BranchController.CreateNewTeamMember(DefaultOwnerId, branch.Id));
				}
				
			}else{
				
				// If there are 0 Branch Team Members assigned to the branch
				// create a new member using the default owner from custom settings
				
					/*
					BranchTeamMember__c newBTM = new BranchTeamMember__c();
					newBTM.Branch__c = branch.Id;
					newBTM.Default__c = true;
					newBTM.TeamMember__c = UserInfo.getUserId();
					insert newBTM;
					
					mapTeam.put(branch.Id, newBTM);
					*/
					
					mapTeam.put(branch.Id, BranchController.CreateNewTeamMember(DefaultOwnerId, branch.Id));
					
			}
			
			//system.debug('BTM MAP: ' +  mapTeam);
			
		}

//============================================================================================================
//============================================================================================================
//============================================================================================================
//	CONVERT EVERYTHING ABOVE TO THE BRANCH CONTROLLER SO IT CAN BE USED BY ACCOUNT & LEAD TOGETHER
//	INSTEAD OF HAVING 2 SEPARATE MODULES

		//Set the Branch and default owner of the account.
		//Be sure the acct.Branch is set first since it is the parameter when assigning the Owner
		for(Lead l : leads){
			
			try{
				l.Branch__c = mapZips.get(l.PostalCode).Branch__r.Id;	
			}catch(system.NullPointerException np){
				//If there is an error assigning the branch then set it to the current user
				l.Branch__c = null;
			}
			
			system.debug('===================================== LEAD BRANCH:' + l.Branch__c);
			
			// NEED ONLY 1 TEAM MEMBER THAT IS THE DEFAULT
			
			try{
				l.OwnerId = mapTeam.get(l.Branch__c).TeamMember__c;	
			}catch(system.NullPointerException np){
				// If there is no team member in the map, set the account owner to the current user
				//l.OwnerId = Userinfo.getUserId();
				l.OwnerId = DefaultOwnerId;
			}
			
			
			system.debug('===================================== ACCOUNT OWNER:' + l.OwnerId);
			//system.debug('===================================== ACCT BRANCHE:' + mapZips.get(acct.BillingPostalCode).Branch__r.Id);
			//system.debug('===================================== ACCT OWNER:' + mapTeam.get(acct.Branch__c).TeamMember__c);
	
		}
		
	}
//==================================================================================================
}