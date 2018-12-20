trigger AccountBeforeInsertUpdate on Account (before insert, before update) {

  // This code is modified by the KAR Killswitch.
  //Get profile Id of Current User
  Id profileId = Userinfo.getProfileId();
  //Get KillSwitch record for the User's profileId.
  Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
  //Check for KillSwitch flag
  if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
    //djpatel on 25-Sep-2014 ( B-31398 )
      String creditAccountRecordType = Utils.getRecordTypeId('Account', 'Credit Account'); 
      
      Map<Id, Account > accToUpdate = new Map<Id, Account >();
      List<Application_Account_Role__c> ar = new List<Application_Account_Role__c>();
      List<Id> acctid = new List<Id>();
      String name = UserInfo.getUserName();         
      //Profile prof = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
      /*
      
       // Start --> code migrated from Openlane
       String usRecordType = Utils.getRecordTypeId('Account', 'Dealership Account US'); 
       String canRecordType = Utils.getRecordTypeId('Account', 'Dealership Account CA');
                  
      for(Account a: Trigger.new){
      
         String strOldMapValue1;
         String strOldMapValue2;
         if (Trigger.isUpdate)
         {
              strOldMapValue1 = Trigger.oldMap.get(a.Id).ca_ideal_spl__c; //Lookup(user)
              strOldMapValue2 = Trigger.oldMap.get(a.Id).ca_field_sales_rep__c; //Lookup(user)
         }
         a.BillingPostalCode__c = a.BillingPostalCode;
        
         //This initializes the Account Assignment fields for CA
         //And if they are modified it overwrites the US Account Assignment fields
         //For Canadian Dealerships
         if(a.recordTypeId == canRecordType)
         {

             if(a.ca_ownerid__c == null && a.OwnerId != null)
             {
                 system.debug('CA Account Owner Null, setting to US Owner');
                 a.ca_ownerid__c = a.OwnerId;
             }
             else
             {
                 system.debug('CA Account Owner Populated, overwriting US Owner');
                 a.OwnerId = a.ca_ownerid__c;
             }
             
             //if(a.ca_ideal_spl__c == null && oldAcct.ca_ideal_spl__c != null)
             if(a.ca_ideal_spl__c == null && strOldMapValue1 != null)
             {
                 a.iDeal_Spl__c = null;
             }
             else if(a.ca_ideal_spl__c == null && a.iDeal_Spl__c != null)
             {
                 system.debug('CA Account IDeal Null, setting to US IDeal ');
                 a.ca_ideal_spl__c = a.iDeal_Spl__c;
             }
             else
             {
                 system.debug('CA Account IDeal Populated, overwriting US Ideal');
                 a.iDeal_Spl__c = a.ca_ideal_spl__c;
             }
             
             //if(a.ca_field_sales_rep__c == null && oldAcct.ca_field_sales_rep__c != null)
             if(a.ca_field_sales_rep__c == null && strOldMapValue2 != null)
             {
                 a.Field_Sales_Rep__c = null;
             }
             else if(a.ca_field_sales_rep__c == null && a.Field_Sales_Rep__c != null)
             {
                 system.debug('CA Account Outside Null, setting to US Outside');
                 a.ca_field_sales_rep__c = a.Field_Sales_Rep__c;
             }
             else
             {
                 system.debug('CA Account Outside Populated, overwriting US Outside');
                 a.Field_Sales_Rep__c = a.ca_field_sales_rep__c;
             }
         }
        //This is to bypass SF issue where Owner field does not allow formula
        //fields to access it's properties.
         if (a.OwnerID != a.Owner_Link__c) {
              a.Owner_Link__c = a.OwnerId;
         }
     }    
       // End --> code migrated from Openlane 
     
     */
     
      /* New changes from Adesa.com Detail owner back out to Account */
      // New Logic for V1 Update - As per requirement given by Crandall(PPM#98526)
      //String canRecordType = Utils.getRecordTypeId('Account', 'Dealership Account CA');
    Set<String> TerritoryRecordTypeIds = Utils.getTerritoryRecTypeIds('Account');

      for(Account a: Trigger.new){
      
         a.BillingPostalCode__c = a.BillingPostalCode;
      
         String strOldCanOwnerId;
         String strOldCanIdealSpl;
         String strOldCanFieldSalesRep;
         if (Trigger.isUpdate)
         {
              strOldCanOwnerId = Trigger.oldMap.get(a.Id).ca_ownerid__c; //Lookup(user)
              strOldCanIdealSpl = Trigger.oldMap.get(a.Id).ca_ideal_spl__c; //Lookup(user)
              strOldCanFieldSalesRep = Trigger.oldMap.get(a.Id).ca_field_sales_rep__c; //Lookup(user)
         }
       

         //if(a.RecordTypeId == canRecordType)
       if(TerritoryRecordTypeIds.contains(a.RecordTypeId) && String.isNotBlank(a.BillingCountry) && a.BillingCountry.trim().containsIgnoreCase('canada'))
         {         
              
            if(a.ca_ownerid__c != strOldCanOwnerId && a.ca_ownerid__c!=null)
            {          
               a.OwnerId = a.ca_ownerid__c;
            }
            if(a.ca_ideal_spl__c != strOldCanIdealSpl)
            {  
                a.iDeal_Spl__c = a.ca_ideal_spl__c;                
            }
            if(a.ca_field_sales_rep__c != strOldCanFieldSalesRep)
            {           
                a.Field_Sales_Rep__c = a.ca_field_sales_rep__c;
            }
        }
        //This is to bypass SF issue where Owner field does not allow formula
        //fields to access it's properties.
        if (a.OwnerID != a.Owner_Link__c) {
            a.Owner_Link__c = a.OwnerId;
        }
      }
       /* End  */
          
      if (Trigger.isUpdate) { 
      
          // Start --> code migrated from Openlane
          List<ID> accountsToGetAADsWith = new List<ID>(); 
          // End --> code migrated from Openlane 
          
          for (Account a : Trigger.new) 
          {
              if( a.recordTypeId != creditAccountRecordType) //djpatel on 29-Sep-2014 ( B-31398 )  
              {
                      Account oldAcct = System.Trigger.oldMap.get(a.Id);
                      if ( a.Ford_Enrolled__c == 'N' && oldAcct.Ford_Enrolled__c == 'Y' && a.Ford_UnEnrolled_Date__c == null ) {
                          a.Ford_UnEnrolled_Date__c = Date.today();
                      } else if ( a.Ford_Enrolled__c == 'Y' && oldAcct.Ford_Enrolled__c == 'N' && a.Ford_UnEnrolled_Date__c != null ) {
                          a.Ford_UnEnrolled_Date__c = null;
                      }
                      
                      if (a.Data_Source__c == 'IAA' && oldAcct.Data_Source__c != 'IAA' && oldAcct.Data_Source__c != null) {
                          a.Data_Source__c.addError('Data Source should not be updated to IAA');
                      }else if(a.Data_Source__c == 'IAA' && oldAcct.Source_Id__c != a.Source_Id__c){
                          a.IAA_Customer_Number__c = a.Source_Id__c;
                      }
                      
                      // Start --> code migrated from Openlane
                      if(oldAcct.Last_Auction_Inside_Sales_Contact_Date__c != a.Last_Auction_Inside_Sales_Contact_Date__c) //ISCHANGED
                      {
                         accountsToGetAADsWith.add(a.Id);
                      }
                      // End --> code migrated from Openlane 
                      
                      //CMDM hierarch updating process
                      //For account object, only the following fields will be in CMDM hieracrch updating process
                      // Account Name 
                      // Billing Address
                      // Fax 
                      // Phone
                      // Account Auction Access Number 
                      // Auction Access Legal Name 
                      // Dealership Type 
                      // Federal Tax Code
                      Boolean updateflag = true;
                      if(Test.isRunningTest() ||
                         !(name.startsWith('sfintegration')||name.startsWith('svc_ihub')) ){
                        updateflag = true;
                     //if (a.Process_Identifier__c ==null||a.Process_Identifier__c ==''&& prof.name!='System Administrator'){
                     }else if (a.Process_Identifier__c ==null||a.Process_Identifier__c ==''){
                        updateflag = false;
                     }else if (a.Process_Identifier__c=='MDM'){                     
                         updateflag = true;
                        
                     }else if (oldAcct.Mdm_Id__c != Null && oldAcct.Mdm_Id__c != ''){
                            updateflag = false; 
                           
                     }else if (a.Process_Identifier__c=='AFC' ){
                            updateflag = true;
                    
                     }else if (a.Process_Identifier__c.startsWith('OPENLANE') && (oldAcct.AFC_Dealer_ID__c == Null || oldAcct.AFC_Dealer_ID__c == '')) {                   
                            updateflag = true;
                          
                     }else if (a.Process_Identifier__c=='IAA' && (oldAcct.Openlane_Org_ID__c == Null || oldAcct.Openlane_Org_ID__c == '') && (oldAcct.AFC_Dealer_ID__c == Null || oldAcct.AFC_Dealer_ID__c == '')) {                   
                            updateflag = true;
                          
                     }else {
                            updateflag = false;                        
                     }

                      if (updateflag == false ){
                              //No MDM Key fields updating. Update incoming data with existing value
                              a.Name = oldAcct.Name;
                              //a.BillingAddress = oldAcct.BillingAddress;
                              a.Fax = oldAcct.Fax;
                              a.Phone = oldAcct.Phone;
                              // Allow OPENLANE-BATCH and OPENLANE-SYND process to update AA# if it was blank  
                              if(!((oldAcct.Auction_Access_Number__c == null || oldAcct.Auction_Access_Number__c == ''|| oldAcct.Auction_Access_Number__c == '0') && a.Process_Identifier__c!=null && a.Process_Identifier__c.startsWith('OPENLANE') ))
                              {
                                  a.Auction_Access_Number__c = oldAcct.Auction_Access_Number__c;
                              }
                              a.Legal_Name__c = oldAcct.Legal_Name__c;
                              a.Dealership_Type__c = oldAcct.Dealership_Type__c;
                              a.Tax_Identification_Number__c = oldAcct.Tax_Identification_Number__c;
                                  
                      }
                  
              }
              //story b-33850 
              if ((a.AFC_BA_Company_Name__c!=null && a.AFC_BA_Company_Name__c!='')||
                  (a.AFC_BA_Dba_Name__c!=null && a.AFC_BA_Dba_Name__c!='')||
                  (a.AFC_BA_Legal_Name__c!=null && a.AFC_BA_Legal_Name__c!='')){
                     Account oldAcct = System.Trigger.oldMap.get(a.Id);
                     String accountId = oldAcct.id;
                     acctid.add(accountid);
                     accToUpdate.put(accountId ,a);
              }
              
              // Start --> openlane SetArbitration trigger 
              a.Arbitrations__c = 0;
              // End --> openlane SetArbitration trigger 
              
          }
          
          // Start --> openlane SetArbitration trigger  
          // Get list of Arbitrations in the past 180 days for logged by accounts in trigger
          for (Case c : [SELECT AccountId, Type, VIN__r.ATC_Sale_Date__c FROM Case WHERE Type = 'Arbitration' AND CreatedDate > :Datetime.now().addDays(-180) AND AccountId IN :Trigger.newMap.keySet()])
          {
              Trigger.newMap.get(c.AccountId).Arbitrations__c += 1;
          }
          // End --> openlane SetArbitration trigger
          
      
          // Start --> code migrated from Openlane
          List<Auction_Detail__c> AADsToUpdate =[SELECT Id FROM Auction_Detail__c WHERE Account__c in :accountsToGetAADsWith];
          if(AADsToUpdate.size() > 0)
          {
             update(AADsToUpdate);
          }  
          // End --> code migrated from Openlane 
          
      }
      if (acctid.size() > 0) {
          List<Application_Account_Role__c> arole = [select id,account__c from Application_Account_Role__c where account__c in :acctid and primary__c =true and afc_contracts__r.id!=null ];
      
                
          if (arole.size() > 0){
          for(Application_Account_Role__c role: arole){
               Account acc = accToUpdate.get(role.account__c);
               if (acc.AFC_BA_Company_Name__c!=null){
                 role.Company_Name__c=acc.AFC_BA_Company_Name__c;
               }
               if (acc.AFC_BA_Dba_Name__c!=null){
                 role.DBA_Name__c=acc.AFC_BA_Dba_Name__c;
               }
               if (acc.AFC_BA_Legal_Name__c!=null){
                 role.Legal_Name__c=acc.AFC_BA_Legal_Name__c;
               }             
                ar.add(role); 
                          
          } 

         }
      }
      if (ar.size()>0){
          try{
              update(ar);
         }catch (System.DmlException e) {
            System.debug('##DEBUGGING##' + e.getMessage());
         }
       }
      if (Trigger.isInsert){
          for (Account a : Trigger.new) {
              if( a.recordTypeId != creditAccountRecordType) //djpatel on 29-Sep-2014 ( B-31398 )  
              {
                      if (a.Data_Source__c == 'IAA')
                          a.IAA_Customer_Number__c = a.Source_Id__c;
                  
              }
          }
      }

    if(Trigger.isUpdate && StewardshipHelper.stewardshipUserNames.contains(UserInfo.getUserName())){
      // Protection against key field deletion
      List<String> keyAccountFields = StewardshipHelper.stewardshipKeyFieldsMap.get('Account');
      for(Account a : Trigger.New){
        Account oldAccount = Trigger.oldMap.get(a.Id);
        Set<String> keyFieldsDeleted = new Set<String>();
        if(keyAccountFields != null){
          for(String keyField : keyAccountFields){
            if(oldAccount.get(keyField) != null && a.get(keyField) == null){
              // Ignore update and Create Stewardship Notification
              a.put(keyField,oldAccount.get(keyField));
              keyFieldsDeleted.add(keyField);
            }
          }
          if(keyFieldsDeleted.size() > 0){
            StewardshipHelper.createKeyFieldDeletionCase(a.Id, keyFieldsDeleted);
            a.In_Stewardship__c = true;
          }
        }
        // Revert changes for any locked fields
        List<String> lockedFields = (a.Locked_Fields__c == null)? new List<String>() : a.Locked_Fields__c.split(',');
        for(String lockedField : lockedFields){
          if(oldAccount.get(lockedField) !=  a.get(lockedField)){
            // Revert lockedField change
            a.put(lockedField,oldAccount.get(lockedField));
          }
        }
      }
    }
  }

    
}