@isTest
private class TestATNQCreateOrders {
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
         Product2 Credit = new Product2(
            ProductCode = 'CREDIT',
            Name = 'Credit'
        );
        insert new List <Product2> {product1, discount, fee, Credit };
        

        insert new PricebookEntry[] {
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product1.Id, UnitPrice = 50, IsActive = true)
        };
		Account a = new Account(Name = 'test');
		insert a;

		Autoniq_Account__c atnqAct = new Autoniq_Account__c(Account__c = a.Id, Name = 'test');
		insert atnqAct;

		Contact c = new Contact (Lastname = 'test', AccountId = a.Id);
		insert c;
		
	}
	

	@isTest static void testOrderCreation_monthly () {
		ATNQ_Order_Creation_Config__mdt [] orderCreationConfig = [SELECT Days_before_creation_Annually__c, Days_before_creation_Monthly__c FROM ATNQ_Order_Creation_Config__mdt];
		integer daysBefore_monthly =  integer.valueOf(orderCreationConfig[0].Days_before_creation_Monthly__c);		

		Contact c = new Contact (Lastname = 'test2', AccountId = [SELECT Id FROM Account LIMIT 1].Id);
		insert c;
		Product2 p = [SELECT Id FROM Product2 LIMIT 1];
		Autoniq_Account__c atnqAct = [SELECT Id FROM Autoniq_Account__c LIMIT 1];

		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',

			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);

		Subscription__c sub2 = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',

			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);
		insert new List <Subscription__c> {sub, sub2};

		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id
		);
		Subscription_Item__c subItem2 = new Subscription_Item__c(
			Subscription__c = sub2.Id, 
			Status__c = 'Active',
            Product__c = p.Id
		);
		insert new List <Subscription_Item__c> {subItem, subItem2};

		Test.startTest();
			Database.executeBatch(new ATNQCreateOrdersBatch());
        Test.stopTest();
        
        Order [] orders = [SELECT Id FROM Order];
        system.assertEquals(2, orders.size());
        
        OrderItem [] oi = [SELECT Id, UnitPrice, PricebookEntry.Product2.Name, OrderId FROM OrderItem];
        system.assertEquals(2, oi.size());
        system.assertEquals(orders[0].Id, oi[0].OrderId);
        system.assertEquals(50, oi[0].UnitPrice);
        system.assertEquals('product1', oi[0].PricebookEntry.Product2.Name);


        system.assertEquals(orders[1].Id, oi[1].OrderId);
        system.assertEquals(50, oi[1].UnitPrice);
        system.assertEquals('product1', oi[1].PricebookEntry.Product2.Name);
	}


	@isTest static void testOrderCreation_annual () {
		ATNQ_Order_Creation_Config__mdt [] orderCreationConfig = [SELECT Days_before_creation_Annually__c, Days_before_creation_Monthly__c FROM ATNQ_Order_Creation_Config__mdt];
		integer daysBefore_annually  = integer.valueOf( orderCreationConfig[0].Days_before_creation_Annually__c );	

		Contact c = new Contact (Lastname = 'test2', AccountId = [SELECT Id FROM Account LIMIT 1].Id);
		insert c;
		Product2 p = [SELECT Id FROM Product2 LIMIT 1];
		Autoniq_Account__c atnqAct = [SELECT Id FROM Autoniq_Account__c LIMIT 1];
		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',

			Next_Bill_Date__c = system.today(),
            Term__c = 'Annual' 
		);

		Subscription__c sub2 = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',

			Next_Bill_Date__c = system.today(),
            Term__c = 'Annual' 
		);
		insert new List <Subscription__c> {sub, sub2};

		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id
		);
		Subscription_Item__c subItem2 = new Subscription_Item__c(
			Subscription__c = sub2.Id, 
			Status__c = 'Active',
            Product__c = p.Id
		);
		insert new List <Subscription_Item__c> {subItem, subItem2};
		

		Test.startTest();
			Database.executeBatch(new ATNQCreateOrdersBatch());
        Test.stopTest();
        
        Order [] orders = [SELECT Id FROM Order];
        system.assertEquals(2, orders.size());
        
        OrderItem [] oi = [SELECT Id, UnitPrice, PricebookEntry.Product2.Name, OrderId FROM OrderItem];
        system.assertEquals(2, oi.size());
        system.assertEquals(orders[0].Id, oi[0].OrderId);
        system.assertEquals(50, oi[0].UnitPrice);
        system.assertEquals('product1', oi[0].PricebookEntry.Product2.Name);


        system.assertEquals(orders[1].Id, oi[1].OrderId);
        system.assertEquals(50, oi[1].UnitPrice);
        system.assertEquals('product1', oi[1].PricebookEntry.Product2.Name);
	}

	@isTest static void testOrderCreation_monthly_Prorated () {
		ATNQ_Order_Creation_Config__mdt [] orderCreationConfig = [SELECT Days_before_creation_Annually__c, Days_before_creation_Monthly__c FROM ATNQ_Order_Creation_Config__mdt];
		integer daysBefore_monthly =  integer.valueOf(orderCreationConfig[0].Days_before_creation_Monthly__c);		

		Contact c = new Contact (Lastname = 'test2', AccountId = [SELECT Id FROM Account LIMIT 1].Id);
		insert c;
		Product2 p = [SELECT Id FROM Product2 LIMIT 1];
		Autoniq_Account__c atnqAct = [SELECT Id FROM Autoniq_Account__c LIMIT 1];

		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',
			Sign_up_Date__c = system.today().addMonths(-1).addDays(1),
			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);

		Subscription__c sub2 = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',
			Sign_up_Date__c = system.today().addMonths(-1).addDays(1),
			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);
		insert new List <Subscription__c> {sub, sub2};
		
		Subscription_Item__c subItem = new Subscription_Item__c(
			Subscription__c = sub.Id, 
			Status__c = 'Active',
            Product__c = p.Id,
            Start_Date__c = system.today().addDays(-10)
		);
		Subscription_Item__c subItem2 = new Subscription_Item__c(
			Subscription__c = sub2.Id, 
			Status__c = 'Active',
            Product__c = p.Id,
            Start_Date__c = system.today().addDays(-10)
		);
		insert new List <Subscription_Item__c> {subItem, subItem2};

		Test.startTest();
			Database.executeBatch(new ATNQCreateOrdersBatch());
        Test.stopTest();
        
        Order [] orders = [SELECT Id FROM Order];
        system.assertEquals(2, orders.size());
        
        OrderItem [] oi = [SELECT Id, UnitPrice, PricebookEntry.Product2.Name, OrderId FROM OrderItem];
        system.assertEquals(2, oi.size());
        system.assertEquals(orders[0].Id, oi[0].OrderId);
        //system.assertEquals(50/10, oi[0].UnitPrice);
        system.assertEquals('product1', oi[0].PricebookEntry.Product2.Name);


        system.assertEquals(orders[1].Id, oi[1].OrderId);
       // system.assertEquals(50/10, oi[1].UnitPrice);
        system.assertEquals('product1', oi[1].PricebookEntry.Product2.Name);
	}
	
}