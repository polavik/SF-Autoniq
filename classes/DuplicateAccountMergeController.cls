public class DuplicateAccountMergeController {

    
    public Account accMaster{get;set;}
    public Account accDuplicate{get;set;}
    public List<Account> searchResults {get;set;}
    public List<Account> searchResultsforDuplicate {get;set;}
    public string MasterIndex{get;set;}
    public boolean ShowDetail{get{if(ShowDetail == null) ShowDetail = true; return ShowDetail;}set;}
    
    
     public string searchText {get;set;}
     public string searchTextDuplicate {get;set;}
     
    
    // Search for master 
    public PageReference search() {
        if(searchText == null || searchText =='')
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Master Index'));
            return null;
        }
        
        if (searchResults == null) {
            searchResults = new List<Account>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
       
        // use some dynamic soql to find the related opportunities by name
        String qry = 'Select Master_Index__c,Data_Source__c,Name,Dba__c,Auction_Access_Number__c,Tax_Identification_Number__c,Company_Email_Address__c,Phone,Mdm_ID__c,Duplicate__c,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c from Account  Where Master_Index__c = \''+searchText+'\'';
        searchResults = Database.query(qry);
        system.debug('####### searchResults:'+searchResults);
        if(searchResults.size()>0)
        {
            accMaster = searchResults[0];
        }
        else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Account not found with Master Index: '+searchText));
        }
        return null;
    }
    
     // Search for Duoplicate 
    public PageReference searchDuplicate() {
    
        if(searchTextDuplicate == null || searchTextDuplicate =='')
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Master Index'));
            return null;
        }
        
        if (searchResultsforDuplicate == null) {
            searchResultsforDuplicate = new List<Account>(); // init the list if it is null
        } else {
            searchResultsforDuplicate .clear(); // clear out the current results if they exist
        }
       
       // Get List of Fields
       String strFields = '';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        List<String> strFieldList = new List<String>(objectFields.keySet());
        Integer intIndex=0;
        for(String strField :strFieldList)
        {
            intIndex+=1;
            if(strField.equalsIgnoreCase('ShippingAddress') ||strField.equalsIgnoreCase('BillingAddress') || strField.equalsIgnoreCase('mailingaddress') || strField.equalsIgnoreCase('otheraddress'))
            {
                continue;
            }
            
            
            String[] strSplitArray = strField.split('__');
            //system.debug('>> strSplitArray.size()'+strSplitArray.size());
            if(strSplitArray.size()==1||strSplitArray.size()==2)
            {
                if(intIndex != strFieldList.size())
                {
                    strFields+= strField+ ',' ;
                }else{      
                    strFields+= strField ;      
                }
            }
            
        }
        //if(strFields.lastIndexOf(',')<strFields.length())
         if(strFields.lastIndexOf(',')==strFields.length()-1)
        {
            strFields = strFields.substring(0,strFields.length()-1);
        }
        //System.debug('>> strFields'+strFields);
       
        // use some dynamic soql to find the related opportunities by name
        String qry = 'Select '+strFields+' from Account  Where Master_Index__c = \''+searchTextDuplicate+'\'';
        //String qry = 'Select Duplicate_with_Master_Index__c,Master_Index__c,Data_Source__c,Name,Dba__c,Auction_Access_Number__c,Tax_Identification_Number__c,Company_Email_Address__c,Phone,Mdm_ID__c,Duplicate__c,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c from Account  Where Master_Index__c = \''+searchTextDuplicate+'\'';
        searchResultsforDuplicate = Database.query(qry);
        system.debug('####### searchResultsforDuplicate :'+searchResultsforDuplicate );
        if(searchResultsforDuplicate.size()>0)
        {
            accDuplicate = searchResultsforDuplicate [0];
            if(accMaster!=null)
            {
               if(accDuplicate.Duplicate_with_Master_Index__c== null || accDuplicate.Duplicate_with_Master_Index__c.trim() == '' )
               {
                    MasterIndex =  accMaster.Master_Index__c ;
               }else
               {
                   MasterIndex =  accDuplicate.Duplicate_with_Master_Index__c;
               }
            }
            if(accDuplicate.Duplicate__c)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+'Duplicate Account already marked as duplicate with Winner Accout Master Index: '+accDuplicate.Duplicate_with_Master_Index__c));
            }
        }else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Account not found with Master Index: '+searchTextDuplicate));
            return null;
        }
        ShowDetail = true;
        return null;
    }
    public string GetToken(){
    
       
        String OrgType = Utils.getOrganizationType('org.type');                        
        String token;                        
        
		String ProdNode = Utils.getProductionNode('prod.instance.node')  ;
		
		
		/*
        if( ProdNode !=null)
        {
            ProdNode = ProdNode.toUppercase();
        }                        
        
		String CurrentUrlNode ;
        String HostURL = URL.getSalesforceBaseUrl().getHost();
        System.Debug('>>> HostURL :'+HostURL );                        
        Integer parts = HostURL.countMatches('.');                        
        System.Debug('>>> countMatches:'+parts);
        // changed for check URL node dynamically e.g. na19, c.na19 
        if(parts== 2)
        {                        
            CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0)).toUpperCase();
        }else{        
            
            CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
        }
        System.Debug('>>> CurrentUrlNode :'+CurrentUrlNode ); 
        if(OrgType == 'prod' && CurrentUrlNode != ProdNode)
		*/
		
		//djpatel on 18-Nov-2016 (B-43977) remove URL dependency
		if(OrgType == 'prod' && Sandbox.isSandbox())
        {        
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Contact Administrator to Chage Organization Type in Property Settings...'));
            return null;        
        }                     
         
         List<String> strPropertyId = new List<String>();
         strPropertyId.Add('mi.service.token.stg');
         strPropertyId.Add('mi.service.token.stg2');
         strPropertyId.Add('mi.service.token.prod');
         strPropertyId.Add('mi.service.token.test');
         
         // work from here 
         List<Property__c> propTokenList = [select Property_Id__c, Property_Value__c,Property_Value_Encrypted__c from Property__c where Property_Id__c IN :strPropertyId];
         
         if( !Sandbox.isSandbox() )
         {
             for(Property__c objProp : propTokenList )
             {
                 if(objProp.Property_Id__c == 'mi.service.token.prod')
                 {
                     token = objProp.Property_Value_Encrypted__c;
                 }
             }
         }else{
         
             for(Property__c objProp : propTokenList )
             {
                 if(objProp.Property_Id__c == 'mi.service.token.'+OrgType)
                 {
                     token = objProp.Property_Value_Encrypted__c;
                 }
             }                        
         }
    return token;
    }
    public PageReference mergeAccount() {       
         
         
        if(accDuplicate ==null && accMaster==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Winner and Duplicate Accounts'));
            return null;
        }        
        if(MasterIndex==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Enter Master Index'));
            return null;
        }
        if(accMaster==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Winner Account'));
            return null;
        }
        if(accDuplicate ==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Duplicate Account'));
            return null;
        }
    
        if(accDuplicate.Master_Index__c==accMaster.Master_Index__c)
        {
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Both Accounts are same'));
           return null;
        }
           
           if(accDuplicate.Duplicate__c==false)
           {

            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Check mark Duplicate Account'));
            return null;

           }
            
            if(MasterIndex == accMaster.Master_Index__c)
            {
				
				Set<String> ListFLSUpdate = new Set<String>();
				Set<String> ListFLSCreate = new Set<String>();
				Boolean blnFLSOverride = Utils.GetFLS();
                 system.debug('### MasterIndex:'+MasterIndex );
                 system.debug('### accMaster.Master_Index__c:'+accMaster.Master_Index__c);
                 system.debug('### accDuplicate.Duplicate__c :'+accDuplicate.Duplicate__c);                
                 
                 
                 //Savepoint sp = Database.setSavepoint();

                 try
                 {
                        
                        string token = GetToken();
                        
                        String masterIndex1 = accDuplicate.Master_Index__c;
                        String masterIndexChangeTo = MasterIndex;
                        String miFactType = 'ACCOUNT'; 
                        boolean blnStatus = false;
                        
                        Integer intResponseCode;
                        String ResponseMessage;
                    
                    // Change After Webservice Work
                    //blnStatus = true;
                    //if(!blnStatus)  // Change After Webservice Work
                    //{
                    
                    // Call web service to Update Master Index 
                    if(!Test.isRunningTest())
                    {                           
                        MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                        objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                        
                        MIServicePhase2.MiUpdateResponse  objMiUpdateResponse = objMiService.updateMasterIndex(token,masterIndex1,masterIndexChangeTo,miFactType,null,null);
                        
                        if(objMiUpdateResponse == null || !objMiUpdateResponse.success)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur on Server while Updating Master Index'));
                            return null;                                
                        }
                        blnStatus = objMiUpdateResponse.success;
                        if(!blnStatus)
                        {
                            MIServicePhase2.Result myServiceResult = objMiUpdateResponse.result;
                            if(myServiceResult!=null)
                            {
                                intResponseCode = myServiceResult.resultCode;
                                ResponseMessage = myServiceResult.message ;
                            }
                        }
                    }
                    //}
                    // End New Web Service 
                        if(blnStatus || Test.isRunningTest())
                        {
                            // Update Master Account All_Data_Sources__c Related Fields
                            
                            if(accDuplicate.AutoCount_Customer__c!=null && accDuplicate.AutoCount_Customer__c.trim()!='' && accMaster.AutoCount_Customer__c!=null && accMaster.AutoCount_Customer__c.trim()!=''){   
								//Story B-44003 : FLS UPDATE ACCESS CHECK
								 if (Schema.sObjectType.Account.fields.AutoCount_Customer__c.isUpdateable() && Schema.sObjectType.Account.fields.AutoCount_Customer__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.AutoCount_Customer__c=accDuplicate.AutoCount_Customer__c; 
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.AutoCount_Customer__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.AutoCount_Customer__c.getName());
								 }
							}
                            if(accDuplicate.ADESA_Customer__c!=null && accDuplicate.ADESA_Customer__c.trim()!='' && accMaster.ADESA_Customer__c!=null && accMaster.ADESA_Customer__c.trim()!=''){   
								if (Schema.sObjectType.Account.fields.ADESA_Customer__c.isUpdateable() && Schema.sObjectType.Account.fields.ADESA_Customer__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.ADESA_Customer__c=accDuplicate.ADESA_Customer__c; 
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.ADESA_Customer__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.ADESA_Customer__c.getName());
								 }
							}
                            if(accDuplicate.OpenLane_Customer__c!=null && accDuplicate.OpenLane_Customer__c.trim()!='' && accMaster.OpenLane_Customer__c!=null && accMaster.OpenLane_Customer__c.trim()!=''){   
								if (Schema.sObjectType.Account.fields.OpenLane_Customer__c.isUpdateable() && Schema.sObjectType.Account.fields.OpenLane_Customer__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.OpenLane_Customer__c=accDuplicate.OpenLane_Customer__c;   
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.OpenLane_Customer__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.OpenLane_Customer__c.getName());
								 }
							}
                            if(accDuplicate.IAA_Customer_Number__c!=null && accDuplicate.IAA_Customer_Number__c.trim()!='' && accMaster.IAA_Customer_Number__c!=null && accMaster.IAA_Customer_Number__c.trim()!=''){   
								if (Schema.sObjectType.Account.fields.IAA_Customer_Number__c.isUpdateable() && Schema.sObjectType.Account.fields.IAA_Customer_Number__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.IAA_Customer_Number__c=accDuplicate.IAA_Customer_Number__c;   
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.IAA_Customer_Number__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.IAA_Customer_Number__c.getName());
								 }
							}
                            if(accDuplicate.PAR_Client_ID__c!=null && accDuplicate.PAR_Client_ID__c.trim()!='' && accMaster.PAR_Client_ID__c!=null && accMaster.PAR_Client_ID__c.trim()!=''){   
								if (Schema.sObjectType.Account.fields.PAR_Client_ID__c.isUpdateable() && Schema.sObjectType.Account.fields.PAR_Client_ID__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.PAR_Client_ID__c=accDuplicate.PAR_Client_ID__c;   
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.PAR_Client_ID__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.PAR_Client_ID__c.getName());
								 }
							}
                            if(accDuplicate.PWI_Customer__c==true && accMaster.PWI_Customer__c ==false ){   
								if (Schema.sObjectType.Account.fields.PWI_Customer__c.isUpdateable() && Schema.sObjectType.Account.fields.PWI_Customer__c.isCreateable() || blnFLSOverride)
								 {
									accMaster.PWI_Customer__c=accDuplicate.PWI_Customer__c; 
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.PWI_Customer__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.PWI_Customer__c.getName());
								 }
							}
                            // check if merge in Winner Master Account or Not
                            
                            // Get List of Field/Value from Duplicate Account for Log 
                            String strFields = '';
                            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
                            List<String> strFieldList = new List<String>(objectFields.keySet());
                            Integer intFieldIndex=0;
                            String strFieldValue = '';
                            for(String strField :strFieldList)
                            {
                                String[] strSplitArray = strField.split('__');
                                    
                                    if(strSplitArray.size()==1||strSplitArray.size()==2)
                                    {
                                        if(strField.equalsIgnoreCase('ShippingAddress') ||strField.equalsIgnoreCase('BillingAddress') || strField.equalsIgnoreCase('mailingaddress') || strField.equalsIgnoreCase('otheraddress'))
                                        {
                                            continue;
                                        }
                                        
                                        if(accDuplicate.get(strField)!=null && accDuplicate.get(strField)!='')
                                        {
                                            intFieldIndex+=1;
                                            strFieldValue+= String.ValueOf(intFieldIndex)+' '+strField+ ':' +accDuplicate.get(strField)+';';
                                        }
                                    }
                            }                           
                            // Insert Log
                            AccountMergeLog__c objAccountMergeLog = new AccountMergeLog__c();
								
							if (Schema.sObjectType.AccountMergeLog__c.fields.Merge_by__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Merge_by__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Merge_by__c = UserInfo.getUserName();
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Merge_by__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Merge_by__c.getName());
							}
							if (Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Master_Index__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Master_Index__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Winner_Account_Master_Index__c = accMaster.Master_Index__c;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Master_Index__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Master_Index__c.getName());
							}
							if (Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Name__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Name__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Winner_Account_Name__c = accMaster.Name;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Name__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Winner_Account_Name__c.getName());
							}
							if (Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Master_Index__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Master_Index__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Duplicate_Account_Master_Index__c = accDuplicate.Master_Index__c; 
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Master_Index__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Master_Index__c.getName());
							}
							if (Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Name__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Name__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Duplicate_Account_Name__c =accDuplicate.Name;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Name__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Name__c.getName());
							}
							if (Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Details__c.isUpdateable() && Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Details__c.isCreateable() || blnFLSOverride)
							{
								objAccountMergeLog.Duplicate_Account_Details__c=strFieldValue;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Details__c.getName());
								ListFLSCreate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Duplicate_Account_Details__c.getName());
							}
                            Insert objAccountMergeLog;
                            
                            //if(MergeAccountRelatedList() && ReParentAccountOfChildObject()) //Migrate Related List 
                            //Call Merge Account 
                            try {
                                merge accMaster accDuplicate;
                                undelete accDuplicate;
                                
                                // Change Duplicate Account Record Type 
                                RecordType objRecordType = [SELECT Id FROM RecordType where Name='Duplicate Account' and IsActive=true and SobjectType='Account' LIMIT 1];
								if (Schema.sObjectType.Account.fields.Duplicate_with_Master_Index__c.isUpdateable() && Schema.sObjectType.Account.fields.Duplicate_with_Master_Index__c.isCreateable() || blnFLSOverride)
								{
									accDuplicate.Duplicate_with_Master_Index__c = MasterIndex ;
								}
								else
								{						
									ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Duplicate_with_Master_Index__c.getName());
									ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.Duplicate_with_Master_Index__c.getName());
								}
                                if(objRecordType != null )
                                {
									if (Schema.sObjectType.Account.fields.RecordTypeid.isUpdateable() && Schema.sObjectType.Account.fields.RecordTypeid.isCreateable() || blnFLSOverride)
									{
										accDuplicate.RecordTypeid= objRecordType.Id;//'012a0000001Fe3SAAS';
									}
									else
									{						
										ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.RecordTypeid.getName());
										ListFLSCreate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.RecordTypeid.getName());
									}
                                }
                                
                                // update duplicate account details
                                update accDuplicate;                                 
                                 
                                 // Update Log
								if (Schema.sObjectType.AccountMergeLog__c.fields.Is_Migrated_in_SF__c.isUpdateable() || blnFLSOverride)
								{
									 objAccountMergeLog.Is_Migrated_in_SF__c = true;
								}
								else
								{						
									ListFLSUpdate.add(Schema.sObjectType.AccountMergeLog__c.getName()+'.'+Schema.sObjectType.AccountMergeLog__c.fields.Is_Migrated_in_SF__c.getName());
								}
                                 Update objAccountMergeLog;
								 
								if(ListFLSUpdate.size()>0)
								{
									Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DuplicateAccountMergeController', ListFLSUpdate);
								}
								if(ListFLSCreate.size()>0)
								{
									Utils.SendEmailforFLS('FLS_CREATE','CLASS:DuplicateAccountMergeController', ListFLSCreate);
								}
                            
                            } catch (DmlException e) {
                                //System.debug('>>> An unexpected error has occurred: ' + e.getMessage()); 
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occur while merging Duplicate Account Data to Winer Account data...<br/> Error : '+e.getMessage()));
                                return null;
                            }
                                                            
                                 
                                                 
                        }else
                        {
                            if(intResponseCode == 1)
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occur while saving data...'));//<br/> Error Code: '+intResponseCode +'<br/>Error Detail : '+ResponseMessage ));
                            }else
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occur while saving data...<br/> Error Code: '+intResponseCode +'<br/> Error Detail : '+ResponseMessage ));
                            }
                            return null;
                        }
                                                             
                     
                 }
                 catch(Exception e)
                 {
                    //Database.rollback(sp);
                     Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while saving data...Please try again later'+'<br/>'+e));
                     return null;
                 }
                 
				 
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'Saved'));
                 
                 
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Winner Accout Master Index not match'));
            }        
        
        return null;
    }
    
   
    public string strOut{get;set;}
}