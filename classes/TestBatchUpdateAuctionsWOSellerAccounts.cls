@isTest
private class TestBatchUpdateAuctionsWOSellerAccounts {
    public static testMethod void testBatch() {


    
         Test.StartTest();
         
            Property__c p = new Property__c();
            p.Name = 'Batch Notifications Email';
            p.Property_Id__c = 'batch.notifications.email';
            p.Property_Value__c = 'salesforceemails@openlane.com';
            insert p;
         
         BatchUpdateAuctionsWOSellerAccounts batchJob = new BatchUpdateAuctionsWOSellerAccounts();
         batchJob.query =
        'SELECT Id, Seller_Account__c ' +
        'FROM Auction__c ' +
        'WHERE Seller_Account__c = NULL';
         ID batchprocessid = Database.executeBatch(batchJob);
         Test.StopTest();
     }  
 
}