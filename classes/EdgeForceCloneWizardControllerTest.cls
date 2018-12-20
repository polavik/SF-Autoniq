@isTest
public with sharing class EdgeForceCloneWizardControllerTest {
  public static testMethod void EdgeForceCloneWizardControllerTestmet(){
    
    
    Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        insert article1;
        
       Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        article2.parent__c = article1.id;
        //article1.Pages__c = 'Brand';
        insert article2;
        /*
        Intranet_Content__c article3 = new Intranet_Content__c();
        article3.Type__c = 'News';
        article3.Start_Date__c = Datetime.now();
        article3.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        insert article3;*/
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Language__c = 'English';
        intraContVer1.name = 'testTitle';
        intraContVer1.description__c = 'testDescription';
        
        insert intraContVer1;
      
      Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article1.Id;
        intraContVer2.Language__c = 'English';
        intraContVer2.name = 'testTitle';
        intraContVer2.description__c = 'testDescription';
        
        insert intraContVer2;
        
        Tags__c tag = new Tags__c(
          tag__c = 'testTag'
        );
        insert tag;
        
        PageReference pageRef = Page.EF_CMSPages;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('id',intraContVer1.id); 
        User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
       /* Intranet_content__c cont=new Intranet_content__c();
        cont.Name=userInfo.getLanguage();
        cont.Value__c='test';
        Id contRecordTypeId = Schema.SObjectType.Intranet_content__c.getRecordTypeInfosByName().get('Config - Portal').getRecordTypeId();
        cont.RecordTypeId=contRecordTypeId;
       insert cont;*/
        ApexPages.currentPage().getParameters().put('id' , article1.Id);
        EdgeForceIntranetCloneWizardController ctrl = new EdgeForceIntranetCloneWizardController();
        ctrl.NewPrefixName='';
        ctrl.userLanguage='';
        ctrl.processContentClone();
        ctrl.processQuickLinksClone();
        
        ctrl.processChildContentsClone(article1.id);
        
        ctrl.newPageName= 'testPageName';
        ctrl.processCloning();
  }

}