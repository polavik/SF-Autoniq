@isTest

private class TestMIServicePhase2
{
     public static testMethod void testCallWebservice1()
     {
         
        

         
         MIServicePhase2 objMiService1  = new  MIServicePhase2();
         
         //Property__c objProperty = new Property__c(Property_Id__c='mi.service.password',Property_Value_Encrypted__c='1234');
         //insert objProperty ;  
                
         MIServicePhase2.Result objResult = new  MIServicePhase2.Result();
         MIServicePhase2.miSearchRequest  objmiSearchRequest  = new  MIServicePhase2.miSearchRequest ();         
         MIServicePhase2.MiUpdateResponse objMiUpdateResponse = new  MIServicePhase2.MiUpdateResponse();
         MIServicePhase2.miSearchResponse objmiSearchResponse = new  MIServicePhase2.miSearchResponse();
         MIServicePhase2.MiRequestBase objMiRequestBase = new  MIServicePhase2.MiRequestBase();        
         MIServicePhase2.MiUpdateRequest objMiUpdateRequest = new  MIServicePhase2.MiUpdateRequest();
         MIServicePhase2.MiResponse objMiResponse = new  MIServicePhase2.MiResponse();
         MIServicePhase2.MiFact objMiFact = new  MIServicePhase2.MiFact();
         MIServicePhase2.MiRequest objMiRequest = new  MIServicePhase2.MiRequest();
        
         MIServicePhase2.MIService objMIService = new  MIServicePhase2.MIService();
         Long[] miFactId = new Long[]{100,101};
         
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
         objmiSearchResponse =  objMIService.searchMi('test_token','ACCOUNT','OL','123',TRUE);//(String strToken,String miFactType,String miDomain,String miDomainUniqueId,Boolean exactMatch);
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
         objMiResponse =  objMIService.getMiFact('test_token','1234','ACCOUNT',null);//(String strToken,String masterIndex,String miFactType,String[] miFactId);
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
         objMiUpdateResponse =  objMIService.updateMasterIndex('test_token','1234','5678','ACCOUNT','OL','123');//(String strToken,String masterIndex,String masterIndexChangeTo,String miFactType,String miDomain,String miDomainUniqueId)
                 
         
     }
}