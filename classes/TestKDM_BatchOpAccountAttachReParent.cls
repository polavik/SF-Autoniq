@isTest
private class TestKDM_BatchOpAccountAttachReParent {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpAccountAttachReParent b = new KDM_BatchOpAccountAttachReParent('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    static testmethod void test2() {
              
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;
        
        Adesa_com_Detail__c Adesa2 = new Adesa_com_Detail__c(Name='Adesa2',ATC_Organization_ID__c='200',Account__c=acct1.Id);
        Insert Adesa2;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Attachment';
        objAttachment.ParentId = Adesa1.Id;//
        objAttachment.body = Blob.valueOf('Unit Test Attachment Body');
        Insert objAttachment;
        
        Openlane_Attachments__c objOpAttachment = new Openlane_Attachments__c();
        objOpAttachment.Attachment_KAR_Id__c = objAttachment.Id;
        objOpAttachment.Attachment_OL_ParentId__c = acct1.Id;//
        objOpAttachment.AttachmentParent_KAR_AdesaComDetail_Id__c = Adesa2.Id;//
        
        Insert objOpAttachment;

       Test.startTest();
        KDM_BatchOpAccountAttachReParent b = new KDM_BatchOpAccountAttachReParent('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}