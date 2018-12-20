public with sharing class PurchaseAuctionDetailUpdater {
   public static void updateAuctionDetail(Purchase__c[] purchases) {
     Map<String, Id> auctionDetailMap = new Map<String, Id>();
     List<Purchase__c> pList = new List<Purchase__c>();
     for (Purchase__c p : purchases) {
        boolean added = false;
        if (p.Buyer_Auction_Detail_Source_Id__c != null && 
             (p.Buyer_ADESA_Auction_Detail__c == null|| p.Buyer_ADESA_Auction_Detail__r.Source_Id__c != p.Buyer_Auction_Detail_Source_Id__c)) {
                auctionDetailMap.put(p.Buyer_Auction_Detail_Source_Id__c, null);
             pList.add(p);  
             added = true;
        }

        if (p.Seller_Auction_Detail_Source_Id__c != null && 
             (p.Seller_ADESA_Auction_Detail__c == null || p.Seller_ADESA_Auction_Detail__r.Source_Id__c != p.Seller_Auction_Detail_Source_Id__c)) {
                auctionDetailMap.put(p.Seller_Auction_Detail_Source_Id__c, null);
            if (!added) {
              pList.add(p);     
            }   
        }
     }
     
     if (auctionDetailMap.size() > 0) {
        List<Auction_Detail__c> auctionDetailList = new List<Auction_Detail__c>([SELECT Id, Source_id__c from Auction_Detail__c
            WHERE Source_id__c in: auctionDetailMap.keySet()]);
        for(Auction_Detail__c a : auctionDetailList){
            auctionDetailMap.put(a.source_id__c,a.id);
        }
     }
     
     for (Purchase__c p : pList) {
        if (p.Buyer_Auction_Detail_Source_Id__c != null && auctionDetailMap.get(p.Buyer_Auction_Detail_Source_Id__c) != null) {
            p.Buyer_ADESA_Auction_Detail__c = auctionDetailMap.get(p.Buyer_Auction_Detail_Source_Id__c);
        }

        if (p.Seller_Auction_Detail_Source_Id__c != null && auctionDetailMap.get(p.Seller_Auction_Detail_Source_Id__c) != null) {
            p.Seller_ADESA_Auction_Detail__c = auctionDetailMap.get(p.Seller_Auction_Detail_Source_Id__c);
        }
     }
   }
}