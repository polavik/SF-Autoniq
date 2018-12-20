@isTest
private class testDRURBeforeInsert{
   private static testMethod void testDRURBeforeInsert(){
   
      Test.startTest();
      String drurRecordType = Utils.getRecordTypeId('Dealer_Registration_User_Request__c', 'Add/Remove User');
      
       Dealer_Registration_User_Request__c drur = new Dealer_Registration_User_Request__c(
       RecordTypeId = drurRecordType,
       Rep_Auction_Access_Number__c = '1233322111',
       Registration_Form_User_Id__c = '123542123',
       Email__c = 'testClass@dummy.com'
       );
       
       insert drur;
       
      Test.stopTest();
   }
   
   
   

}