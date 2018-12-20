@isTest
private class Test_OrderTrigger {

	@testSetup static void setup(){
		Account a = new Account(Name = 'test');
		insert a;
		Contact c = new Contact (Lastname = 'test', AccountId = a.Id);
		insert c;
		Autoniq_Account__c atnqAct = new Autoniq_Account__c(Account__c = a.Id, Name = 'test');
		insert atnqAct;
	}	
 
	@isTest static void testNextBillDate_monthly_nextBillDate_null () { 
		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = [SELECT Id FROM Autoniq_Account__c LIMIT 1].Id,
			Contact__c =  [SELECT Id FROM Contact LIMIT 1].Id,
			Status__c = 'Active',
			Next_Bill_Date__c = null,
            Term__c = 'Monthly' 
		);
		insert sub;
		Order o = new Order (
            Subscription__c = sub.Id,
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,  
            BillToContactId = [SELECT Id fROM Contact LIMIT 1 ].Id,              
            Status = 'Draft',
            EffectiveDate = Date.today(),            
            Pricebook2Id = PricebookUtility.StandardPricebook.Id
        );
        insert o;	
        Subscription__c subscription = [SELECT Next_Bill_Date__c FROM Subscription__c LIMIT 1];
         integer daysBefore = -1;
        system.assertEquals( system.today().addDays(daysBefore).addMonths(1), subscription.Next_Bill_Date__c);
	}

	@isTest static void testNextBillDate_monthly_nextBillDate_NOTnull () { 
		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = [SELECT Id FROM Autoniq_Account__c LIMIT 1].Id,
			Contact__c =  [SELECT Id FROM Contact LIMIT 1].Id,
			Status__c = 'Active',
			Next_Bill_Date__c = Date.newInstance(2018, 01, 21),
            Term__c = 'Monthly' 
		);
		insert sub;
		Order o = new Order (
            Subscription__c = sub.Id,
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,  
            BillToContactId = [SELECT Id fROM Contact LIMIT 1 ].Id,              
            Status = 'Draft',
            EffectiveDate = Date.today(),            
            Pricebook2Id = PricebookUtility.StandardPricebook.Id
        );
        insert o;	
        Subscription__c subscription = [SELECT Next_Bill_Date__c FROM Subscription__c LIMIT 1];
       
        system.assertEquals( Date.newInstance(2018, 02, 21), subscription.Next_Bill_Date__c);
	}

	@isTest static void testNextBillDate_annual_nextBillDate_null () { 
		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = [SELECT Id FROM Autoniq_Account__c LIMIT 1].Id,
			Contact__c =  [SELECT Id FROM Contact LIMIT 1].Id,
			Status__c = 'Active',
			Next_Bill_Date__c = null,
            Term__c = 'Annual' 
		);
		insert sub;
		Order o = new Order (
            Subscription__c = sub.Id,
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,  
            BillToContactId = [SELECT Id fROM Contact LIMIT 1 ].Id,              
            Status = 'Draft',
            EffectiveDate = Date.today(),            
            Pricebook2Id = PricebookUtility.StandardPricebook.Id
        );
        insert o;	
        Subscription__c subscription = [SELECT Next_Bill_Date__c FROM Subscription__c LIMIT 1];
        integer daysBefore = -45;
        system.assertEquals( system.today().addDays(daysBefore).addYears(1), subscription.Next_Bill_Date__c);
	}

	@isTest static void testNextBillDate_annual_nextBillDate_NOTnull () { 
		Subscription__c sub = new Subscription__c(
			Autoniq_Account__c = [SELECT Id FROM Autoniq_Account__c LIMIT 1].Id,
			Contact__c =  [SELECT Id FROM Contact LIMIT 1].Id,
			Status__c = 'Active',
			Next_Bill_Date__c = Date.newInstance(2018, 01, 21),
            Term__c = 'Annual' 
		);
		insert sub;
		Order o = new Order (
            Subscription__c = sub.Id,
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,  
            BillToContactId = [SELECT Id fROM Contact LIMIT 1 ].Id,              
            Status = 'Draft',
            EffectiveDate = Date.today(),            
            Pricebook2Id = PricebookUtility.StandardPricebook.Id
        );
        insert o;	
        Subscription__c subscription = [SELECT Next_Bill_Date__c FROM Subscription__c LIMIT 1];
        integer daysBefore = -45;
        system.assertEquals( Date.newInstance(2018, 01, 21).addYears(1), subscription.Next_Bill_Date__c);
        
	}
	
}