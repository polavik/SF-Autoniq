@isTest
private class TestATNQCalculateDiscounts {
	
	@testsetup static void createTestData()
	{
			
		Product2 product1 = new Product2(
            ProductCode = 'product1',
            Name = 'product1'
        );
        Product2 product2 = new Product2(
            ProductCode = 'product2',
            Name = 'product2'
        );
	   Product2 Credit = new Product2(
            ProductCode = 'CREDIT',
            Name = 'Credit'
        );
        Product2 discount = new Product2(
            ProductCode = 'DISC',
            Name = 'Discount'
        );

		 Product2 fee = new Product2(
            ProductCode = 'FEE',
            Name = 'FEE'
        );
        insert new List <Product2> {product1, product2,Credit,discount, fee};
        
        insert new PricebookEntry[] {
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product1.Id, UnitPrice = 50, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = discount.Id, UnitPrice = 0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product2.Id, UnitPrice = 50, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = Credit.Id,   UnitPrice = 0, IsActive = true)         
                };
		Account a = new Account(Name = 'test');
		insert a;

		Autoniq_Account__c atnqAct = new Autoniq_Account__c(No_Of_Subscriptions__c = 0, Account__c = a.Id, Name = 'test');
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
		Subscription__c subscription_more_credit = new Subscription__c(
			Autoniq_Account__c = atnqAct.Id,            
			Contact__c = c.Id,
			Status__c = 'Active',
			Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
		);
		
		insert new List <Subscription__c> {subscription,subscription_more_credit};

		

		Subscription_Item__c subItem1 = new Subscription_Item__c(
			Subscription__c = subscription.Id, 
			Status__c = 'Active',
            Product__c = product1.Id
		);
		Subscription_Item__c subItem2 = new Subscription_Item__c(
			Subscription__c = subscription.Id, 
			Status__c = 'Active',
            Product__c = product2.Id
		);
        Subscription_Item__c subitem_credit = new Subscription_Item__c(
			Subscription__c = subscription.Id, 
			Status__c = 'Active',
            Product__c = Credit.Id,
            Amount__c = 10
		);
        //sub items to test more credit than total scenario
        Subscription_Item__c subItem3 = new Subscription_Item__c(
			Subscription__c = subscription_more_credit.Id, 
			Status__c = 'Active',
            Product__c = product1.Id
		);
		Subscription_Item__c subItem4 = new Subscription_Item__c(
			Subscription__c = subscription_more_credit.Id, 
			Status__c = 'Active',
            Product__c = product2.Id
		);
        Subscription_Item__c subitem_more_credit = new Subscription_Item__c(
			Subscription__c = subscription_more_credit.Id, 
			Status__c = 'Active',
            Product__c = Credit.Id,
            Amount__c = 100
		);
		insert new List <Subscription_Item__c> {subItem1, subItem2,subitem_credit,subItem3,subItem4,subItem_more_credit};

		Order order1 = new Order(
			Status = 'Draft',
			Subscription__c = subscription.Id,
			AccountId = a.Id,
			EffectiveDate = system.today(),
			Pricebook2Id = PricebookUtility.StandardPricebook.Id
		);
		insert order1;
		
		Order order_sub_more_cred = new Order(
			Status = 'Draft',
			Subscription__c = subscription_more_credit.Id,
			AccountId = a.Id,
			EffectiveDate = system.today(),
			Pricebook2Id = PricebookUtility.StandardPricebook.Id
		);
		insert order_sub_more_cred;
		OrderItem oi  = new OrderItem (
			OrderId = order1.Id,
			Subscription_Item__c = subItem1.Id,
			PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id,
			Quantity = 1,
			UnitPrice = 50
		);
        
       PricebookEntry pbe=[Select Id,Name,PriceBook2ID, Product2Id from PriceBookEntry where ProductCode = 'CREDIT'];
	   OrderItem oic  = new OrderItem (
			OrderId = order1.Id,
			Subscription_Item__c = subitem_credit.Id,
			PricebookEntryId = pbe.id,
			Quantity = 1,
			UnitPrice = 0
		);
		insert new List <OrderItem> {oi,oic};
//order items for more credit than total testing scenario
	OrderItem oi_more_sub  = new OrderItem (
			OrderId = order_sub_more_cred.Id,
			Subscription_Item__c = subItem3.Id,
			PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id,
			Quantity = 1,
			UnitPrice = 50
		);
        
	   OrderItem oic_more_sub  = new OrderItem (
			OrderId = order_sub_more_cred.Id,
			Subscription_Item__c = subItem_more_credit.Id,
			PricebookEntryId = pbe.id,
			Quantity = 1,
			UnitPrice = 0
		);
		insert new List <OrderItem> {oi_more_sub,oic_more_sub};
		subscription.Next_Bill_Date__c = system.today();
		update subscription;

		
		Autoniq_Discount_Type__c discountType1 = new Autoniq_Discount_Type__c(
			Related_Product__c = product1.Id,
			
			Code__c = '123',
			Unit__c = 'Percent',
			Value__c = 10
		);
		insert discountType1;

