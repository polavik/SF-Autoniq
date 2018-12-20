@isTest
public with sharing class TestTriggerAfcContracts {

    static testMethod void testRefreshAccountFields(){
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        upsert a;
        
        AFC_Contracts__c b = new AFC_Contracts__c(Name='Test1',Source_Id__c='Test1',PLN__c=True,CONTRACT_STATUS__c= 'ACTIVE',Account__c=a.Id,Contract_ID__c ='Test1');
        upsert b;        
    }

}