@isTest
private class TestRelatedADCContact {

    static testMethod void myUnitTest() {
    
        Account a = new Account(Name='Test ADC Account');
        insert a; 
        
        Adesa_com_Detail__c adc = new Adesa_com_Detail__c(Name='Test ADC', Account__c = a.id);
        insert adc; 
               
        Contact con = new Contact(LastName='Mr. Anderson', Master_Index__c='112232123');
        insert con;       
        
        Related_Adesa_com_Contact__c rAdc = new Related_Adesa_com_Contact__c (Name='RelatedContactTest', Master_Index_ID__c ='112232123', Adesa_com__c = adc.id);
        insert rAdc;
    
    }
}