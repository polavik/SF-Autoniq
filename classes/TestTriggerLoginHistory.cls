@isTest
private class TestTriggerLoginHistory{
    @isTest static void testMain(){ 
        Contact cont = new Contact(LastName = 'Test', Login_Name__c = 'test', Login_ID__c = '12345');
        insert cont;
        Login_History__c lh = new Login_History__c(Login_Name__c = 'test', Private_Label_Name__c = 'ABC', Login_History_Id__c = '12345-10', contact__c = cont.Id);        
        insert lh;
    }
}