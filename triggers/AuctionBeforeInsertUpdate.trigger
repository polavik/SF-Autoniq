trigger AuctionBeforeInsertUpdate on Auction__c (before insert, before update) {
  
  
    // Set Owner field automatically to current user when status field is changed from 'Open'
    for (Auction__c a: Trigger.new){
        if (Trigger.isUpdate){
            if (Trigger.oldMap.get(a.id) != null &&
                Trigger.oldMap.get(a.id).if_bid_Status__c != null &&
                Trigger.oldMap.get(a.id).if_bid_Status__c.equals('Open') &&
                a.if_bid_status__c != null &&
                !a.if_bid_status__c.equals('Open')){
                a.if_bid_owner__c = UserInfo.getUserId();
            }
        }
    }

    // Set "Seller" fields on Auction record
    Set<ID> vehicleIds = new Set<ID>();
    for (Auction__c a : Trigger.new)
    {
        if (a.Asset__c != null)
        {
            vehicleIds.add(a.Asset__c);
        }
    }

    Map<Id, Asset__c> vehicleMap = new Map<Id, Asset__c>(
    [
        SELECT Seller_Account__c
        FROM Asset__c 
        WHERE Id IN :vehicleIds
    ]);
    
    for (Auction__c a : Trigger.new){
        if (a.Asset__c != null)
        {
            Asset__c v = vehicleMap.get(a.Asset__c);
            a.Seller_Account__c = v.Seller_Account__c;
        }
    }
    
}