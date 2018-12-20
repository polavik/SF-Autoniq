@isTest(SeeAllData=true)
private class testDRURBeforeInsertUpdate{
   private static testMethod void testDRURBeforeInsertUpdate(){   
      Test.startTest();
        Account a = new Account(Name = 'WILLIAM LEHMAN MITSUBISHI', ATC_Organization_id__c='DRR_TEST');
        insert a;                
        Dealer_Registration_Request__c drr = new Dealer_Registration_Request__c(name = 'WILLIAM LEHMAN MITSUBISHI', Organization_Id__c='DRR_TEST', Rep_Auction_Access_Number__c = '',Registration_Form_Id__c='012345');
        insert drr;
        Dealer_Registration_User_Request__c drur = new Dealer_Registration_User_Request__c(
            Dealer_Registration_Request__c = drr.Id,
            remove_user__c = true,
            Registration_Form_User_Id__c = '0123456'
        );
       
        insert drur;       
      Test.stopTest();
   }
}