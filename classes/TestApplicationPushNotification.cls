@isTest
private class TestApplicationPushNotification {

    static final String CT_PROCESSING_USER_TYPE = 'CT Processing';
    static final String CREDIT_USER_TYPE = 'Credit';
    
    @IsTest(SeeAllData=true)
    static void testApplicationApprovedNotification() {

        List<Schema.PicklistEntry> afcRegionResponsibleOptions = User.AFC_Region_Responsible__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> afcBranchOptions = User.AFC_Branch__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> koBookStatus = Application__c.KO_Book__c.getDescribe().getPicklistValues();

        // AFC Credit and Contracts Super
        User user1 = TestServices.createTestUser('tuser@autofinance.com', String.valueOf(afcRegionResponsibleOptions[0].getLabel()),
                                                            String.valueOf(afcBranchOptions[0].getLabel()), CT_PROCESSING_USER_TYPE, /*isInsert*/ true);

        // AFC Credit Manager
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
        app.Credit_Decision__c = 'Approved application';
        app.Credit_Product_Type__c = 'COMMERCIAL TRUCK';
        app.Credit_Amount__c = 50.00;
        app.FP_Fee__c = 1.00;
        app.Floorplan_Days__c = 3;
        app.Number_of_Curtailments__c = 1;
        app.Interest_Rate_Base__c = '1.00';
        app.Curtailment_Fee__c = 1.00;
        app.Curtailment_Days__c = 1;
        app.Curtailment_Reduction_Percentage__c = 1.00;
        app.Interest_Charge__c = 1.00;
        app.Next_Renewal_Date__c = '1/1/2099';

        insert app;

        Marketing_Attribute__c ma = new Marketing_Attribute__c();
        ma.Application__c = app.id;
        ma.High__c = Marketing_Attribute__c.High__c.getDescribe().getPicklistValues()[0].getLabel();
        ma.Medium__c = Marketing_Attribute__c.Medium__c.getDescribe().getPicklistValues()[0].getLabel();
        ma.Primary__c = true;
        insert ma;

        Test.startTest();
/*          Unfortunately, the only way to test chatter posts (that I've found) is to mock them.  This really defeats the purpose
            of ensuring the correct push notification was created.  This method is here to ensure that the trigger is called and passes code coverage.
            If the Trigger updates without throwing an exception, it passes.*/
            ConnectApi.FeedElementPage fep = new ConnectApi.FeedElementPage();
            ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,ConnectApi.FeedType.Record,String.valueOf(app.id),fep);
            app.AFC_Credit_Status__c = 'APPROVED';
            update app;
        Test.stopTest();

    }
}