@isTest
private class TestBatchCaseRelatedObjectUpdate{

    static testmethod void test1() {
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());      
       Test.startTest();
       BatchCaseRelatedObjectUpdate b = new BatchCaseRelatedObjectUpdate('',true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    static testmethod void test2() {
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
        
        Contact Contact1 = new Contact(LastName='Patel',AccountId=acct1.Id);
        Insert Contact1;
        
        Purchase__c Purchase1 = new Purchase__c(Name='Purchase1',Source_Id__c='OL');
        Insert Purchase1;
        
        Case Case1 = new Case(Status='New',Claim_Resolution__c='Void',Type='Problem',VIN__c=Purchase1.Id,Inspection_Company_Responsibility__c='No',contactid=Contact1.id,AccountId=acct1.id,Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Case Case2 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case2;
        
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case2.Id;
        Insert obj_OL_KAR_Mapper;
        
        Temp_Case_Comment__c objTCC = new Temp_Case_Comment__c(CommentBody__c='Test Body',IsPublished__c=true,ParentId__c=Case1.Id);
        Insert objTCC;
        
        Contact objContact = new Contact(LastName='Patel',Login_ID__c='100');
        Insert objContact;
        
        //Task objTask = new Task(Whoid=objContact.id ,Migrated_Openlane_Case_Original_id__c=Case1.Id);
        //Insert objTask;
        
        
        
        Action_Package__c objAP = new Action_Package__c(Migrated_Openlane_Case_Original_id__c=Case1.Id,Case__c=Case1.Id);
        Insert objAP;
        
        Evidence_Request__c objER = new Evidence_Request__c(Case__c=Case2.Id,Migrated_Openlane_Case_Original_id__c=Case1.Id);
        Insert objER;
        
        Case_Escalation__c objCE = new Case_Escalation__c(Migrated_Openlane_Case_Original_id__c=Case1.Id);
        Insert objCE;
     
       Test.startTest();
       BatchCaseRelatedObjectUpdate b = new BatchCaseRelatedObjectUpdate('',true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}