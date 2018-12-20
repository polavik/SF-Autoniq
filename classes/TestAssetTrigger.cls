@isTest
private class TestAssetTrigger {

    static testMethod void myUnitTest() {
        
      
        
        Asset__c a = new Asset__c(Name='VIN1234567980Test', Source_Id__c='OL-123456789', Vehicle_Id__c ='123456789');
        // Asset
        insert a;       
           
        
        
    }
}