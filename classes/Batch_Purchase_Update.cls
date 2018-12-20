global class Batch_Purchase_Update implements Database.Batchable<SObject>,Database.Stateful, Schedulable{

    public String query;
    public String AMSPUrchaseRecordType = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase'); 

    global Database.querylocator start(Database.BatchableContext BC){

        query= 'Select Id,name,source_id__c,buyer_auction_detail_source_id__c,Seller_Auction_Detail_Source_Id__c,Buyer_ADESA_Auction_Detail__r.Source_Id__c,Seller_ADESA_Auction_Detail__r.Source_Id__c '+
             'from purchase__c ' +
             ' where (Buyer_ADESA_Auction_Detail__r.MigrationFlag__c = 1 OR Seller_ADESA_Auction_Detail__r.MigrationFlag__c = 1 ) ' +  
             ' AND (Buyer_ADESA_Auction_Detail__r.Source_Id__c != \'\' OR Seller_ADESA_Auction_Detail__r.Source_Id__c != \'\' ) and Flag_AD__c != 1 ' +
             ' AND RecordTypeId=\''+AMSPUrchaseRecordType+'\''  ;                     
             
             return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<purchase__c> PtoUpdate){


        for(purchase__c purch : PtoUpdate){

            purch.buyer_auction_detail_source_id__c = purch.Buyer_ADESA_Auction_Detail__r.Source_Id__c;
            purch.Seller_Auction_Detail_Source_Id__c = purch.Seller_ADESA_Auction_Detail__r.Source_Id__c;
            purch.Flag_AD__c = 1;
            System.debug(''+purch.buyer_auction_detail_source_id__c) ;
            System.debug(''+purch.Seller_Auction_Detail_Source_Id__c) ;
        }       
        update PtoUpdate; 
    }
    global void finish(Database.BatchableContext ctx) 
    {
    }
    
    global void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(this);
    }    
}