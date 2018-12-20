/**
  * Apex Class: IntranetContentNewController_Test
  * Description: Test class for IntranetContentNewController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 11th,2013
*/
@isTest
private class EdgeForceIntranetContentNewContTest {
    
    private static testmethod void contentNewControllerTest(){
        Map<String, Schema.Recordtypeinfo> recordTypeMap = 
        Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName();
        Intranet_Content__c ic = new Intranet_Content__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(ic);
        
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Article');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Article').getRecordTypeId());
        
        EdgeForceIntranetContentNewController controller = new EdgeForceIntranetContentNewController(sc);
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Banner');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Banner').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Link');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);

        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Collapsible Content');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Collapsible Content').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);
        
        //Apexpages.currentPage().getParameters().put('RecordTypeName', 'Dynamice Component');
        //Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        
        controller = new EdgeForceIntranetContentNewController(sc);
        //controller.fetchObjectFields();
        controller.save();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Search');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Portal');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Language');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController(sc);
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet CMS Pages');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet CMS Pages').getRecordTypeId());
        
        controller = new EdgeForceIntranetContentNewController(sc);
        controller.intranetContent.Name = 'Chatter';
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Template__c = 'Chatter' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController(sc);
        controller.intranetContent.Name = 'Test Team';
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Team' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController(sc);
        controller.intranetContent.Name = 'Employee Directory';
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Template__c = 'Employee Directory' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController(sc);
        controller.intranetContent.Name = 'Search';
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Template__c = 'Search' ;
        controller.intranetContent.RecordTypeId = recordTypeMap.get('Intranet CMS Pages').getRecordTypeId();
        //Assert test for Pagereference
        PageReference ref = controller.save();
        System.assert(ref <> null);
        
        Apexpages.currentPage().getParameters().put('parentContentId', ref.getUrl().substring(1));
        controller = new EdgeForceIntranetContentNewController(sc);
        controller.intranetContent.Name = 'Test Content';
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Template__c = 'Content' ;
        //Assert test for Pagereference
        ref = controller.save();
        System.assert(ref <> null);

        //Test clone Content
        Apexpages.currentPage().getParameters().put('id',ref.getUrl().substring(1));
        controller = new EdgeForceIntranetContentNewController(sc);
        System.assertEquals('Test Content',controller.intranetContent.Name);
        controller.save();

        //Assert test for cancel
        System.assert(controller.cancel() <> null);
    }
}