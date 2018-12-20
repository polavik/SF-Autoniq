@isTest
    private class ATNQCreateDiscountsQueued_Test {
    
   @testsetup static void test_ATNQCreateDiscountsQueuedInsert() {
   
    //Test Account Insert

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
    
    //Test Order Insert
    
    Order o = new Order();
    o.Name = 'Test Order ';
    o.Status = 'Draft';
    o.EffectiveDate = system.today();
    o.EndDate = system.today() + 4;
    o.AccountId = a.id;
    o.Pricebook2Id =  pb.Id ;
    
    insert o;
    
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
    //i2.Total_Price__c = i.Quantity * i.UnitPrice;
    insert i2;
    
    system.assert([SELECT Id FROM OrderItem].size() > 0);


  }
  @istest static void test_ATNQCreateDiscountsQueued(){
    Test.startTest();       
   // List <OrderItem> orderItems = [SELECT Id FROM OrderItem];
    //ATNQCreateDiscountsQueued createDiscounts = new ATNQCreateDiscountsQueued(orderItems); 
    ATNQCreateDiscountsQueued createDiscounts = new ATNQCreateDiscountsQueued([SELECT Id ,OrderId, UnitPrice, Subscription_Item__c FROM OrderItem]); 
    System.enqueueJob(createDiscounts);

    Test.stopTest();
        Integration__c jobs = [SELECT API_Name__c,Order__c FROM Integration__c LIMIT 1];
        System.assertequals('RATEPOINT',jobs.API_Name__c);
        
    }
 }