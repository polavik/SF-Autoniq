public with sharing class ATNQUpdateOrders {
	public static void UpdateOrders(List<Order> allorders) {
		List<Order> updateorders=new List<Order>();

		for(Order ordertobeupdated:allorders){
			updateorders.add(new Order(
						Id = ordertobeupdated.Id, 
						Status ='Activated'
						));
		}
		update updateorders;

	}
    
    public static void setStatusForOrders(List<Order> allorders, String statusValue) {
		List<Order> updateorders=new List<Order>();

		for(Order ordertobeupdated:allorders){
			updateorders.add(new Order(
						Id = ordertobeupdated.Id, 
						Status =statusValue
						));
		}
		update updateorders;

	}
}