trigger PurchaseAfterInsert on Purchase__c (after insert) {

List<Purchase__c> buyerUpdatingPurchases = new List<Purchase__c>();
  
  buyerUpdatingPurchases =
  [
  SELECT Id,
  Private_Label__c,
  ATC_Buyer_Contact__r.Openlane_US_Purchase_Last_120__c,
  ATC_Buyer_Contact__r.Openlane_CA_Purchase_Last_120__c
  FROM Purchase__c
  WHERE Id IN : trigger.new
  ];
  
List<Contact> contactsToUpdate = new List<Contact>();
   
  
  for (Purchase__c purch : buyerUpdatingPurchases)
  {
    if ('OPENLANE Auction'.equalsIgnoreCase(purch.Private_Label__c) && purch.ATC_Buyer_Contact__c != null)
    {
        if (purch.ATC_Buyer_Contact__r.Openlane_US_Purchase_Last_120__c == false)
        {
            purch.ATC_Buyer_Contact__r.Openlane_US_Purchase_Last_120__c = true;
            contactsToUpdate.add(purch.ATC_Buyer_Contact__r);
        }       
    }
    
    else if ('OPENLANE.ca Open Auction'.equalsIgnoreCase(purch.Private_Label__c) && purch.ATC_Buyer_Contact__c != null)
    {
        if (purch.ATC_Buyer_Contact__r.Openlane_CA_Purchase_Last_120__c == false)
        {
            purch.ATC_Buyer_Contact__r.Openlane_CA_Purchase_Last_120__c = true;
            contactsToUpdate.add(purch.ATC_Buyer_Contact__r); 
        }       
    }
    
  }
  


  
update contactsToUpdate;

}