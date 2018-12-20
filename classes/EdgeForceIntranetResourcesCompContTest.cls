/*******************************************************************************
Created By     :   Suraj Rajoria(Appirio Offshore)
Date           :   15 Dec 2012
Description    :   To test resource component page
Class Name     :   IntranetResourcesComponentContTest
*******************************************************************************/
@isTest //(seeAllData = true)
public class EdgeForceIntranetResourcesCompContTest {

    @testSetup static void dataSetup() {
        Group g = new Group(Name='TestGroup');
        insert g;
        GroupMember gm = new GroupMember(GroupId = g.Id, UserOrGroupId = UserInfo.getUserId());
        insert gm;
    }

    static testMethod void testContentLibAsCMSPageObj() {
        Intranet_Content_Buckets__c bucket = IntranetTestUtility.createContentBucket('Test Bucket', 'TestGroup', 'TestGroup', true);
        Intranet_Content__c cmsPage = IntranetTestUtility.createIntranetContent('Intranet CMS Pages', null, 'TestTeam', false);
        cmsPage.Content_Bucket__c = bucket.Id;
        cmsPage.Template__c = 'Team';
        insert cmsPage;
            
        //create ContentVersion instance
        ContentVersion doc = new ContentVersion();
        Blob beforeblob = Blob.valueOf('Testing base 64 encode');
        doc.VersionData = beforeblob;
        doc.Title = 'TestTitle';
        doc.PathOnClient = 'xyz';
        doc.Team__c = 'TestTeam';
        doc.Team_Category__c = 'TestCategory';  
        doc.Language_Custom__c = 'English';
        insert doc;
        
        System.assert(doc.Id != null);
        
        Test.setCurrentPage(Page.KAR_Team);
        ApexPages.currentPage().getParameters().put('name','TestTeam');
        EdgeForceIntranetResourcesCompController intraResource = new EdgeForceIntranetResourcesCompController();

        System.assertNotEquals(0,intraResource.langLibraries.size());

        ApexPages.currentPage().getParameters().put('resourceIdParam',doc.Id);
        intraResource.processContent();
    }
}