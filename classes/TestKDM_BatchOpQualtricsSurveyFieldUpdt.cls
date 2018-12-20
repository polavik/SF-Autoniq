@isTest
private class TestKDM_BatchOpQualtricsSurveyFieldUpdt {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpQualtricsSurveyFieldUpdate b = new KDM_BatchOpQualtricsSurveyFieldUpdate('',false,'');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    static testmethod void test2() {
        
        //Contact
        Contact objContact = new Contact(LastName='Patel',Login_ID__c='100');
        Insert objContact;
        
        //
              
        Qualtrics_Survey__c objQS = new Qualtrics_Survey__c();          
        objQS.Op_RecordType_NAME__c='CC CSI Survey';
        objQS.Op_Contact_LOGIN_ID__c='100';        
        objQS.Op_Load__c=1;        
        Insert objQS;

        Test.startTest();
        KDM_BatchOpQualtricsSurveyFieldUpdate b = new KDM_BatchOpQualtricsSurveyFieldUpdate('WHERE Op_Load__c=1',true,'djpatel@openlane.com');
        Database.executeBatch(b);
        Test.stopTest();
       
    }
}