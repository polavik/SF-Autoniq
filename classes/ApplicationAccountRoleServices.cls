public with sharing class ApplicationAccountRoleServices {

    public static Application_Account_Role__c getApplicationAccountRole(Id accountId, Id applicationId)
    {
    	if(accountId != null && applicationId != null)
    	{
    		Application_Account_Role__c[] aars = [select Legal_Name_New__c,
                    Account__c,
                    Company_Name__c,
    				DBA_Name__c,
    				TIN__c,
    				Sales_Tax_Number__c,
    				Dealer_License_Number__c,
    				Expiration_Date__c,
    				Entity_Type__c,
    				Years_in_Business__c,
    				Lot_Ownership__c
    				from Application_Account_Role__c
    				where Account__c = :accountId
    				and Application__c = :applicationId
    				limit 1];
    		if(aars.size() == 0)
    		{
    			throw new CustomExceptions.ApplicationException(System.Label.No_Business_Accounts);
    		}
    		else
    		{
    			return aars[0];
    		}
    	}
    	else
    	{
			throw new CustomExceptions.ApplicationException(System.Label.No_Business_Accounts);
    	}
    }
}
/*
    public static void createApplicationAccountRoleForContractIfNecessary(Map<Id, AFC_Contracts__c> contractMap){

        System.debug('#### CONTRACT MAP: ' + contractMap);
        //get all of the application account roles related to the contracts and put them in a map from contract to application account role
        Map<Id, Id> contractToAarMap = new Map<Id, Id>();
        for(Application_Account_Role__c aar : [SELECT Id, AFC_Contracts__c FROM Application_Account_Role__c WHERE AFC_Contracts__c IN :contractMap.keyset()]){
            contractToAarMap.put(aar.AFC_Contracts__c, aar.Id);
        }

        System.debug('#### CONTRACT AAR MAP: ' + contractToAarMap);
        //for all the contracts that have no application account role
        List<Application_Account_Role__c> aarListForInsert = new List<Application_Account_Role__c>();
        for(AFC_Contracts__c aContract : contractMap.values()){
            if(!contractToAarMap.containsKey(aContract.Id)){
                aarListForInsert.add(new Application_Account_Role__c(Account__c = aContract.Account__c, AFC_Contracts__c = aContract.Id, Primary__c = true));
            }
        }
        System.debug('#### AAR LIST: ' + aarListForInsert);

        //insert the missing application account roles
        insert aarListForInsert;
    }
}

//Old Class that this was refactored from
//Name        : ApplicationAccountTriggerManager
//Description : Class to manage all Application Account trigger logic. This class contain seperate methods to handle each trigger event.
//Modification History: 09/24/2013, Sushant Bhasin, Created

public with sharing class ApplicationAccountTriggerManager {

    public List<Application_Account_Role__c> 	NewappAccs;
    public List<Application_Account_Role__c> 	OldappAccs;
    public map<Id, Application_Account_Role__c> mapNewappAccs;
    public map<Id, Application_Account_Role__c> mapOldappAccs;
    

    public ApplicationAccountTriggerManager(List<Application_Account_Role__c> newappAccsList, List<Application_Account_Role__c> oldappAccsList, Map<Id, Application_Account_Role__c> newappAccsMap, Map<Id, Application_Account_Role__c> oldappAccsMap)
    {
        this.NewappAccs	   = newappAccsList;
        this.OldappAccs	   = oldappAccsList;
        this.mapNewappAccs = newappAccsMap;
        this.mapOldappAccs = oldappAccsMap;
        
    }

    public void processBeforeInsert()
    {
    }

    public void processBeforeUpdate()
    {
    }
    

    public void processBeforeDelete()
    {
       clearprimaryApplicationAccountsfield(Trigger.isDelete);
    }

    public void processAfterInsert()
    {
      	detectAndApplyappAccountChanges(Trigger.isInsert);
    }
    

    public void processAfterUpdate()
    {
       detectAndApplyappAccountChanges(Trigger.isInsert);
    }
    
    // Helper Methods.
    
	private void detectAndApplyappAccountChanges(boolean isInsert)   
    {
    	List<Application__c> ApplicationstobeUpdated 			 	= new List<Application__c>();
    	Map<Id, Id> 		 ApplicationIdtoprimaryappAccountId  	= new Map<Id, Id>();
    	Map<Id, Id> 		 ApplicationIdtononprimaryappAccountId 	= new Map<Id, Id>();
		for(Application_Account_Role__c appAcc : this.NewappAccs){
			if((isInsert && appAcc.primary__c) || (!isInsert && this.mapOldappAccs.get(appAcc.Id).primary__c != appAcc.primary__c ))
			{	
				if(appAcc.primary__c)
					ApplicationIdtoprimaryappAccountId.put(appAcc.Application__c , appAcc.Account__c);
				else
					ApplicationIdtononprimaryappAccountId.put(appAcc.Application__c, appAcc.Account__c);
			}
		}
    	for(Application__c App : [select Id, Applications_Accounts__c from Application__c where Id IN :ApplicationIdtoprimaryappAccountId.keyset() OR Id IN :ApplicationIdtononprimaryappAccountId.keyset()])
    	{
    		if(ApplicationIdtoprimaryappAccountId.keyset().contains(App.Id) && App.Applications_Accounts__c != ApplicationIdtoprimaryappAccountId.get(App.Id))
    			ApplicationstobeUpdated.add(new Application__c(Id = App.Id, Applications_Accounts__c = ApplicationIdtoprimaryappAccountId.get(App.Id)));
    		else if(ApplicationIdtononprimaryappAccountId.keyset().contains(App.Id) && App.Applications_Accounts__c == ApplicationIdtononprimaryappAccountId.get(App.Id))
    			ApplicationstobeUpdated.add(new Application__c(Id = App.Id, Applications_Accounts__c = null));
    	}	
    	Database.SaveResult[] srList  = Database.update(ApplicationstobeUpdated,false);      // allow for partial successes
    	for (Integer i = 0; i < srList.size(); i++) {
      		if (!srList[i].isSuccess()) {
        		String err  = srList[i].getErrors()[0].getMessage();  
        		Id ErroredappAccId = ApplicationIdtoprimaryappAccountId.keyset().contains(ApplicationstobeUpdated[i].id) ? ApplicationIdtoprimaryappAccountId.get(ApplicationstobeUpdated[i].id) : ApplicationIdtononprimaryappAccountId.get(ApplicationstobeUpdated[i].id);
        		this.mapNewappAccs.get(ErroredappAccId).addError(err);
      		}
     	}
    }
    
    private void clearprimaryApplicationAccountsfield(boolean isDelete)   
    {
    	List<Application__c> ApplicationstobeUpdated 			 	= new List<Application__c>();
    	Map<Id, Id> 		 ApplicationIdtononprimaryappAccountId 	= new Map<Id, Id>();
    	for(Application_Account_Role__c appAcc : this.OldappAccs){
    		if(isDelete && appAcc.primary__c)
			{	
				ApplicationIdtononprimaryappAccountId.put(appAcc.Application__c, appAcc.Account__c);
			}
    	}
    	
    	for(Application__c App : [select Id, Applications_Accounts__c from Application__c where Id IN :ApplicationIdtononprimaryappAccountId.keyset()])
    	{
    		if(ApplicationIdtononprimaryappAccountId.keyset().contains(App.Id) && App.Applications_Accounts__c == ApplicationIdtononprimaryappAccountId.get(App.Id))
    			ApplicationstobeUpdated.add(new Application__c(Id = App.Id, Applications_Accounts__c = null));
    	}
    	Database.SaveResult[] srList  = Database.update(ApplicationstobeUpdated,false);      // allow for partial successes
    	for (Integer i = 0; i < srList.size(); i++) {
      		if (!srList[i].isSuccess()) {
        		String err  = srList[i].getErrors()[0].getMessage();  
        		Id ErroredappAccId = ApplicationIdtononprimaryappAccountId.get(ApplicationstobeUpdated[i].id);
        		this.mapNewappAccs.get(ErroredappAccId).addError(err);
      		}
     	}	
    } 
}
*/