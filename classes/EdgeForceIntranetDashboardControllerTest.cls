/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardControllerTest
* Date          :  December 03,2012
* Related Task  :  T-101364
* Description   :  Verify functionality of EdgeForceIntranetDashboardControllerclass.                 
*******************************************************************/
@isTest
private class EdgeForceIntranetDashboardControllerTest {

    static testMethod void testUserinformationUpdate() {

        Profile intranetProfile = [SELECT Id FROM Profile WHERE Name = 'Intranet User'];
        User testUser = IntranetTestUtility.createUser(intranetProfile.Id, 0, true, 'test@test.com.adesa');

        system.runAs(testUser){
            EdgeForceIntranetDashboardController controller = new EdgeForceIntranetDashboardController();
            //loginUser information should not be null
            system.assert(controller.userInformation != null);
            
            //Update user information with correct data 
            controller.userInformation.Phone = '123878342';
            controller.userInformation.Email = 'TestSystemUser@virginamerica.com';
            PageReference updatePage = controller.updateUserInformation();

            // AA: W-000045 - Justin Hawkins - Prevents updating Okta mastered fields            
            // This story was placed on hold.  Can uncomment next two lines when validation rule is pushed to production
            //system.assert(updatePage == null, 'The page reference should be null due to validation error.');
            //system.assert(String.isNotEmpty(controller.pageMessages), 'The page message should be populated with error text.');
            
            //User updatedUser1 = getUser(testUser.Id);
            //Update user last name information
            controller.userInformation.LastName = 'TestLastname';
            controller.updateUserInformation();
            User updatedUser2 = getUser(userInfo.getUserId());
            system.assert(updatedUser2 != null);
            system.assertEquals(updatedUser2.LastName , 'TestLastname');
        
            // Not sure what the purpose of the following tag insert is for this test - JLH
            //Tags__c testTag = new Tags__c();
            //testTag.Tag__c = 'Test Tag';
            //insert testTag;
        }        
    }
    
    static testmethod void testGoToChatter(){
        EdgeForceIntranetDashboardController controller = new EdgeForceIntranetDashboardController();
        controller.pageMessages='';
        PageReference pg=controller.gotochatter();
        system.assert((pg+'').contains('3DPersonalCollaboration'));
    }
    
   //get User Information
   private static User getUser(Id userId) {
    return [Select u.TimeZoneSidKey, u.Phone, u.LastName, 
                                     u.LanguageLocaleKey, u.FirstName, u.Email 
                            From User u 
                         where Id =: userId];
   }
}