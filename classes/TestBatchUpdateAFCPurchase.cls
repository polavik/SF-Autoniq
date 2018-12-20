@isTest private class TestBatchUpdateAFCPurchase {

      
    static testMethod void testBatch() {
    
     List<Purchase__c> PurchaseList = new List<Purchase__c>();             
     PurchaseList = TestUtility.createPurchaseForAFCUpdate('Purchase' , 'abc' , 150);
                    

     Test.StartTest(); 



     BatchUpdateAFCPurchase b = new BatchUpdateAFCPurchase(); 
     List<sObject> listObj = new List<sObject>();      
     Database.executeBatch(b); 
     b.execute(null, listObj);
     b.execute(null); 

     Test.StopTest();     
 }
 }