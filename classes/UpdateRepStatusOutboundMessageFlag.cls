global class UpdateRepStatusOutboundMessageFlag implements Database.Batchable<SObject>, Database.Stateful,Schedulable{
    //dedupe rep-status survey base on Contact - Auction Site composite key and update outbound message flag.
    global Integer counter = 0;
    global Integer qualtricsCounter = 0;
    global UpdateRepStatusOutboundMessageFlag(){}
    global Map<String, Rep_Status_ADESA_Auction__c> rsMap = new Map<String, Rep_Status_ADESA_Auction__c>();
    global Set<String> ListFLSUpdate = new Set<String>();
	
	
    global void execute(SchedulableContext sc) {
        UpdateRepStatusOutboundMessageFlag proc = new UpdateRepStatusOutboundMessageFlag();
        Database.executeBatch(proc);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([select id, name, contact__c, contact__r.Email, Auction__c, Send_Qualtrics_Survey_Today__c,Send_Qualtrics_Survey_Outbound_Message__c from Rep_Status_ADESA_Auction__c where Send_Qualtrics_Survey_Today__c = true]);
    } 
     
    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
		Boolean blnFLSOverride = Utils.GetFLS();
        List<Rep_Status_ADESA_Auction__c> rsList= (List<Rep_Status_ADESA_Auction__c>) scope;		
		
        List<Rep_Status_ADESA_Auction__c> rsListUpdate = new List<Rep_Status_ADESA_Auction__c>();//use to reset flag: Send_Qualtrics_Survey_Today__c
        List<String> rsIds = new List<String>();
        Map<String, Rep_Status_ADESA_Auction__c> rsMap = new Map<String, Rep_Status_ADESA_Auction__c>();
        for(Rep_Status_ADESA_Auction__c rs:rsList){                       
            rsMap.put(rs.Id,rs);
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			if (Schema.sObjectType.Rep_Status_ADESA_Auction__c.fields.Send_Qualtrics_Survey_Today__c.isUpdateable() || blnFLSOverride)
			{
				rs.Send_Qualtrics_Survey_Today__c = false;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.Rep_Status_ADESA_Auction__c.getName()+'.'+Schema.sObjectType.Rep_Status_ADESA_Auction__c.fields.Send_Qualtrics_Survey_Today__c.getName());
			}
            rsListUpdate.add(rs);  
            counter++;        
        }
        update rsListUpdate;
        
        // Start PPM#105851
        List<AuctionContact__c> acList = [select AuctionIdEmail__c,Last_Updated_by_Rep_Status_Id__c from AuctionContact__c where Last_Updated_by_Rep_Status_Id__c in: rsMap.keySet() order by createddate desc];
        System.debug('>>> AuctionContact__c.size() : '+acList.size());
        
        Set<String> setRepIds = new Set<String>();
        List<AuctionContact__c> acListToRemove = new List<AuctionContact__c>();
        List<AuctionContact__c> acListToProcess = new List<AuctionContact__c>();
        for(AuctionContact__c ac:acList){
            if(setRepIds.add(ac.Last_Updated_by_Rep_Status_Id__c) == false)
            {
                acListToRemove.Add(ac); 
            }else
            {
                acListToProcess.Add(ac);
            }
        }
        System.debug('>>> ActionDetail to remove : '+acListToRemove.size());
        System.debug('>>> ActionDetail to Process : '+acListToProcess.size());
        delete acListToRemove;
        
        // Finish PPM#105851 
        
        //List<AuctionContact__c> acList = [select AuctionIdEmail__c,Last_Updated_by_Rep_Status_Id__c from AuctionContact__c where Last_Updated_by_Rep_Status_Id__c in: rsMap.keySet()];
        List<Rep_Status_ADESA_Auction__c> rsListSendSurvey = new List<Rep_Status_ADESA_Auction__c>();
        for(AuctionContact__c ac:acListToProcess){
            if(rsMap.containsKey(ac.Last_Updated_by_Rep_Status_Id__c)){
                Rep_Status_ADESA_Auction__c tempRS = rsMap.get(ac.Last_Updated_by_Rep_Status_Id__c);                
				//Story B-44003 : FLS UPDATE ACCESS CHECK
				if (Schema.sObjectType.Rep_Status_ADESA_Auction__c.fields.Send_Qualtrics_Survey_Outbound_Message__c.isUpdateable() || blnFLSOverride)
				{
					tempRS.Send_Qualtrics_Survey_Outbound_Message__c = true;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Rep_Status_ADESA_Auction__c.getName()+'.'+Schema.sObjectType.Rep_Status_ADESA_Auction__c.fields.Send_Qualtrics_Survey_Outbound_Message__c.getName());
				}
                rsListSendSurvey.add(tempRS);
            }
        }
        qualtricsCounter += rsListSendSurvey.size();
        update rsListSendSurvey;
    }
    
    global void finish(Database.BatchableContext bc) 
    {  
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:UpdateRepStatusOutboundMessageFlag', ListFLSUpdate);
		}				
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'salesforceemails@openlane.com'});
        mail.setSubject('UpdateRepStatusOutboundMessageFlag Completed');
        String body = 'There are total of ' + counter + ' Reps have been analyzed and ' + qualtricsCounter + ' of Qualtrics Survey had been sent out.';
        mail.setHtmlBody(body);
        if(!Test.isRunningTest())
        { 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }  
}

//UpdateRepStatusOutboundMessageFlag objUpdateRepStatusOutboundMessageFlag = new UpdateRepStatusOutboundMessageFlag();
//Database.executeBatch(objUpdateRepStatusOutboundMessageFlag);