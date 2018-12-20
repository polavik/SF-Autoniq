@isTest(SeeAllData=False)
Public Class EdgeForceIntranetFooterControllerTest{

    Public Static TestMethod void intranetFooterControllerTest(){
        EdgeForceIntranetFooterController footerCon = new EdgeForceIntranetFooterController();        
        footerCon.changeLanguage();
        
        //Login User should not be null
        system.assert(footerCon.userR != null);
        
        //Update user information with correct data
        footercon.userR.LocaleSidKey='en_US';
        footercon.userR.LanguageLocaleKey='en_US';
        footercon.changeLanguage();
       
        
        
    
    }
}