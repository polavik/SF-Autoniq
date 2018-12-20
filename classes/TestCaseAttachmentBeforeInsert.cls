@isTest
private class TestCaseAttachmentBeforeInsert {

    static testMethod void myUnitTest() {
        
        //This is the setup
          
        User testUser = new User();
            
        testUser.Username = 'mrawesome@openlane.com';
        testUser.Email = 'mrawesome@openlane.com';
        
        testUser.FirstName = 'Mr';
        testUser.LastName = 'Awesome';
        testUser.CommunityNickname = 'mrawesome';
        
        testUser.Alias = 'mrawe';
        
        // 'Standard User' Profile Id
        //FIXME: testUser.ProfileId = '00e60000000oMqC';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Max_Approval_Amount__c = 1000;
        
        //FIXME: insert testUser;
        
        Account testAccount = new Account(
        Name='Test Case Attachment',
       // ATC_Organization_Id__c='ACB1234',
        OwnerId = testUser.Id);
        
        Purchase__c p = new Purchase__c
        (
            Name = 'JNKCV54E33M212902', 
            Vehicle_Id__c = '99886102',
            Source_Id__c = '99886102',
            Handles_Payment__c = 'Y', 
            Actual_Dropoff__c = Date.today(), 
            Transport_Preference__c = 'OPENLANE Arranged', 
            sale_Class__c = 'Closed - Grounding Dealer', 
            ATC_Sale_Date__c = Date.today()
        );
        insert p;
        
        Case testCase = new Case(
        VIN__c = p.Id,
        Type = 'Arbitration',
        Description='asdf',
        Reason='Undisclosed Damages',
        Status = 'New',
        OwnerId = testUser.Id);
        //FIXME: insert testCase;
        
        //This is the actual test

        blob blobby = Crypto.generateAesKey(256);
        
        Attachment testAttachment = new Attachment(
        ParentId = testCase.Id,
        Name = 'testAttachment',
        Body = blobby);
        //FIXME: insert testAttachment;
        
        
    }
}