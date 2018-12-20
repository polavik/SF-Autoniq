public class DeDupeContactController { 
    
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
        public String WinnerContactMasterIndex{get;set;}
        public Contact WinnerContact{get;set;}         
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
        }
		else
		{
        
            //CurrentUrlNode = HostURL.substring(0,HostURL.indexOf('.',2)).toUpperCase();
            CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
        }
        System.Debug('>>> CurrentUrlNode :'+CurrentUrlNode ); 
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
        
        System.Debug('>>> propTokenList :'+propTokenList );
        
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
        
        System.Debug('>>> token :'+token ); 
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
                            
                            MIServicePhase2.MiResponse objMiResponse = objMiService.getMiFact(token,MasterIndexSearch,'CONTACT',null);
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
      
      public PageReference getWinnerContact()
      {  
        try{
            System.debug('>> ListclsMiFact'+ListclsMiFact);
            System.debug('>> IndexOfList'+IndexOfList);
            if(ListclsMiFact == null )
            {
                
                  return null;
            }        
              if(ListclsMiFact[IndexOfList]==null || ListclsMiFact[IndexOfList].WinnerContactMasterIndex==null||ListclsMiFact[IndexOfList].WinnerContactMasterIndex=='')
              {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Enter Master Index of Winner Contact'));
                  return null;
              }      

              if(ListclsMiFact[IndexOfList].WinnerContactMasterIndex.equalsIgnoreCase(MasterIndexSearch))
              {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Enter Different Master Index of Winner Contact'));
                  return null;
              } 
              
             //WinnerMasterIndex = ApexPages.currentPage().getParameters().get('WinnerMasterIndex');         
             List<Contact> searchResults = new List<Contact>();
             Contact accMaster ;
            // use some dynamic soql to find the related opportunities by name
            String qry = 'Select Id,Master_Index__c,Name from Contact  Where Master_Index__c = \''+ListclsMiFact[IndexOfList].WinnerContactMasterIndex+'\'';
            searchResults = Database.query(qry);
            system.debug('####### searchResults:'+searchResults);
            if(searchResults.size()>0)
            {
                ListclsMiFact[IndexOfList].WinnerContact= searchResults[0];            
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Contact not found with Master Index: '+ListclsMiFact[IndexOfList].WinnerContactMasterIndex));
            }
        }
        Catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Searching Winner Contact <br/>Error Detail: '+ex.getMessage()));
            return null;
        }
          return null;
      }
      
      public PageReference MigrateToWinerContact()
      {      
      System.debug('>> MigrateToWinerContact() called ');
        try{
         
          if(ListclsMiFact[IndexOfList]== null || ListclsMiFact[IndexOfList].WinnerContactMasterIndex == null || ListclsMiFact[IndexOfList].WinnerContactMasterIndex=='')
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Enter Master Index of Winner Contact'));
              return null;
          }
          if(ListclsMiFact[IndexOfList].WinnerContact == null)
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Please Select Winner Contact'));
              return null;
          }
          System.debug('>> IndexOfList'+IndexOfList);
          System.debug('>> ListclsMiFact'+ListclsMiFact);
          System.debug('>> ListclsMiFact[IndexOfList].WinnerContact.Master_Index__c'+ListclsMiFact[IndexOfList].WinnerContact.Master_Index__c);
          System.debug('>> ListclsMiFact[IndexOfList].WinnerContactMasterIndex'+ListclsMiFact[IndexOfList].WinnerContactMasterIndex);
          if(ListclsMiFact[IndexOfList].WinnerContact.Master_Index__c != ListclsMiFact[IndexOfList].WinnerContactMasterIndex)
          {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Winner Master Index Id Modified, Please Search Winner Contact Again'));
              return null;
          }
          
          clsMiFact objclsMiFact = ListclsMiFact[IndexOfList];
          String token = getToken();   
          System.Debug('>>> Got token !' ); 
          
          System.debug('>> objclsMiFact.miFactType'+objclsMiFact.miFactType);
          System.debug('>> objclsMiFact.miDomain'+objclsMiFact.miDomain);
          System.debug('>> MasterIndexSearch'+MasterIndexSearch);
          
          if(objclsMiFact.miFactType.equalsIgnoreCase('Contact'))
          {     
            /*
              if(objclsMiFact.miDomain.equalsIgnoreCase('OL'))
              {
             */
              
                 //Search Object in SF using Details
                  List<Contact> List_Contact = [SELECT Id,Name,Master_Index__c FROM Contact where Master_Index__c=:MasterIndexSearch LIMIT 1];
                  if(List_Contact==null || List_Contact.Size()==0)
                  {
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Contact Record not found in Salesforce'));
                      return null;                     
                  }
                  
                    // Call web service to Update Master Index 
                                              
                        MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                        objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                        
                        System.debug('>> Before Call ');
                        MIServicePhase2.MiUpdateResponse  objMiUpdateResponse = objMiService.updateMasterIndex(token,MasterIndexSearch,objclsMiFact.WinnerContact.Master_Index__c,objclsMiFact.miFactType,objclsMiFact.miDomain,objclsMiFact.domainUniqueId); //(String strToken,String masterIndex,String masterIndexChangeTo,String miFactType,String miDomain,String miDomainUniqueId)
                        
                        System.debug('>> objMiUpdateResponse:'+objMiUpdateResponse);
                        
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
						Set<String> ListFLSUpdate = new Set<String>();
						Set<String> ListFLSCreate = new Set<String>();
						Boolean blnFLSOverride = Utils.GetFLS();
                        
                        
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
							obj_DeDupe_Migration_Log.Migrated_Object_Type__c='Contact'; //							 
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Migrated_Object_Type__c.getName());
						 }
						 if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						 {						 
							obj_DeDupe_Migration_Log.Old_Acct_Master_Index__c=List_Contact[0].Master_Index__c; //							 
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Master_Index__c.getName());
						 }
						 if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.isCreateable() || blnFLSOverride)
						 {						 
							obj_DeDupe_Migration_Log.Old_Acct_Name__c=List_Contact[0].Name; //							
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Old_Acct_Name__c.getName());
						 }
						 if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.isCreateable() || blnFLSOverride)
						 {						 
							obj_DeDupe_Migration_Log.Winner_Acct_Master_Index__c=objclsMiFact.WinnerContact.Master_Index__c;
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
							ListFLSCreate.add(Schema.sObjectType.DeDupe_Migration_Log__c.getName()+'.'+Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Master_Index__c.getName());
						 }
						 if (Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isUpdateable() && Schema.sObjectType.DeDupe_Migration_Log__c.fields.Winner_Acct_Name__c.isCreateable() || blnFLSOverride)
						 {						 
							obj_DeDupe_Migration_Log.Winner_Acct_Name__c=objclsMiFact.WinnerContact.Name;
							 
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
                      
                      
                        //Merge 
                                Contact MasterContact = [SELECT ID FROM CONTACT WHERE ID=:objclsMiFact.WinnerContact.Id];
                                Contact DuplicateContact = [SELECT ID FROM CONTACT WHERE ID=:List_Contact[0].Id];
                                
                                merge MasterContact DuplicateContact;
                                undelete DuplicateContact;
                                
                                // Change Duplicate Contact Record Type 
                                RecordType objRecordType = [SELECT Id FROM RecordType where Name='Invalid' and IsActive=true and SobjectType='Contact' LIMIT 1];
								 if (Schema.sObjectType.Contact.fields.Duplicate_with_Master_Index__c.isUpdateable() || blnFLSOverride)
								 {						 
									DuplicateContact.Duplicate_with_Master_Index__c = objclsMiFact.WinnerContact.Master_Index__c ;									 
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Duplicate_with_Master_Index__c.getName());
								 }
								 if (Schema.sObjectType.Contact.fields.Duplicate__c.isUpdateable() || blnFLSOverride)
								 {						 
									DuplicateContact.Duplicate__c = TRUE;								 
								 }
								 else
								 {						
									ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Duplicate__c.getName());
								 }
                                
                                if(objRecordType != null )
                                {                                   
									 if (Schema.sObjectType.Contact.fields.RecordTypeid.isUpdateable() || blnFLSOverride)
									 {						 
										 DuplicateContact.RecordTypeid= objRecordType.Id;						 
									 }
									 else
									 {						
										ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.RecordTypeid.getName());
									 }
                                }                                
                                // update duplicate Contact details
                                update DuplicateContact;  
                                
                    
                      // Update Log 
                     
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
							Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DeDupeContactController', ListFLSUpdate);
						}

                      //Show Sucess Save Msg
                      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'Record Saved.'));
                 
            /*
              }else if(objclsMiFact.miDomain.equalsIgnoreCase('AFC')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate Domain:AFC'));
                return null;              
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
              }  */            
                      
          }else if(objclsMiFact.miFactType.equalsIgnoreCase('ACCOUNT')){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Can\'t Migrate FactType:ACCOUNT'));
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
    
}