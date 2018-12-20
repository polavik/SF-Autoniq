@isTest
private class TestKDM_BatchOpAttachReParentToAccount {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpAttachReParentAdesaToAccount b = new KDM_BatchOpAttachReParentAdesaToAccount(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
              
        Account acct1 = new Account();
        acct1.Name = 'Test Account1';
        acct1.Master_Index__c = '9998777766';
        insert acct1;
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='9998777766',Account__c=acct1.Id);
        Insert Adesa1;      
       
            
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Attachment';
        objAttachment.ParentId = Adesa1.Id;
        objAttachment.body = Blob.valueOf('Unit Test Attachment Body');
        
        Insert objAttachment;
        
        Openlane_Attachments__c objOpAttachment = new Openlane_Attachments__c();
        objOpAttachment.Attachment_KAR_Id__c = objAttachment.Id;
        objOpAttachment.Attachment_OL_ParentId__c = acct1.Id;
        objOpAttachment.Attachment_KAR_ParentId__c = Adesa1.Id;
        objOpAttachment.Attachment_KAR_Id2__c = objAttachment.Id;
        objOpAttachment.Is_ReParented__c = true;
        objOpAttachment.AttachmentParent_KAR_AdesaComDetail_Id__c = Adesa1.Id;
        Insert objOpAttachment;

       Test.startTest();
       KDM_BatchOpAttachReParentAdesaToAccount b = new KDM_BatchOpAttachReParentAdesaToAccount(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}