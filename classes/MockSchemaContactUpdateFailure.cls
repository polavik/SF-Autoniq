@isTest
public class MockSchemaContactUpdateFailure implements WebServiceMock {
   @TestVisible static final String ERROR_CODE='12345';
   @TestVisible static final String ERROR_MESSAGE='Test';

   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

    SchemaContactUpdate.ContactUpdateResponseType responseElement = new SchemaContactUpdate.ContactUpdateResponseType();
    responseElement.ServiceResponse = new SchemaContactUpdate.ServiceResponse();

    responseElement.ServiceResponse.ResponseStatus = 'FAILURE';
    responseElement.ServiceResponse.Error = new SchemaContactUpdate.ServiceError();
    responseElement.ServiceResponse.Error.ErrorCode =ERROR_CODE;
    responseElement.ServiceResponse.Error.ErrorMessage =ERROR_MESSAGE;

    response.put('response_x', responseElement); 
   }
}