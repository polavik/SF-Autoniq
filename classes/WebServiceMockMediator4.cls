@isTest
global class  WebServiceMockMediator4 implements WebServiceMock {

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
      
//      if(request instanceof Mediator.cancelPsi_element ){
	       Mediator.cancelPsiResponse_element responseElement = new Mediator.cancelPsiResponse_element();
	       // ms.cancelPsi('1234567'); 
	       
	       Mediator.cancelPsiResponseType resp = new Mediator.cancelPsiResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);     
	        System.debug('-----WebServiceMockMediator4 has been called response= [' + response + ']');
			return;
//      }	

   }

}