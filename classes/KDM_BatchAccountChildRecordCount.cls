global class KDM_BatchAccountChildRecordCount implements Database.Batchable<SObject>, Database.Stateful {
       
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
    public KDM_BatchAccountChildRecordCount(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail, boolean blnSkipProceessedRecord)  
    {
      query = 'SELECT Id,Name FROM Account '+strSOQLWhereClause;  
      
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
           List<Account> List_Account = (List<Account>) scope;           
           System.debug('>>> List_Account.size()'+List_Account.size());           
           if(List_Account.size() == 0)
           {
                return;
           }           
           
           //
           List<Account> List_Account_For_Process = new List<Account>();
           
           List<id> AccountIds = new  List<id>();
           if(SkipProceessedRecord)
           {
               // Skip records that already processed before 
               
               for(Account obj: List_Account)
               {
                   AccountIds.Add(obj.Id);
               }
               
               List<Account_Child_Summary__c> List_ACS_Exist = [SELECT AccountId__c FROM Account_Child_Summary__c where AccountId__c in:AccountIds LIMIT 50000 ];
               
               Set<Id> ACS_AccountIDs = new Set<Id>();             
                for(Account_Child_Summary__c objCCS: List_ACS_Exist)
                {                      
                    ACS_AccountIDs.Add(objCCS.AccountId__c);
                }
                
                for(Account obj: List_Account)
                {
                    // check if AccountId already exist or not using Set - Not Add in List if exist 
                    if(ACS_AccountIDs.Add(obj.Id))
                    {
                       List_Account_For_Process.Add(obj);
                    }
                }
           }
           else
           {
               // Process All Records
               List_Account_For_Process.AddAll(List_Account);
           }
           //
           
           List<Account_Child_Summary__c> List_ACS = new List<Account_Child_Summary__c>();
            
           
           for(Account obj: List_Account_For_Process)
           {
                Account_Child_Summary__c objACS = new Account_Child_Summary__c();
				if (Schema.sObjectType.Account_Child_Summary__c.fields.Account__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Account__c.isCreateable() || blnFLSOverride)
				{
					objACS.Account__c = obj.Id;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Account__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Account__c.getName());
				}
				if (Schema.sObjectType.Account_Child_Summary__c.fields.AccountId__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.AccountId__c.isCreateable() || blnFLSOverride)
				{
					objACS.AccountId__c = obj.Id;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AccountId__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AccountId__c.getName());
				}
				if (Schema.sObjectType.Account_Child_Summary__c.fields.Name.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Name.isCreateable() || blnFLSOverride)
				{
					objACS.Name = obj.Name;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Name.getName());
					ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Name.getName());
				}
               
               
               try{
                    System.debug('>>> Account obj.Id: '+obj.Id);   
                    
                    // For AFC_Contract_Shell__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contract_Shell_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contract_Shell_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAFC_Contract_Shell = [SELECT count() FROM AFC_Contract_Shell__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.AFC_Contract_Shell_Count__c = intCountAFC_Contract_Shell;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contract_Shell_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contract_Shell_Count__c.getName());
					}
                    
                    // For AFC_Contracts__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contracts_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contracts_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAFC_Contracts = [SELECT count() FROM AFC_Contracts__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.AFC_Contracts_Count__c = intCountAFC_Contracts;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contracts_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.AFC_Contracts_Count__c.getName());
					}
                    
                    // For Adesa_com_Detail__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Adesa_com_Detail_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Adesa_com_Detail_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAdesa_com_Detail = [SELECT count() FROM Adesa_com_Detail__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Adesa_com_Detail_Count__c = intCountAdesa_com_Detail;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Adesa_com_Detail_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Adesa_com_Detail_Count__c.getName());
					}
                    
                    // For Attachment
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Attachment_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Attachment_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAttachment = [SELECT count() FROM Attachment WHERE ParentId = :obj.Id LIMIT 50000 ];
						objACS.Attachment_Count__c = intCountAttachment;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Attachment_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Attachment_Count__c.getName());
					}
                    
                    // For Auction_Detail__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Detail_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Detail_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountAuction_Detail = [SELECT count() FROM Auction_Detail__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Auction_Detail_Count__c = intCountAuction_Detail;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Detail_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Detail_Count__c.getName());
					}
                    
                    // For Contact
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Contact_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountContact = [SELECT count() FROM Contact WHERE AccountId = :obj.Id LIMIT 50000 ];
						objACS.Contact_Count__c = intCountContact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Contact_Count__c.getName());
					}
                    
                    // For Related_Account__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Related_Account_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Related_Account_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRelated_Account = [SELECT count() FROM Related_Account__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Related_Account_Count__c = intCountRelated_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Related_Account_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Related_Account_Count__c.getName());
					}
                    
                    // For Application__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Application_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Application_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountApplication = [SELECT count() FROM Application__c WHERE Applications_Accounts__c = :obj.Id LIMIT 50000 ];
						objACS.Application_Count__c = intCountApplication;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Application_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Application_Count__c.getName());
					}
                    
                    // For Related_Contact__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Related_Contact_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Related_Contact_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRelated_Contact = [SELECT count() FROM Related_Contact__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Related_Contact_Count__c = intCountRelated_Contact;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Related_Contact_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Related_Contact_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Buyer_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Buyer_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountBuyer_Account = [SELECT count() FROM Asset__c WHERE Buyer_Account__c = :obj.Id LIMIT 50000 ];
						objACS.Asset_Buyer_Count__c = intCountBuyer_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Buyer_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Buyer_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Seller_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Seller_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountSeller_Account = [SELECT count() FROM Asset__c WHERE Seller_Account__c = :obj.Id LIMIT 50000 ];
						objACS.Asset_Seller_Count__c = intCountSeller_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Seller_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Seller_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Consignee_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Consignee_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountConsignee_Account = [SELECT count() FROM Asset__c WHERE Consignee_Account__c = :obj.Id LIMIT 50000 ];
						objACS.Asset_Consignee_Count__c = intCountConsignee_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Consignee_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Consignee_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Grounding_Dealer_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Grounding_Dealer_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountGrounding_Dealer_Account = [SELECT count() FROM Asset__c WHERE Grounding_Dealer__c = :obj.Id LIMIT 50000 ];
						objACS.Asset_Grounding_Dealer_Count__c = intCountGrounding_Dealer_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Grounding_Dealer_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Grounding_Dealer_Count__c.getName());
					}
                    
                    // For Asset__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Partner_Account_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Partner_Account_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPartner_Account = [SELECT count() FROM Asset__c WHERE Partner_Account__c = :obj.Id LIMIT 50000 ];
						objACS.Asset_Partner_Account_Count__c = intCountPartner_Account;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Partner_Account_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Asset_Partner_Account_Count__c.getName());
					}
                    
                    // For Auction__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intAuction = [SELECT count() FROM Auction__c WHERE Seller_Account__c = :obj.Id LIMIT 50000 ];
						objACS.Auction_Count__c = intAuction;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Auction_Count__c.getName());
					}
                    
                    // For Bids__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Bids_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Bids_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intBids = [SELECT count() FROM Bids__c WHERE Bidder__c = :obj.Id LIMIT 50000 ];
						objACS.Bids_Count__c = intBids;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Bids_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Bids_Count__c.getName());
					}
                    
                    // For Case
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Case_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Case_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountCase = [SELECT count() FROM Case WHERE AccountId = :obj.Id LIMIT 50000 ];
						objACS.Case_Count__c = intCountCase;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Case_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Case_Count__c.getName());
					}
                    
                    // For Dealer_Registration_Request__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Dealer_Registration_Request_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Dealer_Registration_Request_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountDealer_Registration_Request = [SELECT count() FROM Dealer_Registration_Request__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Dealer_Registration_Request_Count__c = intCountDealer_Registration_Request;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Dealer_Registration_Request_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Dealer_Registration_Request_Count__c.getName());
					}
                    
                    // For Inspection__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Inspection_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Inspection_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountInspection = [SELECT count() FROM Inspection__c WHERE Inspector__c = :obj.Id LIMIT 50000 ];
						objACS.Inspection_Count__c = intCountInspection;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Inspection_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Inspection_Count__c.getName());
					}
                    
                    
                    // For Purchase__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Account_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Account_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_Account = [SELECT count() FROM Purchase__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Purchase_Account_Count__c = intCountPurchase_Account;  
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Account_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Account_Count__c.getName());
					}
					
                    // For Purchase__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Buyer_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Buyer_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_ATC_Buyer = [SELECT count() FROM Purchase__c WHERE ATC_Buyer__c = :obj.Id LIMIT 50000 ];
						objACS.Purchase_ATC_Buyer_Count__c = intCountPurchase_ATC_Buyer;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Buyer_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Buyer_Count__c.getName());
					}
					
                    // For Purchase__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Seller_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Seller_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_ATC_Seller = [SELECT count() FROM Purchase__c WHERE ATC_Seller__c = :obj.Id LIMIT 50000 ];
						objACS.Purchase_ATC_Seller_Count__c = intCountPurchase_ATC_Seller;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Seller_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Seller_Count__c.getName());
					}
					
                    // For Purchase__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Transporter_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Transporter_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_ATC_Transporter = [SELECT count() FROM Purchase__c WHERE ATC_Transporter__c = :obj.Id LIMIT 50000 ];
						objACS.Purchase_ATC_Transporter_Count__c = intCountPurchase_ATC_Transporter;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Transporter_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_ATC_Transporter_Count__c.getName());
					}
					
                    // For Purchase__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Consignee_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Consignee_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountPurchase_Consignee = [SELECT count() FROM Purchase__c WHERE Consignee__c = :obj.Id LIMIT 50000 ];
						objACS.Purchase_Consignee_Count__c = intCountPurchase_Consignee;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Consignee_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Purchase_Consignee_Count__c.getName());
					}
					
                    
                    // For Rep_Status_ADESA_Auction__c
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Rep_Status_ADESA_Auction_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Rep_Status_ADESA_Auction_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intCountRep_Status_ADESA_Auction = [SELECT count() FROM Rep_Status_ADESA_Auction__c WHERE Account__c = :obj.Id LIMIT 50000 ];
						objACS.Rep_Status_ADESA_Auction_Count__c = intCountRep_Status_ADESA_Auction;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Rep_Status_ADESA_Auction_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Rep_Status_ADESA_Auction_Count__c.getName());
					}
                    
                    // For Task
					if (Schema.sObjectType.Account_Child_Summary__c.fields.Activity_Count__c.isUpdateable() && Schema.sObjectType.Account_Child_Summary__c.fields.Activity_Count__c.isCreateable() || blnFLSOverride)
					{
						Integer intActivity = [SELECT count() FROM Task WHERE AccountId = :obj.Id LIMIT 50000 ];
						objACS.Activity_Count__c = intActivity;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Activity_Count__c.getName());
						ListFLSCreate.add(Schema.sObjectType.Account_Child_Summary__c.getName()+'.'+Schema.sObjectType.Account_Child_Summary__c.fields.Activity_Count__c.getName());
					}
                    
                    CounterProcessRecords+=1;
                    List_ACS.Add(objACS);
                                        
               }
               catch (Exception e)
                {
                    System.debug('>>>> Error in Account Count :'+obj.Id);
                    System.debug('>>>> Error Detail :'+e);
                    Summary+='Error Count Detail : '+e.getmessage()+'<br/>';
                }               
               
           }
           
           if(ListFLSUpdate.size() == 0)
		   {
            //Update Records;
            Schema.SObjectField Field_ExternalId = Account_Child_Summary__c.Fields.AccountId__c;
            
            Database.UpsertResult[] srList = Database.upsert(List_ACS,Field_ExternalId,false);
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
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }        
    }
   
    global void finish(Database.BatchableContext bc) 
    {
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:KDM_BatchAccountChildRecordCount', ListFLSUpdate);
		}
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:KDM_BatchAccountChildRecordCount', ListFLSCreate);
		}
        if(SendBatchCompleteNotification)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);           
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished process of KDM_BatchAccountChildRecordCount.'); 
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


//KDM_BatchAccountChildRecordCount objKDM_BatchAccountChildRecordCount = new KDM_BatchAccountChildRecordCount('Limit 10',true,'djpatel@openlane.com',true);
//Database.executeBatch(objKDM_BatchAccountChildRecordCount,7);