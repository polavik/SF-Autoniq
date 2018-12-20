@isTest
public with sharing class ATNQSubscriptionTriggerHandler_Test {
	@testsetup static void createDate(){
		Account a = new Account();
    a.Name = 'TestAccount';
    insert a;

    Product2 p = new Product2();
    p.Name = 'FEE';
    p.Description='Test Product Entry 1';
    p.productCode = 'FEE';
    p.isActive = true;
    
   

     Product2 discount = new Product2(
        ProductCode = 'discount',
        Name = 'discount'
    );
    
    insert new List <Product2> { discount, p};
    
    Pricebook2 pb = new Pricebook2( Id = Test.getStandardPricebookId(),IsActive = true);

    
    PricebookEntry standardPrice = new PricebookEntry();
    standardPrice.Pricebook2Id = pb.Id;
    standardPrice.Product2Id = p.Id;
    standardPrice.UnitPrice = 1;
    standardPrice.IsActive = true;
    standardPrice.UseStandardPrice = false;
    insert standardPrice ;

    Autoniq_Account__c atnqAct = new Autoniq_Account__c(Account__c = a.Id, Name = 'test');
        insert atnqAct;
    Contact c = new Contact (Lastname = 'test', AccountId = a.Id);
        insert c;
  
    Subscription__c sub = new Subscription__c(
        Autoniq_Account__c = atnqAct.Id,            
        Contact__c = c.Id,
        Status__c = 'Active',
        Next_Bill_Date__c = system.today(),
        Term__c = 'Monthly' 
    );
    insert sub;
    
	}

	@isTest static void  Test_SubscriptionTriggerHandler() {
		test.starttest();
		List<Autoniq_Account__c> aa=[SELECT id,No_Of_Subscriptions__c FROM Autoniq_Account__c];	
		system.assertEquals(aa.get(0).No_Of_Subscriptions__c,1);
		test.stoptest();
	}
}