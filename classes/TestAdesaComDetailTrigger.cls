@isTest private class TestAdesaComDetailTrigger{
    static testMethod void testTrigger(){
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        insert a;
           
        Adesa_com_Detail__c ads1 = new Adesa_com_Detail__c(Name=a.Name, 
                                                          ATC_Organization_ID__c='1111111');
        ads1.Account__c = a.id;
        insert ads1;
        
        // update 
        a.Fax = '123456789';
        update a;
        
        ads1.First_Closed_Purchase_VIN__c = 'ABCDEFG';
        update ads1;
    }
}