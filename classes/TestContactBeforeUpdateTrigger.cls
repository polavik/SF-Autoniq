@isTest private class TestContactBeforeUpdateTrigger{    
   static testMethod void TestContactBeforeUpdateTTrigger() {       
   Contact c = new Contact(FirstName='Test', LastName = 'Dummy', Source_Id__c='', Mdm_Id__c ='', 
          MailingCity = 'Chico', MailingCountry  = 'US', MailingState = 'CA',  MailingStreet = 'Somewhere St',
           MailingPostalCode = '94002', Phone = '1234567', Title = 'The Man', Rep_Auction_Access_Number__c  = '123', 
           Email = 'no@no.com', Person_ID__c = '');       
           System.debug('Contact before inserting : ' + c);       
           // Insert Contact       
           insert c;       
           c.Person_ID__c  = '';
           update c;
           c.Person_ID__c  = '1234546';
           update c;
           
           c.Source_Id__c = '';
           update c;

           c.Source_Id__c = 'AFC1234';
           update c;

           c.Source_Id__c = '1234';
           update c;
           
           c.Mdm_Id__c ='123456';
           update c;

           c.Mdm_Id__c ='';
           update c;

           Account a =new Account();
           a.name='xyz';
           insert a; 
    
           Id p = [select id from profile where name='System Administrator'].id;
           User user = new User(alias = 'svc_ihub', email='test123@noemail.com',
                        emailencodingkey='UTF-8', lastname='svc_ihub', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                        timezonesidkey='America/Los_Angeles', username='svc_ihub@noemail.com');
           insert user;
           system.runAs(user)
          {
            c.Process_Identifier__c ='';
            update c;
       
            c.Process_Identifier__c='MDM';
            update c;
       
            c.Process_Identifier__c='AFC';
            update c; 
       
            c.Process_Identifier__c='MDM';
            c.Source_Id__c = '';
            update c;
       
            c.Process_Identifier__c='OPENLANE';
            c.Person_ID__c='';
            update c;
              
            c.Process_Identifier__c='IAA';
            update c;
       
            c.Process_Identifier__c='AAAAAA';
            update c;       
         
          }   
   }

  static testMethod void checkForCosmosSync(){
    final Integer NUM_OF_CONTACTS = 10;

    ContactServices.cosmosSyncFieldSet = new List<String>{'Phone', 'Email'};

    List<Contact> contactList = TestServices.createContacts(NUM_OF_CONTACTS, false);
    for(Integer i = 0; i < contactList.size(); i++){
      Contact ctc = contactList[i];
      ctc.FirstName = 'NotUpdated';
      ctc.Phone = '1234567890';
      ctc.Email = 'whatever@test.com';
      ctc.Party_Id__c = String.valueOf(i);
      ctc.Cosmos_Sync_Pending__c = false;
    }
    insert contactList;
    for(Integer i = 0; i < contactList.size(); i++){
      Contact ctc = contactList[i];
      if(Math.mod(i, 2) == 0){
        ctc.FirstName = 'Updated';
        ctc.Phone = '0987654321';
        ctc.Email = 'test@whatever.com';
      }
    }

    Test.startTest();
    update contactList;
    Test.stopTest();

    List<Contact> dbContacts = [SELECT FirstName, Cosmos_Sync_Pending__c FROM Contact WHERE Id IN :Pluck.ids(contactList)];

    System.assertEquals(contactList.size(), dbContacts.size(), 'Unexpected list size returned');
    for(Contact ctc : dbContacts){
      if(ctc.FirstName == 'Updated'){
        System.assertEquals(true, ctc.Cosmos_Sync_Pending__c, 'Sync Pending checkbox should be true');
      } else {
        System.assertEquals(false, ctc.Cosmos_Sync_Pending__c, 'Sync Pending checkbox should be false');
      }
    }
  }                    
 }