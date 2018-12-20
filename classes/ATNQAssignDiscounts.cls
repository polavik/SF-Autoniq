public with sharing class ATNQAssignDiscounts {
	public static void Assign(Set <Id> subscriptionIds ) {
		Map<Id, ATNQProcessDiscountRules.DiscountType> existing_subItems_to_discounts = new Map<Id, ATNQProcessDiscountRules.DiscountType> ();
		Map<Id, ATNQProcessDiscountRules.DiscountType> new_subItems_to_discounts = new Map<Id, ATNQProcessDiscountRules.DiscountType> ();

		Subscription_Item__c [] subitems = [SELECT Id, Subscription__c, ProductCode__c,
			
			(SELECT Id, Autoniq_Discount_Type__c, Autoniq_Discount_Type__r.Value__c, Autoniq_Discount_Type__r.Unit__c 
			FROM Autoniq_Discount_Assignments__r)

			FROM Subscription_Item__c
			WHERE Subscription__c IN : subscriptionIds ];

		List <ATNQProcessDiscountRules.Subscription> subscriptions = new List <ATNQProcessDiscountRules.Subscription>();
		List <ATNQProcessDiscountRules.SubscriptionItem> subscriptionItems = new List <ATNQProcessDiscountRules.SubscriptionItem> ();
		for (Subscription_Item__c subitem : subitems) {
			ATNQProcessDiscountRules.SubscriptionItem newItem = new ATNQProcessDiscountRules.SubscriptionItem();
			newItem.Id = subitem.Id;
			newItem.discountTypes = new List <ATNQProcessDiscountRules.DiscountType> ();
			for (Autoniq_Discount_Assignment__c discount : subitem.Autoniq_Discount_Assignments__r) {
				ATNQProcessDiscountRules.DiscountType newDiscount = new ATNQProcessDiscountRules.DiscountType();
				newDiscount.type = discount.Id; 
				newDiscount.value = discount.Autoniq_Discount_Type__r.Value__c;
				newDiscount.unit = discount.Autoniq_Discount_Type__r.Unit__c ;
				newItem.discountTypes.add(newDiscount);
				existing_subItems_to_discounts.put(subitem.Id, newDiscount);
			}
		}
		system.debug('i am before calling the process engine');

		List <ATNQProcessDiscountRules.Subscription> subscriptionsReturned = 
		ATNQProcessDiscountRules.Process(subscriptionIds);
		system.debug('i am after calling the process engine');
		/* This part is to find the best discount for each Subscription Item */
		for (ATNQProcessDiscountRules.Subscription subscriptionReturned : subscriptionsReturned) {
			for (ATNQProcessDiscountRules.SubscriptionItem item : subscriptionReturned.subItems) {
				PricebookEntry pbe = PricebookUtility.productCode_to_priceBookEntry.get(item.productCode);
				Decimal price = pbe.UnitPrice;
				system.debug('price ' + price);
				ATNQProcessDiscountRules.DiscountType bestDiscount = null;
				if (item.discountTypes != null && item.discountTypes.size() > 0) {
					system.debug('i am here when item.discounttype is not null and size greater than zero');
					for (ATNQProcessDiscountRules.DiscountType discount : item.discountTypes) {
						if (discount != null ) {
							system.debug('i am herer if discount not null');
							if (bestDiscount != null ) {
								system.debug('i am here if  best discount not null');
								system.debug('discount.value  ' + discount.value );
								system.debug('bestDiscount.value  ' + bestDiscount.value );			
								if (discount.unit == 'Percent') {

									if (price * discount.value > price * bestDiscount.value) {
										bestDiscount = discount;
									}
								}
								else {
									if (price - discount.value > price - bestDiscount.value) {
										bestDiscount = discount;
									}
								}
							}
							else {
								bestDiscount = discount;
							}
						}
					}
					new_subItems_to_discounts.put(item.Id, bestDiscount);
				}
			}			
		}
		system.debug('existing_subItems_to_discounts ' + existing_subItems_to_discounts);
		system.debug('new_subItems_to_discounts ' + new_subItems_to_discounts);

		List <Autoniq_Discount_Assignment__c> assignmentsToInsert = new List <Autoniq_Discount_Assignment__c>();

		/*
		
		TODO insert the discount assignments 
		for each subscription item insert the Discount Assignment based on the best discount in the map (new_subItems_to_discounts)
		*/
		for (Id subItemId : new_subItems_to_discounts.keySet()) {
			assignmentsToInsert.add( new Autoniq_Discount_Assignment__c (
				Autoniq_Subscription_Item__c = subItemId, 
				Autoniq_Discount_Type__c = new_subItems_to_discounts.get(subItemId).type,
                Start_Date__c = System.today(),
                End_Date__c = System.today().addMonths(1)
                
			));
            //End_Date__c = System.today().addDays(30)
		}
		insert assignmentsToInsert;
        system.debug('the inserted sub items are'+assignmentsToInsert);
		system.debug('the inserted sub items are'+assignmentsToInsert.size());
	}
}