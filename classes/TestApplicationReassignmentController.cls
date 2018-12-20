@isTest
private class TestApplicationReassignmentController {

    static testMethod void refreshResults(){
        User creditUser = TestServices.createUsers('testAs', 'AFC Credit and Contracts Super', 1, true)[0]; 
        
        system.runAs(creditUser) {
        final String LOOKUP_FIELD_NAME='Credit_User__c';
        final Id LOOKUP_FIELD_VALUE=creditUser.Id;
        final Integer NUM_FILTERED_APPS=ApplicationReassignmentController.PAGE_SIZE/2;

        ApplicationReassignmentController cont = new ApplicationReassignmentController();

        List<Application__c> appsToReturn = TestUtils.createApplications(NUM_FILTERED_APPS, false);
        List<Application__c> appsToFilter = TestUtils.createApplications(NUM_FILTERED_APPS, false);
        for(Application__c app : appsToReturn){
            app.put(LOOKUP_FIELD_NAME, LOOKUP_FIELD_VALUE);
        }

        List<Application__c> allApps = new List<Application__c>(appsToReturn);
        allApps.addAll(appsToFilter);
        
        for(Application__c app : allApps){
            app.Application_Stage__c = 'At Credit';
        }
        
        insert allApps;
        
        ApplicationReassignmentController.filterFields = new Set<String>{LOOKUP_FIELD_NAME};
        cont.applicationFilters.put(LOOKUP_FIELD_NAME, LOOKUP_FIELD_VALUE);

        Test.startTest();
            cont.refreshResults();
        Test.stopTest();
        
        
        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        System.assertEquals(appsToReturn.size(), cont.setCont.getRecords().size(), 'The correct number of records was retrieved');
        System.assertEquals(Pluck.ids(appsToReturn), Pluck.ids(cont.setCont.getRecords()), 'The correct records were retrieved');
        System.assertEquals(Pluck.ids(appsToReturn), cont.applicationSelectedMap.keySet(), 'The correct records were added to the selected map');        
        }
    }

    static testMethod void contNext(){
        final Integer NUM_FILTERED_APPS=ApplicationReassignmentController.PAGE_SIZE*2;

        List<Application__c> apps = TestUtils.createApplications(NUM_FILTERED_APPS, false);
        for (Application__c app : apps) {
            app.Application_Stage__c = 'At Credit';
        }
        insert apps;

        ApplicationReassignmentController cont = new ApplicationReassignmentController();

        Set<Id> oldRecordIds = Pluck.ids(cont.setCont.getRecords());

        Test.startTest();
            cont.contNext();
        Test.stopTest();

        System.assert(ApexPages.getMessages().isEmpty(), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        
        System.assertNotEquals(oldRecordIds, Pluck.ids(cont.setCont.getRecords()), 'The records must change when we click next');
        for(sObject app : cont.setCont.getRecords()){
            System.assert(cont.applicationSelectedMap.containsKey(app.Id), 'The new page must populate the selection map for the new records');
        }
    }

    static testMethod void reassign(){
        User creditUser = TestServices.createUsers('testAs', 'AFC Credit and Contracts Super', 1, true)[0]; 
        
        system.runAs(creditUser) {
        final String LOOKUP_FIELD_NAME='Credit_User__c';
        final Id LOOKUP_FIELD_VALUE=creditUser.Id;
        final Integer NUM_FILTERED_APPS=ApplicationReassignmentController.PAGE_SIZE/2;

        List<Application__c> appsToChange = TestUtils.createApplications(NUM_FILTERED_APPS, false);
        List<Application__c> appsToFilter = TestUtils.createApplications(NUM_FILTERED_APPS, false);
        List<Application__c> allApps = new List<Application__c>(appsToChange);
        allApps.addAll(appsToFilter);
        
        insert allApps;

        ApplicationReassignmentController cont = new ApplicationReassignmentController();

        for(Application__c app : appsToChange){
            cont.applicationSelectedMap.put(app.Id, true);
        }

        ApplicationReassignmentController.reassignFields = new Set<String>{LOOKUP_FIELD_NAME};
        cont.dummyReassignedApplication.put(LOOKUP_FIELD_NAME, LOOKUP_FIELD_VALUE);

        Test.startTest();
            cont.reassign();
        Test.stopTest();

        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There shouldnt be any errors on the page: ' + ApexPages.getMessages());
        
        List<Application__c> actualApplications = [SELECT Id,Credit_User__c from Application__c];

        System.assertEquals(NUM_FILTERED_APPS*2, actualApplications.size(), 'The correct number of records was retrieved');

        Set<Id> appsToChangeIds = Pluck.ids(appsToChange);
        for(Application__c app : actualApplications){
            if(appsToChangeIds.contains(app.Id)){
                System.assertEquals(LOOKUP_FIELD_VALUE, app.Credit_User__c, 'The field must have been reassigned since the app was selected');
            } else {
                System.assertEquals(null, app.Credit_User__c, 'The field must not have been reassigned since the app was not selected');
            }
        }
     }
    }
}