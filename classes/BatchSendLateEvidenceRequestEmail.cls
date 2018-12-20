global class BatchSendLateEvidenceRequestEmail implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
//Batch job that checks Cases for Evidence Requests that have not had evidence provided in time (Two days) 
//Sends an email listing all cases that have requests open for 2 or more days

    global List<Case> casesToEmail = new List<Case>();

//Query used for the getQueryLocator
    public String query = 
        'SELECT Id, CaseNumber, Status ' +
        'FROM Case ' +
        'WHERE Status = \'Evidence Requested\' ';
//First the Scheduler calls our job and 'execute' is performed
    global void execute(SchedulableContext sc) 
    {
        BatchSendLateEvidenceRequestEmail proc = new BatchSendLateEvidenceRequestEmail();
        Database.executeBatch(proc, 1);  //If you put a number after the first argument, it will do it in batches of that many records
    }
    
//Next the job starts which takes our above query and sends it to the next 'execute' method
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    } 

//This execute method will use the results from the query we passed it to send emails       
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        date d = system.today(); //Used in SOQL function since there is no sysdate in SOQL
        //All Evidence Requests that are on these cases that have the criteria of no returned evidence for last 2 or more days
        List<Evidence_Request__c> ers = 
        [
        SELECT Id, Evidence_Req_Date__c, Evidence_Received__c, Case__c
        FROM Evidence_Request__c
        WHERE Evidence_Received__c = false
        AND Evidence_Req_Date__c <= :d - 2
        AND Case__c in :scope
        ];
        system.debug('Found ' + ers.size() + ' Evidence Requests matching criteria');
        
        List<Id> caseIdsToEmail = new List<Id>();
        
        Boolean dup = false;
        //Make a list of all cases that match our criteria
        for(Evidence_Request__c er : ers)
        {
            for(Id checkId : caseIdsToEmail)
            {
                if(er.Case__r.Id == checkId)
                {
                    dup = true;
                }
            }
            //Checks to make sure we don't get duplicate Case IDs
            if(dup == false)
            {
                caseIdsToEmail.add(er.Case__c);
            }
            dup = false;
        }
        
        system.debug('Added ' + caseIdsToEmail.size() + ' Ids to email list');
        
        List<Case> casesToEmailScope = 
        [
        SELECT Id, CaseNumber, Owner.Name, Account.Name, Contact.Name, CreatedDate, Case.VIN__r.Country__c 
        FROM Case
        Where Id in :caseIdsToEmail
        AND Case.VIN__r.Country__c != 'Canada'
        ];
        
        system.debug('Found ' + casesToEmail.size() + ' cases to email');
        
        casesToEmail.addall(casesToEmailScope);
        

        Logger.flush();
    }
    
 public String BodyFormat(List<Case> lst)  
   {  
       String str = '' ;  
       for(Case cs : lst)  
       {  
           str += '<tr><td>' + '<a href='+ URL.getSalesforceBaseUrl().toExternalForm() + '/'  + cs.Id + '>' + cs.CaseNumber + '</a>' + '</td>'+'<td>'+ cs.Owner.Name +'</td>'+'<td>'+ cs.Account.Name +'</td>'+'<td>'+ cs.Contact.Name +'</td>'+'<td>'+ cs.CreatedDate +'</td>'+'</tr>' ;  
       }  
       str = str.replace('null' , '') ;  
       String finalStr = '' ;  
       finalStr = '<table border="1"> <td> CaseNumber </td> <td> Owner </td> <td> Account </td> <td> Contact </td> <td> Created Date </td> '+ str +'</table>' ;  
       return finalStr ;  
   }
    
    global void finish(Database.BatchableContext bc) 
    {
        try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
            mail.setSenderDisplayName('Salesforce Support');
            String body = '' ;
            body = BodyFormat(casesToEmail) ;
            String[] toAddresses = new String[] {'ArbitrationUS@openlane.com'} ;
            mail.setToAddresses(toAddresses) ;
            mail.setSubject('Arbitration Evidence Not Received');
            mail.setHtmlBody('Hello,\nThe following Arbitration cases have Evidence Requests that have gone over 2 days :' + body);  
            if (!Sandbox.isSandbox())
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e)
        {
            system.debug('Could not send email due to error: ' + e);
        }
    }
    
}