@isTest
global class  WebServiceMockMediator2 implements WebServiceMock{

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
      
     if(request instanceof Mediator.updateOrgTaxFormOnFileFlag_element ){
       
	       Mediator.updateOrgTaxFormOnFileFlagResponse_element responseElement = new Mediator.updateOrgTaxFormOnFileFlagResponse_element();
	       
	       Mediator.updateOrgTaxFormOnFileFlagResponseType resp1 = new Mediator.updateOrgTaxFormOnFileFlagResponseType();
	       resp1.responseCode = 'ARBITRATION_SUCCESS';
	       resp1.responseMessage= 'Error Messgae1';
		   responseElement.response = resp1;
		    response.put('response_x', responseElement);     
		     
	        System.debug('-----WebServiceMockMediator2 has been called response= [' + response + ']');
     }
        
   }


}