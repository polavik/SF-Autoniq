trigger PurchaseBeforeInsertUpdate on Purchase__c (before insert, before update) {

    //Attach Purchases to their Contracts

    Map<String, Purchase__c> contractIDPurchMap = new Map<String, Purchase__c>();
    List<String> vehicleIds = new List<String>();
    Map<Id,Id> SellerAdesaIdToAcctId = new Map<Id,Id>();
    Set<Id> SellerAdesaId = new Set<Id>();
    //attach Account with purchase
    //Set<String> accountNames = new Set<String>(); 
    //List<Account> accts = new List<Account>();
    //List<Purchase__c> ps = new List<Purchase__c>(); 
    //List<Account> acctToInsert = new List<Account>();
    String iaaPurchRecordType = Utils.getRecordTypeId('Purchase__c','IAA Purchase');
    PurchaseTriggerHandler.updateRecordType(Trigger.new);
    Map<String,ID> vehicle2upd = new Map<String,ID>();
    Map<String, Purchase__c> pLookUp = new Map<String, Purchase__c>();
    
    //PPM102488 replace "Buyer Status At time of purchase" WFR in order to free up the reference field usage
    Set<Id> buyerAdesaAuctionDetailIds = new Set<Id>();
    //PPM104667 replace "Vehicle Release Exception" WFR in order to free up the reference field usage
    //Set<Id> buyerAdesaComDetailIds = new Set<Id>();
    List<String> vids = new List<String>();
    Map<String, Purchase__c> pLookUp1= new Map<String,Purchase__c>();
   
   String amsRecordType = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase');    
    // Buyout Code
   String BuyoutRecordTypeId = Utils.getRecordTypeId('Purchase__c', 'Buyout'); 
   String RecentPurchaseRecordTypeId = Utils.getRecordTypeId('Purchase__c', 'Recent Purchase'); 
  
    for (Purchase__c p : Trigger.new) 
    {
        if(p.Buyout__c)
        {
            p.recordTypeId = BuyoutRecordTypeId;
        }
        else 
        {
            if(Trigger.isUpdate && (Trigger.oldMap.get(p.Id).recordTypeId == BuyoutRecordTypeId ))
            {
                System.debug('>>>> Trigger.IsUpdate = true and Found oldMap has Buyout recordtype and not now, So changing recordtype');
                p.recordTypeId = RecentPurchaseRecordTypeId;
                p.Buyout_Date__c = null;
                p.Buyout_Amount__c = null;
                p.Buyout_Buyer__c = null;
                p.Buyout_Buyer_ADESA_com_Detail__c = null;
                p.Buyout_Buyer_ADESA_com_Detail_Org_ID__c = null;
                PurchaseTriggerHandler.updateRecordType(p);
                System.debug('>>>> Trigger.IsUpdate = true and new RecordType set');
            }
        }
        
        // Apex Trigger : setDaysToPayment on Purchase__c (before insert, before update)
        //Date referenceDate = Date.newInstance(1900,1,6); // A Saturday for reference
        if (p.ATC_Sale_Date__c != null && p.Payment_Received__c != null) {
          Date startDate = Date.newInstance(p.ATC_Sale_Date__c.Year(), p.ATC_Sale_Date__c.Month(), p.ATC_Sale_Date__c.Day());     
          p.Days_To_Payment__c = Utils.countWeekDays(startDate, p.Payment_Received__c);
        }
        
        // Apex Trigger : setDaysToTitle on Purchase__c (before insert, before update)
        if (p.ATC_Sale_Date__c != null && p.Title_Received__c != null) {            
            Date startDate = Date.newInstance(p.ATC_Sale_Date__c.Year(), p.ATC_Sale_Date__c.Month(), p.ATC_Sale_Date__c.Day());    
            p.Days_To_Title__c = Utils.countWeekDays(startDate, p.Title_Received__c);
        }
        
        //Apex trigger : UpdateSegmentNameOnPurchase on Purchase__c (before insert, before update) 
        if(p.recordTypeId == amsRecordType ){
            p.Segment_Name__c= 'ADESA INLANE';
       }
       
       //Apex trigger : setPSIfieldsOnPurchase on Purchase__c (before insert) 
       //List<Purchase__c> purs = Trigger.new;
       if(p.Vehicle_ID__c!=null)
       {
        vids.add(p.Vehicle_ID__c);
        pLookUp1.put(p.Vehicle_ID__c, p);      
       }

   }
    
    List<Inspection_Request__c> irList = [SELECT id, vehicle_id__c, Purchase__c, Order_Complete_date__c, order_request_date__c, inspection_company_name__c  
                                            FROM Inspection_request__c 
                                           WHERE vehicle_Id__c in :vids 
                                             and (inspection_type__c = 'PSI' OR inspection_type__c = 'PDI')                                            
                                        order by vehicle_id__c, order_request_date__c];    
    if(irList.size() > 0){
       for(Inspection_Request__c ir: irList){
          
          Purchase__c p = pLookUp1.get(ir.vehicle_id__c);
          p.psi_ordered_date__c = ir.order_request_date__c;
          p.psi_completed_date__c = ir.order_complete_date__c;
          p.psi_inspection_company_name__c = ir.inspection_company_name__c;
          
       }      
    }
    
        //Apex trigger : PurchaseBeforeInsert on Purchase__c (before insert) 

        //The following code relates the Purchase to their Buyer/Seller Contacts if they exist
        //This is to solve the issue of duplicate Contacts not allowing AMS Purchases to insert
        //PPM 85129
        If(Trigger.isInsert)
        {
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

    
    
    //Original Trigger code start here 
    for(Purchase__c purch : Trigger.new) 
    {

        /* Added by Eric Whipple to support Partial VIN Search on 1/20/16 for PPM 105464*/
        if (purch.Name != null)// && purch.Vehicle_ID__c != null)
        {
            purch.Indexed_Reversed_VIN__c = Utils.reverse(purch.Name) + ((purch.Vehicle_Id__c == null)?'':'-' + purch.Vehicle_ID__c);
        }
        /* end addition by Eric Whipple */


        if(purch.Contract_ID__c != null)
        {
                contractIDPurchMap.put(purch.Contract_ID__c, purch);    
        }
        
        if(purch.Purchase_Type__c == 'IAA' && purch.Home_Branch__c == 'IAA'){
            purch.RecordTypeId = iaaPurchRecordType;
            /*if(purch.IAA_Buyer_Name__c != null){
                ps.add(purch);
                //accountNames.add(purch.IAA_Buyer_Name__c);
            }*/
        }
        //attach account with purchase
        
        if(purch.Vehicle_ID__c!=null){
           vehicleIds.add(purch.Vehicle_ID__c);
           pLookUp.put(purch.Vehicle_ID__c, purch);
        }
        
        if(purch.Problem_Status__c != null)
        {
            String statuses = ''; 
            if(purch.Problem_Status__c.contains('18'))
            {
                statuses = statuses +'Arbitration\n';
            }
            if(purch.Problem_Status__c.contains('24'))
            {
                statuses = statuses +'Transport Problem\n';
            }
            if(purch.Problem_Status__c.contains('31'))
            {
                statuses = statuses +'Title Problem\n';
            }
            if(purch.Problem_Status__c.contains('414'))
            {
                statuses = statuses +'Pending PSI\n';
            }            
            purch.Problem_Statuses__c = statuses;            
        }
        else
        {
            purch.Problem_Statuses__c = 'None';
        }       
        
        if(purch.Hi_Res_Images_Fee__c != null)
        {
            purch.Hi_Res_Images_Purchased__c = true;
        }    
        //(PPM#100937) Populate ATC_Seller__c from ATC_Seller_Adesa_com_Detail__c
        if(purch.ATC_Seller_Adesa_com_Detail__c != null)
        {
            SellerAdesaId.add(purch.ATC_Seller_Adesa_com_Detail__c);            
        }
        
        //PPM102488 replace "Buyer Status At time of purchase" WFR in order to free up the reference field usage     
        if(Trigger.isInsert && purch.Buyer_ADESA_Auction_Detail__c != null){
            if(purch.Segment_Name__c != null){
                if((purch.Segment_Name__c.equalsIgnoreCase('inlane') || purch.Segment_Name__c.equalsIgnoreCase('adesa/ol'))){
                    buyerAdesaAuctionDetailIds.add(purch.Buyer_ADESA_Auction_Detail__c);
                    //purch.Buyer_Status_Auction_Time_of_Purchase__c = purch.Buyer_ADESA_Auction_Detail__r.Buyer_Category__c;
                }   
            }      
        }
        //PPM104667 replace "Vehicle Release Exception" WFR in order to free up the reference field usage
        /*
        if(Trigger.isInsert){
            buyerAdesaComDetailIds.add(purch.ATC_Buyer_Adesa_com_Detail__c);
        }
        */        
    }
    
    //PPM102488 Replace "Buyer Status At time of purchase" WFR in order to free up the reference field usage
    Map<Id, Auction_Detail__c> purchBuyerCatMap = new Map<Id, Auction_Detail__c>([select Id, Name, Buyer_Category__c from Auction_Detail__c
                                                                                   where Id IN: buyerAdesaAuctionDetailIds]);
                                                                                   
    //PPM104667 replace "Vehicle Release Exception" WFR in order to free up the reference field usage
    /*Map<Id, Adesa_com_Detail__c> purchBuyerVreMap = new Map<Id, Adesa_com_Detail__c>([select Id, Name, Vehicle_Release_Exception__c from Adesa_com_Detail__c
                                                                                        where Id IN: buyerAdesaComDetailIds]);*/
                                                                                   
    
    /* Start (PPM#100937) Populate ATC_Seller__c from ATC_Seller_Adesa_com_Detail__c */
    
    SellerAdesaIdToAcctId = Utils.getAccountIdByAdesaComDetailId(SellerAdesaId);
                
    for(Purchase__c purch : Trigger.new) 
    {
        if(purch.ATC_Seller_Adesa_com_Detail__c != null)
        {
            purch.ATC_Seller__c = SellerAdesaIdToAcctId.get(purch.ATC_Seller_Adesa_com_Detail__c);
        }
         //PPM102488 Replace "Buyer Status At time of purchase" WFR in order to free up the reference field usage
        if(Trigger.isInsert && purch.Buyer_ADESA_Auction_Detail__c != null){
            if(purch.Segment_Name__c != null){
                if(purch.Segment_Name__c.equalsIgnoreCase('inlane') || purch.Segment_Name__c.equalsIgnoreCase('adesa/ol')){
                    purch.Buyer_Status_Auction_Time_of_Purchase__c = purchBuyerCatMap.get(purch.Buyer_ADESA_Auction_Detail__c).Buyer_Category__c;
                }
            }
        }
        //PPM104667 replace "Vehicle Release Exception" WFR in order to free up the reference field usage
        /*
        if(Trigger.isInsert){
            Adesa_com_Detail__c tempDetail = purchBuyerVreMap.get(purch.ATC_Buyer_Adesa_com_Detail__c);
            if(tempDetail != null){
                purch.Vehicle_Release_Exception__c = tempDetail.Vehicle_Release_Exception__c;
            }
        }
        */
    }
    
    /* End (PPM#100937) Populate ATC_Seller__c from ATC_Seller_Adesa_com_Detail__c  */
    
    if (vehicleIds.size() > 0)
        {
          vehicle2upd = VehicleUtils.checkVehicle(vehicleIds);
          // System.debug('Dummy Vehicle creation!');
         
          For( String vid: vehicleIds)
          {
              Purchase__c p2upd = pLookUp.get(vid);
              if (p2upd.Asset__c == null) {
                  p2upd.Asset__c = vehicle2upd.get(vid);
              }
          }
    }
    
    
    List<AFC_Contracts__c> contracts = new List<AFC_Contracts__c>();
    if(contractIDPurchMap != null){
        contracts = 
        [
                  select Id, Contract_ID__c
                    from AFC_Contracts__c 
                   where Contract_ID__c in :contractIDPurchMap.keySet()
        ];
    }
    /* 
    if(accountNames != null){
        accts = [SELECT Id, name FROM Account WHERE name IN:accountNames];        
    }*/

    for(String contId : contractIDPurchMap.keySet())
    {
        for(AFC_Contracts__c cont : contracts)
        {
            if(contId == cont.Contract_ID__c)
            {
                contractIDPurchMap.get(contId).AFC_Contract_Number__c = cont.ID;
            }
        }
    }
    
    //get a list of accounts going to be inserted
    /*for(Purchase__c p:ps){
        boolean hasAccount = false;
        for(Account a:accts){
            if(p.IAA_Buyer_Name__c == a.name){
                hasAccount = true;
            }
        }
        if(!hasAccount){
            Account au = new Account(Data_Source__c = 'IAA', name = p.IAA_Buyer_Name__c,Primary_Street1__c = p.BuyerAddressLine1__c,Primary_Street2__c = p.BuyerAddressLine2__c,Primary_City__c = p.BuyerCity__c,Primary_State__c = p.BuyerState__c,Primary_Country__c = p.BuyerCountry__c,Primary_Postalcode__c = p.BuyerZipCode__c,Phone = p.BuyerPhoneNumber__c,Tax_Identification_Number__c = p.BuyerTaxId__c);
            acctToInsert.add(au);
        }
    }
    if(acctToInsert != null){
        insert(acctToInsert);
    }*/
    
  PurchaseAuctionDetailUpdater.updateAuctionDetail(Trigger.new);
  
        
}