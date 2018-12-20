/**
  * Apex Class: EF_ShareWithViewersPublicGroupsTest
  * Description: Test class for EF_ShareWithViewersPublicGroups
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016

  ********** Revision History **********************************************
  * Modified By:        Justin Hawkins
  * Modified Date:      08/11/2017
  * Change Description: Increased record creation to stress test the trigger
  *
*/
@isTest
private class EF_ShareWithViewersPublicGroupsTest {


    @testSetup
    static void setupData()
    {

        User testUser = IntranetTestUtility.createUser(0, true);
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Intranet_Site_Manager' LIMIT 1];
		insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = testUser.Id);

		Group tg1 = new Group(name='Test Intranet System Admins');
		Group tg2 = new Group(name='Test Intranet All Users');
        Group tg3 = new Group(name='Test Intranet Content Admins');
        Group tg4 = new Group(name='Test Information Technology Admins');
		insert new List<Group>{tg1, tg2, tg3, tg4};

        System.runAs(testUser)
        {
            // Create 200 buckets to stress trigger execution
            List<Intranet_Content_Buckets__c> buckets = new List<Intranet_Content_Buckets__c>();
            for(Integer i = 0; i < 200; i++)
            {
                Intranet_Content_Buckets__c icb = IntranetTestUtility.createContentBucket('Test Bucket ' + i, 'Test Intranet System Admins', 'Test Intranet Content Admins', false);
                buckets.add(icb);
            }
            insert buckets;

            List<Intranet_Content__c> contents = new List<Intranet_Content__c>();
            Integer index = 0;
            for(Intranet_Content_Buckets__c bucket : buckets)
            {
                Intranet_Content__c article = IntranetTestUtility.createIntranetContent('Intranet Article', null, 'Test Article' + index, false);
                article.Content_Bucket__c = bucket.Id;
                contents.add(article);
                ++index;
            }
            insert contents;
        }
        
    }
    
    @isTest
	static void testContentShare() {		

        Map<String, String> groupToAccessMap = new Map<String, String>();
        groupToAccessMap.put('Test Intranet Content Admins', 'Edit');
        groupToAccessMap.put('Test Intranet System Admins', 'Edit');
        groupToAccessMap.put('Test Information Technology Admins', 'Edit');
        groupToAccessMap.put('Test Intranet All Users', 'Read');
        groupToAccessMap.put('All Internal Users - Default', 'Read');
        Map<Id, Group> groupMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Name IN :groupToAccessMap.keySet() OR DeveloperName = 'AllInternalUsers']);

        //Map<Id, Intranet_Content__c> contentIdMap = new Map<Id, Intranet_Content__c>(contents);
		Map<Id, Intranet_Content__c> contentIdMap = new Map<Id, Intranet_Content__c>([SELECT Id FROM Intranet_Content__c]);
        List<Intranet_Content_Buckets__c> buckets = [SELECT Id, Viewers__c, Permission_Groups__c FROM Intranet_Content_Buckets__c];
        
        Test.startTest();

        // First Test: Add groups to the content buckets permissions and make sure the right access level is granted for the group
        for(Intranet_Content_Buckets__c bucket : buckets)
        {
            bucket.Viewers__c = 'Test Intranet All Users';
            bucket.Permission_Groups__c = 'Test Intranet Content Admins;Test Intranet System Admins;Test Information Technology Admins';
        }

        update buckets;

        List<Intranet_Content__Share> contentShares = [SELECT Id,  UserOrGroup.Name, AccessLevel, ParentId FROM Intranet_Content__Share
                                                                                                            WHERE RowCause = 'Manual'
                                                                                                            AND ParentId IN :contentIdMap.keySet()
                                                                                                            AND UserOrGroupId IN :groupMap.keySet()];

        System.assert(!contentShares.isEmpty(), 'Intranet Content Shares were not created for the Intranet All Users group');

        for(Intranet_Content__Share contentShare : contentShares)
        {
            if(groupToAccessMap.containsKey(contentShare.UserOrGroup.Name))
            {
                system.assertEquals(groupToAccessMap.get(contentShare.UserOrGroup.Name), contentShare.AccessLevel, 'The access level was not set correctly for the ' + contentShare.UserOrGroup.Name + ' Group');
            }
                
        }

        // Second Test: Remove groups from viewers and admins buckets and make sure the shares were removed
        for(Intranet_Content_Buckets__c bucket : buckets)
        {
            bucket.Viewers__c = 'All Internal Users - Default';
            bucket.Permission_Groups__c = 'Test Intranet Content Admins;Test Intranet System Admins';
        }

        update buckets;

        contentShares = [SELECT Id,  UserOrGroup.Name, AccessLevel, ParentId FROM Intranet_Content__Share
                                                                                WHERE RowCause = 'Manual'
                                                                                AND ParentId IN :contentIdMap.keySet()
                                                                                AND UserOrGroupId IN :groupMap.keySet()];

        System.assert(!contentShares.isEmpty(), 'Intranet Content Shares were not created for the Intranet All Users group');

        for(Intranet_Content__Share contentShare : contentShares)
        {
            system.assertNotEquals('Test Intranet All Users', contentShare.UserOrGroup.Name, 'The Intranet All Users share was not removed');
            system.assertNotEquals('Test Information Technology Admins', contentShare.UserOrGroup.Name, 'The Information Technology Admins share was not removed');
        }

        Test.stopTest();
    }

    @isTest 
	static void testExceptions()
    {		
		// Update one of the buckets with invalid public groups to trigger the addError() methods
        Intranet_Content_Buckets__c bucket = [SELECT Id, Viewers__c, Permission_Groups__c FROM Intranet_Content_Buckets__c LIMIT 1];

        Test.startTest();
        try
        {
            bucket.Viewers__c = 'InvalidGroup';
            bucket.Permission_Groups__c = 'InvalidGroup';
            update bucket;
            // The following line should not be reached in this test because the line prior should cause an exception and force the test to the catch() method
            // This assert just verifies that this scenario did occur and that the test doesn't just end without peforming the desired test.
            system.assert(false, 'The addError method was not reached in this test.  Please check test parameters, or check to see if method under test has been modified.');
        }
        catch(Exception e)
        {
            system.assert(e.getMessage().contains('Group not found:'));
        }

        Test.stopTest();
    }
    
}