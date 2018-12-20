// 
// (c) 2014 Appirio, Inc.
// 
// EdgeForceIntranetCMSController_Test
// test class for page EdgeForceIntranetCMSController
// T-295755
//
// 28 July 2014     Ashish Goyal(JDC)       Original
//
// 24 October 2014  Sidhant Agarwal         Modified(T-325464)
// 1 December 2014  Sidhant Agarwal         Modified(T-336766)
//
@isTest
public class EdgeForceIntranetCMSController_Test {
    public static String parentId;
    static testMethod void EdgeForceIntranetCMSControllerTest(){
        //Modified(T-336766)
        String configRT = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Config - Portal').getRecordTypeId();
        Intranet_Content__c configIC = new Intranet_Content__c();
        configIC.RecordTypeId = configRT;
        configIC.Name = userinfo.getLanguage();
        configIC.Value__c = '1234';
        configIC.Status__c ='Draft';
        insert configIC;
        
        String rt = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
        Intranet_Content__c IC = new Intranet_Content__c();
        IC.RecordTypeId = rt;
        IC.Name = 'TestIC';
        IC.Template__c = 'Team Home';
        IC.Status__c = 'Published';
        Insert IC;
        
        Intranet_Content__c IC2 = new Intranet_Content__c();
        IC2.RecordTypeId = rt;
        IC2.Name = 'TestIC2';
        IC2.Template__c = 'Team Content';
        IC2.Parent__c = IC.id;
        IC2.Status__c = 'Published';
        Insert IC2;
        
        //Modified(T-336766)
        Intranet_Content__c IC3 = new Intranet_Content__c();
        IC3.RecordTypeId = rt;
        IC3.Name = 'TestIC3';
        IC3.Template__c = 'Team Home';
        IC3.Status__c = 'Draft';
        IC3.URL__c = 'www.google.com';
        Insert IC3;
        
        Intranet_Content_Version__c ICV = new Intranet_Content_Version__c();
        ICV.Name = 'testICV2';
        ICV.Language__c = 'English';
        ICV.Intranet_Content__c = IC2.id;
        ICV.isPublished__c = true;
        ICV.Description__c = 'test';
        insert ICV;
        
        ICV.Name = ICV.Name;
        update ICV;
        
        Intranet_Content_Version__c ICV2 = new Intranet_Content_Version__c();
        ICV2.Name = 'testICV';
        ICV2.Language__c = 'English';
        ICV2.Intranet_Content__c = IC.id;
        ICV2.isPublished__c = true;
        ICV2.Description__c = 'test';
        insert ICV2;
        
        EdgeForceIntranetCMSController controller = new EdgeForceIntranetCMSController();
        //controller.getAllCMSPages();
        controller.ICID = IC.id;
        controller.SelectedICVID = ICV.id;
        controller.showICV();
        controller.publishICV();
        EdgeForceIntranetCMSController.getAllParentPages();
        parentId = IC.id;
        EdgeForceIntranetCMSController.processAllChildRows(parentId);
        controller.deleteICV();
    }
    static testMethod void CMSNewTest(){
        String rt = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
        Intranet_Content__c IC = new Intranet_Content__c();
        IC.RecordTypeId = rt;
        IC.Name = 'TestIC';
        IC.Template__c = 'Team Home';
        IC.Status__c = 'Published';
        Insert IC;
        
        Intranet_Content__c IC2 = new Intranet_Content__c();
        IC2.RecordTypeId = rt;
        IC2.Name = 'TestIC2';
        IC2.Template__c = 'Team Content';
        IC2.Parent__c = IC.id;
        IC2.Status__c = 'Published';
        Insert IC2;
        
        Intranet_Content_Version__c ICV = new Intranet_Content_Version__c();
        ICV.Name = 'testICV';
        ICV.Language__c = 'English';
        ICV.Intranet_Content__c = IC2.id;
        ICV.Description__c = 'test';
        ICV.isPublished__c = true;
        insert ICV;
        
        ICV.Name = ICV.Name;
        update ICV;
        
        Intranet_Content_Version__c ICV2 = new Intranet_Content_Version__c();
        ICV2.Name = 'testICV';
        ICV2.Language__c = 'English';
        ICV2.Intranet_Content__c = IC.id;
        ICV2.Description__c = 'test';
        ICV2.isPublished__c = true;
        insert ICV2;
        
        EdgeForceIntranetCMSController controller = new EdgeForceIntranetCMSController();
        //controller.getAllCMSPages();
        controller.ICID = IC.id;
        controller.SelectedICVID = ICV.id;
        controller.showICV();
        controller.publishICV();
        EdgeForceIntranetCMSController.getAllParentPages();
        parentId = IC.id;
        EdgeForceIntranetCMSController.processAllChildRows(parentId);
        controller.deleteICV();
    }
}