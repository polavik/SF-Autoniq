/**
  * Apex Class: EdgeForceIntranetContentRTSelControllerTest
  * Description: Test class for IntranetContentRTSelectionController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 11th, 2013.
*/
@isTest
private class EdgeForceIntranetContentRTSelCnrlTest {

    @testSetup static void setup(){
      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      User testUser = IntranetTestUtility.createUser(1, true, 'testuser1@adesa.com.marketing');
      system.runAs(thisUser){
        PermissionSet perm = [SELECT Id FROM PermissionSet WHERE Name = 'Intranet_Site_Manager'];
        PermissionSetAssignment permAssign = new PermissionSetAssignment(
          AssigneeId = testUser.Id,
          PermissionSetId = perm.Id
        );
        insert permAssign;
      }
    }

    private static testmethod void rtSelectionControllerTest(){
      User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1@adesa.com.marketing' LIMIT 1];
      System.runAs(testUser){
        Intranet_Content__c testContent = new Intranet_Content__c();
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(testContent);
        EdgeForceIntranetContentRTSelController controller = new EdgeForceIntranetContentRTSelController(stdController);
                                    
        //Assert test for intranetContentRecordTypes size 
        System.assert(controller.intranetContentRecordTypes.size() != 0);  
        
        //Assert test for Pagereference
        System.assert(controller.selectRecordType() <> null);
        
        //Assert test for cancel
        System.assert(controller.cancel() <> null);
      }
    }
    
    private static testmethod void rtSelectionFromICB() {
      User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1@adesa.com.marketing' LIMIT 1];
      System.runAs(testUser){
        Intranet_Content__c testContent = new Intranet_Content__c();
        Intranet_Content_Buckets__c testICB = new Intranet_Content_Buckets__c();
  	    testICB.Name = 'testICB';
  	    testICB.Permission_Groups__c = 'FastTrack';
  	    insert testICB;
  	    
  	    Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(testContent);
  	    ApexPages.currentPage().getParameters().put('retURL', testICB.Id);
  	    EdgeForceIntranetContentRTSelController controller = new EdgeForceIntranetContentRTSelController(stdController);
  	                                
  	    //Assert test for intranetContentRecordTypes size 
  	    System.assert(controller.intranetContentRecordTypes.size() != 0);  
  	    
  	    //Assert test for Pagereference
  	    System.assert(controller.selectRecordType() <> null);
  	    
  	    //Assert test for cancel
  	    System.assert(controller.cancel() <> null);
      }
    }
}