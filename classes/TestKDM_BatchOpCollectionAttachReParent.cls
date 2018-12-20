@isTest
private class TestKDM_BatchOpCollectionAttachReParent {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpCollectionAttachReParent b = new KDM_BatchOpCollectionAttachReParent(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
              
        
        
        Account a = new Account();
        a.Name = 'Test Account1';
        a.Master_Index__c = '9998777766';
        insert a;
        
        Collection__c c = new Collection__c();
        c.Name = 'Test Collection1';
        c.Account__c = a.Id;
        c.Organization_Id__c = '9998777766';
        insert c;
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test Attachment';
        objAttachment.ParentId = c.Id;
        objAttachment.body = Blob.valueOf('Unit Test Attachment Body');
        Insert objAttachment;
        
        Openlane_Attachments__c objOpAttachment = new Openlane_Attachments__c();
        objOpAttachment.Attachment_KAR_Id__c = objAttachment.Id;
        objOpAttachment.Attachment_OL_ParentId__c = c.Id;
        objOpAttachment.Attachment_KAR_ParentId__c = c.Id;
        Insert objOpAttachment;

       Test.startTest();
       KDM_BatchOpCollectionAttachReParent b = new KDM_BatchOpCollectionAttachReParent(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}