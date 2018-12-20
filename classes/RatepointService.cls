public with sharing class RatepointService implements IntegrationService {
    public RatepointService ( ) {  }
    public integer getBatchSize() { return 1; }
  
 public   void execute(Integration__c[] records) {
   //try {
     
        callout(records[0].Order__c);
        system.debug('i am after callout');
   //}
   // catch (Exception e) {
   //   throw new RatepointService.RatepointServiceException(e.getTypeName() + ' Exception ' + e.getMessage());
    
   // }
    
 }

public  void callout( Id ordId ) {
    string addressReq;
    String bd;
    try{
      Order ord = [SELECT Subscription__c,TotalAmount,SalesTax__c FROM Order where Id =: ordid];
      Autoniq_Subscription_Payment_Profile__c asp =  [SELECT IsActive__c,Autoniq_Subscription__c,Billing_City__c,Billing_Country__c,Billing_Postal_Code__c,Billing_State__c,Billing_Street__c FROM Autoniq_Subscription_Payment_Profile__c where IsActive__c =True and Autoniq_Subscription__c=:ord.Subscription__c];        
      addressReq = getAddress(asp,ord);
      HttpResponse hr=getInfo(addressReq);
      bd=hr.getBody();
      fromResponse resBody = (fromResponse) JSON.deserialize(bd,fromResponse.class);
      system.debug('the deserialized response is'+resBody);
      update_order_with_tax(resBody,ord);
      if(resBody.code==200 && resBody.text != null) {
        System.debug('The status code returned was  expected from java: ' +resBody.Text);
      }
      else {
        throw new RatepointService.RatepointServiceException('Error  '+ resBody.Text );
      }
    }     
    catch(JSONException e)
    { 
      throw new RatepointService.RatepointServiceException('JSON req ' + addressReq + ' resp ' + bd + ' - ' + e.getMessage());
    } 
  }
  public static HttpResponse getInfo(String address){
      try{
     HttpRequest req = new HttpRequest();
     req.setTimeout(120000);
     req.setMethod('POST');
     req.setHeader('Content-Type', 'application/json');
     req.setHeader('x-api-key','UtjFaSss25946pxkA9Fkl2glWJAaGFQc1XjyKHFM');
     //String endpoint = 'http://staging-ext-api-1879353697.us-east-2.elb.amazonaws.com/autoniq-tax-api/api/tax/rate';
     String endpoint = 'https://oyp43o1xq2.execute-api.us-east-2.amazonaws.com/development/tax/rate';//new end point
     req.setEndPoint(endpoint);
     //req.setBody('{"amount": 0,"streetAddress1": "2520 arborside ln", "streetAddress2": "","city": "Aurora","state": "IL","zip": "60502"}');
     
     req.setBody(address);
     HttpResponse res = (new Http()).send(req);
     if(res.getStatusCode() == 200) 
        System.debug('The status code returned was  expected for making a callout: ' +res.getStatusCode() + ' ' + res.getStatus());
          return res;
       
          }
     catch(Exception e){
         Exception e1;
          throw new RatepointService.RatepointServiceException('no callout made to proxy'+e.getMessage());
      
       return null;
     }
  }
  public static string getAddress(Autoniq_Subscription_Payment_Profile__c aspp,Order ordid) {
     toRequestWrapper tr=new toRequestWrapper();
     SYSTEM.DEBUG('THIS IS BEFORE ASSIGNING ORDERID'+ORDID);
     SYSTEM.DEBUG('THIS IS BEFORE ASSIGNING ASPP'+ASPP);
     tr.amount=ordid.TotalAmount;
     tr.city=aspp.Billing_City__c;
     tr.state=aspp.Billing_State__c;
     tr.streetAddress1=aspp.Billing_Street__c;
    // tr.streetAddress2="";
     tr.zip=aspp.Billing_Postal_Code__c;
     String Address = JSON.serialize(tr);
     system.debug('the serialized address is'+Address);
     return  Address;
  }
  public class toRequestWrapper{
     public Decimal amount;
     public String  city;
     public String  state;
     public String  streetAddress1;
    // public String streetAddress2;
     public String zip;
  }
    public class RatepointServiceException extends Exception {}
    RatepointServiceException e1=new RatepointServiceException('no callout made');
  public static void update_order_with_tax(fromResponse fr,Order o){
      o.SalesTax__c=fr.Taxes;
      update o;
	    system.debug('the value in fr.taxes is'+fr.taxes);
      system.debug('the value in o.salestax is'+o.SalesTax__c);
    }
  public class fromResponse{
      public Decimal Taxes;
      public Integer Code;   
      public String Text;
    }
}