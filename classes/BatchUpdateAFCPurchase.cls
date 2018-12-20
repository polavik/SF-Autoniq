global class BatchUpdateAFCPurchase implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
//Batch job to clean all history data which meet the condition
// 1.if data source=AFC and Record Type null -->data source=AFC : Product_Type__c!=null and IAA_Branch_Name__c=null and Car_Group__c=null
// 2.Update record type = "AFC Purchase"
   public String adesaRecordType =  Utils.getRecordTypeId('Purchase__c', 'AFC Purchase');
  
   public String query = 'SELECT  Id ,RecordTypeId FROM Purchase__c where Product_Type__c != null and IAA_Branch_Name__c = null and Car_Group__c = null and RecordTypeId= null ' ;
   
    global void execute(SchedulableContext sc) 
    {
        BatchUpdateAFCPurchase proc = new BatchUpdateAFCPurchase ();
        Database.executeBatch(proc, 100);  //  So that 1 batch can process 100 records
    }
    
//Next the job starts which takes our above query and sends it to the next 'execute' method
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
       
        return Database.getQueryLocator(query); 
    } 

//This execute method will use the results from the query we passed it to uncheck the boxes for this story      
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {
        integer Flag = 1;
        integer blockcount = 1;
        List<Purchase__c> PurchaseListToUpdate= (List<Purchase__c>) scope;
        List<Purchase__c> PurchaseListToUpsert = new List<Purchase__c>();
        
         for(integer i = 0; i < PurchaseListToUpdate.size(); i++)
            {   
                if(Flag== 1)
                {PurchaseListToUpsert = new List<Purchase__c>();}
                
                if (i < blockcount*100)
                {
                    PurchaseListToUpdate.get(i).RecordTypeId = adesaRecordType;
                    PurchaseListToUpsert.add(PurchaseListToUpdate.get(i) );
                     Flag = 0;
                }   
                else
                {
                     Flag = 1;
                }
                
                  if (PurchaseListToUpsert.size() > 99 )
                  {
                    
                    upsert PurchaseListToUpsert ID ; 
                     Flag = 1;
                    //System.debug('Size of PurchaseListToUpsert ' + PurchaseListToUpsert.size()+'I  ' + i +' Block Count ' +blockcount+' Flag ' +Flag);
                   // System.debug('I  ' + i);
                    //System.debug(' Block Count ' +blockcount);
                   // System.debug(' Flag ' +Flag);
                    
                    blockcount =blockcount+1;
                    PurchaseListToUpsert = null;
                    
                    }
            }
        
            if (PurchaseListToUpsert != null)
            {
                if (PurchaseListToUpsert.size() >0 )
                {   
                    //System.debug('Size of PurchaseListToUpsert ' + PurchaseListToUpsert.size() );
                    upsert PurchaseListToUpsert ID ; 
                }
             }  
                
    
            Logger.flush();
        }
        
        global void finish(Database.BatchableContext bc) 
        {
            
        }
        
}