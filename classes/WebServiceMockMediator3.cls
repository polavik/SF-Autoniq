@isTest
global class  WebServiceMockMediator3 implements WebServiceMock{

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
      
//     if(request instanceof Mediator.arbitrateVehicle_element ){
       
	       Mediator.arbitrateVehicleResponse_element responseElement = new Mediator.arbitrateVehicleResponse_element();
	       
	       Mediator.arbitrateVehicleResponseType resp = new Mediator.arbitrateVehicleResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);     
	        System.debug('-----WebServiceMockMediator3 has been called response= [' + response + ']');
	     
//     }
             
   }




}