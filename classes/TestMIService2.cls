@isTest

private class TestMIService2
{
     public static testMethod void testCallWebservice1()
     {
         MIService2 objMIService2  = new  MIService2();
         Property__c objProperty = new Property__c(Property_Id__c='mi.service.password',Property_Value_Encrypted__c='1234');
         insert objProperty ;         
         MIService2.Result objResult = new  MIService2.Result();
         MIService2.MiUpdateResponse objMiUpdateResponse = new  MIService2.MiUpdateResponse();
         MIService2.MiUpdateRequest objMiUpdateRequest = new  MIService2.MiUpdateRequest();
         MIService2.MiResponse objMiResponse = new  MIService2.MiResponse();
         MIService2.MiFact objMiFact = new  MIService2.MiFact();
         MIService2.MiRequest objMiRequest = new  MIService2.MiRequest();
         MIService2.MiRequestBase objMiRequestBase  = new MIService2.MiRequestBase();
         MIService2.MIService objMIService = new  MIService2.MIService();
         Long[] miFactId = new Long[]{100,101};
         MIService2.MiResponse objMiResponse1 = objMIService.getMiFact(100,'CONTACT',miFactId ) ;
         MIService2.MiUpdateResponse objMiUpdateResponse1  = objMIService.updateMasterIndex('100','200','CONTACT','TOKEN') ;
         
     }
}