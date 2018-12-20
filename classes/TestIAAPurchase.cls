@isTest
private class TestIAAPurchase {    
    static testMethod void myUnitTest() {
            Account a = new Account(Name='test',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
            upsert a;        
            Purchase__c purch = new Purchase__c();        
            purch.Purchase_Type__c = 'IAA'; 
            purch.Home_Branch__c = 'IAA';
            //purch.Account__c = a.id;   
            purch.IAA_Buyer_Name__c = 'IAA';   
            purch.Source_Id__c = '567';      
            insert purch;  
    }}