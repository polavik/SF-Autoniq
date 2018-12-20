Public Class EdgeForceIntranetFooterController{
    
    Public User userR{get;set;}
    
    Public EdgeForceIntranetFooterController(){
        userR = [Select id,LocaleSidKey,LanguageLocaleKey
                    From User
                    Where id=:Userinfo.getUserID()
                    Limit 1];
    
    }
    
    Public void changeLanguage(){
        update userR;
    }

}