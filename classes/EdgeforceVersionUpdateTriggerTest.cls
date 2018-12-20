@isTest
private class EdgeforceVersionUpdateTriggerTest {
    @isTest static void testUpdate() {
        
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        insert article1;
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Language__c = 'English';
        intraContVer1.Name = 'testTitle';
        intraContVer1.description__c = 'testDescription';
        intraContVer1.Header__c = 'test1';
        intraContVer1.Summary__c = 'test11';
        insert intraContVer1;
        
        intraContVer1.URL__c = 'www.test.com';
        update intraContVer1;
        
        intraContVer1.Name = 'test';
        intraContVer1.Language__c= 'hindi';
        update intraContVer1;
        
        
    }
}