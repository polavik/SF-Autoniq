@isTest
private class TestSMSMessageBeforeInsert{
   private static testMethod void testSMSMessageBeforeInsert(){
      Test.startTest();

      Contact oCont = new Contact(lastName='oCont');
      insert oCont;
      Contact iCont = new Contact(lastName='iCont');
      insert iCont;
      Account a = new Account(Name='Test SMS', ATC_Organization_Id__c='ACB12345');
      insert a;
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User usr = new User();        
      usr.Username = 'mrawesome@openlane.com';
      usr.Email = 'mrawesome@openlane.com';
      usr.FirstName = 'Mr';
      usr.LastName = 'Awesome';
      usr.CommunityNickname = 'mrawesome';
      usr.Alias = 'mrawe';     
      usr.ProfileId = p.id;
      usr.TimeZoneSidKey = 'America/Los_Angeles';
      usr.LocaleSidKey = 'en_US';
      usr.EmailEncodingKey = 'ISO-8859-1';
      usr.LanguageLocaleKey = 'en_US';        
      insert usr;
      
      User usr2 = new User();        
      usr2.Username = 'mrawesome2@openlane.com';
      usr2.Email = 'mrawesome2@openlane.com';
      usr2.FirstName = 'Mr';
      usr2.LastName = 'Awesome2';
      usr2.CommunityNickname = 'mrawesome2';
      usr2.Alias = 'mrawe2';     
      usr2.ProfileId = p.id;
      usr2.TimeZoneSidKey = 'America/Los_Angeles';
      usr2.LocaleSidKey = 'en_US';
      usr2.EmailEncodingKey = 'ISO-8859-1';
      usr2.LanguageLocaleKey = 'en_US';        
      insert usr2;
      
      
      simplesms__SMS_Message__c oSms = new simplesms__SMS_Message__c (
          simplesms__Type__c = 'Outgoing',
          simplesms__To__c = '(555) 123-4567', 
          simplesms__From_Num__c = '(555) 765-4321', 
          simplesms__Message_Date__c = Date.Today(),
          simplesms__Contact__c = oCont.Id,
          simplesms__Account__c = a.Id,
          OwnerId = usr.Id );
          
      insert oSms;
    
      simplesms__SMS_Message__c iSms = new simplesms__SMS_Message__c (
          simplesms__Type__c = 'Incoming',
          simplesms__To__c = '+15557654321', 
          simplesms__From_Num__c = '+15551234567', 
          simplesms__Message_Date__c = Date.Today(),
          simplesms__Contact__c = iCont.Id,
          simplesms__Account__c = a.Id,
          OwnerId = usr2.Id );
          
      insert iSms;
      
      //System.assertEquals(iSms.OwnerId, usr.Id);

    }
}