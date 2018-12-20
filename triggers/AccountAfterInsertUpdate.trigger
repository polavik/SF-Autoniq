trigger AccountAfterInsertUpdate on Account (after insert, after update) 
{
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
       //djpatel on 25-Sep-2014 ( B-31398 )
      String creditAccountRecordType = Utils.getRecordTypeId('Account', 'Credit Account');      
     List<ID> accountIdsForOrgTaxFormOnFileFlag = new List<ID>();
      
       // Link Dealer Registrations to Accounts by Organization Id
    if (Trigger.isInsert)
    {
      Map<Id, Id> accountDQMap = new Map<Id, Id>();
      List<Dealer_Questionnaire__c> dqs = new List<Dealer_Questionnaire__c>();
      Set<Dealer_Questionnaire__c> dqSetToUpdate = new Set<Dealer_Questionnaire__c>();
      List<Dealer_Questionnaire__c> dqsToUpdate = new List<Dealer_Questionnaire__c>();
      
      Map<String, List<Account>> organizationNameAccountMap = new Map<String, List<Account>>();//Creates the ability to make a map with the Org ID, Account object

      for (Account a : Trigger.new) //For variable type of Account Object, go through all the triggering objects.  This could be a huge list of accounts
      {
          if( a.recordTypeId != creditAccountRecordType) //djpatel on 29-Sep-2014 ( B-31398 )  
          {
                List<Account> lst = organizationNameAccountMap.get(a.Name);//Is there a value in the Map with Name = Name on account we are currently checking?
                if (lst == null)//If not we will make one.
                { 
                    lst = new List<Account>();//Since there was no account objects that matched our name we will make a list of accounts that do match the a.name
                    organizationNameAccountMap.put(a.Name, lst);//Maps a single account Name to possibly multiple account objects
                }
                lst.add(a);//Now we will simply add a the account object to our list mapped to that name
                
                if(a.Dealer_Questionnaire_Id__c != null)
                  {
                      accountDQMap.put(a.Dealer_Questionnaire_Id__c, a.Id);
                  }
               //Story B-39962 The field in SF is “CDN Joint Election Form on File”…whatever the value is, should be communicated to V1.
                 if (a.CDN_Joint_Election_Form_on_File__c !=null){
                 System.debug('Checking OrgTaxFormOnFileFlag ');
                 accountIdsForOrgTaxFormOnFileFlag.add(a.Id);
             
          }  
                
              
          }
      }

      
      if(accountDQMap != null)
          {
              dqs =
              [
                  SELECT Id, Account__c
                  FROM Dealer_Questionnaire__c
                  WHERE Id in: accountDQMap.keySet()
              ];
              
              for(Dealer_Questionnaire__c dq: dqs)
              {
                  dq.Account__c = accountDQMap.get(dq.Id);
                  dqSetToUpdate.add(dq);
              }
              
              if(dqSetToUpdate != null)
              {
                  for(Dealer_Questionnaire__c dq: dqSetToUpdate )
                  {
                      dqsToUpdate.add(dq);
                  }
                  Database.update(dqsToUpdate);
              }

          }
      
      if (organizationNameAccountMap.size() > 0)//Did we map an account to an Org id?  If not we do nothing.
      {
        System.Debug('Creating regsToUpdate');
        List<Dealer_Registration_Request__c> regsToUpdate = //Create a list of DRR objects that we plan to check against zipcodes.  List contains everything found by query
        [
          SELECT
            Account__c, Name, Zipcode__c, Adesa_DRR__c, Adesa_Customer_Type__c, Training_Required__c
          FROM 
            Dealer_Registration_Request__c
          WHERE
            Account__c = NULL //This is the Account Lookup field.  We are making sure we haven't already linked this.
            AND Registration_Approved__c = true //This solves the issue of having multiple DRRs trying to link to an account
            AND Name IN :organizationNameAccountMap.keySet()//Checks our Map for that Account Name
        ];
        System.Debug('regsToUpdate = ' + regsToUpdate);
        //We now have a list of all DRR that share a name with an account in our map
        List<Dealer_Registration_Request__c> finalRegsToUpdate = new List<Dealer_Registration_Request__c>();//This list will also make sure the Zipcode matches the name
        List<Opportunity> oppsToInsert = new List<Opportunity>();//We need to create new opps for this account
        List<Account> acctsToUpdate = new List<Account>();
        Boolean isDupe = false;
        Set<Id> DRRIds = new Set<Id>();
        for (Dealer_Registration_Request__c DRR : regsToUpdate)
        {    
              List<Account> lst = organizationNameAccountMap.get(DRR.name.toUpperCase());//Makes a list of Account Objects in the map that have the same name as the DRR
              if (lst != null)//If there is no DRR match we simply insert the account
              {
                  for (Account a : lst)
                  {
                      System.Debug('Account being analyzed = ' + a.Name);
                      if (a.BillingPostalCode != null && a.BillingPostalCode.equalsIgnoreCase(DRR.Zipcode__c))
                      {
                          System.Debug('Match found for account:' + a.Name + ' DRR:' + DRR.Name + ' Account Zip: ' + a.BillingPostalCode + ' DRR Zip: ' + DRR.Zipcode__c);
                          DRR.Account__c = a.Id;//Links the DRR to the Account which was our main goal here
                          DRR.Registration_Status__c = 'Completed';
                          //DRR.Organization_Id__c = a.ATC_Organization_ID__c;// don't do the update for one-many relation now.                    
                          oppsToInsert.add(OpportunityHelper.createNewRegistrationOpportunity(a));//Adds the Opp to the Account
                          Account tempAccount = new Account(Id = a.Id);
                          tempAccount.Training_Requested_at_Registration__c = DRR.Training_Required__c;
                          if(DRR.Adesa_DRR__c != null && DRR.Adesa_DRR__c == true)
                          {
                              tempAccount.Created_from_Adesa_DRR__c = true;
                              tempAccount.Adesa_Customer_Type__c = DRR.Adesa_Customer_Type__c;            
                          }
                          if(acctsToUpdate != null)
                          {
                              for(Account acct : acctsToUpdate)
                              {
                                  if(a.Id == acct.Id) //PPM#101252
                                  {
                                      isDupe = true;
                                      break;
                                  }
                              }
                          }
                          if(isDupe == false)
                          {
                              acctsToUpdate.add(tempAccount); 
                          }
                          isDupe = false; 
                          System.Debug('DRR = ' + DRR);
                          if(DRRIds.Add(DRR.Id)) //PPM#101252
                          {
                              finalRegsToUpdate.add(DRR);//Updates the list of DRRs that we need to update below
                          }
                          System.Debug('Final update list = ' + finalRegsToUpdate);
                          
                      }
                  }
              }
          }
        
        Database.update(finalRegsToUpdate);//Basically applies the updates
        Database.update(acctsToUpdate);//Basically applies the updates
        Database.insert(oppsToInsert);
      }
      
    }  

    for (Account a : Trigger.new) 
      {
                //Story B-39962 The field in SF is “CDN Joint Election Form on File”…whatever the value is, should be communicated to V1.
                 if (a.CDN_Joint_Election_Form_on_File__c !=null){
                 System.debug('Checking OrgTaxFormOnFileFlag ');
                 accountIdsForOrgTaxFormOnFileFlag.add(a.Id);
             
          }  
       
      }
      
   //Story B-39962 The field in SF is “CDN Joint Election Form on File”…whatever the value is, should be communicated to V1.
       if (accountIdsForOrgTaxFormOnFileFlag.size() > 0)
      {
          System.debug('AccountHelper.OrgTaxFormOnFileFlag(accountIds) --> send webservice call for updating OrgTaxFormOnFileFlag');
          AccountHelper.OrgTaxFormOnFileFlag(accountIdsForOrgTaxFormOnFileFlag);

      }

        // If an Account is inserted and does not have a good (recent) refresh date, refresh it from MDM.
        Integer staleHours = Integer.valueOf(MDM_Settings__c.getInstance().Stale_Hours__c);
        if(staleHours == null){
            staleHours = 48;
        }

        Map<Id,List<String>> historyMap = new Map<Id,List<String>>();
        // If an Account is updated by a stewardship user, check for data flipping
        if(Trigger.isUpdate && StewardshipHelper.stewardshipUserNames.contains(UserInfo.getUserName())){
            Integer dataFlippingLimit = -Integer.valueOf((MDM_Settings__c.getInstance().Data_Flipping_Limit__c != null)?MDM_Settings__c.getInstance().Data_Flipping_Limit__c : 48);
            if(Test.isRunningTest() && TestStewardshipAccountTriggers.currentTest == 'FlipTest'){
                historyMap.put(Trigger.new[0].id,new List<String>{'Name','Auction_Access_Number__c'});
            } else {
                for(AggregateResult ar : [select AccountId, field, count(id) from AccountHistory where AccountId in :Trigger.newMap.keyset() and CreatedDate > :System.now().addHours(dataFlippingLimit) 
                                and CreatedById in :StewardshipHelper.stewardshipUserIds group by accountid, field having count(id) > 1]){

                    String fieldName = String.valueOf(ar.get('field'));
                    if(fieldName == 'TextName'){ // Nuance...I think in the history object the 'Name' field is actually 'TextName'
                        fieldName = 'Name';
                    }
                    Id accountId = String.valueOf(ar.get('AccountId'));
                    if(Account.sObjectType.getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase())){
                        // It is ONLY if a field that has been changed multiple times is updated in THIS PARTICULAR update that we create a Case for it.
                        // Otherwise, any update to the Account would create a Case because the prior updates (that created the original Case) still exist!
                        if(Trigger.oldMap.get(accountId) != null && Trigger.oldMap.get(accountId).get(fieldName) != Trigger.newMap.get(accountId).get(fieldName)){

                            if(historyMap.get(accountId) == null){
                                historyMap.put(accountId,new List<String>{fieldName});
                            } else {
                                List<String> tempList = historyMap.get(accountId);
                                tempList.add(fieldName);
                                historyMap.put(accountId,tempList);
                            }           
                        }
                    } 
                }
            }
            if(historyMap.keySet().size() > 0){
                StewardshipHelper.createDataFlippingCases(historyMap);
            }
        }

        List<Id> idList = new List<Id>();
        for(Account a : Trigger.New){
            if(!System.isFuture() && Trigger.isInsert && (a.MDM_Refresh_Date__c == null || a.MDM_Refresh_Date__c.addHours(staleHours) < System.now())){
                if(!Test.isRunningTest()){
                    if(idList.size() == 20){ // Accounting for future limits and CPU time limits
                        MDMServiceHelper.refreshSalesforceAccountAsync(idList);
                        idList.clear();
                    } else {
                        idList.add(a.id);
                    }
                }
            }
        }
        if(idList.size() > 0){
            MDMServiceHelper.refreshSalesforceAccountAsync(idList);
        }

    }
   
}