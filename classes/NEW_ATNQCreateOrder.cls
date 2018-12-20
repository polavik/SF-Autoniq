public class NEW_ATNQCreateOrder  {
    
    public List<Order> findLastOrderList(List<Subscription__c> subscriptions){
        
        return null;
    }
    
    /*
    public static List <ATNQBillingUtil.MyOrderItem> orderItemList = new List <ATNQBillingUtil.MyOrderItem>();
    public static List <Order> orderList = new List <Order>();
    public static Map<Id, 
   
    public static void CreateOrders(List<Subscription__c> subscriptionList) {
        
        Map<Id, <DTO>> dtoMap = new Map<Id, <DTO>>();
        for(Subscription__c sub: subscriptionList){
            orderList.add(createOrder(sub));
            DTO d = new DTO(sub);
            dtoMap.put(sub.Id, d);
        }
        
        insert orderList;
        
        List<Order> ordersCreated = [SELECT Id, Subscription__c FROM Order WHERE Id IN : orderList];
        
        for(Order o: ordersCreated){
            dtoMap.get(o.Subscription__c).orderId = o.Id;
        }
        
        List<ATNQBillingUtil.MyOrderItem> orderItemsToBeInserted = new List<ATNQBillingUtil.MyOrderItem>();
        for(Id key: dtoMap.keySet()){
            DOT d = dtoMap.get(key);
            d.orderItems = createOrderItems(d.subscription, d.orderId);
            orderItemsToBeInserted.addAll(d.orderItems);
        }
        
        System.enqueueJob( new ATNQCreateDiscountsQueued( ATNQBillingUtil.getOrderItemsToInsert(orderItemsToBeInserted)));
        
        

        Map<Order, List<ATNQBillingUtil.MyOrderItem>> orderOrdrItemListMap = ATNQBillingUtil.pupulateOrderListAndOrderItemList(subscriptionList);
        List<orderItem> orderItemsToInsertWithOrderId = ATNQBillingUtil.setOrderIdForOrderItems(orderList, orderItemList);
        insert orderItemsToInsertWithOrderId;
        System.enqueueJob( new ATNQCreateDiscountsQueued(orderItemsToInsertWithOrderId) );
    }
 
   	@testVisible
    private static void pupulateOrderListAndOrderItemList(List<Subscription__c> subscriptionList){
        for (Subscription__c subscription : subscriptionList) {
               orderList.add(createOrder(subscription));
               orderItemList.addAll(createOrderItems (subscription));
        }
    }
    
    @testVisible
    private static Order createOrder(Subscription__c subscription) {
        Date orderEndate = setEndDate(subscription);
        Order o = new Order (
            Subscription__c = subscription.Id,
            AccountId = subscription.Contact__r.AccountId, 
            BillToContactId = subscription.Contact__c,             
            Status = Constants.ORDER_STATUS_DRAFT,
            EffectiveDate = subscription.Next_Bill_Date__c,           
            Pricebook2Id = PricebookUtility.StandardPricebook.Id,
            EndDate=orderEndate
        );
        return o;
    }
   
    @testVisible
    private static Map<Id,Id> createSubscriptionIdToOrderIdMap(List<Order> orders, List<ATNQBillingUtil.MyOrderItem> orderItemList){
        Map <Id, Id> subscriptionIdToOrderIdMap = new Map <Id, Id>();
        for (Order createdOrder : [SELECT Id, Subscription__c FROM Order WHERE Id IN : orders]) {
            subscriptionIdToOrderIdMap.put(createdOrder.Subscription__c, createdOrder.Id);
        }
        return subscriptionIdToOrderIdMap;
    }

    @testVisible
    private static List<orderItem> setOrderIdForOrderItems(List<Order> orderList, List<ATNQBillingUtil.MyOrderItem> orderItemList){
        Map<Id,Id> subscriptionIdToOrderIdMap = createSubscriptionIdToOrderIdMap(orderList, orderItemList);
        for (ATNQBillingUtil.MyOrderItem oi : orderItemList){
            oi.orderId = subscriptionIdToOrderIdMap.get(oi.subscriptionId);
        }
        return ATNQBillingUtil.getOrderItemsToInsert(orderItemList);
    }
   
    @testVisible
    private static Date setEndDate(Subscription__c subscription){
       
        Date endDate;
        if(subscription.Term__c == 'Monthly'){
            endDate=subscription.Next_Bill_Date__c.addMonths(1).addDays(-1);
        }
        else
        {
            //Endate=   subscription.Next_Bill_Date__c.addYears(1).addDays(-1);
            endDate= subscription.Next_Bill_Date__c.addMonths(12);
        }      
        return endDate;
    }
 
    private static List<ATNQBillingUtil.MyOrderItem> createOrderItems (Subscription__c subscription, Id, orderId ) {
        List <ATNQBillingUtil.MyOrderItem> orderItems = ATNQBillingUtil.createOrderItemsFromSubItems(orderId, subscription, subscription.Subscription_Item__r);
        return orderItems;
    }
    
    @testVisible
    private static List<ATNQBillingUtil.MyOrderItem> createOrderItems (Subscription__c subscription ) {
        List <ATNQBillingUtil.MyOrderItem> orderItems = ATNQBillingUtil.createOrderItemsFromSubItems(null, subscription, subscription.Subscription_Item__r);
        return orderItems;
    }
    
    public class SubscriptionOrderDTO{
        public Subscription__c subscription;
		public list<MyOrderItem> myOrderItems;
        public Order order;

        public SubscriptionOrderDTO(Subscription__c sub){
            subscription = sub;
            myOrderItems = new List<MyOrderItem>();
            orders = new List<Order>();
		} 
    }
    
    public class DTO{
        public Subscription__c s subscription;
		public list<MyOrderItem> myOrderItems;
        public Id orderId;

        public DTO(Subscription__c sub){
            subscription = sub;
            myOrderItems = new List<MyOrderItem>();
            //orderId = Order;
		} 
    }
   */
}