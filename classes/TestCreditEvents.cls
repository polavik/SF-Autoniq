/*******************************************************************************************
*   Author: Modern Apple
*   Purpose: Test class for the creditEvents trigger.
*
*   Date of Change          Author                  Change Summary
*   ---------------------   ---------------------   ---------------------------------------
*   12/02/2016              Rick May                Initial development.
*******************************************************************************************/

@isTest
private class TestCreditEvents {

    static testMethod void myUnitTest() {
        list<Credit_Event__c> insertCreditEvents = new list<Credit_Event__c>();
        
        Account testAcct = new Account();
        testAcct.Name = 'Test Account';
        testAcct.AFC_Dealer_ID__c = '123456';
        
        insert testAcct;
        
        AFC_Contracts__c testContract = new AFC_Contracts__c(Account__c = testAcct.id, AFC_Dealer_ID__c='123456');
        insert testContract;


        Contact testCont = new Contact();
        testCont.AccountId = testAcct.Id;
        testCont.FirstName = 'Test';
        testCont.LastName = 'Contact';
        testCont.SSN__c = '123456789';
        
        insert testCont;
        
        Credit_Event__c testCredEvent1 = new Credit_Event__c();
        testCredEvent1.Dealer_ID__c = '123456';
        testCredEvent1.Social_Security_Number__c = '123456789';
        testCredEvent1.FICO_Auto_Score_5_NF__c = '95';
        testCredEvent1.Date__c = system.today();
        insertCreditEvents.add(testCredEvent1);
        
        Credit_Event__c testCredEvent2 = new Credit_Event__c();
        testCredEvent2.Dealer_ID__c = '123456';
        testCredEvent2.Social_Security_Number__c = '123456789';
        testCredEvent2.FICO_Auto_Score_5_NF__c = '59';
        testCredEvent2.Date__c = system.today();
        insertCreditEvents.add(testCredEvent2);
        
        Credit_Event__c testCredEvent3 = new Credit_Event__c();
        testCredEvent3.Dealer_ID__c = '123456';
        testCredEvent3.Social_Security_Number__c = '123456789';
        testCredEvent3.Date__c = system.today();
        testCredEvent3.Guarantor__c = 'Test Guarantor';
        testCredEvent3.X60_Day_Delinquency__c = true;
        testCredEvent3.Judgement__c = true;
        insertCreditEvents.add(testCredEvent3);
        
        Credit_Event__c testCredEvent4 = new Credit_Event__c();
        testCredEvent4.Dealer_ID__c = '123456';
        testCredEvent4.Social_Security_Number__c = '123456789';
        testCredEvent4.Date__c = system.today();
        testCredEvent4.Guarantor__c = 'Test Guarantor 2';
        testCredEvent4.X60_Day_Delinquency__c = false;
        testCredEvent4.Judgement__c = true;
        insertCreditEvents.add(testCredEvent4);
        
        insert insertCreditEvents;
        
        Credit_Event__c checkCredEvent1 = [select Account__c, Contact__c, Type__c, AFC_Contract__c from Credit_Event__c where Id =: testCredEvent1.Id];
        system.assertEquals(checkCredEvent1.AFC_Contract__c, testContract.id);
        system.assertEquals(checkCredEvent1.Contact__c, testCont.Id);
        system.assertEquals(checkCredEvent1.Type__c, 'Equifax');
        
        Credit_Event__c checkCredEvent2 = [select Account__c, Contact__c, Type__c, AFC_Contract__c from Credit_Event__c where Id =: testCredEvent2.Id];
        system.assertEquals(checkCredEvent2.AFC_Contract__c, testContract.id);
        system.assertEquals(checkCredEvent2.Contact__c, testCont.Id);
        system.assertEquals(checkCredEvent2.Type__c, 'Equifax');
        
        Credit_Event__c checkCredEvent3 = [select Account__c, Contact__c, Type__c, AFC_Contract__c from Credit_Event__c where Id =: testCredEvent3.Id];
        system.assertEquals(checkCredEvent3.AFC_Contract__c, testContract.id);
        system.assertEquals(checkCredEvent3.Contact__c, testCont.Id);
        system.assertEquals(checkCredEvent3.Type__c, 'TransUnion');
        
        Credit_Event__c checkCredEvent4 = [select Account__c, Contact__c, Type__c, AFC_Contract__c from Credit_Event__c where Id =: testCredEvent4.Id];
        system.assertEquals(checkCredEvent4.AFC_Contract__c, testContract.id);
        system.assertEquals(checkCredEvent4.Contact__c, testCont.Id);
        system.assertEquals(checkCredEvent4.Type__c, 'TransUnion');
    }
}