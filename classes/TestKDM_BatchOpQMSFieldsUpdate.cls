@isTest
private class TestKDM_BatchOpQMSFieldsUpdate{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpQMSFieldsUpdate objKDM_BatchOpQMSFieldsUpdate = new KDM_BatchOpQMSFieldsUpdate('',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchOpQMSFieldsUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
        insert objProperty1 ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='username.patch',Property_Value__c='.kar@');
        insert objProperty2 ;   
        
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='170');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
       Insert Adesa1;
        
       Quality_Measurement_System__c objQSM = new Quality_Measurement_System__c(
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Account_Manager_USERNAME__c = UserName,
                                Op_CC_Rep_USERNAME__c = UserName,
                                Op_RecordType_NAME__c = 'abc',
                                Is_Migrated_Record__c = true,
                                Op_Load__c=1                                                               
                            );
       insert objQSM; 
        
        
       Test.startTest();
       KDM_BatchOpQMSFieldsUpdate objKDM_BatchOpQMSFieldsUpdate = new KDM_BatchOpQMSFieldsUpdate('and Op_Load__c=1',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchOpQMSFieldsUpdate);
       Test.stopTest();
       
    }
    static testmethod void test3() {
    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
       insert objProperty1 ; 
       
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='170');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
       Insert Adesa1;
        
       Quality_Measurement_System__c objQSM = new Quality_Measurement_System__c(
                                Op_Account_ATC_ORG_ID__c = '100',
                                Op_Account_Manager_USERNAME__c = UserName,
                                Op_CC_Rep_USERNAME__c = UserName,
                                Op_RecordType_NAME__c = 'abc',
                                Is_Migrated_Record__c = true,
                                Op_Load__c=1                                                               
                            );
       insert objQSM; 
        
        
       Test.startTest();
       KDM_BatchOpQMSFieldsUpdate objKDM_BatchOpQMSFieldsUpdate = new KDM_BatchOpQMSFieldsUpdate('and Op_Load__c=1',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchOpQMSFieldsUpdate);
       Test.stopTest();
       
    }
}