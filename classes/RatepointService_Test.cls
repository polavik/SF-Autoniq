@istest
private class RatepointService_Test{
@testSetup
static void testRate() {
       
    Account a = new Account();
    a.Name = 'TestAccount';
    insert a;

    Product2 p = new Product2();
    p.Name = ' Test Product ';
    p.Description='Test Product Entry 1';
    p.productCode = 'ABC';
    p.isActive = true;
    

    Product2 discount = new Product2(
        ProductCode = 'discount',
        Name = 'discount'
    );

    Product2 fee = new Product2(
        ProductCode = 'FEE',
        Name = 'FEE'
    );
    insert new List <Product2> {p, discount, fee};
    
    Pricebook2 pb = new Pricebook2( Id = Test.getStandardPricebookId(),IsActive = true);

    
    PricebookEntry standardPrice = new PricebookEntry();
    standardPrice.Pricebook2Id = pb.Id;
    standardPrice.Product2Id = p.Id;
    standardPrice.UnitPrice = 1;
    standardPrice.IsActive = true;
    standardPrice.UseStandardPrice = false;
    insert standardPrice ;
   
    Contact c = new Contact (Lastname = 'test', AccountId = a.Id);
        insert c;

    Autoniq_Account__c atnqAct = new Autoniq_Account__c(Account__c = a.Id, Name = 'test');
        insert atnqAct;

    Subscription__c sub = new Subscription__c(
        Autoniq_Account__c = atnqAct.Id,            
        Contact__c = c.Id,
        Status__c = 'Active',

        Next_Bill_Date__c = system.today(),
        Term__c = 'Monthly' 
    );
    insert sub;
    Subscription_Item__c subItem = new Subscription_Item__c(
        Subscription__c = sub.Id, 
        Status__c = 'Active',
        Product__c = p.Id
    );
    Subscription_Item__c subItem2 = new Subscription_Item__c(
        Subscription__c = sub.Id, 
        Status__c = 'Active',
        Product__c = p.Id
    );

    insert new List <Subscription_Item__c> {subItem, subItem2};
    //Test Order Insert
    
    Order o = new Order();
    o.Name = 'Test Order ';
    o.Status = 'Draft';
    o.EffectiveDate = system.today();
    o.EndDate = system.today() + 4;
    o.AccountId = a.id;
    o.Pricebook2Id =  pb.Id ;
    o.Subscription__c = sub.Id;
    insert o;
    
    

   OrderItem i = new OrderItem();
    i.OrderId = o.id;
    i.Quantity = 24;
    i.UnitPrice = 240;
    i.Subscription_Item__c = subItem.Id;
    i.Product2id = p.id;
    i.PricebookEntryId=standardPrice.id;
    insert i;

    //Test OrderItem on second insert
 
    OrderItem i2 = new OrderItem();
    i2.OrderId = o.id;
    i2.Quantity = 24;
    i2.UnitPrice = 240;
    i2.Subscription_Item__c = subItem2.Id;
    i2.PricebookEntryId=standardPrice.id;
    insert i2;
    
	Order o2 = new Order();
    o2.Name = 'Test Order ';
    o2.Status = 'Draft';
    o2.EffectiveDate = system.today();
    o2.EndDate = system.today() + 3;
    o2.AccountId = a.id;
    o2.Pricebook2Id =  pb.Id ;
    o2.Subscription__c = sub.Id;
    insert o2;
    

     Integration__c inte1 = new  Integration__c();
        inte1.API_Name__c = 'RATEPOINT';
        inte1.Order__c=o.id;
        inte1.Status__c = 'Pending';
       insert inte1;
    Integration__c inte2 = new  Integration__c();
        inte2.API_Name__c = 'RATEPOINT';
        inte2.Order__c=o2.id;
        inte2.Status__c = 'Test';
       insert inte2;
        
    
		Autoniq_Subscription_Payment_Profile__c asppc= new Autoniq_Subscription_Payment_Profile__c(
         Autoniq_Subscription__c =sub.id,
         Last_Four_Digits__c= 4444.0,
         Payment_Type__c= 'check',
         Billing_City__c='chicago',
         Billing_Postal_Code__c='60502',
         Billing_State__c='il',
         Billing_Street__c='arborside ln',
         IsActive__c=TRUE
    	);
        insert asppc;

   }

@isTest static void testService_200() {
        ServiceMock mock = new ServiceMock();
        mock.status = 'SUCCESS';
           // mock.responseBodyAsString='{"amount": 0,"streetAddress1": "2520 arborside ln", "streetAddress2": "","city": "Aurora","state": "IL","zip": "60502"}';
        mock.responseBodyAsString  = '{"code":200,"Taxes":950.40,"Text":"The tax returned successfully"}';
        mock.code = 200;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();           
        RatepointService rs = new RatepointService();
        Integration__c[] records = [SELECT Id, API_Name__c,Order__c FROM   Integration__c where API_Name__c='RATEPOINT'] ;
        system.debug('before call to ratepoint');
        if(records.size()>0)

        {
            rs.execute(records);
        }
        Order ord=[select salestax__c from order where id=:records[0].order__c];
        system.assertEquals(ord.salestax__c,950.40);
        
             Test.stopTest();
      //system.assertEquals({"zip":"60502","streetAddress1":"arborside ln","state":"IL","city":"chicago","amount":11520.00},h.getStatusCode() );
	}

 
    class ServiceMock implements HttpCalloutMock {
        String responseBodyAsString {get; set;}
        String status {get; set;}
        Integer code {get; set;}

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBodyAsString);
            response.setStatusCode(code);
            response.setStatus(status);
            return response;
	}
 }	

}