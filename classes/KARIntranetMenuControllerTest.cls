/**
  * Apex Class: KARIntranetMenuControllerTest 
  * Description: test class for KARIntranetMenuController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: October 3rd,2013
  * 10 Feb,2015 : Sidhant            S-387519, Modified Test Class
*/
@isTest
private class KARIntranetMenuControllerTest {
    
	private static testmethod void MenuControllerTest(){
	  //Insert Intranet_CMS_Page__c records        
	  String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
	  //Insert new Intranet_Article__c records
	  Intranet_Content__c article1 = new Intranet_Content__c();
	  article1.Name = 'Test';
	  article1.Start_Date__c = Datetime.now();
	  article1.End_Date__c = Datetime.now().addDays(5);
	  //article1.Pages__c = 'Brand';
	  article1.RecordTypeId = recordTypeId;
	  article1.Status__c = 'Published';
	  article1.Show_In_Header_Menu__c = true;
	  article1.Template__c = 'Home';
	  article1.Sequence__c = '1';
	  insert article1;
	  
	  Intranet_Content__c article2 = new Intranet_Content__c();
	  article2.Name = 'Test';
	  article2.Start_Date__c = Datetime.now();
	  article2.End_Date__c = Datetime.now().addDays(5);
	  article2.Status__c = 'Published';
	  article2.RecordTypeId = recordTypeId;
	  article2.Show_In_Header_Menu__c = true;
	  article2.Template__c = 'Team';
	  article2.Sequence__c = '1';
	  insert article2;
	  
	  Intranet_Content__c article3 = new Intranet_Content__c();
	  article3.Name = 'Test';
	  article3.Start_Date__c = Datetime.now();
	  article3.End_Date__c = Datetime.now().addDays(5);
	  article3.RecordTypeId = recordTypeId;
	  article3.Status__c = 'Published';
	  article3.Show_In_Header_Menu__c = true;
	  article3.Template__c = 'Content';
	  article3.Sequence__c = '2';
	  insert article3;
	  
	  Intranet_Content__c article4 = new Intranet_Content__c();
	  article4.Name = 'Test';
	  article4.Start_Date__c = Datetime.now();
	  article4.End_Date__c = Datetime.now().addDays(5);
	  article4.Status__c = 'Published';
	  article4.RecordTypeId = recordTypeId;
	  article4.Show_In_Header_Menu__c = true;
	  article4.Template__c = 'Chatter';
	  article4.Sequence__c = '1';
	  insert article4;

	  Intranet_Content__c article5 = new Intranet_Content__c();
	  article5.Name = 'Test Child';
	  article5.Start_Date__c = Datetime.now();
	  article5.End_Date__c = Datetime.now().addDays(5);
	  article5.Status__c = 'Published';
	  article5.RecordTypeId = recordTypeId;
	  article5.Show_In_Header_Menu__c = true;
	  article5.Template__c = 'Team';
	  article5.Sequence__c = '1';
	  article5.Parent__c = article2.Id;
	  insert article5;
	  
	  Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
	  intraContVer1.Intranet_Content__c = article1.Id;
	  intraContVer1.Name = 'Article 1';
	  intraContVer1.Language__c = 'English';
	  intraContVer1.Description__c ='Dummy Description';
	  insert intraContVer1;
	  
	  Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
	  intraContVer2.Intranet_Content__c = article2.Id;
	  intraContVer2.Name = 'Article 2';
	  intraContVer2.Language__c = 'English';
	  intraContVer2.Description__c ='Dummy Description';
	  insert intraContVer2;

	  Intranet_Content_Version__c intraContVer3 = new Intranet_Content_Version__c();
	  intraContVer3.Intranet_Content__c = article3.Id;
	  intraContVer3.Name = 'Article 3';
	  intraContVer3.Language__c = 'English';
	  intraContVer3.Description__c ='Dummy Description';
	  insert intraContVer3;
	  
	  Intranet_Content_Version__c intraContVer4 = new Intranet_Content_Version__c();
	  intraContVer4.Intranet_Content__c = article4.Id;
	  intraContVer4.Name = 'Article 4';
	  intraContVer4.Language__c = 'English';
	  intraContVer4.Description__c ='Dummy Description';
	  insert intraContVer4;

	 	Intranet_Content_Version__c intraContVer5 = new Intranet_Content_Version__c();
	  intraContVer5.Intranet_Content__c = article5.Id;
	  intraContVer5.Name = 'Article 2';
	  intraContVer5.Language__c = 'English';
	  intraContVer5.Description__c ='Dummy Description';
	  insert intraContVer5;
	  
	  RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Language'];
	  Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
	  insert IC;
	  
	  Test.startTest();
	  KARIntranetMenuController conObj = new KARIntranetMenuController();
	  //Assert controller's ulString propety is not null
	  system.assert(conObj.ulString != null);
	  Test.StopTest();
	}
}