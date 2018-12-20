@isTest
public class ATNQSubItemFeeAssignTriggerHandler_Test {

@testsetup static void test_ATNQFeeAssTrigCreateData() {
   
    //Test Account Insert

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
    Contact c1 = new Contact (Lastname = 'test', AccountId = a.Id);
    Contact c2 = new Contact(Lastname='myname',AccountId=a.Id);
        insert new List <Contact> {c1,c2};
  
   Subscription__c sub1 = new Subscription__c(
            Autoniq_Account__c = atnqAct.Id,            
            Contact__c = c1.Id,
            Status__c = 'Active',
            Next_Bill_Date__c = system.today(),
            Term__c = 'Monthly' 
        );
        

        Subscription__c sub2 = new Subscription__c(
            Autoniq_Account__c = atnqAct.Id,            
            Contact__c = c2.Id,
            Status__c = 'Active',


            Term__c = 'Annual'
        );

        insert new List <Subscription__c> {sub1,sub2};

    //Test Order Insert
    
    Order o = new Order();
    o.Name = 'Test Order ';
    o.Status = 'Draft';
    o.EffectiveDate = system.today();
    o.EndDate = system.today() + 4;
    o.AccountId = a.id;
    o.Pricebook2Id =  pb.Id ;
    o.Subscription__c = sub1.id;    
    insert o;

    Subscription_Item__c si = new   Subscription_Item__c(
            Amount__c=20,
            Subscription__c=sub1.Id,
            Product__c=p.Id,
            Start_Date__c=system.today()-15
        );
        Insert si;
    
   /* Autoniq_Discount_Type__c adt= new Autoniq_Discount_Type__c(
        Name='Fee',
        Code__c='FEE'
        );
    Insert adt;*/
    system.debug('Inserted subscription item for fee type');

    }


@istest static void test_ATNQFeeAssignTriggerHandler(){
        Test.startTest(); 
        system.debug('I am Before order item query');
        List<OrderItem> oi = [SELECT OrderId,PricebookEntryId,Quantity,Product2Id,UnitPrice FROM OrderItem WHERE UnitPrice = -20  ];
        system.debug('I am After order item query'+oi.get(0).UnitPrice);
       
        system.assertEquals(oi.get(0).UnitPrice,-20);
         Test.stopTest();
    }
}