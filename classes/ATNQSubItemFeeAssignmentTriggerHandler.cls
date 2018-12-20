public class ATNQSubItemFeeAssignmentTriggerHandler {
public static void UpdateOrderWithFee(Map<Id,Subscription_Item__c> newVersionMap){      
    Map<Id,Decimal> subscriptionId_to_amount = new Map<Id,Decimal>();
    for(String si:newVersionMap.keySet()){
        system.debug('I am inside the trigger map for loop');
        system.debug('the if condition pre value'+newVersionMap.get(si).ProductCode__c);
        system.debug('the if condition post value'+Constants.PRODUCT_CODE_FEE);
        if(newVersionMap.get(si).ProductCode__c==Constants.PRODUCT_CODE_FEE){
            String subscriptionId = newVersionMap.get(si).Subscription__c;
            Decimal d=newVersionMap.get(si).Amount__c;
            system.debug('the subscription id is'+subscriptionId);
             
			system.debug('i got my subID list ready');
            system.debug('the amount from subscription item map is'+newVersionMap.get(si).Amount__c);
           subscriptionId_to_amount.put(subscriptionId,d);
            //system.debug('the amount value i got finaaly is'+subscriptionId_to_amount.get(subscriptionId).add(newVersionMap.get(si).Amount__c));
      
        }
    }   
    Product2 p=[SELECT ProductCode,Id FROM Product2 WHERE ProductCode =: Constants.PRODUCT_CODE_FEE];
    system.debug('productcode'+p.ProductCode);
    List<Order> ord=[SELECT Id ,Status,Pricebook2Id,Subscription__c from Order where (Status =: Constants.ORDER_STATUS_PENDING OR Status =: Constants.ORDER_STATUS_DRAFT ) AND Subscription__c IN : subscriptionId_to_amount.keySet() ];
    List<OrderItem> orderItemsToInsert  = new List<OrderItem>();
    PricebookEntry pbe = PricebookUtility.productCode_to_priceBookEntry.get(p.ProductCode);    
    for(Order o:ord){
        system.debug('i am in order and order size is'+ord.size());
        for(Decimal Amount:subscriptionId_to_amount.values()){
            if(subscriptionId_to_amount.size()>0){
        	system.debug('map size is more than zero');
            OrderItem oi=new OrderItem();
          	system.debug('i am in sub id to amount loop and my size is'+subscriptionId_to_amount.size());
        	oi.OrderId=o.id;
        	System.debug('order id is'+o.id);
        	oi.PricebookEntryId= pbe != null ? pbe.Id : null;
         	system.debug('pricebookentry id is'+oi.PricebookEntryId);   
        	oi.Quantity=1;
        	oi.Product2Id=p.id;
          	system.debug('product id is'+p.id);
        //	oi.UnitPrice=Amount * -1; 
           oi.UnitPrice= subscriptionId_to_amount.get('Amount__c')*-1;  
			system.debug('the amount is'+Amount);               
            orderItemsToInsert.add(oi);   
        }
      }
    
    if(orderItemsToInsert.size()>0)
    	Insert orderItemsToInsert;
    System.enqueueJob( new ATNQCreateDiscountsQueued(orderItemsToInsert) );
	}
  }
}