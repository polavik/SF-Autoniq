trigger PurchaseBeforeInsert on Purchase__c (before insert) {



//The following code relates the Purchase to their Buyer/Seller Contacts if they exist
//This is to solve the issue of duplicate Contacts not allowing AMS Purchases to insert
//PPM 85129
List<Purchase__c> purchsWithBuyerContact = new List<Purchase__c>();
List<Purchase__c> purchsWithSellerContact = new List<Purchase__c>();
Set<String> auctionAccessIdSet = new Set<String>();
Map<String, Contact> AAIDContMap = new Map<String, Contact>();

for(Purchase__c purch : Trigger.new)
{

    if (purch.AMS_Inventory_ID__c != null)//Only do this to AMS Purchases
    {
    
        if(purch.Buyer_Contact_AAID__c != null)//Make a list of all Purches to be considered
        {
        purchsWithBuyerContact.add(purch);
        auctionAccessIdSet.add(purch.Buyer_Contact_AAID__c);//Keep a list of all AAIDs used
        }
        
        if(purch.Seller_Contact_AAID__c != null)
        {
        purchsWithSellerContact.add(purch);
        auctionAccessIdSet.add(purch.Seller_Contact_AAID__c);
        }

    }

if(auctionAccessIdSet.contains('5999998'))//Don't link to dummy AAIDs
    {
        auctionAccessIdSet.remove('5999998');
    }

if(auctionAccessIdSet.contains('5999999'))
    {
        auctionAccessIdSet.remove('5999999');
    }

if(auctionAccessIdSet.contains('5777777'))
    {
        auctionAccessIdSet.remove('5777777');
    }

}
//Make a unique list of Contacts we will need to link that don't include Marketo Contacts
Set<Contact> conts = new Set<Contact>
(
    [
    SELECT Id, Rep_Auction_Access_Number__c
    FROM Contact
    WHERE Rep_Auction_Access_Number__c in : auctionAccessIdSet
    ]
);
//Create the map needed to look up contacts by AAID
for(Contact c : conts)
{
    AAIDContMap.put(c.Rep_Auction_Access_Number__c, c);
}
//If we have at least one contact that isn't a Marketo contact, we will relate it to the Purch
for(Purchase__c buyerPurch : purchsWithBuyerContact)
{
    Contact cont = new Contact();
    cont = AAIDContMap.get(buyerPurch.Buyer_Contact_AAID__c);
    if(cont != null)
    {
        buyerPurch.ATC_Buyer_Contact__c = cont.Id;
    }
}

for(Purchase__c sellerPurch : purchsWithSellerContact)
{
    Contact cont = new Contact();
    cont = AAIDContMap.get(sellerPurch.Seller_Contact_AAID__c);
    if(cont != null)
    {
        sellerPurch.Seller_Contact__c = cont.Id;
    }
}

}