trigger PromoBeforeInsertUpdate on Promotions__c (before insert, before update) {

    List<Promotions__c> proList = Trigger.new;
   
    List<ID> accountIds = new List<ID>();
    List<String> accountNames = new List<String>();
    
    
    for (Promotions__c pro : Trigger.new) 
    {
        if (pro.Auction_Title_Reference__c != null) 
        {
            accountNames.add(pro.Auction_Title_Reference__c.toUpperCase());

        }
      
    }
    
    // Retrieve Account data for all Promotions
    Map<String, Adesa_com_Detail__c> acctMaplist = new Map<String, Adesa_com_Detail__c>();
                                                
    List<Adesa_com_Detail__c> acctList = [SELECT Id,ATC_Organization_ID__c,Name FROM Adesa_com_Detail__c
            WHERE Name IN :accountNames ] ;
          //WHERE Name IN :accountNames and RecordTypeId = '01260000000DJqk' and AMS_CO_ID__c != '' ] ;
        
    for(Adesa_com_Detail__c act: acctList){
        acctMaplist.put(act.Name,act);
        
    }
    
   
    // Attach Account obj to Promotion Object
    System.debug(proList.size());    
    for (Promotions__c pro : proList) 
    {
        if (pro.Auction_Title_Reference__c!= null )
        {
            Adesa_com_Detail__c actObj = acctMaplist.get(pro.Auction_Title_Reference__c.toUpperCase());
        
            if (actObj != null) {
                 pro.Auction_Name__c = actObj.id;
            }
        }   
    }

}