@isTest
                        
global class WebServiceMockImpl1 implements WebServiceMock{
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
      
      //(1)
       MIServicePhase2.MiResponse objMiResponse = new  MIServicePhase2.MiResponse();
       
       MIServicePhase2.MiFact Obj_miFacts = new MIServicePhase2.MiFact();
       List<MIServicePhase2.MiFact> List_MiFact = new List<MIServicePhase2.MiFact>();
       List_MiFact.Add(Obj_miFacts);
       
       MIServicePhase2.Result objResult = new MIServicePhase2.Result();
       objResult.resultCode=100;
       objResult.message='Error Messgae';
       
       objMiResponse.miFacts = List_MiFact;
       objMiResponse.result = objResult;
       response.put('response_x', objMiResponse);     
        
   }
}