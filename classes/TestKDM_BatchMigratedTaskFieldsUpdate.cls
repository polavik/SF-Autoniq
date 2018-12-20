@isTest
private class TestKDM_BatchMigratedTaskFieldsUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchMigratedTaskFieldsUpdate b = new KDM_BatchMigratedTaskFieldsUpdate('2011-08-23T00:00:00Z','2050-12-17T00:00:00Z',true,true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
 
    static testmethod void test5() {
        Test.startTest();
        //UserName
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
        system.debug('------' + ObjUser.Username);
        

        Property__c objProperty1 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        Insert objProperty1 ;  

        Property__c objProperty2 = new Property__c(Property_Id__c='sandbox.suffix',Property_Value__c='');
        Insert objProperty2 ;    
        
                //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='1700');
        Insert acct1;
        
        //Contact
        Contact objContact = new Contact(LastName='Test Contact',Login_ID__c='1700');
        Insert objContact;
        
        //Task      
        Task objTask = new Task();
        objTask.Whoid=objContact.id;
        Insert objTask;
        
                            
        
        //CASE1,2,CASE_MAP
        Case Case1 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Case Case2 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234599',Description='PSI FAILED:Description');
        Insert Case2;
       
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case2.Id;
        Insert obj_OL_KAR_Mapper;
        
        //
        Activity_Detail__c objAD = new Activity_Detail__c();
        objAD.Op_Task_SF_ID__c = objTask.Id;
        objAD.Is_Migration_Details_Applied_to_Task__c=false;
        objAD.Op_CreatedDate__c=datetime.newInstance(2012, 08, 23, 12, 30, 2);//'2012-08-23T00:00:00Z';
        objAD.Is_OwnerId_Applied__c = false;
        objAD.Is_RecordType_Applied__c = false;
        objAD.Is_WhoId_Applied__c = false ;
        objAD.Is_WhatId_Applied__c = false;
        objAD.Op_Account_ATC_ORG_ID__c = '1700';
        objAD.Op_Contact_LOGIN_ID__c='1700';
        objAD.Op_Case_SF_Id__c=Case1.Id;
        objAD.Op_Owner_TYPE__c='User';
        objAD.Op_Owner_USERNAME__c=ObjUser.UserName+'123';//      
        objAD.Op_RecordTypeId__c='RT_ID_0001';
        objAD.Op_RecordType_NAME__c='Sales';
        objAD.Op_WhatId__c='WHAT_ID_0001';
        objAD.Op_WhatType__c='Account';//
        objAD.Op_WhoId__c='WHO_ID';//
        objAD.Op_WhoType__c='Contact';//
        Insert objAD;
        
        objTask.Openlane_Task_SF_ID__c = objTask.Id;
        update objTask;

       
       KDM_BatchMigratedTaskFieldsUpdate b = new KDM_BatchMigratedTaskFieldsUpdate('2011-08-23T00:00:00Z','2050-12-17T00:00:00Z',true,true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
        
    } 

    
    static testmethod void test3() {
        Test.startTest();
        //UserName
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
        system.debug('------' + ObjUser.Username);
        

        
        Property__c objProperty5 = new Property__c(Property_Id__c='migrated.case.default.lead.id',Property_Value__c=ObjUser.Username+'test');
        Insert objProperty5 ;
        
        Property__c objProperty4 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.Username+'test');
        Insert objProperty4 ; 
        
                //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='1700');
        Insert acct1;
        
        //Contact
        Contact objContact = new Contact(LastName='Test Contact',Login_ID__c='1700');
        Insert objContact;
        
        //Task      
        Task objTask = new Task();
        objTask.Whoid=objContact.id;
        Insert objTask;
        
                            
        
        //CASE1,2,CASE_MAP
        Case Case1 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Case Case2 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234599',Description='PSI FAILED:Description');
        Insert Case2;
       
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case2.Id;
        Insert obj_OL_KAR_Mapper;
        
        //
        Activity_Detail__c objAD = new Activity_Detail__c();
        objAD.Op_Task_SF_ID__c = objTask.Id;
        objAD.Is_Migration_Details_Applied_to_Task__c=false;
        objAD.Op_CreatedDate__c=datetime.newInstance(2012, 08, 23, 12, 30, 2);//'2012-08-23T00:00:00Z';
        objAD.Is_OwnerId_Applied__c = false;
        objAD.Is_RecordType_Applied__c = false;
        objAD.Is_WhoId_Applied__c = false ;
        objAD.Is_WhatId_Applied__c = false;
        objAD.Op_Account_ATC_ORG_ID__c = '1700';
        objAD.Op_Contact_LOGIN_ID__c='1700';
        objAD.Op_Case_SF_Id__c=Case1.Id;
        objAD.Op_Owner_TYPE__c='User';
        objAD.Op_Owner_USERNAME__c=ObjUser.UserName;//      
        objAD.Op_RecordTypeId__c='RT_ID_0001';
        objAD.Op_RecordType_NAME__c='Sales';
        objAD.Op_WhatId__c='WHAT_ID_0001';
        objAD.Op_WhatType__c='Account';//
        objAD.Op_WhoId__c='WHO_ID';//
        objAD.Op_WhoType__c='Contact';//
        Insert objAD;
        
        objTask.Openlane_Task_SF_ID__c = objTask.Id;
        update objTask;

       
       KDM_BatchMigratedTaskFieldsUpdate b = new KDM_BatchMigratedTaskFieldsUpdate('2011-08-23T00:00:00Z','2050-12-17T00:00:00Z',true,true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
        
    }    
    static testmethod void test2() {
        
        //UserName
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
        
        Property__c objProperty5 = new Property__c(Property_Id__c='migrated.case.default.lead.id',Property_Value__c=ObjUser.Username);
        Insert objProperty5 ;
        
        Property__c objProperty4 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.Username);
        Insert objProperty4 ;  
        
        Property__c objProperty1 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        Insert objProperty1 ;  

        Property__c objProperty2 = new Property__c(Property_Id__c='sandbox.suffix',Property_Value__c='');
        Insert objProperty2 ;       
        
        
        // Task Trigger  Property 
        Property__c objProperty3 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='YES');
        insert objProperty3 ;     
        
        //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='1700');
        Insert acct1;
        
        //Contact
        Contact objContact = new Contact(LastName='Test Contact',Login_ID__c='1700');
        Insert objContact;
        
        //Task      
        Task objTask = new Task();
        objTask.Whoid=objContact.id;
        Insert objTask;
        
                            
        
        //CASE1,2,CASE_MAP
        Case Case1 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Case Case2 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case2;
       
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case2.Id;
        Insert obj_OL_KAR_Mapper;
        
        //
              
        Activity_Detail__c objAD = new Activity_Detail__c();
        objAD.Op_Task_SF_ID__c = objTask.Id;
        objAD.Is_Migration_Details_Applied_to_Task__c=false;
        objAD.Op_CreatedDate__c=datetime.newInstance(2012, 08, 23, 12, 30, 2);//'2012-08-23T00:00:00Z';
        objAD.Is_OwnerId_Applied__c = false;
        objAD.Is_RecordType_Applied__c = false;
        objAD.Is_WhoId_Applied__c = false ;
        objAD.Is_WhatId_Applied__c = false;
        objAD.Op_Account_ATC_ORG_ID__c = '1700';
        objAD.Op_Contact_LOGIN_ID__c='1700';
        objAD.Op_Case_SF_Id__c=Case1.Id;
        objAD.Op_Owner_TYPE__c='User';
        objAD.Op_Owner_USERNAME__c=ObjUser.UserName;//      
        objAD.Op_RecordTypeId__c='RT_ID_0001';
        objAD.Op_RecordType_NAME__c='Sales';
        objAD.Op_WhatId__c='WHAT_ID_0001';
        objAD.Op_WhatType__c='Account';//
        objAD.Op_WhoId__c='WHO_ID';//
        objAD.Op_WhoType__c='Contact';//
        Insert objAD;
        
        objTask.Openlane_Task_SF_ID__c = objTask.Id;
        update objTask;

       Test.startTest();
       KDM_BatchMigratedTaskFieldsUpdate b = new KDM_BatchMigratedTaskFieldsUpdate('2011-08-23T00:00:00Z','2050-12-17T00:00:00Z',true,true,'Dipesh.Patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}