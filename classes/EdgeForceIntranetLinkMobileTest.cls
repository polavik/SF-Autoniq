// (c) 2015 Appirio, Inc.
//
// 04 August, 2015    Prakarsh Jain     Test Class for EdgeForceIntranetContentFullController
//
@isTest
public class EdgeForceIntranetLinkMobileTest {
    static testMethod void testEdgeForceIntranetLinkMobile(){
       Test.startTest();
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Link').getRecordTypeId();
        
        
        //Insert new Intranet_Article__c records
        Intranet_Content__c link = new Intranet_Content__c();
        link.Type__c = 'Quick Link';
        link.Start_Date__c = Datetime.now();
        link.End_Date__c = Datetime.now().addDays(5);
        link.RecordTypeId = recordTypeId;
        link.URL__c = 'www.google.com';
        insert link;
        
        Intranet_Content_Version__c intraContVer = new Intranet_Content_Version__c();
        intraContVer.Intranet_Content__c = link.Id;
        intraContVer.Language__c = 'English';
        intraContVer.URL__c = 'www.google.com';
        insert intraContVer;
        
        //Attach attachments to Intranet Links records
        IntranetTestUtility.createAttachment(true, link.ID);
        
        
        EdgeForceIntranetLinkMobile conObj = new EdgeForceIntranetLinkMobile();
        
        //Assert intranetList size is greater than 0. 
        System.assertNotEquals(conObj.intranetList, null);
       Test.stopTest();
    }
}