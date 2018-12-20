public class DeDupeController {
    
   public class clsMiFact {
        public Integer Index{get;set;}
        public String masterIndex{get;set;}
        public String miFactType{get;set;}
        public String miFactId{get;set;}
        public String miDomain{get;set;}
        public String domainUniqueId{get;set;}
        public String name{get;set;}
        public String tin{get;set;}
        public String auctionAccessId{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String country{get;set;}
        public String zip{get;set;}
        public Boolean isDuplicate{get;set;}
        public Date lastUpdateDate{get;set;}
        public String WinnerAccountMasterIndex{get;set;}
        public Account WinnerAccount{get;set;}         
     }
     
     public string MasterIndexSearch{get;set;}
     public Integer IndexOfList{get;set;}
     public  List<clsMiFact> ListclsMiFact{get;set;}
     
     public void DeDupeController()
     {
         List<clsMiFact> ListclsMiFact = new List<clsMiFact>();
     }
     
     public String getToken()
     {
        String OrgType = Utils.getOrganizationType('org.type');                        
        String token;                        
        /*
		String ProdNode = Utils.getProductionNode('prod.instance.node')  ;
        if( ProdNode !=null)
        {
            ProdNode = ProdNode.toUppercase();
        }                        
        String CurrentUrlNode ;
        String HostURL = URL.getSalesforceBaseUrl().getHost();
        System.Debug('>>> HostURL :'+HostURL );                        
        Integer parts = HostURL.countMatches('.');                        
        System.Debug('>>> countMatches:'+parts);
        
         if(parts== 2)
        {                        
            CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0)).toUpperCase();
        }else{
        
            //CurrentUrlNode = HostURL.substring(0,HostURL.indexOf('.',2)).toUpperCase();
            CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
        }
        */
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
        
        if(!Sandbox.isSandbox())
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
     public PageReference getMiFact() {
     
        try{
          
          if(ListclsMiFact!=null)
          {
              ListclsMiFact.clear();
          }
          system.debug('>>>> MasterIndexSearch:'+MasterIndexSearch);
          if(MasterIndexSearch==null ||MasterIndexSearch=='')
          {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Please Enter Master Index'));
            return null;
          } 
          
                        String token = getToken();                       
                        
                        // call  New web service
                                                
                            MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                            objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                            //objMiService.timeout_x = 5000;
                            system.debug('>>> objMiService:'+objMiService);
                            system.debug('>>> token:'+token);
                            system.debug('>>> MasterIndexSearch:'+MasterIndexSearch);
                            system.debug('>>> objMiService:'+objMiService);
                            
                            MIServicePhase2.MiResponse objMiResponse = objMiService.getMiFact(token,MasterIndexSearch,'ACCOUNT',null);
                            if(objMiResponse == null)
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Record(s) not found...Please Enter Valid Master Index'));
                                return null;
                            }
                            if(objMiResponse.miFacts==null || objMiResponse.miFacts.size()==0)
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Record(s) not found...Please Enter Valid Master Index'));
                                return null;
                            }
                            
                              Integer intIndex =0;
                            for(MIServicePhase2.MiFact objRecord :objMiResponse.miFacts)
                            {   
                                clsMiFact objclsMiFact = new clsMiFact();
                                objclsMiFact.Index = intIndex;
                                objclsMiFact.masterIndex = objRecord.masterIndex;
                                objclsMiFact.miFactType= objRecord.miFactType;
                                objclsMiFact.miFactId= objRecord.miFactId;
                                objclsMiFact.miDomain= objRecord.miDomain;
                                objclsMiFact.domainUniqueId= objRecord.domainUniqueId;
                                objclsMiFact.name= objRecord.name;
                                objclsMiFact.tin= objRecord.tin;
                                objclsMiFact.auctionAccessId= objRecord.auctionAccessId;
                                objclsMiFact.city= objRecord.city;
                                objclsMiFact.state= objRecord.state;
                                objclsMiFact.zip= objRecord.zip;
                                objclsMiFact.country= objRecord.country;
                                objclsMiFact.isDuplicate= objRecord.isDuplicate;
                                objclsMiFact.lastUpdateDate= objRecord.lastUpdateDate;
                                If(ListclsMiFact==null)
                                {
                                    ListclsMiFact = new List<clsMiFact>();
                                }
                                ListclsMiFact.Add(objclsMiFact);
                                intIndex+=1;
                            }
                            
                        
                        // End New Web Service                 
        }
        Catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Searching Record(s) <br/>Error Detail: '+ex.getMessage()));
            return null;
        }
          return null;
      }
      
      public PageReference getWinnerAccount()
      {  
        try{
            System.debug('>> ListclsMiFact'+ListclsMiFact);
            System.debug('>> IndexOfList'+IndexOfList);
            if(ListclsMiFact == null )
            {
                
                  return null;
            }        
              if(ListclsMiFact[IndexOfList]==null || ListclsMiFact[IndexOfList].WinnerAccountMasterIndex==null||ListclsMiFact[IndexOfList].WinnerAccountMasterIndex=='')
              {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Enter Master Index of Winner Account'));
                  return null;
              }      

             //WinnerMasterIndex = ApexPages.currentPage().getParameters().get('WinnerMasterIndex');         
             List<Account> searchResults = new List<Account>();
             Account accMaster ;
            // use some dynamic soql to find the related opportunities by name
            String qry = 'Select Id,Master_Index__c,Name from Account  Where Master_Index__c = \''+ListclsMiFact[IndexOfList].WinnerAccountMasterIndex+'\'';
            searchResults = Database.query(qry);
            system.debug('####### searchResults:'+searchResults);
            if(searchResults.size()>0)
            {
                ListclsMiFact[IndexOfList].WinnerAccount= searchResults[0];            
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Account not found with Master Index: '+ListclsMiFact[IndexOfList].WinnerAccountMasterIndex));
            }
        }
        Catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Searching Winner Account <br/>Error Detail: '+ex.getMessage()));
            return null;
        }
          return null;
      }
      
      public PageReference MigrateToWinerAccount()
      {
      
        try{
         
		 Set<String> ListFLSUpdate = new Set<String>();
		 Set<String> ListFLSCreate = new Set<String>();
		 Boolean blnFLSOverride = Utils.GetFLS();
		 
          if(ListclsMiFact[IndexOfList]== null || ListclsMiFact[IndexOfList].WinnerAccountMasterIndex == null || ListclsMiFact[IndexOfList].WinnerAccountMasterIndex=='')
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Enter Master Index of Winner Account'));
              return null;
          }
          if(ListclsMiFact[IndexOfList].WinnerAccount == null)
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Select Winner Account'));
              return null;
          }
          System.debug('>> IndexOfList'+IndexOfList);
          System.debug('>> ListclsMiFact'+ListclsMiFact);
          System.debug('>> ListclsMiFact[IndexOfList].WinnerAccount.Master_Index__c'+ListclsMiFact[IndexOfList].WinnerAccount.Master_Index__c);
          System.debug('>> ListclsMiFact[IndexOfList].WinnerAccountMasterIndex'+ListclsMiFact[IndexOfList].WinnerAccountMasterIndex);
           if(ListclsMiFact[IndexOfList].WinnerAccount.Master_Index__c != ListclsMiFact[IndexOfList].WinnerAccountMasterIndex)
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Winner Master Index Id Modified, Please Search Winner Account Again'));
              return null;
          }
          
          clsMiFact objclsMiFact = ListclsMiFact[IndexOfList];
          String token = getToken();   
          if(objclsMiFact.miFactType.equalsIgnoreCase('ACCOUNT'))
          {         
              if(objclsMiFact.miDomain.equalsIgnoreCase('OL'))
              {
                 //===========================================================
                 // Adesa_com_Detail__c Object    -    ATC_Organization_ID__c 
                 //===========================================================
                 
                  //Search Object in SF using Details
                  List<Adesa_com_Detail__c> List_Adesa_com_Detail = [SELECT Account__c,Account__r.Name,Account__r.Master_Index__c FROM Adesa_com_Detail__c where ATC_Organization_ID__c=:objclsMiFact.domainUniqueId LIMIT 1];
                  if(List_Adesa_com_Detail==null || List_Adesa_com_Detail.Size()==0)
                  {
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'ADESA.com Detail Record not found in Salesforce'));
                      return null;                     
                  }
                  
                    // Call web service to Update Master Index 
                                              
                        MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                        objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                        
                        MIServicePhase2.MiUpdateResponse  objMiUpdateResponse = objMiService.updateMasterIndex(token,MasterIndexSearch,objclsMiFact.WinnerAccount.Master_Index__c,objclsMiFact.miFactType,objclsMiFact.miDomain,objclsMiFact.domainUniqueId); //(String strToken,String masterIndex,String masterIndexChangeTo,String miFactType,String miDomain,String miDomainUniqueId)
                        
                        System.debug('>> objMiUpdateResponse'+objMiUpdateResponse);
                        
                        if(objMiUpdateResponse == null)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur on Server while Updating Master Index'));
                            return null;                                
                        } 
                        
                        if(!objMiUpdateResponse.success)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Migration not allow on Server.'));
                            return null;                                
                        }                            
                    
                    // End New Web Service 
                       
					    
                        //Insert Migration Log
                        DeDupe_Migration_Log__c obj_DeDupe_Migration_Log = new DeDupe_Migration_Log__c();
						
						//Story B-44003 : FLS UPDATE ACCESS CHECK
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_MasterIndex__c=objclsMiFact.masterIndex;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.getName());
						}
						
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_FactType__c=objclsMiFact.miFactType;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_FactId__c=objclsMiFact.miFactId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Domain__c=objclsMiFact.miDomain;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_DomainUniqueId__c=objclsMiFact.domainUniqueId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Name__c=objclsMiFact.name;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Tin__c=objclsMiFact.tin;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_AuctionAccessId__c=objclsMiFact.auctionAccessId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_City__c=objclsMiFact.city;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_State__c=objclsMiFact.state;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Zip__c=objclsMiFact.zip;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Country__c=objclsMiFact.country;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_IsDuplicate__c=objclsMiFact.isDuplicate;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_LastUpdateDate__c=objclsMiFact.lastUpdateDate;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Migrated_Object_Type__c='Adesa_com_Detail__c'; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Old_Acct_Master_Index__c=List_Adesa_com_Detail[0].Account__r.Master_Index__c; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Old_Acct_Name__c=List_Adesa_com_Detail[0].Account__r.Name; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Winner_Acct_Master_Index__c=objclsMiFact.WinnerAccount.Master_Index__c;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Winner_Acct_Name__c=objclsMiFact.WinnerAccount.Name;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Merge_By__c=UserInfo.getUserName();
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.getName());
						}
						
                        Insert obj_DeDupe_Migration_Log; 
                      
                       //Migate Object to Winner Account
						if (Schema.sObjectType.Adesa_com_Detail__c.fields.Account__c.isUpdateable() || blnFLSOverride)
						{							
						  List_Adesa_com_Detail[0].Account__c = objclsMiFact.WinnerAccount.Id;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.Adesa_com_Detail__c.getName()+'.'+Schema.sObjectType.Adesa_com_Detail__c.fields.Account__c.getName());
						}
						
                      Update List_Adesa_com_Detail;
                      
                      //Migate Its Related Object to Winner Account
                      if(!ReParentAccountOfAdesaDetailRelatedObject(List_Adesa_com_Detail[0].Id,objclsMiFact.WinnerAccount.Id))
                      {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error while reassigning account of ADESA.Com Detail related list'));
                         return null;
                      }                      
                       
                      //Update Winner Accout Field
                      List<Account> ListWinAccount = [SELECT Id,Name,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c FROM Account WHERE ID=:objclsMiFact.WinnerAccount.Id];
                      if(ListWinAccount.size()>0)
                      {
                        Account objWinnerAccount = ListWinAccount[0];
                        if(objWinnerAccount.OpenLane_Customer__c==null || objWinnerAccount.OpenLane_Customer__c.trim()=='')
                        {
                            objWinnerAccount.OpenLane_Customer__c = 'YES';
                        }
                        Update objWinnerAccount;
                      }
                    
                      // Update Log 
                      obj_DeDupe_Migration_Log.Is_Migrated_in_SF__c = true;
                      Update obj_DeDupe_Migration_Log; 
                      
                      //Show Sucess Save Msg
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'ADESA.com Detail Record Assign to Winner Account Successfully.'));
                  
                  
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('AFC')){
                  
                  //===========================================================
                  //    AFC Contact Object    -    AFC_Dealer_ID__c                  
                  //===========================================================
                  
                  //Search Object in SF using Details
                  List<AFC_Contracts__c> List_AFC_Contracts = [SELECT Account__c,Account__r.Name,Account__r.Master_Index__c FROM AFC_Contracts__c where AFC_Dealer_ID__c=:objclsMiFact.domainUniqueId LIMIT 1];
                  if(List_AFC_Contracts==null || List_AFC_Contracts.Size()==0)
                  {
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'AFC Contract Record not found in Salesforce'));
                      return null;                     
                  }
                  else
                  {
                      // Call web service to Update Master Index 
                                                 
                        MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                        objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                        
                        MIServicePhase2.MiUpdateResponse  objMiUpdateResponse  = objMiService.updateMasterIndex(token,MasterIndexSearch,objclsMiFact.WinnerAccount.Master_Index__c,objclsMiFact.miFactType,objclsMiFact.miDomain,objclsMiFact.domainUniqueId); //(String strToken,String masterIndex,String masterIndexChangeTo,String miFactType,String miDomain,String miDomainUniqueId)
                        System.debug('>> objMiUpdateResponse'+objMiUpdateResponse);
                        
                        if(objMiUpdateResponse == null || !objMiUpdateResponse.success)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur on Server while Updating Master Index'));
                            return null;                                
                        }                            
                      
                      // End New Web Service
                    
                    //Insert Migration Log
                        DeDupe_Migration_Log__c obj_DeDupe_Migration_Log = new DeDupe_Migration_Log__c();
						
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_MasterIndex__c=objclsMiFact.masterIndex;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_MasterIndex__c.getName());
						}
						
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_FactType__c=objclsMiFact.miFactType;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactType__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_FactId__c=objclsMiFact.miFactId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_FactId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Domain__c=objclsMiFact.miDomain;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Domain__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_DomainUniqueId__c=objclsMiFact.domainUniqueId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_DomainUniqueId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Name__c=objclsMiFact.name;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Tin__c=objclsMiFact.tin;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Tin__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_AuctionAccessId__c=objclsMiFact.auctionAccessId;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_AuctionAccessId__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_City__c=objclsMiFact.city;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_City__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_State__c=objclsMiFact.state;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_State__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Zip__c=objclsMiFact.zip;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Zip__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_Country__c=objclsMiFact.country;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_Country__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_IsDuplicate__c=objclsMiFact.isDuplicate;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_IsDuplicate__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.MF_LastUpdateDate__c=objclsMiFact.lastUpdateDate;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.MF_LastUpdateDate__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Migrated_Object_Type__c='AFC_Contracts__c'; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Old_Acct_Master_Index__c=List_AFC_Contracts[0].Account__r.Master_Index__c; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Old_Acct_Name__c=List_AFC_Contracts[0].Account__r.Name; //
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Winner_Acct_Master_Index__c=objclsMiFact.WinnerAccount.Master_Index__c;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Winner_Acct_Name__c=objclsMiFact.WinnerAccount.Name;
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.getName());
						}
						if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.isCreateable() || blnFLSOverride)
						{	
							obj_DeDupe_Migration_Log.Merge_By__c=UserInfo.getUserName();
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Merge_By__c.getName());
						}
						
                        Insert obj_DeDupe_Migration_Log; 
                        
                      //Migate Object to Winner Account
					  
					    if (Schema.sObjectType.AFC_Contracts__c.fields.Account__c.isUpdateable() || blnFLSOverride)
						{	
						  List_AFC_Contracts[0].Account__c = objclsMiFact.WinnerAccount.Id;							
						}
						else
						{						
							ListFLSUpdate.add(Schema.sObjectType.AFC_Contracts__c.getName()+'.'+Schema.sObjectType.AFC_Contracts__c.fields.Account__c.getName());
						}
						
                      Update List_AFC_Contracts;
                      
                      //Migate Its Related Object to Winner Account
                      if(!ReParentAccountOfAFCCotractRelatedObject(List_AFC_Contracts[0].Id,objclsMiFact.WinnerAccount.Id))
                      {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error while reassigning account of AFC Contract related list'));
                         return null;
                      }
                      
                      //Update Winner Accout Field
                      List<Account> ListWinAccount = [SELECT Id,Name,AFC_Dealer_ID__c,AutoCount_Customer__c,ADESA_Customer__c,OpenLane_Customer__c,IAA_Customer_Number__c,PAR_Client_ID__c,PWI_Customer__c FROM Account WHERE ID=:objclsMiFact.WinnerAccount.Id];
                      if(ListWinAccount.size()>0)
                      {
                        Account objWinnerAccount = ListWinAccount[0];
                        if(objWinnerAccount.AFC_Dealer_ID__c==null || objWinnerAccount.AFC_Dealer_ID__c.trim() =='')
                        {
							if (Schema.sObjectType.Account.fields.AFC_Dealer_ID__c.isUpdateable() || blnFLSOverride)
							{	
							   objWinnerAccount.AFC_Dealer_ID__c = objclsMiFact.domainUniqueId;							
							}
							else
							{						
								ListFLSUpdate.add(Schema.sObjectType.Account.getName()+'.'+Schema.sObjectType.Account.fields.AFC_Dealer_ID__c.getName());
							}
                            
                        }
                        Update objWinnerAccount;
                      }
                  
                      //Update Migration Log
                      
					  if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Is_Migrated_in_SF__c.isUpdateable() || blnFLSOverride)
					  {	
					  	obj_DeDupe_Migration_Log.Is_Migrated_in_SF__c = true;
					  }
					  else
					  {						
					  	ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Is_Migrated_in_SF__c.getName());
					  }
						
                      Update obj_DeDupe_Migration_Log; 
                      
					  if(ListFLSUpdate.size()>0)
					  {
						Utils.SendEmailforFLS('FLS_UPDATE','DeDupeController', ListFLSUpdate);
					  }

                      //Show Sucess Save Msg
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'AFC Contracts Record Assign to Winner Account Successfully.'));
                  }              
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('IAA')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:IAA'));
                return null;              
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('ADESA')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:ADESA'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('AFCCONVERT')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:AFCCONVERT'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('AUCTIONACCESS')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:AUCTIONACCESS'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('AUTOCOUNT')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:AUTOCOUNT'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('CMDM')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:CMDM'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('DMV')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:DMV'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('INFOUSA')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:INFOUSA'));
                return null; 
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('KARAFC')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:KARAFC'));
                return null; 
              }              
                      
          }else if(objclsMiFact.miFactType.equalsIgnoreCase('CONTACT')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate FactType:CONTACT'));
                return null;
          }
          }
          Catch(Exception ex)
          {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Updating Record <br/>Error Detail: '+ex.getMessage()));
                return null;
          }
           
          return null;
      }
      
    public boolean ReParentAccountOfAdesaDetailRelatedObject(String AdesaDetailId,String WinnerAccountId) {

        List<Payment_Method__c> List_Payment_Method = [SELECT Account__c FROM Payment_Method__c WHERE Adesa_com__c=:AdesaDetailId];    
        List<ADESA_Compliance__c> List_ADESA_Compliance = [SELECT Account__c FROM ADESA_Compliance__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Asset__c> List_Asset = [SELECT Buyer_Account__c,Consignee_Account__c,Grounding_Dealer__c,Partner_Account__c,Seller_Account__c,Buyer_ADESA_com_Detail__c ,Consignee_ADESA_com_Detail__c, Grounding_Dealer_ADESA_com_Detail__c, Partner_ADESA_com_Detail__c,Seller_ADESA_com_Detail__c FROM Asset__c WHERE Buyer_ADESA_com_Detail__c=:AdesaDetailId OR Consignee_ADESA_com_Detail__c=:AdesaDetailId OR Grounding_Dealer_ADESA_com_Detail__c=:AdesaDetailId OR Partner_ADESA_com_Detail__c=:AdesaDetailId OR Seller_ADESA_com_Detail__c=:AdesaDetailId];    
        List<Auction__c> List_Auction = [SELECT Highest_Bidder_Account__c FROM Auction__c WHERE Highest_Bidder_Adesa_ORG__c=:AdesaDetailId];     
        List<Collection__c> List_Collection = [SELECT Account__c FROM Collection__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Dealer_Registration_Request__c> List_Dealer_Registration_Request = [SELECT Account__c FROM Dealer_Registration_Request__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Incentive__c> List_Incentive = [SELECT Account__c FROM Incentive__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Inside_Sales_Auction_Performance__c> List_Inside_Sales_Auction_Performance = [SELECT Auction_Name__c FROM Inside_Sales_Auction_Performance__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Inspection__c> List_Inspection = [SELECT Inspector__c FROM Inspection__c WHERE Inspector_ADESA_com_Detail__c=:AdesaDetailId];    
        List<Listing_Request__c> List_Listing_Request = [SELECT Account__c FROM Listing_Request__c WHERE ADESA_com_Detail__c=:AdesaDetailId];    
        List<Proxy_Bid__c> List_Proxy_Bid = [SELECT Account__c FROM Proxy_Bid__c WHERE ADESA_com_Detail__c=:AdesaDetailId];   
        List<Purchase__c> List_Purchase = [SELECT Consignee__c,Account__c,ATC_Buyer__c,ATC_Seller__c,ATC_Transporter__c,Adesa_com__c,ATC_Buyer_Adesa_com_Detail__c,Consignee_Adesa_com_Detail__c ,ATC_Seller_Adesa_com_Detail__c,Transporter__c  FROM Purchase__c WHERE Consignee_Adesa_com_Detail__c=:AdesaDetailId OR Adesa_com__c=:AdesaDetailId OR ATC_Buyer_Adesa_com_Detail__c=:AdesaDetailId OR ATC_Seller_Adesa_com_Detail__c=:AdesaDetailId  OR Transporter__c=:AdesaDetailId];     
        
        List<Case> List_Case = [SELECT AccountId FROM Case WHERE ADESA_com_Detail__c=:AdesaDetailId];
        List<Opportunity> List_Opportunity = [SELECT AccountId FROM Opportunity WHERE ADESA_com_Detail__c=:AdesaDetailId];  
        List<Contact> List_Contact = [SELECT AccountId FROM Contact WHERE OpenLane_Details__c=:AdesaDetailId];
        
        //========
        
        for(ADESA_Compliance__c objADESA_Compliance: List_ADESA_Compliance)
        {
            objADESA_Compliance.Account__c =WinnerAccountId;              
        }
       
        for(Collection__c objCollection: List_Collection)
        {
            objCollection.Account__c =WinnerAccountId;              
        }
        for(Dealer_Registration_Request__c objDealer_Registration_Request: List_Dealer_Registration_Request)
        {
            objDealer_Registration_Request.Account__c =WinnerAccountId;              
        }
       
        for(Incentive__c objIncentive: List_Incentive)
        {
            objIncentive.Account__c =WinnerAccountId;              
        }
        
        for(Inside_Sales_Auction_Performance__c objInside_Sales_Auction_Performance: List_Inside_Sales_Auction_Performance)
        {
            objInside_Sales_Auction_Performance.Auction_Name__c=WinnerAccountId;              
        }
        
        for(Inspection__c objInspection: List_Inspection)
        {
            objInspection.Inspector__c=WinnerAccountId;              
        }
        
        for(Listing_Request__c objListing_Request: List_Listing_Request)
        {
            objListing_Request.Account__c =WinnerAccountId;              
        }
        
        for(Payment_Method__c objPayment_Method: List_Payment_Method)
        {
            objPayment_Method.Account__c =WinnerAccountId;              
        }
        
        for(Proxy_Bid__c objProxy_Bid: List_Proxy_Bid)
        {
            objProxy_Bid.Account__c =WinnerAccountId;              
        }
        
        for(Auction__c objAuction: List_Auction)
        {
            if(objAuction.Highest_Bidder_Account__c == AdesaDetailId) {objAuction.Highest_Bidder_Account__c =WinnerAccountId;  }        
        }
        
        for(Purchase__c objPurchase: List_Purchase)
        {
            if(objPurchase.Adesa_com__c == AdesaDetailId) {objPurchase.Account__c =WinnerAccountId; }
            if(objPurchase.ATC_Buyer_Adesa_com_Detail__c == AdesaDetailId) {objPurchase.ATC_Buyer__c =WinnerAccountId; }
            if(objPurchase.Consignee_Adesa_com_Detail__c == AdesaDetailId) {objPurchase.Consignee__c =WinnerAccountId; }
            if(objPurchase.ATC_Seller_Adesa_com_Detail__c == AdesaDetailId) {objPurchase.ATC_Seller__c =WinnerAccountId; }
            if(objPurchase.Transporter__c == AdesaDetailId) {objPurchase.ATC_Transporter__c =WinnerAccountId; }
        }
        
        for(Asset__c objAsset: List_Asset)
        {
            if(objAsset.Buyer_ADESA_com_Detail__c == AdesaDetailId) {objAsset.Buyer_Account__c =WinnerAccountId; }
            if(objAsset.Consignee_ADESA_com_Detail__c == AdesaDetailId) {objAsset.Consignee_Account__c =WinnerAccountId; }
            if(objAsset.Grounding_Dealer_ADESA_com_Detail__c == AdesaDetailId) {objAsset.Grounding_Dealer__c =WinnerAccountId; }
            if(objAsset.Partner_ADESA_com_Detail__c == AdesaDetailId) {objAsset.Partner_Account__c =WinnerAccountId; }
            if(objAsset.Seller_ADESA_com_Detail__c == AdesaDetailId) {objAsset.Seller_Account__c =WinnerAccountId; }
            
        }
        
        for(Case objCase: List_Case)
        {
            objCase.AccountId =WinnerAccountId;              
        }
        for(Opportunity objOpportunity: List_Opportunity)
        {
            objOpportunity.AccountId =WinnerAccountId;              
        }
        for(Contact objContact: List_Contact)
        {
            objContact.AccountId =WinnerAccountId;              
        }
        //=========    
      
        Update List_ADESA_Compliance;       
        Update List_Asset;       
        Update List_Auction;     
        Update List_Collection;  
        Update List_Dealer_Registration_Request;
        Update List_Incentive;   
        Update List_Inside_Sales_Auction_Performance;
        Update List_Inspection;  
        Update List_Listing_Request;
        Update List_Payment_Method;
        Update List_Proxy_Bid;   
        Update List_Purchase;   
        Update List_Case;
        Update List_Opportunity;
        Update List_Contact;
        
        return true;

    }

    public boolean ReParentAccountOfAFCCotractRelatedObject(String AFCContractId,String WinnerAccountId) {
        
        List<Contract_Versions__c> List_Contract_Versions = [SELECT Account__c FROM Contract_Versions__c WHERE AFC_Contracts__c=:AFCContractId];
        for(Contract_Versions__c objContract_Versions: List_Contract_Versions)
        {
            objContract_Versions.Account__c =WinnerAccountId;              
        }
        
        List<AFC_Contract_Shell__c> List_AFC_Contract_Shell = [SELECT Account__c FROM AFC_Contract_Shell__c WHERE AFC_Area_Sales_Manager__c=:AFCContractId];
        for(AFC_Contract_Shell__c objAFC_Contract_Shell: List_AFC_Contract_Shell)
        {
            objAFC_Contract_Shell.Account__c =WinnerAccountId;              
        }
        
        List<Application_Account_Role__c> List_Application_Account_Role = [SELECT Account__c FROM Application_Account_Role__c WHERE AFC_Contracts__c=:AFCContractId];
        for(Application_Account_Role__c objApplication_Account_Role: List_Application_Account_Role)
        {
            objApplication_Account_Role.Account__c =WinnerAccountId;              
        }
        
        List<Application_Contact_Role__c> List_Application_Contact_Role = [SELECT Account__c FROM Application_Contact_Role__c WHERE AFC_Contracts__c=:AFCContractId];
        for(Application_Contact_Role__c objApplication_Contact_Role: List_Application_Contact_Role)
        {
            objApplication_Contact_Role.Account__c =WinnerAccountId;              
        }
        
        List<Application__c> List_Application = [SELECT Applications_Accounts__c FROM Application__c WHERE AFC_Contract_Number__c=:AFCContractId];
        for(Application__c objApplication: List_Application)
        {
            objApplication.Applications_Accounts__c =WinnerAccountId;              
        }
        
        List<Purchase__c> List_Purchase = [SELECT Account__c FROM Purchase__c WHERE AFC_Contract_Number__c=:AFCContractId];
        for(Purchase__c objPurchase: List_Purchase)
        {
            objPurchase.Account__c =WinnerAccountId;              
        }
        
        List<Case> List_Case = [SELECT AccountId FROM Case WHERE AFC_Contracts__c=:AFCContractId];
        for(Case objCase: List_Case)
        {
            objCase.AccountId =WinnerAccountId;              
        }
        
        List<Opportunity> List_Opportunity = [SELECT AccountId FROM Opportunity WHERE AFC_Contracts__c=:AFCContractId];
        for(Opportunity objOpportunity: List_Opportunity)
        {
            objOpportunity.AccountId =WinnerAccountId;              
        }
        
        Update List_Contract_Versions;
        Update List_AFC_Contract_Shell;
        Update List_Application_Account_Role;
        Update List_Application_Contact_Role;
        Update List_Application;
        Update List_Purchase;
        Update List_Case;
        Update List_Opportunity;
        
        
        return true;
    }

}