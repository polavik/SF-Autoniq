@isTest
global class  WebServiceMockMediatorForUnitTest implements WebServiceMock{

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
      
        System.debug('-----WebServiceMockMediatorForUnitTest has been called requestName= [' + requestName + ']');

		 if(requestName.equalsIgnoreCase('holdPSForVoid'))   {    
	       Mediator.holdPSForVoidResponse_element responseElement = new Mediator.holdPSForVoidResponse_element();	       
	       String resp =  'ARBITRATION_SUCCESS';
		    responseElement.resultCode = resp;
		    response.put('response_x', responseElement);                     
		 }
		 
		 if(requestName.equalsIgnoreCase('releasePSFromHold'))   {    
	       Mediator.releasePSFromHoldResponse_element responseElement = new Mediator.releasePSFromHoldResponse_element();	       
	       String resp =  requestName + '_SUCCESS';
		    responseElement.resultCode = resp;
		    response.put('response_x', responseElement);                     
		 }
		 
	     if(requestName.equalsIgnoreCase('cancelPsi') ){
	       Mediator.cancelPsiResponse_element responseElement = new Mediator.cancelPsiResponse_element();
	       
	       Mediator.cancelPsiResponseType resp = new Mediator.cancelPsiResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     
	     }
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     
	     if(requestName.equalsIgnoreCase('arbitrateVehicle') ){
	       Mediator.arbitrateVehicleResponse_element responseElement = new Mediator.arbitrateVehicleResponse_element();
	       
	       Mediator.arbitrateVehicleResponseType resp = new Mediator.arbitrateVehicleResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('restoreVehicleFromArbitration') ){
	       Mediator.restoreVehicleFromArbitrationResponse_element responseElement = new Mediator.restoreVehicleFromArbitrationResponse_element();
	       
	       Mediator.restoreVehicleFromArbitrationResponseType resp = new Mediator.restoreVehicleFromArbitrationResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('auctionVoid') ){
	       Mediator.auctionVoidResponse_element responseElement = new Mediator.auctionVoidResponse_element();
	       
	       Mediator.auctionVoidResponseType resp = new Mediator.auctionVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('recAuctionVoid') ){
	       Mediator.recAuctionVoidResponse_element responseElement = new Mediator.recAuctionVoidResponse_element();
	       
	       Mediator.recAuctionVoidResponseType resp = new Mediator.recAuctionVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('swapAuctionVoid') ){
	       Mediator.swapAuctionVoidResponse_element responseElement = new Mediator.swapAuctionVoidResponse_element();
	       
	       Mediator.swapAuctionVoidResponseType resp = new Mediator.swapAuctionVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('addExtraCost') ){
	       Mediator.addExtraCostResponse_element responseElement = new Mediator.addExtraCostResponse_element();
	       
	       Mediator.addExtraCostResponseType resp = new Mediator.addExtraCostResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('thirdPartyHouseVoid') ){
	       Mediator.thirdPartyHouseVoidResponse_element responseElement = new Mediator.thirdPartyHouseVoidResponse_element();
	       
	       Mediator.thirdPartyHouseVoidResponseType resp = new Mediator.thirdPartyHouseVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('thirdPartyHouseRecVoid') ){
	       Mediator.thirdPartyHouseRecVoidResponse_element responseElement = new Mediator.thirdPartyHouseRecVoidResponse_element();
	       
	       Mediator.thirdPartyHouseRecVoidResponseType resp = new Mediator.thirdPartyHouseRecVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('aiaHouseVoid') ){
	       Mediator.aiaHouseVoidResponse_element responseElement = new Mediator.aiaHouseVoidResponse_element();
	       
	       Mediator.aiaHouseVoidResponseType resp = new Mediator.aiaHouseVoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     if(requestName.equalsIgnoreCase('recHouseVoid') ){
	       Mediator.recHouseVoidResponse_element responseElement = new Mediator.recHouseVoidResponse_element();
	       
	       Mediator.recHousevoidResponseType resp = new Mediator.recHousevoidResponseType();
	       resp.returnCode = 'ARBITRATION_SUCCESS';
	       resp.errorMsg= new String[]{'Error Messgae1','Error Messgae'};
		    responseElement.response = resp;
		    response.put('response_x', responseElement);                     

	     }
	     
	     	     
        System.debug('-----the response= [' + response + ']');
	  	return;	
       }
}