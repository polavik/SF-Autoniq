@isTest
private class TestKDM_BatchOpCaseAttachReParent {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpCaseAttachReParent b = new KDM_BatchOpCaseAttachReParent('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    static testmethod void test2() {
              
      
        
        Case Case1 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567', Description='PSI FAILED:Description');
        Insert Case1;
        
        Case Case2 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567', Description='PSI FAILED:Description');
        Insert Case2;
        
        Case CaseTemp = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=false,Openlane_Case_Owner_TYPE__c='User',Vehicle_Identification_Number__c='12345678901234567', Description='PSI FAILED:Description');
        Insert CaseTemp;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Attachment';
        objAttachment.ParentId = CaseTemp.Id;
        objAttachment.body = Blob.valueOf('Unit Test Attachment Body');
        Insert objAttachment;
        
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
       
        Property__c objProperty = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.Username);
        insert objProperty ;  
        
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case2.Id;
        Insert obj_OL_KAR_Mapper;
        
        Openlane_Attachments__c objOpAttachment = new Openlane_Attachments__c();
        objOpAttachment.Attachment_KAR_Id__c = objAttachment.Id;
        objOpAttachment.Attachment_OL_ParentId__c = Case1.Id;
        Insert objOpAttachment;

       Test.startTest();
       KDM_BatchOpCaseAttachReParent b = new KDM_BatchOpCaseAttachReParent('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}