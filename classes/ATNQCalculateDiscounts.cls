/**This apex class applies discounts,credits and fee to order line items and updates the subscription next bill date**/

public class ATNQCalculateDiscounts {
	static Product2 discountProduct, creditProduct,feeProduct;
	static PricebookEntry discountPBE, creditPBE,feePBE; 

	public static void Discount ( List<OrderItem> orderItems ) {
		system.debug('--> orderItems ' + orderItems);
		discountProduct = [SELECT Id, ProductCode From Product2 WHERE Name = 'Discount' LIMIT 1];
        creditProduct = [SELECT Id, ProductCode From Product2 WHERE Name = 'Credit' LIMIT 1];
        feeProduct =[SELECT Id, ProductCode From Product2 WHERE Name = 'Fee' LIMIT 1];
		discountPBE = PricebookUtility.productCode_to_priceBookEntry.get(discountProduct.ProductCode);
		creditPBE = PricebookUtility.productCode_to_priceBookEntry.get('CREDIT');
		feePBE = PricebookUtility.productCode_to_priceBookEntry.get('FEE');
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrapped = populateOIsForDiscounts (orderitems);
		system.debug('the values wrapped for applying discounts'+orderItemsWrapped.size());
		applyDiscounts(orderItemsWrapped.values());
		system.debug('the size of orderitemswrapped before calling applycredits'+orderItemsWrapped.values().size());
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrappedForCredits = populateCredits (orderitems);
        system.debug('## orderItemsWrappedForCredits ' + orderItemsWrappedForCredits );
		if (orderItemsWrappedForCredits.values().size() > 0) {
			applyCredits( orderItemsWrappedForCredits.values());
		}
		Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrappedFee = populateFee(orderitems);
        system.debug('## orderItemsWrappedForFee ' + orderItemsWrappedFee);
		if (orderItemsWrappedFee.values().size() > 0) {
			applyFee( orderItemsWrappedFee.values());
		}

		SetNextBillingDate(orderItems);
		
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
		for (Subscription_Item__c subscriptionItem : [SELECT Id, Subscription__r.Next_Bill_Date__c,
			(SELECT Id, Start_Date__c, End_Date__c, ADTUnit__c, ADTValue__c
			FROM Autoniq_Discount_Assignments__r) FROM Subscription_Item__c WHERE Id = : subscriptionItemIds]){
			ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItem.Id);
			system.debug('item -> ' + item);
			for (Autoniq_Discount_Assignment__c discount : subscriptionItem.Autoniq_Discount_Assignments__r) {
				system.debug('the next bill date is'+subscriptionItem.Subscription__r.Next_Bill_Date__c);
				system.debug('The end date on discount records is'+discount.End_Date__c);
				system.debug('the start date on discount '+discount.Start_Date__c);
				if (isDiscountValidForBillingPeriod(subscriptionItem.Subscription__r.Next_Bill_Date__c, discount.End_Date__c )) {
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
     Public static Map <Id, ATNQBillingUtil.MyOrderItem> populateFee (List<OrderItem> orderItems) {
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
			 FROM Subscription_Item__c WHERE  Id IN : subscriptionItemIds and Product_Name__c='Fee' and Status__c IN ('Active')] )

		{
			if( subscriptionItem.Status__c=='Active')
			{
			ATNQBillingUtil.MyOrderItem item = orderItemsWrapped.get(subscriptionItem.Id);
			item.discountOffAmount = subscriptionItem.Amount__c ;
			item.type = 'Fee';
			item.subscriptionItemId=subscriptionItem.Id;
			item.ProductCode='FEE';
			system.debug('fee Amount'+item.discountOffAmount);
			orderItemsWrapped.put(subscriptionItem.Id, item);
		 	}
		system.debug('size of orderitemswrapped'+orderItemsWrapped.values().size());
		}
		return orderItemsWrapped;
	
    }	
    public static List <OrderItem> applyFee (List <ATNQBillingUtil.MyOrderItem> orderItemsWrapped) {
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
            
            
                 		orderItemsToUpdate.add(new OrderItem(
						Subscription_Item__c = oi.subscriptionItemId,
						PricebookEntryId = feePBE.Id, 
						OrderId = oi.orderId,
						UnitPrice=oi.discountOffAmount,
						Quantity = 1,
						OriginalOrderItemId = oi.Id,
						Id = oi.Id				
					));
                    
                                    
				}
            }
          
