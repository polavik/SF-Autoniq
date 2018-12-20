global class BatchUpdateContactPromotion implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
//Batch job that checks Contacts for Valid Promotions


//Query used for the getQueryLocator
   // public String query = 'select id,Name,Location__c,Consignor__c,ADESA_Dallas__c,ADESA_Atlanta__c,ADESA_Birmingham__c,ADESA_Wisconsin__c from Contact where Location__c != null  and Active__c = True and Recordtypeid =01230000000DEXY';
   //public String query = 'select id,Name,Location__c,Consignor__c,ADESA_Dallas__c,ADESA_Atlanta__c,ADESA_Birmingham__c,ADESA_Wisconsin__c from Contact where Location__c != null  and Active__c = True and Recordtypeid =\'01230000000DEXY\'';
    public String adesaRecordType = Utils.getRecordTypeId('Contact', 'Contact');
  
    public String query = 'select id,Name,Location__c,Consignor__c,ADESA_Central_Kentucky__c,ADESA_Mercer__c,ADESA_Northern_Ohio__c,ADESA_Springdale__c,ADESA_Pittsburgh__c,ADESA_Queen_City__c ,ADESA_Dallas__c, ADESA_Atlanta__c, ADESA_Austin__c, ADESA_Birmingham__c, ADESA_Boston__c, ADESA_Charlotte__c, ADESA_Cincinnati__c, ADESA_Cleveland__c, ADESA_Colorado_Springs__c, ADESA_Concord__c, ADESA_Des_Moines__c, ADESA_East_Tennessee__c, ADESA_Fargo__c, ADESA_Golden_Gate__c, ADESA_Great_Lakes__c, ADESA_Houston__c, ADESA_Indianapolis__c, ADESA_Jacksonville__c, ADESA_Kansas_City__c,ADESA_Knoxville__c, ADESA_Lansing__c, ADESA_Las_Vegas__c, ADESA_Lexington__c, ADESA_Little_Rock__c, ADESA_Long_Island__c, ADESA_Los_Angeles__c, ADESA_Memphis__c, ADESA_Miami__c, ADESA_Minneapolis__c, ADESA_Nashville__c, ADESA_New_Jersey__c, ADESA_Ocala__c, ADESA_PA__c, ADESA_Phoenix__c, ADESA_Raleigh__c, ADESA_Sacramento__c, ADESA_San_Antonio__c, ADESA_San_Diego__c, ADESA_Sarasota__c, ADESA_Seattle__c, ADESA_Shreveport__c, ADESA_Sioux_Falls__c, ADESA_St_Louis__c, ADESA_Syracuse__c, ADESA_Tampa__c, ADESA_Tulsa__c, ADESA_Washington_DC__c, ADESA_Wisconsin__c, ADESA_Calgary__c,ADESA_Edmonton__c,ADESA_Halifax__c,ADESA_Kitchener__c,ADESA_Moncton__c,ADESA_Montreal__c,ADESA_Ottawa__c,ADESA_Quebec_City__c,ADESA_Richmond__c,ADESA_Saskatoon__c,ADESA_St_John_s__c,ADESA_Toronto__c,ADESA_Vancouver__c,ADESA_Winnipeg__c from Contact where Location__c != null  and Active__c = True and sign_me_up__c=true and Recordtypeid = \''+adesaRecordType +'\'' ;

    //ADESA_Calgary__c,ADESA_Edmonton__c,ADESA_Halifax__c,ADESA_Kitchener__c,ADESA_Moncton__c,ADESA_Montreal__c,ADESA_Ottawa__c,ADESA_Quebec_City__c,ADESA_Richmond__c,ADESA_Saskatoon__c,ADESA_St_John_s__c,ADESA_Toronto__c,ADESA_Vancouver__c,ADESA_Winnipeg__c   
    //public String query = 'select id,Name,Location__c,Consignor__c,ADESA_Dallas__c,ADESA_Atlanta__c,ADESA_Birmingham__c,ADESA_Wisconsin__c from Contact where Active__c = True and Recordtypeid =\'01230000000DEXY\'';


    UpdateContactHTMLBlock ClassToRun = new UpdateContactHTMLBlock();   
//List<Contact> ListOfContcts = [ select id,Name,Location__c,Consignor__c,ADESA_Dallas__c,ADESA_Atlanta__c,ADESA_Birmingham__c,ADESA_Wisconsin__c from Contact  where Location__c != '' limit 1000];        
//First the Scheduler calls our job and 'execute' is performed
    global void execute(SchedulableContext sc) 
    {
        BatchUpdateContactPromotion proc = new BatchUpdateContactPromotion();
        Database.executeBatch(proc, 50);  //  So that 1 batch can process 200 records Not sure why '1' was specified
    }
    
//Next the job starts which takes our above query and sends it to the next 'execute' method
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        System.debug('QueryLocator start...');
        return Database.getQueryLocator(query);
    } 

//This execute method will use the results from the query we passed it to uncheck the boxes for this story      
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {
       System.debug('BatchableContext execute start...');
       List<Contact> contsToProcess = (List<Contact>) scope;
    
       List<Contact> ContactListToUpsert = new List<Contact>();
    
     //   ClassToRun.FetchContacts(ContactListToUpsert);
    
         ClassToRun.FetchContacts(contsToProcess);
         
         System.debug('BatchableContext after FetchContacts');

        Logger.flush();
    }
    
    global void finish(Database.BatchableContext bc) 
    {
    }
    
}