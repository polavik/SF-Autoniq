@isTest
private class ATNQSubscriptionItemTriggerHandler_Test {
	
	@testsetup static void createTestData()
	{		
        Date startDate;
        integer y = Date.today().year();
        integer m = 0;//January
        startDate = Date.newInstance(y, m, 1);
        
		Product2 product1 = new Product2(
            ProductCode = 'product1',
            Name = 'product1'
        );

		Product2 product2 = new Product2(
            ProductCode = 'product2',
            Name = 'product2'
        );

        Product2 discount = new Product2(
            ProductCode = 'discount',
            Name = 'discount'
        );
        Product2 Credit = new Product2(
            ProductCode = 'CREDIT',
            Name = 'Credit'
        );

         Product2 fee = new Product2(
            ProductCode = 'FEE',
            Name = 'FEE'
        );
        insert new List <Product2> {product1, product2, discount,Credit, fee};
        

        PricebookEntry pe =  new PricebookEntry(
        	Pricebook2Id = Test.getStandardPricebookId(),
        	Product2Id = product1.Id, 
        	UnitPrice = 50, 
        	IsActive = true);
        PricebookEntry pe2 =  new PricebookEntry(
        	Pricebook2Id = Test.getStandardPricebookId(),
        	Product2Id = product2.Id, 
        	UnitPrice = 50, 
        	IsActive = true);
        insert new List <PricebookEntry>{pe, pe2};
		Account a = new Account(Name = 'test');
		insert a;

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
		insert new List <Subscription__c> {sub};

		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = product1.Id
            
		);
		
		insert new List <Subscription_Item__c> {subItem};

		Order o = new Order (
			Status = 'Draft' , 
			Subscription__c = sub.Id,
			AccountId = a.Id,
			EffectiveDate = system.today(),
			Pricebook2Id = PricebookUtility.StandardPricebook.Id
		);
		insert o;

		OrderItem oi = new OrderItem (
			Subscription_Item__c = subItem.Id,
			OrderId = o.Id,
			Product2Id = product1.Id,
			UnitPrice = 50,
			Quantity = 1,
			PricebookEntryId = pe.Id
		);
		insert oi;

	}

	@isTest static void testAddMidMonth() {
		Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
		Product2 p = [SELECT Id FROM Product2 WHERE Name = 'product2'];

		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id
		);
		Test.startTest();
			insert subItem;
		Test.stopTest();
		system.assertEquals(2, [SELECT Id FROM OrderItem ].size());
		
	}

    /*
	@isTest static void testAddMidMonth_prorated () {
		Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
		Product2 p = [SELECT Id FROM Product2 WHERE Name = 'product2'];
		Date subItemDate = system.today().addDays(5);
		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id,
            Start_Date__c = system.today().addDays(5)
		);
		Test.startTest();
			insert subItem;
		Test.stopTest();
		integer daysBetween = subItemDate.daysBetween(system.today().addMonths(1));
		//system.assertEquals(50/daysBetween, [SELECT UnitPrice FROM OrderItem WHERE Product2Id = : p.Id ].UnitPrice);
		//system.assertEquals(1.92, [SELECT UnitPrice FROM OrderItem WHERE Product2Id = : p.Id ].UnitPrice);
	}
	*/
    
    @isTest static void testAddMidMonth_prorated() {
		Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
		Product2 p = [SELECT Id FROM Product2 WHERE Name = 'product2'];
		//Date subItemDate = system.today().addDays(5);
        
        Date startDate = Date.today();
        /*
        integer y = Date.today().year();
        integer m = 0;//January
        startDate = Date.newInstance(y, m, 1);
		*/
        Date subItemDate = startDate.addDays(5);
        
		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id,
            Start_Date__c = startDate.addDays(5)
		);
        decimal price = 50.00;
		Test.startTest();
			insert subItem;
		Test.stopTest();
        integer daysBetween = startDate.daysBetween(startDate.addMonths(1));
        decimal expectedPrice = ((price/Date.daysInMonth(startDate.year(),startDate.month()))*daysBetween).setScale(2,RoundingMode.HALF_UP);
		
		system.assertEquals(price, [SELECT UnitPrice FROM OrderItem WHERE Product2Id = : p.Id ].UnitPrice);
		system.assertEquals(expectedPrice, [SELECT UnitPrice FROM OrderItem WHERE Product2Id = : p.Id ].UnitPrice);
	}
	
}