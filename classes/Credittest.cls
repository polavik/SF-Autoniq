public with sharing class Credittest {
	static Product2 creditProduct;
	static PricebookEntry  creditPBE; 

	public static void Credit ( List<OrderItem> orderItems ) {
		system.debug('--> orderItems ' + orderItems);
		creditPBE = PricebookUtility.productCode_to_priceBookEntry.get('CREDIT');
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrappedForCredits = populateCredits (orderitems);
        system.debug('## orderItemsWrappedForCredits ' + orderItemsWrappedForCredits );
		if (orderItemsWrappedForCredits.values().size() > 0) {
			applyCredits( orderItemsWrappedForCredits.values() );
		}
	}
	Public static Map <Id, ATNQBillingUtil.MyOrderItem> populateCredits (List<OrderItem> orderItems) {
		Set<Id> subscriptionItemIds = new Set <Id> ();
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrapped = new Map <Id,ATNQBillingUtil.MyOrderItem>();
		for (OrderItem orderItem : orderItems) {
			ATNQBillingUtil.MyOrderItem orderItemWrapped = new ATNQBillingUtil.MyOrderItem();
			orderItemWrapped.id = orderitem.Id;
			orderItemWrapped.orderId = orderItem.OrderId;
			orderItemWrapped.originalUnitPrice = orderitem.UnitPrice;
			orderItemWrapped.subscriptionItemId = orderitem.Subscription_Item__c;
			orderItemsWrapped.put( orderitem.Subscription_Item__c, orderItemWrapped );
			subscriptionItemIds.add( orderitem.Subscription_Item__c );
		}
		for (Subscription_Item__c subscriptionItem : [SELECT Id,Subscription__c , Amount__c,Status__c,Product_Name__c
			 FROM Subscription_Item__c WHERE  Id IN : subscriptionItemIds and Product_Name__c='Credit' and Status__c IN ('Active')] )

		{
			if( subscriptionItem.Status__c=='Active')
			{
			ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItem.Id);
			item.discountOffAmount = subscriptionItem.Amount__c *-1;
			item.type = 'Credit';
			item.subscriptionItemId=subscriptionItem.Id;
			item.ProductCode='CREDIT';
			system.debug('discountOffAmount'+item.discountOffAmount);
			orderItemsWrapped.put(subscriptionItem.Id, item);
		 	}
		system.debug('size of orderitemswrapped'+orderItemsWrapped.values().size());
		}
		return orderItemsWrapped;
	
}	
	public static List <OrderItem> applyCredits (List <ATNQBillingUtil.MyOrderItem> orderItemsWrapped) {
		List <OrderItem> orderItemsToUpdate = new List <OrderItem>();
        List<Subscription_Item__c> updateSubscriptionItem = new List<Subscription_Item__c> ();
		Set <Id> orderIds = new Set<Id>();
		Set <Id> orderItemIds = new Set<Id>();
		//chk for price book entry as credit,create a list and assign it to soql query where pbe=credit,update the unitprice with amount__c
		for (ATNQBillingUtil.MyOrderItem orderItemWrapped : orderItemsWrapped) {
			orderIds.add(orderItemWrapped.orderId);
			orderItemIds.add(orderItemWrapped.Id);
		}
		Map <Id, Order> orderId_to_totalAmount = new Map<Id, Order>([SELECT Id, Totalamount FROM Order WHERE Id IN : orderIds]);
        for (ATNQBillingUtil.MyOrderItem oi : orderItemsWrapped) {
			system.debug('#@# orderitem wrapped ' + oi);
            if (oi.discountoffAmount!=null){
            if 	(((oi.discountOffAmount*-1) > orderId_to_totalAmount.get(oi.orderid).Totalamount)){
                Decimal order_credit_amt =  orderId_to_totalAmount.get(oi.orderid).Totalamount * -1;
                Decimal subscription_amt = (oi.discountOffAmount * -1) - orderId_to_totalAmount.get(oi.orderid).Totalamount;
                orderItemsToUpdate.add(new OrderItem(
						Subscription_Item__c = oi.subscriptionItemId,
						PricebookEntryId = creditPBE.Id, 
						OrderId = oi.orderId,
						UnitPrice=order_credit_amt,
						Quantity = 1,
						OriginalOrderItemId = oi.Id,
						Id = oi.Id				
					));
                updateSubscriptionItem.add(new Subscription_Item__c(
						Id = oi.subscriptionitemId, 
						Amount__c =subscription_amt
						));
                
            }
            else{
                 		 orderItemsToUpdate.add(new OrderItem(
						Subscription_Item__c = oi.subscriptionItemId,
						PricebookEntryId = creditPBE.Id, 
						OrderId = oi.orderId,
						UnitPrice=oi.discountOffAmount,
						Quantity = 1,
						OriginalOrderItemId = oi.Id,
						Id = oi.Id				
					));
                    updateSubscriptionItem.add(new Subscription_Item__c(
						Id = oi.subscriptionitemId, 
						Status__c = 'InActive'
						));
                                    
				}
            }
          
		system.debug('#@# orderItemsToUpdate ' + orderItemsToUpdate);
		}
		if (orderItemsToUpdate.size() > 0) {			
			update orderItemsToUpdate;			
		}

		if (updateSubscriptionItem.size() > 0) {
			update updateSubscriptionItem;
		}
		return orderItemsToUpdate;

	}
}