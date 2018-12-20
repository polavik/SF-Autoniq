trigger AssetBeforeInsertUpdate on Asset__c (before insert, before update) 
{
    Set<String> vids = new Set<String>();
    Map<Asset__c, Id> assetToADDIdSeller = new Map<Asset__c, Id>();
    Map<Asset__c, Id> assetToADDIdBuyer = new Map<Asset__c, Id>();
    Map<Asset__c, Id> assetToADDIdConsignee = new Map<Asset__c, Id>();
    Map<Asset__c, Id> assetToADDIdGrounding = new Map<Asset__c, Id>();
    Map<Asset__c, Id> assetToADDIdPartner = new Map<Asset__c, Id>();
    
    //String acctsfid;
    for (Asset__c v : Trigger.new)
    {
        /* vehicle id != null check removed by Eric Whipple to support Partial VIN Search on 1/20/16 for PPM 105464*/
        if (v.Name != null)// && v.Vehicle_ID__c != null)
        {
            v.Indexed_Reversed_VIN__c = Utils.reverse(v.Name) + ((v.Vehicle_Id__c == null)?'':'-' + v.Vehicle_ID__c);
        }
        /* end addition by Eric Whipple */
        
            vids.add(v.Source_Id__c);
            
         //PPM 101537
            
         system.debug('v.Seller_ADESA_com_Detail__c = ' + v.Seller_ADESA_com_Detail__c);
         if(v.Seller_ADESA_com_Detail__c != null)
         {
             assetToADDIdSeller.put(v, v.Seller_ADESA_com_Detail__c);
             system.debug('Added the following to assetToADDIdSeller map: ' + v.Seller_ADESA_com_Detail__c);
         }
         
         system.debug('v.Buyer_ADESA_com_Detail__c= ' + v.Buyer_ADESA_com_Detail__c);
         if(v.Buyer_ADESA_com_Detail__c!= null)
         {
             assetToADDIdBuyer.put(v, v.Buyer_ADESA_com_Detail__c);
             system.debug('Added the following to assetToADDIdBuyer map: ' + v.Buyer_ADESA_com_Detail__c);
         }
          
         system.debug('v.Consignee_ADESA_com_Detail__c= ' + v.Consignee_ADESA_com_Detail__c);
         if(v.Consignee_ADESA_com_Detail__c != null)
         {
             assetToADDIdConsignee.put(v, v.Consignee_ADESA_com_Detail__c);
             system.debug('Added the following to assetToADDIdConsignee map: ' + v.Consignee_ADESA_com_Detail__c);
         } 
         
         system.debug('v.Grounding_Dealer_ADESA_com_Detail__c = ' + v.Grounding_Dealer_ADESA_com_Detail__c);
         if(v.Grounding_Dealer_ADESA_com_Detail__c!= null)
         {
             assetToADDIdGrounding.put(v, v.Grounding_Dealer_ADESA_com_Detail__c);
             system.debug('Added the following to assetToADDIdGrounding map: ' + v.Grounding_Dealer_ADESA_com_Detail__c);
         } 
         
         system.debug('v.Partner_ADESA_com_Detail__c= ' + v.Partner_ADESA_com_Detail__c);
         if(v.Partner_ADESA_com_Detail__c!= null)
         {
             assetToADDIdPartner.put(v, v.Partner_ADESA_com_Detail__c);
             system.debug('Added the following to assetToADDIdPartner map: ' + v.Partner_ADESA_com_Detail__c);
         }                  
       
    }
    
    
    if(assetToADDIdSeller.size() > 0)
    {
        List<Adesa_com_Detail__c> addList = [select Id, Account__c from Adesa_com_Detail__c where Id in :assetToADDIdSeller.values()];
        
        for(Asset__c v : assetToADDIdSeller.keySet())
        {
            for(Adesa_com_Detail__c add : addList)
            {
                if(v.Seller_ADESA_com_Detail__c == add.Id)
                {
                    v.Seller_Account__c = add.Account__c;
                    break;
                }
                
            }
            
        }
        
         
     }
     
     if(assetToADDIdBuyer.size() > 0)
    {
        List<Adesa_com_Detail__c> addList = [select Id, Account__c from Adesa_com_Detail__c where Id in :assetToADDIdBuyer.values()];
        
        for(Asset__c v : assetToADDIdBuyer.keySet())
        {
            for(Adesa_com_Detail__c add : addList)
            {
                if(v.Buyer_ADESA_com_Detail__c == add.Id)
                {
                    v.Buyer_Account__c = add.Account__c;
                    break;
                }
                
            }
            
        }
        
         
     }
     
     if(assetToADDIdConsignee.size() > 0)
    {
        List<Adesa_com_Detail__c> addList = [select Id, Account__c from Adesa_com_Detail__c where Id in :assetToADDIdConsignee.values()];
        
        for(Asset__c v : assetToADDIdConsignee.keySet())
        {
            for(Adesa_com_Detail__c add : addList)
            {
                if(v.Consignee_ADESA_com_Detail__c == add.Id)
                {
                    v.Consignee_Account__c = add.Account__c;
                    break;
                }
                
            }
            
        }
        
         
     }
     
     if(assetToADDIdGrounding.size() > 0)
    {
        List<Adesa_com_Detail__c> addList = [select Id, Account__c from Adesa_com_Detail__c where Id in :assetToADDIdGrounding.values()];
        
        for(Asset__c v : assetToADDIdGrounding.keySet())
        {
            for(Adesa_com_Detail__c add : addList)
            {
                if(v.Grounding_Dealer_ADESA_com_Detail__c == add.Id)
                {
                    v.Grounding_Dealer__c = add.Account__c;
                    break;
                }
                
            }
            
        }
        
         
     }
     
     if(assetToADDIdPartner.size() > 0)
    {
        List<Adesa_com_Detail__c> addList = [select Id, Account__c from Adesa_com_Detail__c where Id in :assetToADDIdPartner.values()];
        
        for(Asset__c v : assetToADDIdPartner.keySet())
        {
            for(Adesa_com_Detail__c add : addList)
            {
                if(v.Partner_ADESA_com_Detail__c == add.Id)
                {
                    v.Partner_Account__c = add.Account__c;
                    break;
                }
                
            }
            
        }
        
         
     }
     
        
    List<Purchase__c> purList = [select Id, Source_Id__c from Purchase__c where Source_Id__c in: vids];
    Map<String, String> assetPurchaseIds= new Map<String, String>(); 
    
    for(Purchase__c p: purList){
        assetPurchaseIds.put(p.Source_Id__c, p.Id);
    }

    if(assetPurchaseIds.size() > 0){
        for(Asset__c v : Trigger.new){
            v.Purchase__c = assetPurchaseIds.get(v.Source_Id__c);
        }
    }
    
   
    
}