global class AccountTerritoryUpdateHelper{

  @future 
  public static void updateAccounts(Set<Id> tIdList, Set<String> territoryZipSet) {
    List<Account> ListUsAccounts = new List<Account>();
    
    String ActiveDealershipUSRecordTypeId = Utils.getRecordTypeId('Account', 'Dealership Account US'); 
    if(ActiveDealershipUSRecordTypeId==null)
    {
        return;
    }
    
    List<Territory__c> territoryList = 
    
    [
        Select Account_Owner__c, Zipcode__c, D2D_Specialist__c, DOSS__c, DST_Outside_Sales_Rep__c, ADESA_Territory_Name__c, ISS__c
        FROM Territory__c
        WHERE Id IN :tIdList
        
    ];
    
    ListUsAccounts = 
     [   
            SELECT Id, BillingPostalCode, Assignment_Exception_Account_Owner__c,
            Assignment_Exception_D2D_Specialist__c, Assignment_Exception_DOSS__c,
            Assignment_Exception_Outside_Rep__c, Assignment_Exception_ADESA_Territory_N__c,
            Assignment_Exception_ISS__c 
            FROM Account 
            WHERE RecordTypeId = :ActiveDealershipUSRecordTypeId 
            AND BillingPostalCode__c IN :territoryZipSet
    ];
    
    List<Account> updateUsAccounts = new List<Account>();
	Set<String> ListFLSUpdate = new Set<String>();	
	Boolean blnFLSOverride = Utils.GetFLS();

    for(Territory__c zipTer : territoryList ){   
          for(Account objAccount: ListUsAccounts){
               
              if(objAccount.BillingPostalCode.length() >= 5){             
               
                
               if(zipTer.Zipcode__c == objAccount.BillingPostalCode.substring(0,5)){    
               
               System.debug('>>>> zipTer:'+zipTer);
              // System.debug('>>>> objAccount.DST_Outside_Sales_Rep_Lookup__c:'+objAccount.DST_Outside_Sales_Rep_Lookup__c);
               
                  if(!objAccount.Assignment_Exception_Account_Owner__c && zipTer.Account_Owner__c != null )    
				  {
					  //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.OwnerId.isUpdateable() || blnFLSOverride)
					 {						 
						objAccount.OwnerId = zipTer.Account_Owner__c;
					 }
					 else
					 {
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.OwnerId.getName());
					 }
				  }
                  if(!objAccount.Assignment_Exception_D2D_Specialist__c)
				  {
					  //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.iDeal_Spl__c.isUpdateable() || blnFLSOverride)
					 {						 
						objAccount.iDeal_Spl__c = zipTer.D2D_Specialist__c;
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.iDeal_Spl__c.getName());
					 }
				  }
                  if(!objAccount.Assignment_Exception_DOSS__c)
				  {
					  //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.Field_Sales_Rep__c.isUpdateable() || blnFLSOverride)
					 {						 
						objAccount.Field_Sales_Rep__c = zipTer.DOSS__c;						
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Field_Sales_Rep__c.getName());
					 }
				  }
                  if(!objAccount.Assignment_Exception_Outside_Rep__c)
				  {
					  //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.DST_Outside_Sales_Rep_Lookup__c.isUpdateable() || blnFLSOverride)
					 {						 
						 objAccount.DST_Outside_Sales_Rep_Lookup__c = zipTer.DST_Outside_Sales_Rep__c;						
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.DST_Outside_Sales_Rep_Lookup__c.getName());
					 }                  
				  }                     
                  if(zipTer.ADESA_Territory_Name__c != null && objAccount.Assignment_Exception_ADESA_Territory_N__c == false) 
                  {
					 //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.ADESA_Territory_Name__c.isUpdateable() || blnFLSOverride)
					 {						 
                      objAccount.ADESA_Territory_Name__c = zipTer.ADESA_Territory_Name__c;					
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.ADESA_Territory_Name__c.getName());
					 }
									  }
                  if(zipTer.ISS__c != null && objAccount.Assignment_Exception_ISS__c == false)
                  {
					   //Story B-44003 : FLS UPDATE ACCESS CHECK
					 if (Schema.sObjectType.Account.fields.ISS__c.isUpdateable() || blnFLSOverride)
					 {						 
						objAccount.ISS__c = zipTer.ISS__c;						
					 }
					 else
					 {						
						ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.ISS__c.getName());
					 }
									  }
                                
                  updateUsAccounts.add(objAccount);
                  
               }
              }
          }
    }
	if(ListFLSUpdate.size()>0)
	{
		Utils.SendEmailforFLS('FLS_UPDATE','CLASS:AccountTerritoryUpdateHelper', ListFLSUpdate);
	}
	
    try {
         
        update updateUsAccounts;
        
    } catch (DmlException e) {
     System.debug('>>>> e'+e);
    }
    
    
    
  }
}