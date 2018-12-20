@isTest
private class TestKDM_BatchContactChildRecordCount {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchContactChildRecordCount b0 = new KDM_BatchContactChildRecordCount('',false,'',true);
       Database.executeBatch(b0,12);
       Test.stopTest();
       
    }
    static testmethod void test2() {
        
        //Contact
        Contact objContact = new Contact(LastName='Patel',Login_ID__c='100');
        Insert objContact;
        
        Contact objContact2 = new Contact(LastName='Patel2',Login_ID__c='200');
        Insert objContact2;
        
        Contact_Child_Summary__c objCCS = new Contact_Child_Summary__c();
        objCCS.Contact__c = objContact.Id;
        objCCS.ContactId__c = objContact.Id;
        objCCS.Name = objContact.Name;
        Insert objCCS;     
        
        Test.startTest();
        KDM_BatchContactChildRecordCount b1 = new KDM_BatchContactChildRecordCount('',true,'djpatel@openlane.com',false);
        Database.executeBatch(b1,12);
        Test.stopTest();        
        
       
    }
    static testmethod void test3() {
        
        //Contact
        Contact objContact = new Contact(LastName='Patel',Login_ID__c='100');
        Insert objContact;
        
        Contact objContact2 = new Contact(LastName='Patel2',Login_ID__c='200');
        Insert objContact2;
        
        Contact_Child_Summary__c objCCS = new Contact_Child_Summary__c();
        objCCS.Contact__c = objContact.Id;
        objCCS.ContactId__c = objContact.Id;
        objCCS.Name = objContact.Name;
        Insert objCCS;  
        
        Test.startTest();
        KDM_BatchContactChildRecordCount b2 = new KDM_BatchContactChildRecordCount('',true,'djpatel@openlane.com',true);
        Database.executeBatch(b2,5);
        Test.stopTest();
       
    }
}