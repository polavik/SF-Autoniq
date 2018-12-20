@isTest
public class ATNQCreateOrdersTest {

    @testsetup static void createTestData() {

        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description = 'Test Product Entry 1';
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

        Product2 credit = new Product2(
            ProductCode = 'credit',
            Name = 'credit'
        );

        insert new List <Product2> {p, discount, fee, credit};

        Pricebook2 pb = new Pricebook2( Id = Test.getStandardPricebookId(), IsActive = true);


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

        Contact c = new Contact (Lastname = 'test', AccountId = a.Id, Autoniq_User_ID__c = 'TestId');
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

        OrderItem oi = new OrderItem(
            OrderId = o.Id,
            Subscription_Item__c = subItem.Id,
            PricebookEntryId = standardPrice != null ? standardPrice.Id : null,
            Quantity = 1,
            UnitPrice = 50
        );

        insert oi;

        insert new List <Subscription_Item__c> {subItem, subItem2};
    }

    @isTest
    private static void createNewOrderTest() {

        List<Subscription__c> existingSubs = [select Id, Status__c, Autoniq_Account__c, Contact__c, Term__c, Next_Bill_Date__c, Contact__r.AccountId, (select Id, Product__c, Product__r.ProductCode, Start_Date__c, Cancel_Date__c from Subscription_Item__r) from Subscription__c where Status__c = 'Active' AND Id IN (select Subscription__c from Subscription_Item__c where Status__c = 'Active')];
       
        for (Subscription__c sub : existingSubs) {
            for (Subscription_Item__c subItem : sub.Subscription_Item__r) {
            }
        }
        List<Order> orderList = [select Id, AccountId, Subscription__c, Status from Order];
        Order existingOrder = orderList[0];

        Test.startTest();
            List<Order> createdOrders =  ATNQCreateOrders.createOrders(existingSubs);
            Order updatedExistingOrder = [select Id, AccountId, Subscription__c, Status from Order where Id = : existingOrder.Id ];
        Test.stopTest();

        System.assertEquals(Constants.ORDER_STATUS_DRAFT, existingOrder.Status, ' Expected ' + Constants.ORDER_STATUS_DRAFT + ' Actual value: ' + existingOrder.Status);
        System.assertEquals(Constants.ORDER_STATUS_ACTIVATED, updatedExistingOrder.Status, ' Expected ' + Constants.ORDER_STATUS_ACTIVATED + ' Actual value: ' + updatedExistingOrder.Status);
		System.assertEquals(Constants.ORDER_STATUS_DRAFT, createdOrders[0].Status, ' Expected ' + Constants.ORDER_STATUS_DRAFT + ' Actual value: ' + createdOrders[0].Status);
    }
}