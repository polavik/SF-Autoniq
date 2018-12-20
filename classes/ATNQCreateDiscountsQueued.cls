public class ATNQCreateDiscountsQueued implements Queueable {
	public List <OrderItem> orderItemsCreated;
	public ATNQCreateDiscountsQueued( List <OrderItem> orderItemsCreated ) {
		this.orderItemsCreated = orderItemsCreated;
	}
	public void execute(QueueableContext context) {
    	ATNQCalculateDiscounts.Discount(orderItemsCreated);
    	//Credittest.Credit(orderItemsCreated);
    	Set<id> orid=new set<id>();
        for(orderitem oi:orderItemsCreated)
        {
        	orid.add(oi.OrderId);
        }
        List<Integration__c> intg=new List<Integration__c>();
		for(Id id:orid)
		{
			Integration__c ii=new Integration__C(API_Name__c='RATEPOINT',Order__c=id);
			intg.add(ii);
		}
		insert intg;
    	

   }      
       
 }