		system.debug('#@# orderItemsToUpdate ' + orderItemsToUpdate);
		
		if (orderItemsToUpdate.size() > 0) {			
			update orderItemsToUpdate;			
		}

		
		return orderItemsToUpdate;

	}
	public static boolean isDiscountValidForBillingPeriod(Date nextBillDate,  Date discountEndDate) {
		return (nextBillDate != null  && discountEndDate != null &&  nextBillDate<=discountEndDate/*&& discountStartDate != null&&discountEndDate>=nextBillDate.addmonths(+1)*/);
	}


	public static List <OrderItem> applyDiscounts (List <ATNQBillingUtil.MyOrderItem> orderItemsWrapped) {
		//system.debug('!!! orderItemsWrapped ' + orderItemsWrapped);
		List <OrderItem> orderItemsToInsert = new List <OrderItem>();
		for (ATNQBillingUtil.MyOrderItem oiWrapped : orderItemsWrapped) {
			//for (ATNQBillingUtil.DIscount discount : oiWrapped.discounts) {0

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
			
		}
		System.debug('orderItemsToInsert.size =' + orderItemsToInsert.size());
		if (orderItemsToInsert.size() > 0) {			
			insert orderItemsToInsert;			
		}
		return orderItemsToInsert;
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
						Status__c = 'InActive',
						Amount__c = 0.00
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
	public static void SetNextBillingDate (List <OrderItem> orderitemstoupdatesub) {
		//Set<Id> subscriptionItemIds = new Set <Id> ();
		List <Subscription__c> subscriptionsToUpdate = new List <Subscription__c>();
        Set <Id> orderIds = new Set<Id>();
        Set <Id> subscriptionIds = new Set<Id> ();
        integer daysBefore_monthly, daysBefore_annually;
		//Map <Id, ATNQBillingUtil.MyOrderItem> orderItemsWrapped = new Map <Id,ATNQBillingUtil.MyOrderItem>();
		for (OrderItem oi: orderitemstoupdatesub) {
			orderIds.add(oi.OrderId);
			//subscriptionIds.add(orderitemstoupdatesub.orderIdsubscriptionid);
		}

        ATNQ_Order_Creation_Config__mdt [] orderCreationConfig = [SELECT Days_before_creation_Annually__c, Days_before_creation_Monthly__c FROM ATNQ_Order_Creation_Config__mdt];
        daysBefore_monthly =  integer.valueOf(orderCreationConfig[0].Days_before_creation_Monthly__c);
        daysBefore_annually  = integer.valueOf(orderCreationConfig[0].Days_before_creation_Annually__c );

        Date adjustedDateAnnualy, adjustedDateMonthly;
        adjustedDateMonthly = system.today().addDays(daysBefore_monthly * -1);
        adjustedDateAnnualy = system.today().addDays(daysBefore_annually * -1);
        

        for (Order o : [select Id,Subscription__c  from order where id in : orderIds]) {
            subscriptionIds.add ( o.Subscription__c );
            
        }
        for (Subscription__c subscription : [SELECT Id, Next_Bill_Date__c, Term__c FROM Subscription__c WHERE Id IN : subscriptionIds ]) {
            Subscription__c subscriptionToUpdate = new Subscription__c(Id = subscription.Id);

           /* if (subscription.Next_Bill_Date__c == null) {
                if (subscription.Term__c == 'Monthly') {
                    subscriptionToUpdate.Next_Bill_Date__c = adjustedDateMonthly.addMonths(1);
                }
                else  if (subscription.Term__c == 'Annual'){
                    subscriptionToUpdate.Next_Bill_Date__c = adjustedDateMonthly.addYears(1);
                    
                }
            } 
            else{*/
                if (subscription.Term__c == 'Monthly') {
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addMonths(1);
                }
                else if (subscription.Term__c == 'Annual'){
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addYears(1);//.addDays(daysBefore_monthly * -1);//addDays(daysBefore_annually * -1);

                }
            //}
            subscriptionsToUpdate.add(subscriptionToUpdate);
        }
        system.debug('The subscription is about to update');
        update subscriptionsToUpdate;
    }
	
}