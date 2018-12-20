public class DuplicateContactMergeController {
    
    public Contact conMaster{get;set;}
    public Contact conDuplicate{get;set;}
    public List<Contact> searchResults {get;set;}
    public List<Contact> searchResultsforDuplicate {get;set;}
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
            searchResults = new List<Contact>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
       
        //String qry = 'Select Master_Index__c,Data_Source__c,Name,Dba__c,Auction_coness_Number__c,Tax_Identification_Number__c,Company_Email_Address__c,Phone,Mdm_ID__c,Duplicate__c,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c from Contact  Where Master_Index__c = \''+searchText+'\'';
        String qry = 'Select ID,Duplicate__c,Duplicate_with_Master_Index__c,Account.Name,MailingStreet, MailingCity, MailingCountry, MailingState,  MailingPostalCode ,Master_Index__c ,Name ,Email ,Phone ,MobilePhone ,AccountId ,Active__c ,Mdm_ID__c ,Party_Id__c ,Person_ID__c ,Login_ID__c ,Login_Name__c  from Contact  Where Master_Index__c = \''+searchText+'\'';
        searchResults = Database.query(qry);
        system.debug('####### searchResults:'+searchResults);
        if(searchResults.size()>0)
        {
            conMaster = searchResults[0];
        }
        else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Contact not found with Master Index: '+searchText));
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
            searchResultsforDuplicate = new List<Contact>(); // init the list if it is null
        } else {
            searchResultsforDuplicate .clear(); // clear out the current results if they exist
        }
       
       // Get List of Fields
       String strFields = '';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
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
        String qry = 'Select '+strFields+',Account.Name from Contact  Where Master_Index__c = \''+searchTextDuplicate+'\'';
        //String qry = 'Select Duplicate_with_Master_Index__c,Master_Index__c,Data_Source__c,Name,Dba__c,Auction_coness_Number__c,Tax_Identification_Number__c,Company_Email_Address__c,Phone,Mdm_ID__c,Duplicate__c,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c from Contact  Where Master_Index__c = \''+searchTextDuplicate+'\'';
        searchResultsforDuplicate = Database.query(qry);
        system.debug('####### searchResultsforDuplicate :'+searchResultsforDuplicate );
        if(searchResultsforDuplicate.size()>0)
        {
            conDuplicate = searchResultsforDuplicate [0];
            if(conMaster!=null)
            {
               if(conDuplicate.Duplicate_with_Master_Index__c== null || conDuplicate.Duplicate_with_Master_Index__c.trim() == '' )
               {
                    MasterIndex =  conMaster.Master_Index__c ;
               }else
               {
                   MasterIndex =  conDuplicate.Duplicate_with_Master_Index__c;
               }
            }
            if(conDuplicate.Duplicate__c)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+'Duplicate Contact already marked as duplicate with Winner Contact Master Index: '+conDuplicate.Duplicate_with_Master_Index__c));
            }
        }else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Contact not found with Master Index: '+searchTextDuplicate));
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
    public PageReference mergeContact() {
        
         
         
        if(conDuplicate ==null && conMaster==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Winner and Duplicate Contacts'));
            return null;
        }        
        if(MasterIndex==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Enter Master Index'));
            return null;
        }
        if(conMaster==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Winner Contact'));
            return null;
        }
        if(conDuplicate ==null)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Select Duplicate Contact'));
            return null;
        }
    
        if(conDuplicate.Master_Index__c==conMaster.Master_Index__c)
        {
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Both Contacts are same'));
           return null;
        }
           
           if(conDuplicate.Duplicate__c==false)
           {

            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Check mark Duplicate Contact'));
            return null;

           }
            system.debug('### conMaster:'+conMaster );
            system.debug('### conDuplicate:'+conDuplicate );
            
            system.debug('### conMaster.Master_Index__c:'+conMaster.Master_Index__c );
            system.debug('### conDuplicate.Master_Index__c:'+conDuplicate.Master_Index__c );
            
            if(MasterIndex == conMaster.Master_Index__c)
            {
                 system.debug('### MasterIndex:'+MasterIndex );
                 system.debug('### conMaster.Master_Index__c:'+conMaster.Master_Index__c);
                 system.debug('### conDuplicate.Duplicate__c :'+conDuplicate.Duplicate__c);
                 
                 
                 
                 //Savepoint sp = Database.setSavepoint();

                 try
                 {
                        Set<String> ListFLSUpdate = new Set<String>();
                        Set<String> ListFLSCreate = new Set<String>();
						Boolean blnFLSOverride = Utils.GetFLS();
                        string token = GetToken();
                        
                        String masterIndex1 = conDuplicate.Master_Index__c;
                        String masterIndexChangeTo = MasterIndex;
                        String miFactType = 'CONTACT'; 
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
                        
                        system.debug('### Parameter(masterIndex1)Duplicate Contact Master Index:'+masterIndex1 );
                        system.debug('### Parameter(masterIndexChangeTo)Winner Contact Master Index:'+masterIndexChangeTo );
                        
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
                            system.debug('### Suceess Updates');
                            /*
                            // Update Master Contact All_Data_Sources__c Related Fields
                            
                            if(conDuplicate.AutoCount_Customer__c!=null && conDuplicate.AutoCount_Customer__c.trim()!='' && conMaster.AutoCount_Customer__c!=null && conMaster.AutoCount_Customer__c.trim()!=''){   conMaster.AutoCount_Customer__c=conDuplicate.AutoCount_Customer__c; }
                            if(conDuplicate.ADESA_Customer__c!=null && conDuplicate.ADESA_Customer__c.trim()!='' && conMaster.ADESA_Customer__c!=null && conMaster.ADESA_Customer__c.trim()!=''){   conMaster.ADESA_Customer__c=conDuplicate.ADESA_Customer__c; }
                            if(conDuplicate.OpenLane_Customer__c!=null && conDuplicate.OpenLane_Customer__c.trim()!='' && conMaster.OpenLane_Customer__c!=null && conMaster.OpenLane_Customer__c.trim()!=''){   conMaster.OpenLane_Customer__c=conDuplicate.OpenLane_Customer__c;   }
                            if(conDuplicate.IAA_Customer_Number__c!=null && conDuplicate.IAA_Customer_Number__c.trim()!='' && conMaster.IAA_Customer_Number__c!=null && conMaster.IAA_Customer_Number__c.trim()!=''){   conMaster.IAA_Customer_Number__c=conDuplicate.IAA_Customer_Number__c;   }
                            if(conDuplicate.PAR_Client_ID__c!=null && conDuplicate.PAR_Client_ID__c.trim()!='' && conMaster.PAR_Client_ID__c!=null && conMaster.PAR_Client_ID__c.trim()!=''){   conMaster.PAR_Client_ID__c=conDuplicate.PAR_Client_ID__c;   }
                            if(conDuplicate.PWI_Customer__c==true && conMaster.PWI_Customer__c ==false ){   conMaster.PWI_Customer__c=conDuplicate.PWI_Customer__c; }
                            */
                            
                            // check if merge in Winner Master Contact or Not
                            
                            // Get List of Field/Value from Duplicate Contact for Log 
                            String strFields = '';
                            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
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
                                        
                                        if(conDuplicate.get(strField)!=null && conDuplicate.get(strField)!='')
                                        {
                                            intFieldIndex+=1;
                                            strFieldValue+= String.ValueOf(intFieldIndex)+' '+strField+ ':' +conDuplicate.get(strField)+';';
                                        }
                                    }
                            }                           
                            // Insert Log
                            ContactMergeLog__c objContactMergeLog = new ContactMergeLog__c();
							//Story B-44003 : FLS UPDATE ACCESS CHECK
							if (Schema.sObjectType.ContactMergeLog__c.fields.Merge_by__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Merge_by__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Merge_by__c = UserInfo.getUserName();
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Merge_by__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Merge_by__c.getName());
							}
							if (Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Master_Index__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Master_Index__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Winner_Contact_Master_Index__c = conMaster.Master_Index__c;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Master_Index__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Master_Index__c.getName());
							}
							if (Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Name__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Name__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Winner_Contact_Name__c = conMaster.Name;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Name__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Winner_Contact_Name__c.getName());
							}
							if (Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Master_Index__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Master_Index__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Duplicate_Contact_Master_Index__c = conDuplicate.Master_Index__c; 
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Master_Index__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Master_Index__c.getName());
							}
							if (Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Name__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Name__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Duplicate_Contact_Name__c =conDuplicate.Name;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Name__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Name__c.getName());
							}
							if (Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Details__c.isUpdateable() && Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Details__c.isCreateable() || blnFLSOverride)
							{
								objContactMergeLog.Duplicate_Contact_Details__c=strFieldValue;
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Details__c.getName());
								ListFLSCreate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Duplicate_Contact_Details__c.getName());
							}							
                            Insert objContactMergeLog;
                            
                            //if(MergeContactRelatedList() && ReParentContactOfChildObject()) //Migrate Related List 
                            //Call Merge Contact 
                            try {
                                
                                Contact MasterContact = [SELECT ID,Master_Index__c FROM CONTACT WHERE ID=:conMaster.Id];
                                Contact DuplicateContact = [SELECT ID,Master_Index__c FROM CONTACT WHERE ID=:conDuplicate.Id];
                                
                                system.debug('### Before Merge');
                                
                                system.debug('### MasterContact.Master_Index__c:'+MasterContact.Master_Index__c );
                                system.debug('### DuplicateContact.Master_Index__c:'+DuplicateContact.Master_Index__c );
                                
                                merge MasterContact DuplicateContact;
                                undelete DuplicateContact;
                                
                                system.debug('### After Merge');
                                
                                system.debug('### MasterContact.Master_Index__c:'+MasterContact.Master_Index__c );
                                system.debug('### DuplicateContact.Master_Index__c:'+DuplicateContact.Master_Index__c );
                                
                                // Change Duplicate Contact Record Type 
                                RecordType objRecordType = [SELECT Id FROM RecordType where Name='Invalid' and IsActive=true and SobjectType='Contact' LIMIT 1];
                                
                                system.debug('### MasterIndex:'+MasterIndex );
                                
								if (Schema.sObjectType.Contact.fields.Duplicate_with_Master_Index__c.isUpdateable() || blnFLSOverride)
								{
									conDuplicate.Duplicate_with_Master_Index__c = MasterIndex ;
								}
								else
								{						
									ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Duplicate_with_Master_Index__c.getName());
								}
								
                                if(objRecordType != null )
                                {
									if (Schema.sObjectType.Contact.fields.RecordTypeid.isUpdateable() || blnFLSOverride)
									{
										conDuplicate.RecordTypeid= objRecordType.Id;//'012a0000001Fe3SAAS';
									}
									else
									{						
										ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.RecordTypeid.getName());
									}
                                }
                                
                                // update duplicate Contact details
                                update conDuplicate;                                 
                                 
                                // Update Log
								if (Schema.sObjectType.ContactMergeLog__c.fields.Is_Migrated_in_SF__c.isUpdateable() || blnFLSOverride)
								{
									 objContactMergeLog.Is_Migrated_in_SF__c = true;
								}
								else
								{						
									ListFLSUpdate.add(Schema.sObjectType.ContactMergeLog__c.getName()+'.'+Schema.sObjectType.ContactMergeLog__c.fields.Is_Migrated_in_SF__c.getName());
								}
                                
								Update objContactMergeLog;
								
								
								if(ListFLSUpdate.size()>0)
								{
									Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DuplicateContactMergeController', ListFLSUpdate);
								}
                            
                            } catch (DmlException e) {
                                //System.debug('>>> An unexpected error has occurred: ' + e.getMessage()); 
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occur while merging Duplicate Contact Data to Winer Contact data...<br/> Error : '+e.getMessage()));
                                System.debug('>>> conDuplicate: ' + conDuplicate); 
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
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Winner Contact Master Index not match'));
            }        
        
        return null;
    }
    
   
    public string strOut{get;set;}
}