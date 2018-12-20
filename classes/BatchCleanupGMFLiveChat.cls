Global class BatchCleanupGMFLiveChat implements Database.Batchable<SObject>,Database.Stateful, Schedulable{
    global String usURL = setUsURL();
    global String caURL = setCaURL();
   
    global Integer intDeleteCounter = 0;   
    global string Summary='';
    public Integer expireationDate = Integer.valueof([select date__c from Cleanup_Properties__c where name = 'GMF_Live_Chat_Expiration'].date__c); //3 month  90 days  
    public String email = [select date__c from Cleanup_Properties__c where name = 'GMF_Live_Chat_Email'].date__c; //email notification
        
    global String strPurgeDateAction  = string.valueOf(system.today() - expireationDate) + 'T23:01:01Z';   
    
    public String query = 'select id from LiveChatTranscript where createddate<'+strPurgeDateAction+' and (ReferrerUri like \'%'+usURL+'%\' or ReferrerUri like \'%'+caURL+'%\')';    
      
    global void execute(SchedulableContext sc) 
    {
        BatchCleanupGMFLiveChat objProcess = new BatchCleanupGMFLiveChat();
        Database.executeBatch(objProcess);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {   
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {     
        try{
            List<LiveChatTranscript> TranscriptsToProcess = (List<LiveChatTranscript>) scope;    
            List<LiveChatTranscript> TranscriptsToDelete = new List<LiveChatTranscript>();            
            
            for(LiveChatTranscript obj: TranscriptsToProcess){
                TranscriptsToDelete.add(obj);
                intDeleteCounter++;               
             
            }
            delete TranscriptsToDelete; 
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
       
    }
    
    global void finish(Database.BatchableContext bc) 
    {       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('GMF Live Chat Transcript Cleanup Job Completed');
        String body = 'There are total of ' + intDeleteCounter + ' Live Chat Transcripts deleted. <br/><br/> Error:'+Summary+'';
        mail.setHtmlBody(body);
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    global String setUsURL()
    {
        String returnURL = null;
        List<Property__c> GMFURLprops = [select property_value__c From Property__c where property_id__c = 'gmf.us.url'];
        if(GMFURLprops.size()==1)
        {
            returnURL = GMFURLprops[0].property_value__c;
        }
        return returnURL;        
    }
    
    global String setCaURL()
    {
        String returnURL = null;
        List<Property__c> GMFURLprops = [select property_value__c From Property__c where property_id__c = 'gmf.canada.url'];
        if(GMFURLprops.size()==1)
        {
            returnURL = GMFURLprops[0].property_value__c;
        }
        return returnURL;
    }
}