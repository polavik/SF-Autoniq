global class BatchCaseAttachmentReParent implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    // Constructor  
    public BatchCaseAttachmentReParent()  
    {
      query = 'SELECT ID FROM case WHERE Is_Migrated_Openlane_Case__c = true ';  
      Summary='';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
           //1. Get List of 200 Records
           List<Case> ListKARCase = (List<Case>) scope;
           //System.debug('>>>> ListKARCase:'+ListKARCase);
           if(ListKARCase.size() == 0)
           {
                return;
           }
           
           //2. Get Ids of Case who migrated from openlane
            List<String> List_KAR_Case_Id = new List<String>();
            for(Case c: ListKARCase){
                List_KAR_Case_Id.Add(c.Id);         
            }
                        
            //3. Get List of Openlane Case belongs to 200 records 
            List<Temp_Openlane_KAR_Case_Mapper__c> ListOpenlaneCasesMapper = [SELECT Migrated_Openlane_Case_Original_id__c,Migrated_Openlane_Case_KAR_id__c,ID FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_KAR_id__c IN :List_KAR_Case_Id];
            
            // 4. Get List of Openlane_id to search in all object 
            List<Id> ListMigratedOpenlaneCaseId = new List<Id>();           
            Map<String,String>  mapOpenlaneCaseIdToKARCaseId = new Map<String, String>(); 
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
            
                ListMigratedOpenlaneCaseId.Add(oc.Migrated_Openlane_Case_Original_id__c);
                mapOpenlaneCaseIdToKARCaseId.put(oc.Migrated_Openlane_Case_Original_id__c,oc.Migrated_Openlane_Case_KAR_id__c);             
            }           
            
            List<Id> KARAttachmentId = new List<Id>();
            Map<String,String>  mapKARAttachmentIdToKARCaseId = new Map<String, String>(); 
            List<Openlane_Attachments__c> ListOpAttachments = [SELECT Id, Attachment_KAR_Id__c,Attachment_OL_ParentId__c  FROM Openlane_Attachments__c WHERE Is_ReParented__c=false and  Attachment_OL_ParentId__c IN :ListMigratedOpenlaneCaseId];
            for(Openlane_Attachments__c objOLA:ListOpAttachments)
            {
                KARAttachmentId.Add(objOLA.Attachment_KAR_Id__c);
                if(mapOpenlaneCaseIdToKARCaseId.get(objOLA.Attachment_OL_ParentId__c)!=null)
                {
                    mapKARAttachmentIdToKARCaseId.put(objOLA.Attachment_KAR_Id__c,mapOpenlaneCaseIdToKARCaseId.get(objOLA.Attachment_OL_ParentId__c));
                }
            }
            
            System.debug('>>> KARAttachmentId'+KARAttachmentId);
            List<Attachment> List_KAR_Attachment = [SELECT Id, Body, BodyLength, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength<12000000 and Id IN:KARAttachmentId];
           
            
            
            List<Id> IdsToPurge = new List<Id>();
            List<Attachment> ListNewAttachmet = new List<Attachment>();
            
            for(Attachment objAttachment: List_KAR_Attachment){             
                
                Attachment CloneAttachment = objAttachment.clone(false,true,true,false);                
                CloneAttachment.ParentId = mapKARAttachmentIdToKARCaseId.get(objAttachment.Id); 
                ListNewAttachmet.Add(CloneAttachment);
                IdsToPurge.Add(objAttachment.Id);
                    
            }
            
            
            
            //Insert Reparented Attachment ;
            Database.SaveResult[] ListSR = Database.Insert(ListNewAttachmet);
            
            for (Database.SaveResult sr : ListSR) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error >>');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        Summary+='Error : '+err.getMessage()+'<br/><br/>';
                    }
                }
            }           
            
            
            
            if(IdsToPurge.size()>0)
            {
                //Update Openlane_Attachments Object
                List<Openlane_Attachments__c> ListOpAttachmentsToUpdate = [SELECT Id, Is_ReParented__c FROM Openlane_Attachments__c WHERE Attachment_KAR_Id__c IN :IdsToPurge];
                for(Openlane_Attachments__c objOLA:ListOpAttachmentsToUpdate)
                {
                    objOLA.Is_ReParented__c = true;
                }
                Update ListOpAttachmentsToUpdate;
                
                Delete List_KAR_Attachment;
                
                Database.emptyRecycleBin(IdsToPurge);
            }
            
            
            
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
        String[] toAddresses = new String[] {'djpatel@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        //mail.setReplyTo('salesforceemails@openlane.com');
        mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
        mail.setSubject('Finished processing BatchCaseAttachmentReParent.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.sethtmlBody(Summary);
        if(!Test.isRunningTest())
        { 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
   
}


//BatchCaseAttachmentReParent objBatchCaseAttachmentReParent = new BatchCaseAttachmentReParent();
//Database.executeBatch(objBatchCaseAttachmentReParent);