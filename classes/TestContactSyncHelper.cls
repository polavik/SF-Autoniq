@isTest
private class TestContactSyncHelper {
    
    static testMethod void myUnitTest() {


        List<Account> AcList = new List<Account>();
        Contact Cnt1 = new Contact( LastName='lastName1',FirstName='FirstName1', Location__c='ADESA New Jersey;ADESA PA;ADESA Pittsburgh;ADESA Washington DC;ADESA Mercer' , Email= '12345@hotmail.com', Sync_Contact__c=True,Active__c= True );
        insert Cnt1;

        Contact Cnt2 = new Contact( LastName='lastName2',FirstName='FirstName2', Location__c='ADESA New Jersey;ADESA PA;ADESA Pittsburgh;ADESA Mercer' , Email= '4567@hotmail.com', Sync_Contact__c=False ,Active__c= True );
        insert Cnt2;

        Contact Cnt3 = new Contact( LastName='lastName3',FirstName='FirstName3', Location__c='ADESA PA;ADESA Pittsburgh;ADESA Mercer' , Email= '8910@hotmail.com', Sync_Contact__c=False ,Active__c= True );
        insert Cnt3;

        
       String strEmail  ;
       String strLocationList;
        strEmail   = '12345@hotmail.com,4567@hotmail.com';
        
         ContactSyncHelper updateHelper = new ContactSyncHelper();
        
        
       updateHelper.UpdateContactList(strEmail, strLocationList);
       
    strEmail   = '8910@hotmail.com,4567@hotmail.com,12345@hotmail.com';
       updateHelper.UpdateContactList(strEmail, strLocationList);
        
        

        
    }
}