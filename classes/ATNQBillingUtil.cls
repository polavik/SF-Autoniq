public with sharing class ATNQBillingUtil {


	public static boolean isInBillingPeriod ( Date nextBillDate, Date subItemEndDate ) {
		return (subItemEndDate != null && subItemEndDate < nextBillDate.addMonths(+1) && subItemEndDate > nextBillDate);
	}

	public static boolean isInBillingPeriod ( Date subItemStartDate, Date subItemEndDate, Date nextBillDate ) {
		boolean isInBetweenDates;
		Date startOfNextSub = nextBillDate.addMonths(1).addDays(-1);
		isInBetweenDates = ((subItemStartDate < subItemEndDate) && (((subItemStartDate >= nextBillDate) && (subItemEndDate < startOfNextSub)) || ((subItemStartDate > nextBillDate) && (subItemEndDate <= startOfNextSub))));
		return isInBetweenDates;
	}

	public static integer numberOfDaysProrated ( Date nextBillDate, Date subItemEndDate ) {
		if(subItemEndDate<nextBillDate){
			return 0;
		}
		return nextBillDate.daysBetween(subItemEndDate) + (cancelAtTheEndOfTheDay?1:0);
	}

	public static decimal proratedPriceForMonthlySubscription(decimal price, integer numberOfDays, Date startDate) {
		decimal daysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
		decimal pricePerDay  = (decimal)(price / daysInMonth);

		decimal proratedPrice = (pricePerDay * numberOfDays).setScale(2, RoundingMode.HALF_UP);
		return proratedPrice;

	}

	public static List<MyOrderItem> createOrderItemsFromSubItems(Map <Id, Id> subscriptionId_to_orderId, Subscription__c subscription, List <Subscription_Item__c> subItems) {
		System.debug('=================> Util subscriptionId_to_orderId: ' + subscriptionId_to_orderId);
		System.debug('=================> Util subItems: ' + subItems);
		List <MyOrderItem> orderItems = new List <MyOrderItem>();
		
		for (Subscription_Item__c subItem : subItems) {
			MyOrderItem oi = new MyOrderItem();
			if (subscriptionId_to_orderId != null) {
				oi.orderId = subscriptionId_to_orderId.get(subscription.Id);
			}
			oi.subscriptionId = subscription.Id;
			oi.subscriptionRecord = subscription;
			oi.subscriptionItemId = subItem.Id;
			oi.ProductCode = subItem.Product__r.ProductCode;
			oi.startDate = subItem.Start_Date__c;
			if (subItem.Cancel_Date__c != null && subItem.Cancel_Date__c < subscription.Next_Bill_Date__c.addMonths(+1)) {
				oi.endDate = subItem.Cancel_Date__c;
			}else{
				oi.endDate = subscription.Next_Bill_Date__c.addMonths(+1).addDays(-1);
			}
			orderItems.add(oi);
		}
		System.debug('=================> Util returning orderItems: ' + orderItems);
		return orderItems;
	}

	public static List <OrderItem> getOrderItemsToInsert (List <MyOrderItem> orderItems) {
		List <OrderItem> orderItemsToInsert = new List <OrderItem>();
		for (MyOrderItem oi : orderItems) {
			Decimal price, perdayprice;
			Integer daystobebilled = 0, daysProrated;
			Date startofbilldate, endofbilldate;
			PricebookEntry pbe = PricebookUtility.productCode_to_priceBookEntry.get(oi.ProductCode);
			startofbilldate = oi.subscriptionRecord.Next_Bill_Date__c;
			endofbilldate = oi.subscriptionRecord.Next_Bill_Date__c.addMonths(+1).addDays(-1);

			if(isInBillingPeriod(oi.startDate, oi.endDate,startofbilldate )){		
				integer numberOfDays = numberOfDaysProrated(oi.startDate, oi.endDate);
				price = proratedPriceForMonthlySubscription(pbe.unitPrice, numberOfDays,oi.startDate);
			}else{
				price = pbe.unitPrice;
			}

			orderItemsToInsert.add(new OrderItem(
			                           OrderId = oi.orderId,
			                           Subscription_Item__c = oi.subscriptionItemId,
			                           PricebookEntryId = pbe != null ? pbe.Id : null,
			                           Quantity = 1,
			                           UnitPrice = price
			                       ));
		}

		return orderItemsToInsert;
	}

	public class MyOrderItem {
		public Id subscriptionId, subscriptionItemId, orderId, Id;
		public Subscription__c subscriptionRecord;
		public Date startDate, endDate;
		public string ProductCode;
		public Decimal originalUnitPrice;
		//public List <Discount> discounts;
		public string unit, term;
		public decimal discountOffAmount, discountPercentage;
		public string type;
		public string assignmentId;
	}
    
    public static BillingPriceBooks setBillingPriceBooks(List<OrderItem> orderItems){
        BillingPriceBooks pb = new BillingPriceBooks();
        Product2 discountProduct, creditProduct,feeProduct;
        
        pb.discountProduct = [SELECT Id, ProductCode From Product2 WHERE Name = 'Discount' LIMIT 1];
        pb.creditProduct = [SELECT Id, ProductCode From Product2 WHERE Name = 'Credit' LIMIT 1];
		pb.discountPBE = PricebookUtility.productCode_to_priceBookEntry.get(pb.discountProduct.ProductCode);
		pb.creditPBE = PricebookUtility.productCode_to_priceBookEntry.get('CREDIT');
        
        return pb;
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

                if (subscription.Term__c == 'Monthly') {
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addMonths(1);
                }
                else if (subscription.Term__c == 'Annual'){
                    subscriptionToUpdate.Next_Bill_Date__c = subscription.Next_Bill_Date__c .addYears(1);//.addDays(daysBefore_monthly * -1);//addDays(daysBefore_annually * -1);

                }
            subscriptionsToUpdate.add(subscriptionToUpdate);
        }
        system.debug('The subscription is about to update');
        update subscriptionsToUpdate;
    }
    
    public Class BillingPriceBooks {
        public PricebookEntry discountPBE, creditPBE,feePBE;
        public Product2 discountProduct, creditProduct, feeProduct;
        
        public BillingPriceBooks(){
            
        }
    }

	public static  boolean cancelAtTheEndOfTheDay = true;

	/*public class Discount {
	                public string unit;
	                public decimal discountOffAmount, discountPercentage;
	                public string type;
	                public string assignmentId;
	}*/

}