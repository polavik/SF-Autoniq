// (c) 2015 Appirio, Inc.
//
// 05 August, 2015    Prakarsh Jain		Test Class for EdgeForceIntranetHeaderCompController
//
@isTest
public class EdgeForceIntraHeaderCompControllerTest {
    static testMethod void testEdgeForceIntraHeaderCompController(){
        User usr = IntranetTestUtility.createUser(1, true);
        system.runAs(usr){
            Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('Intranet Article', 'News', 'Test', false);
        	article1.Status__c = 'Published';
        	insert article1;

            EdgeForceIntranetHeaderCompController edgeForce = new EdgeForceIntranetHeaderCompController();
        }
    }
}