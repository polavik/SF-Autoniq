public class AutoniqAccountTriggerHandler{

 public void OnAfterInsert(List<Autoniq_Account__c > newRecords){
   // updatePrimaryCountry(newRecords); salesorder=account,salesorderitem=subscription
  }

  // update the primary country when records are updated from trigger  
  public void OnAfterUpdate(List<Autoniq_Account__c > oldRecords, 
      List<Autoniq_Account__c > updatedRecords,  Map<ID, Autoniq_Account__c > oldMap, 
      Map<ID, Autoniq_Account__c > newMap){
   // updatePrimaryCountry(updatedRecords); 
  }
/*private void updatePrimaryCountry(List<Sales_Order_Item__c> newRecords) {

    // create a new map to hold the sales order id / country values
    Map<ID,String> salesOrderCountryMap = new Map<ID,String>();

    // if an item is marked as primary, add the purchased country
    // to the map where the sales order id is the key 
    for (Sales_Order_Item__c soi : newRecords) {
      if (soi.Primary_Item__c)
        salesOrderCountryMap.put(soi.Sales_Order__c,soi.Purchased_Country__c);
    } 

    // query for the sale orders in the context to update
    List<Sales_Order__c> orders = [select id, Primary_Country__c from Sales_Order__c 
      where id IN :salesOrderCountryMap.keyset()];

    // add the primary country to the sales order. find it in the map
    // using the sales order's id as the key
    for (Sales_Order__c so : orders)
      so.Primary_Country__c = salesOrderCountryMap.get(so.id);

    // commit the records 
    update orders;

  }*/

}