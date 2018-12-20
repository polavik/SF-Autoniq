@isTest
private class TestKDM_BatchDTSCFieldsUpdate{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchDTSCFieldsUpdate objKDM_BatchDTSCFieldsUpdate = new KDM_BatchDTSCFieldsUpdate('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchDTSCFieldsUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
        insert objProperty1 ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        insert objProperty2 ;   
        
        Property__c objProperty3 = new Property__c(Property_Id__c='username.suffix',Property_Value__c='');
        insert objProperty3 ;   
        
        Daily_Transactional_DC_Rep_Stats__c objDTSC = new Daily_Transactional_DC_Rep_Stats__c(                               
                                Op_DC_Sales_Rep_Username__c = UserName,                               
                                Op_Load__c=1                                                               
                            );
       insert objDTSC; 
        
        
       Test.startTest();
       KDM_BatchDTSCFieldsUpdate objKDM_BatchDTSCFieldsUpdate = new KDM_BatchDTSCFieldsUpdate(' where Op_Load__c=1',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchDTSCFieldsUpdate);
       Test.stopTest();
       
    }
    static testmethod void test3() {    
       
       String UserId = UserInfo.getUserId();
       String UserName = UserInfo.getUserName();
       
       Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
        insert objProperty1 ; 
      
        
        Daily_Transactional_DC_Rep_Stats__c objDTSC = new Daily_Transactional_DC_Rep_Stats__c(                               
                                Op_DC_Sales_Rep_Username__c = UserName,                               
                                Op_Load__c=1                                                               
                            );
       insert objDTSC; 
        
        
       Test.startTest();
       KDM_BatchDTSCFieldsUpdate objKDM_BatchDTSCFieldsUpdate = new KDM_BatchDTSCFieldsUpdate(' where Op_Load__c=1',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchDTSCFieldsUpdate);
       Test.stopTest();
       
    }
    
}