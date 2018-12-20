@isTest
global class  WebServiceMockMediator implements WebServiceMock{
   public String type;

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
      
		 if(requestName.equalsIgnoreCase('cancelPsi'))   {    
			new WebServiceMockMediator4().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
	        System.debug('-----WebServiceMockMediator4 has been called requestName= [' + requestName + ']');
                
		  return;	
                
		 }else if( requestName.equalsIgnoreCase('updateOrgTaxFormOnFileFlag')){
			new WebServiceMockMediator2().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
	        System.debug('-----WebServiceMockMediator2 has been called requestName= [' + requestName + ']');
		  return;	
                
		 }else if(requestName.equalsIgnoreCase('arbitrateVehicle'))
			new WebServiceMockMediator3().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
	        System.debug('-----WebServiceMockMediator3 has been called requestName= [' + requestName + ']');
		  return;	
		}
   }