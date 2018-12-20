trigger NPSSurveyDedupe on Purchase__c (after insert, after update) {

    List<Purchase__c> purchasesDealerBlockOffsite = new List<Purchase__c>();
    List<Purchase__c> purchasesLiveBlockDealerBlockOnsite = new List<Purchase__c>();
    List<String> emailDealerBlockOffsites = new List<String>();
    List<String> emailLiveBlockDealerBlockOnsite = new List<String>();
    List<String> emails = new List<String>();
    Date last30days = system.today() - 30;
    Date last7days = system.today() - 7;
    
    for (Purchase__c p: Trigger.new){
        if(p.NPS_Survey_Sent__c != true){
        System.debug('NPSSurveyDedupe: NPS_Survey_DealerBlock_Offsite__c='+p.NPS_Survey_DealerBlock_Offsite__c+ ' NPS_Survey_LiveBlock_DealerBlock_Onsite__c='+ p.NPS_Survey_LiveBlock_DealerBlock_Onsite__c + ' Last_NPS_Survey_Date__c='+p.Last_NPS_Survey_Date__c+' Buyer_Contact_Email__c='+p.Buyer_Contact_Email__c);
            if(p.NPS_Survey_DealerBlock_Offsite__c && p.Last_NPS_Survey_Date__c == Date.today() && p.Buyer_Contact_Email__c != null){        
                purchasesDealerBlockOffsite.add(p);
                emailDealerBlockOffsites.add(p.Buyer_Contact_Email__c + '@1');
                emails.add(p.Buyer_Contact_Email__c);
            }else if(p.NPS_Survey_LiveBlock_DealerBlock_Onsite__c && p.Last_NPS_Survey_Date__c == Date.today() && p.Buyer_Contact_Email__c != null){
                purchasesLiveBlockDealerBlockOnsite.add(p);
                emailLiveBlockDealerBlockOnsite.add(p.Buyer_Contact_Email__c + '@2');
                emails.add(p.Buyer_Contact_Email__c);
            }
        }
    }
    
    System.debug('NPSSurveyDedupe: DBoffsite Size=' + purchasesDealerBlockOffsite.size() + ' and LBDBonsite Size='+purchasesLiveBlockDealerBlockOnsite.size());
    Map<String, Integer> totalSurvey = new Map<String, Integer>();
    
    if(purchasesDealerBlockOffsite.size()>0 || purchasesLiveBlockDealerBlockOnsite.size()>0){
        //create a email based 7 days dictionary for dedupe later
        List<PurchaseTypeContact__c> contactPur7Days = [select id, email__c from PurchaseTypeContact__c where email__c in: emails and Last_Survey_Date__c >: last7days];        
        for(PurchaseTypeContact__c pc: contactPur7Days){
            Integer numberNPSSurveys = 1;
            if(totalSurvey.containsKey(pc.email__c)){
                numberNPSSurveys = totalSurvey.get(pc.email__c) + 1;
            }
            totalSurvey.put(pc.email__c, numberNPSSurveys);//insert or overwrite with the most updated total number of NPS surveys
        }
        
        //create a email based 7 days dictionary for dedupe later
        List<AuctionContact__c> contactAuc7Days = [select id, email__c from AuctionContact__c where email__c in: emails and Last_Survey_Date__c >: last7days];
        for(AuctionContact__c ca: contactAuc7Days){
            Integer numberCSISurveys = 1;
            if(totalSurvey.containsKey(ca.email__c)){
                numberCSISurveys = totalSurvey.get(ca.email__c) + 1;
            }
            totalSurvey.put(ca.email__c, numberCSISurveys);//insert or overwrite with the most updated total number of surveys (Add CSI Surveys)
        }    
        
        //Search if there is any DealerBlock offsite purchase with same email in last 30 days
        List<PurchaseTypeContact__c> contactPur1 = [select id, email__c,Email_Purchase_Type__c,Last_Survey_Date__c from PurchaseTypeContact__c where Email_Purchase_Type__c in: emailDealerBlockOffsites];
        Map<String, PurchaseTypeContact__c> purContactDic1 = new Map<String, PurchaseTypeContact__c>();
        for(PurchaseTypeContact__c pc: contactPur1){
            purContactDic1.put(pc.Email_Purchase_Type__c, pc);
        }
        Map<String,PurchaseTypeContact__c> dealerBlockOffsiteSurvey = new Map<String,PurchaseTypeContact__c>();
        for(Purchase__c p: purchasesDealerBlockOffsite){
            if(!purContactDic1.containsKey(p.Buyer_Contact_Email__c + '@1')){ // '@1' stands for DealerBlock offsite purchase type
                if(totalSurvey.containsKey(p.Buyer_Contact_Email__c)){
                    Integer numberNPSSurveys = totalSurvey.get(p.Buyer_Contact_Email__c);
                    if(numberNPSSurveys < 4){//verify total# of CSI + NPS surveys are < 4 before adding another survey
                        PurchaseTypeContact__c pc = new PurchaseTypeContact__c(Email_Purchase_Type__c = p.Buyer_Contact_Email__c + '@1', Email__c = p.Buyer_Contact_Email__c, Last_Updated_by_Purchase_Id__c = p.Id, Last_Survey_Date__c = p.Last_NPS_Survey_Date__c);
                        dealerBlockOffsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                        totalSurvey.put(p.Buyer_Contact_Email__c, numberNPSSurveys + 1);
                    }
                }else{
                    PurchaseTypeContact__c pc = new PurchaseTypeContact__c(Email_Purchase_Type__c = p.Buyer_Contact_Email__c + '@1', Email__c = p.Buyer_Contact_Email__c, Last_Updated_by_Purchase_Id__c = p.Id, Last_Survey_Date__c = p.Last_NPS_Survey_Date__c);
                    dealerBlockOffsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                    totalSurvey.put(p.Buyer_Contact_Email__c, 1);
                }
            }else{//have matching purchaseTypeContact, verify if it's within the last 30 days below
                if(purContactDic1.get(p.Buyer_Contact_Email__c + '@1').Last_Survey_Date__c < last30days){
                    if(totalSurvey.containsKey(p.Buyer_Contact_Email__c)){
                        Integer numberNPSSurveys = totalSurvey.get(p.Buyer_Contact_Email__c);
                        if(numberNPSSurveys < 4){
                            PurchaseTypeContact__c pc = purContactDic1.get(p.Buyer_Contact_Email__c + '@1');
                            pc.Last_Survey_Date__c = p.Last_NPS_Survey_Date__c;
                            pc.Last_Updated_by_Purchase_Id__c = p.Id;
                            dealerBlockOffsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                            totalSurvey.put(p.Buyer_Contact_Email__c, numberNPSSurveys + 1);
                        }
                    }else{
                        PurchaseTypeContact__c pc = purContactDic1.get(p.Buyer_Contact_Email__c + '@1');
                        pc.Last_Survey_Date__c = p.Last_NPS_Survey_Date__c;
                        pc.Last_Updated_by_Purchase_Id__c = p.Id;
                        dealerBlockOffsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                        totalSurvey.put(p.Buyer_Contact_Email__c, 1);
                    }
                }
            }            
        }
        
        //Search if there is any LiveBlock or DealerBlock at auction purchase with same email in last 30 days
        List<PurchaseTypeContact__c> contactPur2 = [select id, email__c,Email_Purchase_Type__c,Last_Survey_Date__c from PurchaseTypeContact__c where Email_Purchase_Type__c in: emailLiveBlockDealerBlockOnsite];
        Map<String, PurchaseTypeContact__c> purContactDic2 = new Map<String, PurchaseTypeContact__c>();
        for(PurchaseTypeContact__c pc: contactPur2){
            purContactDic2.put(pc.Email_Purchase_Type__c, pc);
        }
        Map<String,PurchaseTypeContact__c> liveBlockDealerBlockOnsiteSurvey = new Map<String,PurchaseTypeContact__c>();
        for(Purchase__c p: purchasesLiveBlockDealerBlockOnsite){
            if(!purContactDic2.containsKey(p.Buyer_Contact_Email__c + '@2')){// '@2' stands for LiveBlock or DealerBlock at auction purchase type
                if(totalSurvey.containsKey(p.Buyer_Contact_Email__c)){
                    Integer numberNPSSurveys = totalSurvey.get(p.Buyer_Contact_Email__c);
                    if(numberNPSSurveys < 4){//verify total# of CSI + NPS surveys are < 4 before adding another survey
                        PurchaseTypeContact__c pc = new PurchaseTypeContact__c(Email_Purchase_Type__c = p.Buyer_Contact_Email__c + '@2', Email__c = p.Buyer_Contact_Email__c, Last_Updated_by_Purchase_Id__c = p.Id, Last_Survey_Date__c = p.Last_NPS_Survey_Date__c);
                        liveBlockDealerBlockOnsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                        totalSurvey.put(p.Buyer_Contact_Email__c, numberNPSSurveys + 1);
                    }
                }else{
                    PurchaseTypeContact__c pc = new PurchaseTypeContact__c(Email_Purchase_Type__c = p.Buyer_Contact_Email__c + '@2', Email__c = p.Buyer_Contact_Email__c, Last_Updated_by_Purchase_Id__c = p.Id, Last_Survey_Date__c = p.Last_NPS_Survey_Date__c);
                    liveBlockDealerBlockOnsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                    totalSurvey.put(p.Buyer_Contact_Email__c, 1);
                }
            }else{//have matching purchaseTypeContact, verify if it's within the last 30 days below
                if(purContactDic2.get(p.Buyer_Contact_Email__c + '@2').Last_Survey_Date__c < last30days){
                    if(totalSurvey.containsKey(p.Buyer_Contact_Email__c)){
                        Integer numberNPSSurveys = totalSurvey.get(p.Buyer_Contact_Email__c);
                        if(numberNPSSurveys < 4){
                            PurchaseTypeContact__c pc = purContactDic2.get(p.Buyer_Contact_Email__c + '@2');
                            pc.Last_Survey_Date__c = p.Last_NPS_Survey_Date__c;
                            pc.Last_Updated_by_Purchase_Id__c = p.Id;
                            liveBlockDealerBlockOnsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                            totalSurvey.put(p.Buyer_Contact_Email__c, numberNPSSurveys + 1);
                        }
                    }else{
                        PurchaseTypeContact__c pc = purContactDic2.get(p.Buyer_Contact_Email__c + '@2');
                        pc.Last_Survey_Date__c = p.Last_NPS_Survey_Date__c;
                        pc.Last_Updated_by_Purchase_Id__c = p.Id;
                        liveBlockDealerBlockOnsiteSurvey.put(pc.Email_Purchase_Type__c,pc);
                        totalSurvey.put(p.Buyer_Contact_Email__c, 1);
                    }
                }
            }           
        }
        
        if(dealerBlockOffsiteSurvey.size()>0){
            try{
                Database.upsert(dealerBlockOffsiteSurvey.values(), PurchaseTypeContact__c.Email_Purchase_Type__c , false);
            }catch(Exception e){
                system.debug(e);
            }
        }
        
        if(liveBlockDealerBlockOnsiteSurvey.size()>0){
            try{
                Database.upsert(liveBlockDealerBlockOnsiteSurvey.values(), PurchaseTypeContact__c.Email_Purchase_Type__c , false);
            }catch(Exception e){
                system.debug(e);
            }
            //upsert new List<PurchaseTypeContact__c>(liveBlockDealerBlockOnsiteSurvey);
        }
    }
}