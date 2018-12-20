global class BatchCaseFieldsRelationUpdate implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    public String strError ='' ;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global Integer Counter;
    global boolean blnUpdateOnlyAdesaComDetailPALSProvider;
    
     // Constructor  
    public BatchCaseFieldsRelationUpdate(String strSOQLWhereClause, boolean blnSendBatchCompleteNotification, string strToEmail, boolean UpdateOnlyAdesaComDetailPALSProvider)   
    {  
      query = 'SELECT ID,Openlane_Case_Owner_TYPE__c FROM case WHERE Is_Migrated_Openlane_Case__c = true '+strSOQLWhereClause;  
      Summary=''; 
      ToEmail = strToEmail;
      Counter=0;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
      blnUpdateOnlyAdesaComDetailPALSProvider = UpdateOnlyAdesaComDetailPALSProvider;
      System.debug('>>> query'+query);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
           //1. Get List of 200 Records
           List<Case> ListKARCase = (List<Case>) scope;
           //System.debug('>>>> ListKARCase:'+ListKARCase);
           if(ListKARCase.size() == 0)
           {
                return;
           }
           
           //2. Get Ids of Case who migrated from openlane
            List<String> List_KAR_Case_Id = new List<String>();
            for(Case c: ListKARCase){
                List_KAR_Case_Id.Add(c.Id);         
            }
            System.debug('>>>> List_KAR_Case_Id:'+List_KAR_Case_Id.size());
            
            //3. Get List of Openlane Case belongs to 200 records
            List<Temp_Openlane_KAR_Case_Mapper__c> ListOpenlaneCasesMapper  = new List<Temp_Openlane_KAR_Case_Mapper__c>();     
            ListOpenlaneCasesMapper = [SELECT PALS_ATC_ORG_ID__c,Owner_USERNAME__c,Related_to_Enhancement_Case_ID__c,Purchase_VEHICLE_ID_SOURCE_ID__c,Secondary_Owner_USERNAME__c,Requested_By_Internal_USERNAME__c,Account_ATC_ORG_ID__c,Transporter_ATC_ORG_ID__c,Seller_ATC_ORG_ID__c,Seller_Contact_LOGIN_ID__c,Contact_LOGIN_ID__c,RecordType_Name__c,Migrated_Openlane_Case_KAR_id__c,ID FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_KAR_id__c IN :List_KAR_Case_Id];
            System.debug('>>>> ListOpenlaneCasesMapper:'+ListOpenlaneCasesMapper.size());
            
            //4. Generate List which required to find in other object 
            // Define List Here
            //List<String> List_RecordTypes = new List<String>();
            Set<String> List_RecordTypes = new Set<String>();
            
            //List<String> List_ContactLoginID = new List<String>();
            Set<String> List_ContactLoginID = new Set<String>();
            
            //List<String> List_SellerContactLoginID = new List<String>();
            Set<String> List_SellerContactLoginID = new Set<String>();
            
            //List<String> List_SellerATCOrgId = new List<String>();
            Set<String> List_PALSATCOrgId = new Set<String>();
            Set<String> List_SellerATCOrgId = new Set<String>();
            
            //List<String> List_TransATCOrgId = new List<String>();
            Set<String> List_TransATCOrgId = new Set<String>();
            
            //List<String> List_AccATCOrgId = new List<String>();
            Set<String> List_AccATCOrgId = new Set<String>();
            
            //List<String> List_PurchaseSourceId = new List<String>();
            Set<String> List_PurchaseSourceId = new Set<String>();
            
            //List<String> List_RelatedEnhanceCaseId = new List<String>();
            Set<String> List_RelatedEnhanceCaseId = new Set<String>();
            
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
                // Make List here 
                if(oc.PALS_ATC_ORG_ID__c !=null && oc.PALS_ATC_ORG_ID__c!=''){    List_PALSATCOrgId.Add(oc.PALS_ATC_ORG_ID__c);   }
                if(blnUpdateOnlyAdesaComDetailPALSProvider == false) //new 
                {
                    if(oc.Seller_ATC_ORG_ID__c !=null && oc.Seller_ATC_ORG_ID__c!=''){    List_SellerATCOrgId.Add(oc.Seller_ATC_ORG_ID__c);   }
                    if(oc.RecordType_Name__c!=null && oc.RecordType_Name__c!=''){  List_RecordTypes.Add(oc.RecordType_Name__c);    }
                    if(oc.Contact_LOGIN_ID__c !=null && oc.Contact_LOGIN_ID__c!=''){ List_ContactLoginID.Add(oc.Contact_LOGIN_ID__c);    }
                    if(oc.Seller_Contact_LOGIN_ID__c !=null && oc.Seller_Contact_LOGIN_ID__c!=''){  List_SellerContactLoginID.Add(oc.Seller_Contact_LOGIN_ID__c);   }
                    if(oc.Transporter_ATC_ORG_ID__c !=null && oc.Transporter_ATC_ORG_ID__c!=''){   List_TransATCOrgId.Add(oc.Transporter_ATC_ORG_ID__c);   }
                    if(oc.Account_ATC_ORG_ID__c !=null && oc.Account_ATC_ORG_ID__c!=''){   List_AccATCOrgId.Add(oc.Account_ATC_ORG_ID__c); }
                    if(oc.Purchase_VEHICLE_ID_SOURCE_ID__c !=null && oc.Purchase_VEHICLE_ID_SOURCE_ID__c!=''){    List_PurchaseSourceId.Add(oc.Purchase_VEHICLE_ID_SOURCE_ID__c); }
                    if(oc.Related_to_Enhancement_Case_ID__c !=null && oc.Related_to_Enhancement_Case_ID__c!=''){   List_RelatedEnhanceCaseId.Add(oc.Related_to_Enhancement_Case_ID__c);    }
                }
            }
           
           //System.debug('>>>>op List_RecordTypes.size():'+List_RecordTypes.size());
           //System.debug('>>>>op List_RecordTypes:'+List_RecordTypes);
                        
            //5. Find Id from other object that need to map with 200 records 
            List<RecordType> ListKARRecordType = new List<RecordType>();
            List<Contact> ListKARContact = new List<Contact>();
            List<Contact> ListKARSellerContact = new List<Contact>();
            List<Adesa_com_Detail__c> ListKARAdesaDetail_PALS = new List<Adesa_com_Detail__c>();
            List<Adesa_com_Detail__c> ListKARAdesaDetail_Seller = new List<Adesa_com_Detail__c>();
            List<Adesa_com_Detail__c> ListKARAdesaDetail_Trans = new List<Adesa_com_Detail__c>();
            List<Adesa_com_Detail__c> ListKARAdesaDetail_Acct = new List<Adesa_com_Detail__c>();
            List<User> ListKARUser = new List<User>();
            List<Group> ListKARGroup = new List<Group>();
            List<Purchase__c> ListKARPurchase = new List<Purchase__c>();
            List<Temp_Openlane_KAR_Case_Mapper__c> ListKAREnhancedCase = new List<Temp_Openlane_KAR_Case_Mapper__c>();
            
            if(List_PALSATCOrgId.size()>0)
            {
                ListKARAdesaDetail_PALS = [SELECT ATC_Organization_ID__c,Account__c, Id FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN :List_PALSATCOrgId ];
            }            
            
            if(blnUpdateOnlyAdesaComDetailPALSProvider == false) //new 
            {
                if(List_SellerATCOrgId.size()>0)
                {
                    ListKARAdesaDetail_Seller = [SELECT ATC_Organization_ID__c,Account__c, Id FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN :List_SellerATCOrgId ];
                }
                if(List_RecordTypes.size()>0)
                {
                    ListKARRecordType = [SELECT Name, Id, DeveloperName FROM RecordType WHERE SobjectType='Case' AND Name IN :List_RecordTypes ];           
                }
                
                //System.debug('>>>>KAR ListKARRecordType.size():'+ListKARRecordType.size());
                //System.debug('>>>>KAR ListKARRecordType:'+ListKARRecordType);
               
                if(List_ContactLoginID.size()>0)
                {
                    ListKARContact = [SELECT Login_ID__c, Id FROM Contact WHERE Login_ID__c IN :List_ContactLoginID ];
                }           
                 if(List_SellerContactLoginID.size()>0)
                {
                    ListKARSellerContact = [SELECT Login_ID__c, Id FROM Contact WHERE Login_ID__c IN :List_SellerContactLoginID ];
                }
                if(List_TransATCOrgId.size()>0)
                {
                    ListKARAdesaDetail_Trans = [SELECT ATC_Organization_ID__c,Account__c, Id FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN :List_TransATCOrgId ];
                }
                if(List_AccATCOrgId.size()>0)
                {
                    ListKARAdesaDetail_Acct = [SELECT ATC_Organization_ID__c,Account__c, Id FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c IN :List_AccATCOrgId ];
                }
                
                ListKARUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false];//and UserName IN :List_SecOwnerUserName ];            
                ListKARGroup = [SELECT Name,Id FROM Group WHERE  Name NOT IN (' ','             ','')];
                
                
                
                if(List_PurchaseSourceId.size()>0)
                {
                    ListKARPurchase = [SELECT Source_Id__c, Id FROM Purchase__c WHERE Source_Id__c IN :List_PurchaseSourceId ];
                }
                if(List_RelatedEnhanceCaseId.size()>0)
                {
                    ListKAREnhancedCase = [SELECT Migrated_Openlane_Case_Original_id__c, Migrated_Openlane_Case_KAR_id__c FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_Original_id__c IN :List_RelatedEnhanceCaseId ];
                }
            }
            
            
            //6. Generate Map that give Id of their by relation name 
            
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_PALS = new Map<String, String>();
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailId_PALS = new Map<String, String>(); //new 
            for(Adesa_com_Detail__c obj: ListKARAdesaDetail_PALS){
                mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_PALS.put(obj.ATC_Organization_ID__c,obj.Account__c);
                mapKARAdesaDetailATCOrgIdToAdesaDetailId_PALS.put(obj.ATC_Organization_ID__c,obj.Id); //new 
            }
            
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_seller = new Map<String, String>();
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailId_seller = new Map<String, String>(); //new 
            
            Map<String,String>  mapKARRecordTypeNameToId = new Map<String, String>();
            Map<String,String>  mapKARContactLoginIdToContactId = new Map<String, String>();
            Map<String,String>  mapKARSellerContactLoginIdToContactId = new Map<String, String>();
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Trans = new Map<String, String>();
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Acct = new Map<String, String>();
            Map<String,String>  mapKARAdesaDetailATCOrgIdToAdesaDetailId = new Map<String, String>();
            Map<String,String>  mapKARGroupNameToId = new Map<String, String>();
            Map<String,String>  mapKARPurchaseSourceIdToId = new Map<String, String>();
            Map<String,String>  mapOpenlaneCaseEnhanceIdToKARCaseId = new Map<String, String>();
            Map<String,String>  mapKARUserNameToId = new Map<String, String>();
                
            if(blnUpdateOnlyAdesaComDetailPALSProvider == false) //new 
            {
                for(Adesa_com_Detail__c obj: ListKARAdesaDetail_Seller){
                    mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_seller.put(obj.ATC_Organization_ID__c,obj.Account__c);
                    mapKARAdesaDetailATCOrgIdToAdesaDetailId_seller.put(obj.ATC_Organization_ID__c,obj.Id); //new 
                }
                    
                for(RecordType obj: ListKARRecordType){
                    mapKARRecordTypeNameToId.put(obj.Name,obj.Id);
                }
                System.debug('>>>> mapKARRecordTypeNameToId:'+mapKARRecordTypeNameToId);
                
                for(Contact obj: ListKARContact){
                    mapKARContactLoginIdToContactId.put(obj.Login_ID__c,obj.Id);
                }
                
                for(Contact obj: ListKARSellerContact){
                    mapKARSellerContactLoginIdToContactId.put(obj.Login_ID__c,obj.Id);
                }
                
                for(Adesa_com_Detail__c obj: ListKARAdesaDetail_Trans){
                    mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Trans.put(obj.ATC_Organization_ID__c,obj.Account__c);
                }
                
                for(Adesa_com_Detail__c obj: ListKARAdesaDetail_Acct){
                    mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Acct.put(obj.ATC_Organization_ID__c,obj.Account__c);
                }
                
                for(Adesa_com_Detail__c obj: ListKARAdesaDetail_Acct){
                    mapKARAdesaDetailATCOrgIdToAdesaDetailId.put(obj.ATC_Organization_ID__c,obj.Id);
                }
                
                //for(User obj: ListKARUser){
                //    mapKARUserNameToId.put(obj.Username,obj.Id);
                //}   
                // New Changes 
                List<Property__c>  ListProperty = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='username.patch' LIMIT 1];   
                
                //new
                List<Property__c>  ListProperty2 = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c ='sandbox.suffix' LIMIT 1];   
           
                String UsernamePatch = '';
                System.debug('>>>>ListProperty:'+ListProperty);
                System.debug('>>>>ListProperty2:'+ListProperty2);
                
                if(ListProperty.size()>0)
                {               
                    UsernamePatch = ListProperty[0].Property_Value__c;
                    String strDefaultOwnerUserName = Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username');
                    for(User obj: ListKARUser){
                        String strUsername = obj.Username;
                        if(!strUsername.EqualsIgnorecase(strDefaultOwnerUserName))
                         {
                            //strUsername = strUsername.Replace('@',UsernamePatch);
                            strUsername = strUsername.Replace(UsernamePatch,'@');
                            //new 
                            if(ListProperty2.size()>0 && ListProperty2[0].Property_Value__c!='')
                            { 
                                strUsername = strUsername.Replace(ListProperty2[0].Property_Value__c,'');
                            }
                        }
                        mapKARUserNameToId.put(strUsername,obj.Id);
                        
                    }                    
                }else{
                    
                    for(User obj: ListKARUser){
                        mapKARUserNameToId.put(obj.Username,obj.Id);
                    }                   
                }   
                //
               
                
                for(Group obj: ListKARGroup){
                    mapKARGroupNameToId.put(obj.Name,obj.Id);
                }
                
                for(Purchase__c obj: ListKARPurchase){
                    mapKARPurchaseSourceIdToId.put(obj.Source_Id__c,obj.Id);
                }
                
                for(Temp_Openlane_KAR_Case_Mapper__c obj: ListKAREnhancedCase){
                    mapOpenlaneCaseEnhanceIdToKARCaseId.put(obj.Migrated_Openlane_Case_Original_id__c,obj.Migrated_Openlane_Case_KAR_id__c);
                }
            
            }
            
            
            //7. Generate map using Openlane_Case 
            Map<String,String>  map_OpenlaneCaseRecordType_To_KARRecordTypeId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneContactLoginID_To_KARContactId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneSellerContactLoginID_To_KARContactId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Seller = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId_Seller = new Map<String, String>(); //new 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Trans = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Acct = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneSecOwnerUsername_To_KARUserId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneReqByInternalUsername_To_KARUserId = new Map<String, String>(); 
            
            Map<String,String>  map_OpenlaneOwnerUsername_To_KARUserId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneOwnerGroupname_To_KARGroupId = new Map<String, String>(); 
            
            Map<String,String>  map_OpenlaneSourceId_To_PurchaseId = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneCaseEnhanceId_To_KARCaseId = new Map<String, String>(); 
            // New 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId = new Map<String, String>();
            
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_PALS = new Map<String, String>(); 
            Map<String,String>  map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId_PALS = new Map<String, String>(); //new 
            
            //System.debug('>>>> Before Enter Loop');
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
                // Make map here                
                map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId_PALS.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailId_PALS.get(oc.PALS_ATC_ORG_ID__c)); //new 
                map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_PALS.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_PALS.get(oc.PALS_ATC_ORG_ID__c));
                
                if(blnUpdateOnlyAdesaComDetailPALSProvider == false) //new 
                {
                    map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId_Seller.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailId_seller.get(oc.Seller_ATC_ORG_ID__c)); //new 
                    map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Seller.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_seller.get(oc.Seller_ATC_ORG_ID__c));
                    map_OpenlaneCaseRecordType_To_KARRecordTypeId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARRecordTypeNameToId.get(oc.RecordType_Name__c)); 
                    map_OpenlaneContactLoginID_To_KARContactId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARContactLoginIdToContactId.get(oc.Contact_LOGIN_ID__c));
                    map_OpenlaneSellerContactLoginID_To_KARContactId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARSellerContactLoginIdToContactId.get(oc.Seller_Contact_LOGIN_ID__c));
                    map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Trans.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Trans.get(oc.Transporter_ATC_ORG_ID__c));
                    map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Acct.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailAcctId_Acct.get(oc.Account_ATC_ORG_ID__c));
                    map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARAdesaDetailATCOrgIdToAdesaDetailId.get(oc.Account_ATC_ORG_ID__c));
                    map_OpenlaneSecOwnerUsername_To_KARUserId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARUserNameToId.get(oc.Secondary_Owner_USERNAME__c));
                    map_OpenlaneReqByInternalUsername_To_KARUserId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARUserNameToId.get(oc.Requested_By_Internal_USERNAME__c));
                    
                    if(!Test.isRunningTest())
                    {
                        map_OpenlaneOwnerUsername_To_KARUserId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARUserNameToId.get(oc.Owner_USERNAME__c));
                        map_OpenlaneOwnerGroupname_To_KARGroupId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARGroupNameToId.get(oc.Owner_USERNAME__c));
                    }
                    
                    map_OpenlaneSourceId_To_PurchaseId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapKARPurchaseSourceIdToId.get(oc.Purchase_VEHICLE_ID_SOURCE_ID__c));                
                    map_OpenlaneCaseEnhanceId_To_KARCaseId.put(oc.Migrated_Openlane_Case_KAR_id__c,mapOpenlaneCaseEnhanceIdToKARCaseId.get(oc.Related_to_Enhancement_Case_ID__c));
                }
            }
            //System.debug('>>>> After Enter Loop');
            
            String strDefaultOwnerId = mapKARUserNameToId.get(Utils.getMigratedCaseDefaultOwnerUserName('migrated.case.default.owner.username'));
            //String strDefaultOwnerId = Utils.getDummyCaseId('dummy.case.id');
            
            //8. Set other object Id to Case 
            for(Case c: ListKARCase){
                // Set id here 
                c.PALSPRovider__c = map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_PALS.get(c.Id); //new 
                if(blnUpdateOnlyAdesaComDetailPALSProvider == false) //new 
                {
                    c.ADESA_com_Detail_Seller__c = map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId_Seller.get(c.Id); //new 
                    c.Seller__c = map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Seller.get(c.Id);
                    c.RecordTypeId = map_OpenlaneCaseRecordType_To_KARRecordTypeId.get(c.Id);
                    c.ContactId = map_OpenlaneContactLoginID_To_KARContactId.get(c.Id);
                    c.Seller_Contact__c = map_OpenlaneSellerContactLoginID_To_KARContactId.get(c.Id);
                    c.Transporter__c = map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Trans.get(c.Id);
                    c.AccountId = map_OpenlaneAdesaDetailATCOrgId_To_KARAccountId_Acct.get(c.Id);
                    c.ADESA_com_Detail__c = map_OpenlaneAdesaDetailATCOrgId_To_KARAdesaDetailId.get(c.Id);
                    c.Secondary_Owner__c = map_OpenlaneSecOwnerUsername_To_KARUserId.get(c.Id);
                    c.Requested_By_Internal__c = map_OpenlaneReqByInternalUsername_To_KARUserId.get(c.Id);
                    c.VIN__c = map_OpenlaneSourceId_To_PurchaseId.get(c.Id);
                    c.Related_to_Enhancement_Case__c = map_OpenlaneCaseEnhanceId_To_KARCaseId.get(c.Id);
                    
                    if(c.Openlane_Case_Owner_TYPE__c == 'User')
                    {
                        string strUserid = map_OpenlaneOwnerUsername_To_KARUserId.get(c.Id);
                        if(strUserid!=null && strUserid!='') {  c.ownerid = strUserid; } else { c.ownerid = strDefaultOwnerId;}
                        
                    }
                    else
                    {
                        string strGroupid = map_OpenlaneOwnerGroupname_To_KARGroupId.get(c.Id);
                        if(strGroupid!=null && strGroupid!='') { c.ownerid = strGroupid; } else { c.ownerid = strDefaultOwnerId;}
                    }
                }               
                counter++;
            }
            
            //Update Case
            Update ListKARCase;
            
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        if(SendBatchCompleteNotification)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing BatchCaseFieldsRelationUpdate.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            String body = Summary + '<br/><br/><br/><br/>There are total of ' + counter + ' Cases have been Updated.';
            mail.setHtmlBody(body);         
            if(!Test.isRunningTest())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//BatchCaseFieldsRelationUpdate objBatchCaseFieldsRelationUpdate = new BatchCaseFieldsRelationUpdate('and Load__c=2',true,'Dipesh.patel@openlane.com',false);
//Database.executeBatch(objBatchCaseFieldsRelationUpdate);