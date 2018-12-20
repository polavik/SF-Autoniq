public class ATNQCreateOrders  {
   
    public static List <Order> CreateOrders(List<Subscription__c> subscriptions) {
 
        List <ATNQBillingUtil.MyOrderItem> orderItems = new List <ATNQBillingUtil.MyOrderItem>();
        List <Order> orders = new List <Order>();
        for (Subscription__c subscription : subscriptions) {
            Order ord = createOrder(subscription);
            orders.add(ord);
            List <ATNQBillingUtil.MyOrderItem> oiList = createOrderItems(subscription);
            orderItems.addAll(oiList);
        }

        insert orders;
       
        Map <Id, Id> subscriptionId_to_orderId = new Map <Id, Id>();
        for (Order createdOrder : [SELECT Id, Subscription__c FROM Order WHERE Id IN : orders]) {
            subscriptionId_to_orderId.put(createdOrder.Subscription__c, createdOrder.Id);
        }
        for (ATNQBillingUtil.MyOrderItem oi : orderItems){
            oi.orderId = subscriptionId_to_orderId.get(oi.subscriptionId);
        }
 
        List <OrderItem> orderItemsToInsert = ATNQBillingUtil.getOrderItemsToInsert(orderItems);
        insert orderItemsToInsert;
 
        // ATNQ-1829 The Order needs to be Activated at the End of a Billing Period                ----------------
        List<Id> orderAccountIdList = getSubscriptionAccountIdList(subscriptions);
        List<Order> ordersNeedingStatusChange = setStatusOfOrdersRelatedToAccounts(orderAccountIdList,orders, Constants.ORDER_STATUS_ACTIVATED);
        update ordersNeedingStatusChange;
        // ------------------------------------------------------------------------------------------
 
 
        //ATNQCalculateDiscounts.Discount(orderItemsToInsert);
        System.enqueueJob( new ATNQCreateDiscountsQueued(orderItemsToInsert) );
        //OrderTriggerHandler.SetNextBillingDate(orders);
        return orders;
    }
 
    private static Order createOrder(Subscription__c subscription) {
        Date Endate;
        if(subscription.Term__c == 'Monthly'){
            Endate=subscription.Next_Bill_Date__c.addMonths(1).addDays(numberOfDaysInAdvanceForMonthlySubs);
        }
        else
        {
            Endate= subscription.Next_Bill_Date__c.addMonths(12).addDays(numberOfDaysInAdvanceForAnnualSubs);
        }
        Order o = new Order (
            Subscription__c = subscription.Id,
            AccountId = subscription.Contact__r.AccountId, 
            BillToContactId = subscription.Contact__c,             
            Status = Constants.ORDER_STATUS_DRAFT,
            EffectiveDate = subscription.Next_Bill_Date__c,           
            Pricebook2Id = PricebookUtility.StandardPricebook.Id,
            EndDate=Endate
 
 
        );
        return o;
   
    }
 
    @testVisible
    private static List<Order> setStatusOfOrdersRelatedToAccounts(List<Id> accountIdList, List<Order> newOrders,String newStatus){       
        List<OrderItem> oiList = [select Id,Subscription_Item__r.Product__c,Subscription_Item__r.Product__r.ProductCode, Order.Id, OrderId, Order.AccountId, Order.Account.Name, Subscription_Item__r.Subscription__r.Autoniq_Account__c from OrderItem where order.Id NOT IN: newOrders];
        Set<Order> orders = new Set<Order>();
        for(OrderItem oi: oiList){
               orders.add(oi.order);
        }
        List<Order> draftOrders = new List<Order>(orders);
		for(Order o: draftOrders){
			o.Status = newStatus;
		}
 
		return draftOrders;
    }
 
    @testVisible
    private static List<Id> getSubscriptionAccountIdList(List<Subscription__c> subList){
		List<Id> subscriptionAccountIdList = new List<Id>();
		for(Subscription__c sub: subLIst){
			subscriptionAccountIdList.add(sub.Autoniq_Account__c);
		}
		return subscriptionAccountIdList;
    }
 
 
    @testVisible
    private static List<ATNQBillingUtil.MyOrderItem> createOrderItems (Subscription__c subscription ) {
        List <ATNQBillingUtil.MyOrderItem> orderItems = ATNQBillingUtil.createOrderItemsFromSubItems(null, subscription, subscription.Subscription_Item__r);
        return orderItems;
    }
    
    public static final integer numberOfDaysInAdvanceForAnnualSubs = -45;
    public static final integer numberOfDaysInAdvanceForMonthlySubs = -1;
   
}