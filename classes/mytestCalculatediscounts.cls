public with sharing class mytestCalculatediscounts {
	static Product2 discountProduct;
	static PricebookEntry discountPBE;
	public static boolean isDiscountValidForBillingPeriod(Date nextBillDate, Date discountStartDate, Date discountEndDate) {
		return (nextBillDate != null && discountStartDate != null && discountEndDate != null &&  nextBillDate >=  discountStartDate && nextBillDate <= discountEndDate);
	}
public static List <OrderItem> applyDiscounts (List <ATNQBillingUtil.MyOrderItem> orderItemsWrapped) {
		//system.debug('!!! orderItemsWrapped ' + orderItemsWrapped);
		List <OrderItem> orderItemsToInsert = new List <OrderItem>();
		for (ATNQBillingUtil.MyOrderItem oiWrapped : orderItemsWrapped) {
			//for (ATNQBillingUtil.DIscount discount : oiWrapped.discounts) {
				//create new discount order item related to current orderitem and order
				Decimal unitPrice;
				if (oiWrapped.unit == 'Amount') {
					unitPrice = oiWrapped.discountOffAmount * -1;
					System.debug (' Enter Amount ='+ unitPrice);
				}
				else if (oiWrapped.unit == 'Percent') {
					Decimal percent = oiWrapped.discountPercentage / 100;
					unitPrice = oiWrapped.originalUnitPrice * percent * -1;
					System.debug (' Enter percent ='+ unitPrice);
				}
				if (unitPrice != null) {

					orderItemsToInsert.add(new OrderItem(
						PricebookEntryId = discountPBE.Id, 
						OrderId = oiWrapped.orderId,
						UnitPrice = unitPrice,
						OriginalOrderItemId = oiWrapped.Id,
						Quantity = 1,
						Subscription_Item__c = oiWrapped.subscriptionItemId
					));
					System.debug (' Unit Price on order item ='+ unitPrice);
				}
			//}
		}
		System.debug('orderItemsToInsert.size =' + orderItemsToInsert.size());
		if (orderItemsToInsert.size() > 0) {			
			insert orderItemsToInsert;			
		}
		return orderItemsToInsert;
	}

	
	public static void Discount ( List<OrderItem> orderItems ) {
		system.debug('--> size of order itesm passed to discounts orderItems ' + orderItems.size());
		discountProduct = [SELECT Id, ProductCode From Product2 WHERE Name = 'Discount' LIMIT 1];
		discountPBE = PricebookUtility.productCode_to_priceBookEntry.get(discountProduct.ProductCode);
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrapped = populateOIsForDiscounts (orderitems);
		system.debug('the size of order wrapped for discounts after populateOIsForDiscounts'+orderItemsWrapped.size());
		applyDiscounts(orderItemsWrapped.values());
		system.debug('the size of orderitemswrapped after updatediscounts call'+orderItemsWrapped.size());
	}
		private static Map <Id, ATNQBillingUtil.MyOrderItem> populateOIsForDiscounts (List<OrderItem> orderItems) {
		Set<Id> subscriptionItemIds = new Set <Id> ();
		
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrapped = new Map <Id, ATNQBillingUtil.MyOrderItem>();
		for (OrderItem orderItem : orderItems) {
			ATNQBillingUtil.MyOrderItem orderItemWrapped = new ATNQBillingUtil.MyOrderItem();
			orderItemWrapped.id = orderitem.Id;
			orderItemWrapped.orderId = orderItem.OrderId;
			orderItemWrapped.originalUnitPrice = orderitem.UnitPrice;
			orderItemWrapped.subscriptionItemId = orderitem.Subscription_Item__c;
			orderItemsWrapped.put( orderitem.Subscription_Item__c, orderItemWrapped );
			subscriptionItemIds.add( orderitem.Subscription_Item__c );
		}
		/* Autoniq_Discount_Assignment__c [] discountAssignments = [
			SELECT Id, Amount__c, Start_Date__c, End_Date__c, ADTUnit__c, 
				ADTValue__c, Autoniq_Subscription_Item__c,
				Subscription__r.Next_Bill_Date__c, Subscription__c
			FROM Autoniq_Discount_Assignment__c
			WHERE Subscription__c IN : subscriptionIds];*/

        /*for (Autoniq_Discount_Type discountype : [SELECT Id, Autoniq_Discount_Assignments__r.Subscription_Item__r.Subscription__r.Next_Bill_Date__c,
			 Autoniq_Discount_Assignments__r.Start_Date__c, Autoniq_Discount_Assignments__r.End_Date__c, Unit__c, Value__c,
			 Autoniq_Discount_Assignments__r.Subscription_Item__r.id
			FROM Autoniq_Discount_Type__c WHERE Autoniq_Discount_Assignments__r.Subscription_Item__r.id = : subscriptionItemIds ]) {*/

			//ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItemId.Id);
			//system.debug('item -> ' + item);
			//ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItem.Id);
		for (Subscription_Item__c subscriptionItem : [SELECT Id, Subscription__r.Next_Bill_Date__c,
			(SELECT Id, Start_Date__c, End_Date__c, ADTUnit__c, ADTValue__c
			FROM Autoniq_Discount_Assignments__r) FROM Subscription_Item__c WHERE Id = : subscriptionItemIds]){
			/*[SELECT Id, Amount__c, Start_Date__c, End_Date__c, ADTUnit__c, 
				ADTValue__c, Autoniq_Subscription_Item__c,
				Subscription__r.Next_Bill_Date__c, Subscription__c
			FROM Autoniq_Discount_Assignment__c
			WHERE Subscription__c IN : subscriptionItemIds ]) {*/
			ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItem.Id);
			system.debug('item -> ' + item);
			for (Autoniq_Discount_Assignment__c discount : subscriptionItem.Autoniq_Discount_Assignments__r) {
			//item.discounts = new List<ATNQBillingUtil.Discount>();
			//for (Autoniq_Discount_Assignment__c discount : subscriptionItem.Autoniq_Discount_Assignments__r) {
				if (isDiscountValidForBillingPeriod(subscriptionItem.Subscription__r.Next_Bill_Date__c, discount.Start_Date__c, discount.End_Date__c )) {
					//ATNQBillingUtil.Discount newDiscount = new ATNQBillingUtil.Discount();
					//item.unit = discount.Autoniq_Discount_Type__r.Unit__c;
					item.unit = discount.ADTUnit__c;
					//System.debug('item.unit = ' + item.unit + '    ' + 'discount.Autoniq_Discount_Type__r.Unit__c = ' + subscriptionItem.Autoniq_Discount_Assignments__r.Autoniq_Discount_Type__r.Unit__c);
					item.type ='Discount';
					if (discount.ADTUnit__c == 'Amount') {
						item.discountOffAmount = discount.ADTValue__c;
						system.debug('value is'+discount.ADTValue__c);
					}
					else if (discount.ADTUnit__c == 'Percent') {
						item.discountPercentage = discount.ADTValue__c;
						system.debug('percent is'+discount.ADTValue__c);
					}
					
			}
			system.debug('item after popluating discounts-> ' + item);
			orderItemsWrapped.put(subscriptionItem.Id, item);
		}
		system.debug('@@@ orderItemsWrapped size for insert in updatediscounts' + orderItemsWrapped.size());
	}
		return orderItemsWrapped;
	}
}