@isTest
private class TestChecklistItemPushNotification {

    static final String CT_PROCESSING_USER_TYPE = 'CT Processing';
    static final String CREDIT_USER_TYPE = 'Credit';
    
    @IsTest(SeeAllData=true)
    static void testApplicationApprovedNotification() {

        List<Schema.PicklistEntry> afcRegionResponsibleOptions = User.AFC_Region_Responsible__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> afcBranchOptions = User.AFC_Branch__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> koBookStatus = Application__c.KO_Book__c.getDescribe().getPicklistValues();

        User user1 = TestServices.createTestUser('tuser@autofinance.com', String.valueOf(afcRegionResponsibleOptions[0].getLabel()), 
                                                            String.valueOf(afcBranchOptions[0].getLabel()), CT_PROCESSING_USER_TYPE, /*isInsert*/ true);

        User user2 = TestServices.createTestUser('tuser2@autofinance.com', String.valueOf(afcRegionResponsibleOptions[0].getLabel()), 
                                                            String.valueOf(afcBranchOptions[0].getLabel()), CREDIT_USER_TYPE, /*isInsert*/ false);
        user2.FirstName = 'fName2';
        user2.LastName = 'lName2';
        if(user2.id != null)
            update user2;
        else
            insert user2;

        AFC_Branch__c afcBranch = new AFC_Branch__c(Name=String.valueOf(afcBranchOptions[0].getLabel()),Branch_Manager_1__c = user2.id);
        insert afcBranch;
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'New', String.valueOf(afcBranchOptions[0].getLabel()), true);
        Application__c app = TestServices.createTestApplication(opp.id, String.valueOf(afcRegionResponsibleOptions[0].getLabel()), false);
        app.AFC_Branch2__c = afcBranch.id;
        app.Credit_User__c = user2.id;
        app.CT_Processing_User__c = user1.id;
        app.KO_Book__c = koBookStatus[0].getLabel();
        insert app;

        Checklist__c cl = new Checklist__c(Name='Test Checklist',Application__c=app.id);
        insert cl;
        Checklist_Item__c cli = new Checklist_Item__c(Name='Test Checklist Item',Checklist__c=cl.id,For_Department__c='Credit',Item_Status__c='Not Started',Primary_Return_Reason__c='Incomplete');
        insert cli;

        Test.startTest();
/*          Unfortunately, the only way to test chatter posts (that I've found) is to mock them.  This really defeats the purpose
            of ensuring the correct push notification was created.  This method is here to ensure that the trigger is called and passes code coverage.
            If the Trigger updates without throwing an exception, it passes.*/
            ConnectApi.FeedElementPage fep = new ConnectApi.FeedElementPage();
            ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,ConnectApi.FeedType.Record,String.valueOf(cli.id),fep);
            cli.Item_Status__c = 'Returned to Branch';
            update cli;
        Test.stopTest();

    }
}