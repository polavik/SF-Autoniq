/**
  * Apex Class: BrandsLandingControllerTest
  * Description: Test class for TagUtilities
  * Created By: Niza Khunger (Appirio)
  * Created Date: September 20th 2016
*/
@isTest
public with sharing class BrandsLandingControllerTest {
  static testmethod void BrandsLandingTest(){
      
    PageReference pageRef = Page.KAR_Team;
    Test.setCurrentPage(pageRef);  
    pageRef.getParameters().put('view','brandshome'); 
    
      
    Intranet_Content__c team1 = IntranetTestUtility.createIntranetContent(
        'Brand Landing RT',
        'Content',
        'Brand1',
        false
    );
       team1.currencyISOCode = 'USD';
       team1.Status__c = 'Published';
       team1.Document_Location__c = 'Attachment';
       insert team1;
       
      Intranet_Content_Version__c intraContVer1 = IntranetTestUtility.createContentVersion(team1.Id, true);
      Tags__c tag = IntranetTestUtility.createTag('Home', true);
      Intranet_Content_Tags__c ict = IntranetTestUtility.createContentTag(team1.Id, tag.Id, true);
                      
      Attachment testarticle = IntranetTestUtility.createAttachment(true, team1.Id);
      IntranetTestUtility.createIntranetConfig(true, 'Allowed Test Preview Formats', 'PDF,GIF');
        
      
      Intranet_Content__c team2 = IntranetTestUtility.createIntranetContent(
      'Team Page RT', null,''+userinfo.getLanguage(),false);
      team2.Status__c = 'Published';
      team2.Page_Type__c='Team';
      team2.CurrencyISOCode = 'USD';
      insert team2;
     
      
      Intranet_Content__c team3 = IntranetTestUtility.createIntranetContent(
      'Team Page RT',null,'Brand3',false);
      team3.Status__c = 'Published';
      team3.Page_Type__c='Brand';
      // [NBRUHN 10/15] Added below 1 line
      team3.Brand_Lifecycle_Category__c = 'Grounding';
      insert team3;
      
   
      BrandsLandingController obj=new BrandsLandingController();
       obj.bannerFileLoc = 0;
       obj.visionFileLoc = 0;
   	   obj.bListFileLoc = 0;
       obj.remarketFileLoc = 0;
       obj.pbs = new List<BrandsLandingController.PairedBrands>();
      
   
     BrandsLandingController.BrandsWrapper obj1 = new BrandsLandingController.BrandsWrapper();
      obj1.getPairedCount(); 
      obj1.getCount();
      obj1.getLabel();
      obj1.getRawLabel();
      obj1.getFirstName();
      
     BrandsLandingController.PairedBrands obj2 = new  BrandsLandingController.PairedBrands();
      obj2.getCount();
      obj2.lhsFlipCardLoc = 0;
	  obj2.rhsFlipCardLoc = 0;
      obj2.lhsFlipCardFrontLoc = 0; 
      obj2.rhsFlipCardFrontLoc = 0;    
      

      System.assertNotEquals(obj, null);
    
   }
    
}