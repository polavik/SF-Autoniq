@isTest
private class ATNQProcessDiscountRules_Test {
	@testsetup static void createTestData()
	{
		Product2 product1 = new Product2(
            ProductCode = 'product1',
            Name = 'product1'
        );

	    Product2 discount = new Product2(
	        ProductCode = 'discount',
	        Name = 'discount'
	    );
	        Product2 fee = new Product2(
	        ProductCode = 'FEE',
	        Name = 'FEE'
	    );

	    insert new List <Product2> {product1, discount, fee};
       
  
        
        insert new PricebookEntry[] {
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product1.Id, UnitPrice = 50, IsActive = true)            
        };

		Account a = new Account(Name = 'test');
		insert a;

		Autoniq_Account__c atnqAct = new Autoniq_Account__c(Account__c = a.Id, Name = 'test');
		insert atnqAct;

		Contact c = new Contact (Lastname = 'test', AccountId = a.Id);
		insert c;

		Subscription__c subscription = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',

			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);
		
		insert new List <Subscription__c> {subscription};

		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = subscription.Id, 
			Status__c = 'Active',
            Product__c = product1.Id
		);
		insert new List <Subscription_Item__c> {subItem };
		
		Autoniq_Discount_Type__c discType = new Autoniq_Discount_Type__c(
			Code__c = 'test'
		);
		insert discType;

		Autoniq_Discount_Assignment_Rule__c rule = new Autoniq_Discount_Assignment_Rule__c(
			Autoniq_Discount_Type__c = discType.Id
		);
		insert rule;

		Autoniq_Discount_Assignment_Rule_Criteri__c criteria1 = new Autoniq_Discount_Assignment_Rule_Criteri__c(
			Autoniq_Discount_Assignment_Rule__c = rule.Id, 
			Field__c = 'Subscription_Status__c',
			Value__c = 'Active',
			Operand__c = '='
		);
		insert criteria1;
	}

	
	@isTest static void testCheckSubscriptionStatus() {
				
		List <Id> subIds = new List<Id>();
		subIds.add([SELECT Id FROM Subscription__c].Id);
		Test.startTest();
		List <ATNQProcessDiscountRules.Subscription> subscriptionResponse = ATNQProcessDiscountRules.Process(subIds);
		Test.stopTest();
		system.assertEquals([SELECT Id FROM Autoniq_Discount_Type__c].Id, subscriptionResponse[0].subItems[0].discountTypes[0].type);
	}
	
	
}