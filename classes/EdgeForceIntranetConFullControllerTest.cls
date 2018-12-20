// (c) 2015 Appirio, Inc.
//
// 04 August, 2015    Prakarsh Jain		Test Class for EdgeForceIntranetContentFullController
//
@isTest
public class EdgeForceIntranetConFullControllerTest {
    static testMethod void testEdgeForceIntranetConFullController(){
        User usr = IntranetTestUtility.createUser(1, true);
        System.runAs(usr){
            String testGroup = ApexPages.currentPage().getParameters().put('name', 'tabname');
            
            CollaborationGroup testGroup1 = IntranetTestUtility.createGroup(true);
            Intranet_Content__c intraContent = new Intranet_Content__c();
            intraContent.Content_Type__c = 'Custom Content';
            EdgeForceIntranetContentFullController edForce = new EdgeForceIntranetContentFullController();
        }
    }
}