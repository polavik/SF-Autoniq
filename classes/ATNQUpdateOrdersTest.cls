@isTest
private class ATNQUpdateOrdersTest {
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
            Product__c = product1.Id
		);
		Subscription_Item__c subItem2 = new Subscription_Item__c(
			Subscription__c = sub2.Id, 
			Status__c = 'Active',
            Product__c = product1.Id
		);
		insert new List <Subscription_Item__c> {subItem, subItem2};
		Order o = new Order(EffectiveDate=system.today().adddays(-10),Subscription__c=sub.id,AccountID=a.Id,Pricebook2Id=Test.getStandardPricebookId(),BillToContactId=c.id,Status='Draft',EndDate=system.today());
		insert o;
		

	}
	@istest static void  ATNQUpdateOrdersTest() {
		Test.startTest();
			Database.executeBatch(new ATNQUpdateOrderBatch());
        Test.stopTest();
        Order [] orders = [SELECT Id,Status FROM Order];
        system.assertEquals('Activated', orders[0].status);
}	
}