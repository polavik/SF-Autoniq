@isTest
                        
global class WebServiceMockImpl5 implements WebServiceMock{
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
      
       MIServicePhase2.MiUpdateResponse objMiUpdateResponse = new MIServicePhase2.MiUpdateResponse();
       
       MIServicePhase2.Result objResult = new MIServicePhase2.Result();
       objResult.resultCode=100;
       objResult.message='Error Messgae';
       
       objMiUpdateResponse.result = objResult;
       objMiUpdateResponse.success = false;
       response.put('response_x', objMiUpdateResponse);     
        
   }
}