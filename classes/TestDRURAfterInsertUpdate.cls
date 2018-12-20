@isTest(SeeAllData=true)
private class TestDRURAfterInsertUpdate {

    static testMethod void dealerRegistrationUserRequestTrigger() {
    
      Account a = new Account(Name = 'WILLIAM LEHMAN MITSUBISHI', ATC_Organization_id__c='DRR_TEST');
        insert a;
                
        Dealer_Registration_Request__c drr = new Dealer_Registration_Request__c(name = 'WILLIAM LEHMAN MITSUBISHI', Organization_Id__c='DRR_TEST', Rep_Auction_Access_Number__c = '',Registration_Form_Id__c='abc');
        insert drr;

     
   Dealer_Registration_User_Request__c drur1 = new Dealer_Registration_User_Request__c(Name = 'Test-Drur1', Requested_Username__c = 'RTR-Test1', Registration_Form_User_Id__c = '123321231',Rep_Auction_Access_Number__c = '1233322111',
    First_Name__c = 'Tester', Last_Name__c = 'Test', Phone__c = '(555) 555-5555)', Email__c = 'no@no.com', Date_Of_Birth__c = system.today(), Dealer_Registration_Request__c = drr.Id);
    insert drur1;
  
    }
}