		Autoniq_Discount_Assignment__c discount1 = new Autoniq_Discount_Assignment__c(
			Autoniq_Discount_Type__c = discountType1.Id,
			Autoniq_Subscription_Item__c = subItem1.Id, 
			Start_Date__c = system.today(), 
			End_Date__c = system.today().addDays(20) 
		);
		insert discount1;
	}
@isTest static void testOffPercent () {
       
		
		Test.startTest();
			
			System.enqueueJob( new ATNQCreateDiscountsQueued(
				[SELECT Id, OrderId, Subscription_Item__c, UnitPrice, PricebookEntryId FROM OrderItem]) 
			);
        Test.stopTest();

        OrderItem [] orderItems = [SELECT UnitPrice,PricebookEntry.Product2.Name FROM OrderItem WHERE PricebookEntry.Product2.Name='Discount'];
        system.assertEquals(-5, orderItems[0]. UnitPrice);
	}
	@isTest static void testOffAmount () {
	
		Autoniq_Discount_Type__c discountType = [SELECT Id FROM Autoniq_Discount_Type__c LIMIT 1];
		discountType.Unit__c = 'Amount';
		discountType.Value__c = 5;
		update discountType;
		
		
		Test.startTest();
			
			System.enqueueJob( new ATNQCreateDiscountsQueued(
				[SELECT Id, OrderId, Subscription_Item__c, UnitPrice, PricebookEntryId FROM OrderItem]) 
			);
        Test.stopTest();
        for (OrderItem oi : [SELECT UnitPrice, OrderId, Subscription_Item__c, OriginalOrderItemId , Id
        	FROM OrderItem ]) {
        	system.debug('^^^^ ' + oi.OriginalOrderItemId);	
        }
        
        OrderItem [] orderItems = [
        	SELECT UnitPrice, OrderId, Subscription_Item__c,PricebookEntry.Product2.Name, OriginalOrderItemId 
        	FROM OrderItem 
        	WHERE PricebookEntry.Product2.Name='Discount'];
        
        system.assertEquals(-5, orderItems[0].UnitPrice);
        
        
        system.assertEquals( [Select Id FROM Subscription_Item__c LIMIT 1].Id, orderItems[0].Subscription_Item__c);
       
	}

	

	@isTest static void testOffAmount_outsideDateRange () {
	
		
		
		Autoniq_Discount_Assignment__c discountAssignment = [SELECT Id FROM Autoniq_Discount_Assignment__c LIMIT 1];
		discountAssignment.Start_Date__c = system.today().addYears(-1);
		discountAssignment.End_Date__c = system.today().addYears(-1).addDays(2);
		update discountAssignment;
		
		Test.startTest();			
			System.enqueueJob( new ATNQCreateDiscountsQueued(
				[SELECT Id, OrderId, Subscription_Item__c, UnitPrice, PricebookEntryId FROM OrderItem]) 
			);
        Test.stopTest();

        system.assertEquals(0, [SELECT UnitPrice, OrderId,PricebookEntry.Product2.Name, OriginalOrderItemId FROM OrderItem WHERE PricebookEntry.Product2.Name='Discount'].size() );  
	}

	/*@isTest static void testCredit (){
		 Test.startTest();			
			System.enqueueJob( new ATNQCreateDiscountsQueued(
				[SELECT Id, OrderId,  Subscription_Item__c, UnitPrice, PricebookEntryId FROM OrderItem]) 
			);
        Test.stopTest();
        
        OrderItem [] oi = [SELECT UnitPrice, Order.TotalAmount,PricebookEntry.Product2.Name, OrderId,PricebookEntryId, OriginalOrderItemId FROM OrderItem where PricebookEntry.Product2.Name='CREDIT' Limit 1];
        
        system.assertEquals(-10, oi[0].UnitPrice);   

	}*/

	@isTest static void testCredit_creditExceedsTotal (){
		
		 Test.startTest();			
			System.enqueueJob( new ATNQCreateDiscountsQueued(
				[SELECT Id, OrderId,  Subscription_Item__c, UnitPrice, PricebookEntryId FROM OrderItem ]) 
			);
        Test.stopTest();
        OrderItem [] oi = [SELECT UnitPrice, Order.TotalAmount,PricebookEntry.Product2.Name, OrderId, OriginalOrderItemId FROM OrderItem WHERE  PricebookEntry.Product2.Name='CREDIT'];
        //test credit
        system.assertEquals(-10, oi[0].UnitPrice);
        //test credit exceeds total
        system.assertEquals(-50, oi[1].UnitPrice);
      
       
	}
}