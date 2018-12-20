/*

Created By        : Lovish Goyal
Created Date        : 13 April, 2016
===========================================

Description        : Test class for the KAR_Frame_Controller class

*/

@isTest
private class KAR_Frame_ControllerTest {
    
    static testMethod void unitTest() {
        // Test start
        Test.startTest();
            // Setting the variables for the page url
            ApexPages.currentPage().getParameters().put('height', '400');
            ApexPages.currentPage().getParameters().put('url', 'https://www.salesforce.com');
            
            // Initialising the object for the KAR_Frame_Controller class
            KAR_Frame_Controller controller = new KAR_Frame_Controller();
            
        // Test stop
        Test.stopTest();
    }
}