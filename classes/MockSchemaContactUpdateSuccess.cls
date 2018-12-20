@isTest
public class MockSchemaContactUpdateSuccess implements WebServiceMock {
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

    SchemaContactUpdate.ContactUpdateResponseType responseElement = new  SchemaContactUpdate.ContactUpdateResponseType();
    responseElement.ServiceResponse = new SchemaContactUpdate.ServiceResponse();

    responseElement.ServiceResponse.ResponseStatus = SchemaContactUpdateHelper.SUCCESS_STRING;

    response.put('response_x', responseElement); 
   }
}