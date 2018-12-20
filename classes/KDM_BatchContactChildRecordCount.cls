global class KDM_BatchContactChildRecordCount implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global boolean SkipProceessedRecord;
    global string ToEmail;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpsertRecords;
    global Integer CounterSuccessInsertRecords;
    global Integer CounterSuccessUpdateRecords;
    global Set<String> ListFLSUpdate ;
    global Set<String> ListFLSCreate ;
    
	 
    // Constructor  
    public KDM_BatchContactChildRecordCount(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail, boolean blnSkipProceessedRecord)  
    {
      query = 'SELECT Id,Name FROM Contact '+strSOQLWhereClause;  
      
      Summary='';
      ToEmail = strToEmail;
      CounterProcessRecords=0;
      CounterSuccessUpsertRecords=0;
      CounterSuccessInsertRecords=0;
      CounterSuccessUpdateRecords=0;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
      SkipProceessedRecord = blnSkipProceessedRecord;
      System.debug('>>> query'+query);
	  ListFLSUpdate = new Set<String>();
	  ListFLSCreate = new Set<String>();
	  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
		Boolean blnFLSOverride = Utils.GetFLS();
        try{
           //1. Get List of 200 Records
           List<Contact> List_Contact = (List<Contact>) scope;           
           System.debug('>>> List_Contact.size()'+List_Contact.size());           
           if(List_Contact.size() == 0)
           {
                return;
           }           
           
           List<Contact> List_Contact_For_Process = new List<Contact>();
           
           List<id> ContactIds = new  List<id>();
           if(SkipProceessedRecord)
           {
               // Skip records that already processed before 
               
               for(Contact obj: List_Contact)
               {
                   ContactIds.Add(obj.Id);
               }
               
               List<Contact_Child_Summary__c> List_CCS_Exist = [SELECT ContactId__c FROM Contact_Child_Summary__c where ContactId__c in:ContactIds LIMIT 50000 ];
               
               Set<Id> CCS_ContactIDs = new Set<Id>();             
                for(Contact_Child_Summary__c objCCS: List_CCS_Exist)
                {                      
                    CCS_ContactIDs.Add(objCCS.ContactId__c);
                }
                
                for(Contact obj: List_Contact)
                {
                    // check if ContactId already exist or not using Set - Not Add in List if exist 
                    if(CCS_ContactIDs.Add(obj.Id))
                    {
                       List_Contact_For_Process.Add(obj);
                    }
                }
           }
           else
           {
               // Process All Records
               List_Contact_For_Process.AddAll(List_Contact);
           }
           
           List<Contact_Child_Summary__c> List_CCS = new List<Contact_Child_Summary__c>();
            
           //2. Make List 
           for(Contact obj: List_Contact_For_Process)
           {
               Contact_Child_Summary__c objCCS = new Contact_Child_Summary__c();
			   
				if (Schema.sObjectType.Contact_Child_Summary__c.fields.Contact__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Contact__c.isCreateable() || blnFLSOverride)
				{
					objCCS.Contact__c = obj.Id;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Contact__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Contact__c.getName());
				}
				if (Schema.sObjectType.Contact_Child_Summary__c.fields.ContactId__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.ContactId__c.isCreateable() || blnFLSOverride)
				{
					objCCS.ContactId__c = obj.Id;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ContactId__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ContactId__c.getName());
				}
				if (Schema.sObjectType.Contact_Child_Summary__c.fields.Name.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Name.isCreateable() || blnFLSOverride)
				{
					objCCS.Name = obj.Name;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Name.getName());
					ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Name.getName());
				}
               
               try{
                    System.debug('>>> Contact obj.Id: '+obj.Id);                
                    
                    // For Case
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Case_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Case_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountCase = [SELECT count() FROM Case WHERE ContactId = :obj.Id LIMIT 50000 ];
						objCCS.Case_Count__c = intCountCase;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Case_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Case_Count__c.getName());
					}
                    
                    // For Task
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Activity_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Activity_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intActivity = [SELECT count() FROM Task WHERE WhoId = :obj.Id LIMIT 50000 ];
						objCCS.Activity_Count__c = intActivity;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Activity_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Activity_Count__c.getName());
					}
                    
                    // For ActivityHistory -- ActivityHistory does not support query
                    //Integer intCountActivityHistory = [SELECT count() FROM ActivityHistory WHERE WhoId = :obj.Id LIMIT 50000 ];
                    //objCCS.ActivityHistory_Count__c = intCountActivityHistory;                    
                    
                    // For ApplicationScoringAdverseAction__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.ApplicationScoringAdverseAction_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.ApplicationScoringAdverseAction_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountApplicationScoringAdverseAction = [SELECT count() FROM ApplicationScoringAdverseAction__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.ApplicationScoringAdverseAction_Count__c = intCountApplicationScoringAdverseAction;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ApplicationScoringAdverseAction_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ApplicationScoringAdverseAction_Count__c.getName());
					}
                    
                    // For Application_Contact_Role__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Application_Contact_Role_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Application_Contact_Role_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountApplication_Contact_Role = [SELECT count() FROM Application_Contact_Role__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Application_Contact_Role_Count__c = intCountApplication_Contact_Role;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Application_Contact_Role_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Application_Contact_Role_Count__c.getName());
					}
                    
                    // For ContactHistory
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.ContactHistory_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.ContactHistory_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountContactHistory = [SELECT count() FROM ContactHistory WHERE ContactId = :obj.Id LIMIT 50000 ];
						objCCS.ContactHistory_Count__c = intCountContactHistory;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ContactHistory_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.ContactHistory_Count__c.getName());
					}
                    
                    // For Login_History__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Login_History_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Login_History_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountLogin_History = [SELECT count() FROM Login_History__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Login_History_Count__c = intCountLogin_History;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Login_History_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Login_History_Count__c.getName());
					}
                    
                    // For OpenActivity -- OpenActivity does not support query 
                    //Integer intCountOpenActivity = [SELECT count() FROM OpenActivity WHERE WhoId = :obj.Id LIMIT 50000 ];
                    //objCCS.OpenActivity_Count__c = intCountOpenActivity;
                    
                    // For Related_AFC_Contract_Contact__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Related_AFC_Contract_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Related_AFC_Contract_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRelated_AFC_Contract_Contact = [SELECT count() FROM Related_AFC_Contract_Contact__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Related_AFC_Contract_Contact_Count__c = intCountRelated_AFC_Contract_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_AFC_Contract_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_AFC_Contract_Contact_Count__c.getName());
					}
                    
                    // For Related_Adesa_com_Contact__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Adesa_com_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Adesa_com_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRelated_Adesa_com_Contact = [SELECT count() FROM Related_Adesa_com_Contact__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Related_Adesa_com_Contact_Count__c = intCountRelated_Adesa_com_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Adesa_com_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Adesa_com_Contact_Count__c.getName());
					}
                    
                    // For Related_Contact__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRelated_Contact = [SELECT count() FROM Related_Contact__c WHERE Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Related_Contact_Count__c = intCountRelated_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Related_Contact_Count__c.getName());
					}
                    
                    // For Action_Package__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Action_Package_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Action_Package_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAction_Package = [SELECT count() FROM Action_Package__c WHERE Seller_Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Action_Package_Count__c = intCountAction_Package;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Action_Package_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Action_Package_Count__c.getName());
					}

                    
                    // For Asset__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_LastModifiedBy_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_LastModifiedBy_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountLast_Modified_By = [SELECT count() FROM Asset__c WHERE Last_Modified_By__c = :obj.Id LIMIT 50000 ];
						objCCS.Asset_LastModifiedBy_Count__c = intCountLast_Modified_By;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_LastModifiedBy_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_LastModifiedBy_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_Seller_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_Seller_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountSeller_Contact = [SELECT count() FROM Asset__c WHERE Seller_Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Asset_Seller_Contact_Count__c = intCountSeller_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_Seller_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Asset_Seller_Contact_Count__c.getName());
					}
                    
                    // For Bids__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Bids_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Bids_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intBids = [SELECT count() FROM Bids__c WHERE Bidder_Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Bids_Count__c = intBids;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Bids_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Bids_Count__c.getName());
					}
                    
                    // For Purchase__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_ATC_Buyer_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_ATC_Buyer_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_ATC_Buyer = [SELECT count() FROM Purchase__c WHERE ATC_Buyer_Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Purchase_ATC_Buyer_Contact_Count__c = intCountPurchase_ATC_Buyer;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_ATC_Buyer_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_ATC_Buyer_Contact_Count__c.getName());
					}
                    
                    // For Purchase__c
					if (Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_Seller_Contact_Count__c.isUpdateable() && Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_Seller_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchaseSeller_Contact = [SELECT count() FROM Purchase__c WHERE Seller_Contact__c = :obj.Id LIMIT 50000 ];
						objCCS.Purchase_Seller_Contact_Count__c = intCountPurchaseSeller_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_Seller_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Contact_Child_Summary__c.getName()+'.'+Schema.sObjectType.Contact_Child_Summary__c.fields.Purchase_Seller_Contact_Count__c.getName());
					}
                    
                    CounterProcessRecords+=1;
                    List_CCS.Add(objCCS);
                                        
               }
               catch (Exception e)
                {
                    System.debug('>>>> Error in Contact Count :'+obj.Id);
                    System.debug('>>>> Error Detail :'+e);
                    Summary+='Error Count Detail : '+e.getmessage()+'<br/>';
                }               
               
           }
           
           
            //Update Records;
            Schema.SObjectField Field_ExternalId = Contact_Child_Summary__c.Fields.ContactId__c;
            
            Database.UpsertResult[] srList = Database.upsert(List_CCS,Field_ExternalId,false);
            for (Database.UpsertResult sr : srList) {
                CounterSuccessUpsertRecords+=1;
                
                if (!sr.isSuccess()){
                    CounterSuccessUpsertRecords-=1;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                      
                        System.debug('>>> Error in Update ACS : '+err.getStatusCode() + ': ' + err.getMessage());                        
                    }
                }
                else if(sr.Created)
                {
                    CounterSuccessInsertRecords+=1;
                }
                else
                {
                    CounterSuccessUpdateRecords+=1;                 
                }
            }            
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }        
    }
   
    global void finish(Database.BatchableContext bc) 
    {
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:KDM_BatchContactChildRecordCount', ListFLSUpdate);
		}
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:KDM_BatchContactChildRecordCount', ListFLSCreate);
		}
        if(SendBatchCompleteNotification)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);           
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished process of KDM_BatchContactChildRecordCount.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Summary+='<br/><br/> Organization Id: ' + Userinfo.getOrganizationId();
            Summary+='<br/><br/> Organization Name: ' + Userinfo.getOrganizationName() +' ('+ URL.getSalesforceBaseUrl().getHost().substring(0,URL.getSalesforceBaseUrl().getHost().indexOf('.',0)).toUpperCase() +')';
            
            Summary+='<br/><br/> Processed Records: ' + String.valueOf(CounterProcessRecords);
            Summary+='<br/><br/> Success Upserted Records: ' + String.valueOf(CounterSuccessUpsertRecords);
            Summary+='<br/><br/> ---------------------------- ';
            Summary+='<br/> Success Inserted Records: ' + String.valueOf(CounterSuccessInsertRecords);
            Summary+='<br/> Success Updated Records: ' + String.valueOf(CounterSuccessUpdateRecords);
            Summary+='<br/>>> Fail to Upsert Records: ' + String.valueOf(CounterProcessRecords - CounterSuccessUpsertRecords);
            Summary+='<br/> ---------------------------- ';
            
            mail.sethtmlBody(Summary);
            if(!Test.isRunningTest() && !Sandbox.isSandbox())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//KDM_BatchContactChildRecordCount objKDM_BatchContactChildRecordCount = new KDM_BatchContactChildRecordCount('Limit 10',true,'djpatel@openlane.com',true);
//Database.executeBatch(objKDM_BatchContactChildRecordCount,12);