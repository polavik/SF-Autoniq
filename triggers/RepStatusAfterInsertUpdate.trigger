trigger RepStatusAfterInsertUpdate on Rep_Status_ADESA_Auction__c (after insert, after update) {
    Date last30days = system.today() - 30;
    Date last7days = system.today() - 7;
    List<Rep_Status_ADESA_Auction__c> repList = new List<Rep_Status_ADESA_Auction__c>();
    List<String> auctionContactIds = new List<String>();
    List<String> emails = new List<String>();
    for (Rep_Status_ADESA_Auction__c rep: Trigger.new){
        System.debug('rep status: ' + rep.Contact_Email__c + ' ' + rep.Send_Qualtrics_Survey_Today__c);
        if(rep.Send_Qualtrics_Survey_Today__c && rep.Contact_Email__c !=null && rep.Contact_Email__c !=''){
            repList.add(rep);
            auctionContactIds.add(rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase());
            emails.add(rep.Contact_Email__c.toLowerCase());
        }        
    }    
    
    Map<String, Integer> totalSurvey = new Map<String, Integer>();
    
    if(auctionContactIds.size()>0){
        //create a email based 7 days dictionary for dedupe later
        List<AuctionContact__c> contactAuc7Days = [select id, email__c from AuctionContact__c where email__c in: emails and Last_Survey_Date__c>:last7days];
        for(AuctionContact__c ca: contactAuc7Days){
            Integer numberCSISurveys = 1;
            if(totalSurvey.containsKey(ca.email__c)){
                numberCSISurveys = totalSurvey.get(ca.email__c) + 1;
            }
            totalSurvey.put(ca.email__c, numberCSISurveys);//insert or overwrite with the most updated total number of surveys (Add CSI Surveys)
        }
        
        List<PurchaseTypeContact__c> contactPur7Days = [select id, email__c from PurchaseTypeContact__c where email__c in: emails and Last_Survey_Date__c >: last7days];        
        for(PurchaseTypeContact__c pc: contactPur7Days){
            Integer numberNPSSurveys = 1;
            if(totalSurvey.containsKey(pc.email__c)){
                numberNPSSurveys = totalSurvey.get(pc.email__c) + 1;
            }
            totalSurvey.put(pc.email__c, numberNPSSurveys);//insert or overwrite with the most updated total number of NPS surveys
        }            
    
        //Search if there is any CSI survey with the same auction site + email in the last 30 days
        List<AuctionContact__c> contactAucs = [select id, AuctionIdEmail__c, email__c, Last_Survey_Date__c from AuctionContact__c where AuctionIdEmail__c in: auctionContactIds];
        Map<String, AuctionContact__c> aucContactDic = new Map<String, AuctionContact__c>();
        for(AuctionContact__c ac: contactAucs){
            aucContactDic.put(ac.AuctionIdEmail__c,ac);
        }
        Map<String,AuctionContact__c> repStatusSurvey = new Map<String,AuctionContact__c>();
        for(Rep_Status_ADESA_Auction__c rep:repList){
            if(!aucContactDic.containsKey(rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase())){//if there's no CSI survey sent before
                if(totalSurvey.containsKey(rep.Contact_Email__c.toLowerCase())){
                    Integer numberCSISurveys = totalSurvey.get(rep.Contact_Email__c.toLowerCase());
                    if(numberCSISurveys<4){//verify total# of CSI + NPS surveys are < 4 before adding another survey
                        AuctionContact__c ac = new AuctionContact__c(AuctionIdEmail__c=rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase(),Email__c=rep.Contact_Email__c.toLowerCase(),Last_Updated_by_Rep_Status_Id__c=rep.Id,Last_Survey_Date__c=system.today());
                        repStatusSurvey.put(ac.AuctionIdEmail__c, ac);
                        totalSurvey.put(rep.Contact_Email__c.toLowerCase(), numberCSISurveys+1);
                    }
                }else{
                    AuctionContact__c ac = new AuctionContact__c(AuctionIdEmail__c=rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase(),Email__c=rep.Contact_Email__c.toLowerCase(),Last_Updated_by_Rep_Status_Id__c=rep.Id,Last_Survey_Date__c=system.today());
                    repStatusSurvey.put(ac.AuctionIdEmail__c, ac);
                    totalSurvey.put(rep.Contact_Email__c.toLowerCase(), 1);
                }
            }else{//have matching AuctionContact, verify if it's sent within the last 30 days below
                if(aucContactDic.get(rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase()).Last_Survey_Date__c < last30days){
                    if(totalSurvey.containsKey(rep.Contact_Email__c.toLowerCase())){
                        Integer numberCSISurveys = totalSurvey.get(rep.Contact_Email__c.toLowerCase());
                        if(numberCSISurveys<4){//verify total# of CSI + NPS surveys are < 4 before adding another survey
                            AuctionContact__c ac = aucContactDic.get(rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase());
                            ac.Last_Survey_Date__c = system.today();
                            ac.Last_Updated_by_Rep_Status_Id__c = rep.Id;
                            repStatusSurvey.put(ac.AuctionIdEmail__c, ac);
                            totalSurvey.put(rep.Contact_Email__c.toLowerCase(), numberCSISurveys+1);
                        }
                    }else{
                        AuctionContact__c ac = aucContactDic.get(rep.Auction__c + '' + rep.Contact_Email__c.toLowerCase());
                        ac.Last_Survey_Date__c = system.today();
                        ac.Last_Updated_by_Rep_Status_Id__c = rep.Id;
                        repStatusSurvey.put(ac.AuctionIdEmail__c, ac);
                        totalSurvey.put(rep.Contact_Email__c.toLowerCase(), 1);
                    }
                }
            }
        }
        if(repStatusSurvey.size()>0){
            try{
                Database.upsert(repStatusSurvey.values(), AuctionContact__c.AuctionIdEmail__c, false);
            }catch(Exception e){
                system.debug(e);
            }
        }
    }    
       
}