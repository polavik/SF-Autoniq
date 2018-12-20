global class KDM_BatchOpCaseAttachReParent implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    // Constructor  
    public KDM_BatchOpCaseAttachReParent(String strCondition,boolean blnSendBatchCompleteNotification, string strToEmail)   
    {
      query = 'SELECT ID,Attachment_KAR_Id__c,Attachment_OL_ParentId__c FROM Openlane_Attachments__c WHERE Is_ReParented__c=false and Parent_Object_Type__c = \'Case\'' +strCondition;  
      Summary='';
      System.debug('>>> query'+query);
      ToEmail = strToEmail;      
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        try{
           //1. Get List of 200 Records
           List<Openlane_Attachments__c> List_Openlane_Attachments = (List<Openlane_Attachments__c>) scope;
           
           System.debug('>>> List_Openlane_Attachments.size()'+List_Openlane_Attachments.size());
           
           if(List_Openlane_Attachments.size() == 0)
           {
                return;
           }           
           
           //2. Get Ids of Case who migrated from openlane
            List<String> List_Op_Case_Id = new List<String>();
            List<String> List_KAR_Attachment_Id = new List<String>();
            Map<String,String>  mapKARAttachIdToOpenlaneCaseId = new Map<String, String>(); 
            Map<String,Openlane_Attachments__c>  mapKARAttachIdToOpenlaneAttachmentsObject = new Map<String, Openlane_Attachments__c>(); 
            for(Openlane_Attachments__c obj: List_Openlane_Attachments){
                List_Op_Case_Id.Add(obj.Attachment_OL_ParentId__c);   
                List_KAR_Attachment_Id.Add(obj.Attachment_KAR_Id__c);
                mapKARAttachIdToOpenlaneCaseId.put(obj.Attachment_KAR_Id__c,obj.Attachment_OL_ParentId__c);
                mapKARAttachIdToOpenlaneAttachmentsObject.put(obj.Attachment_KAR_Id__c,obj); //new for 12 MB
            }
            
            System.debug('>>> List_Op_Case_Id'+List_Op_Case_Id);
            System.debug('>>> List_KAR_Attachment_Id'+List_KAR_Attachment_Id);
            System.debug('>>> mapKARAttachIdToOpenlaneCaseId'+mapKARAttachIdToOpenlaneCaseId);
            
                        
            //3. Get List of Openlane Case belongs to 200 records 
            List<Temp_Openlane_KAR_Case_Mapper__c> ListOpenlaneCasesMapper = [SELECT Migrated_Openlane_Case_Original_id__c,Migrated_Openlane_Case_KAR_id__c,ID FROM Temp_Openlane_KAR_Case_Mapper__c WHERE Migrated_Openlane_Case_Original_id__c IN :List_Op_Case_Id];
            
            If(ListOpenlaneCasesMapper.size()==0)
            {
                return;
            }
            
            // 4. Get List of Openlane_id to search in all object 
            List<Id> ListMigratedKARCaseId = new List<Id>();           
            Map<String,String>  mapOpenlaneCaseIdToKARCaseId = new Map<String, String>(); 
            for(Temp_Openlane_KAR_Case_Mapper__c oc: ListOpenlaneCasesMapper){
            
                ListMigratedKARCaseId.Add(oc.Migrated_Openlane_Case_KAR_id__c);
                mapOpenlaneCaseIdToKARCaseId.put(oc.Migrated_Openlane_Case_Original_id__c,oc.Migrated_Openlane_Case_KAR_id__c);             
            }           
            
            List<Attachment> List_KAR_Attachment = [SELECT Id, Body, BodyLength, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength<12000000 AND Id IN:List_KAR_Attachment_Id];
            
            if(List_KAR_Attachment.size()>0)
            {
                List<Id> IdsToPurge = new List<Id>();
                List<Attachment> ListNewAttachmet = new List<Attachment>();
                
                for(Attachment objAttachment: List_KAR_Attachment){             
                    if(mapKARAttachIdToOpenlaneCaseId.get(objAttachment.Id)!=null)
                    {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false); //clone(Boolean opt_preserve_id, Boolean opt_IsDeepClone, Boolean opt_preserve_readonly_timestamps, Boolean opt_preserve_autonumber)                
                        CloneAttachment.ParentId = mapOpenlaneCaseIdToKARCaseId.get(mapKARAttachIdToOpenlaneCaseId.get(objAttachment.Id)); 
                        ListNewAttachmet.Add(CloneAttachment);
                        IdsToPurge.Add(objAttachment.Id);
                    }
                        
                }
                //Insert Reparented Attachment ;
                Database.SaveResult[] ListSR = Database.Insert(ListNewAttachmet);
                
                for (Database.SaveResult sr : ListSR) {
                    if (!sr.isSuccess()) {
                        // Operation failed, get all errors                
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
                    //List<Openlane_Attachments__c> ListOpAttachmentsToUpdate = [SELECT Id, Is_ReParented__c FROM Openlane_Attachments__c WHERE Attachment_KAR_Id__c IN :IdsToPurge];
                    
                    List<Openlane_Attachments__c> ListOpAttachmentsToUpdate = new List<Openlane_Attachments__c>();
                    
                    for(String strId:IdsToPurge)
                    {
                        Openlane_Attachments__c objOLA = mapKARAttachIdToOpenlaneAttachmentsObject.get(strId);
                        objOLA.Is_ReParented__c = true;
                        ListOpAttachmentsToUpdate.Add(objOLA);
                    }
                    
                    //for(Openlane_Attachments__c objOLA:ListOpAttachmentsToUpdate)
                    //{
                    //  objOLA.Is_ReParented__c = true;
                    //}
                    
                    Update ListOpAttachmentsToUpdate;
                    
                    Delete List_KAR_Attachment;
                    
                    Database.emptyRecycleBin(IdsToPurge);
                }
            }
            else // for size > 12 MB
            {
                List<Attachment> List_KAR_Attachment2 = [SELECT Id, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength>=12000000 AND Id IN:List_KAR_Attachment_Id];
                if(List_KAR_Attachment2.size()==1)
                {
                    Attachment objAttachment = List_KAR_Attachment2[0];
                    
                    List<Id> IdsToPurge = new List<Id>();
                    
                    if(mapKARAttachIdToOpenlaneCaseId.get(objAttachment.Id)!=null)
                    {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false);                
                        CloneAttachment.ParentId = mapOpenlaneCaseIdToKARCaseId.get(mapKARAttachIdToOpenlaneCaseId.get(objAttachment.Id)); 
                        CloneAttachment.body= Blob.valueof('Dummy Body');
                        IdsToPurge.Add(objAttachment.Id);
                        Insert CloneAttachment ;
                        
                        if(IdsToPurge.size()>0)
                        {
                            //Update Openlane_Attachments Object
                            Openlane_Attachments__c OpAttachmentsToUpdate = mapKARAttachIdToOpenlaneAttachmentsObject.get(objAttachment.Id);
                            
                            OpAttachmentsToUpdate.Is_ReParented__c = true;
                            OpAttachmentsToUpdate.Attachment_KAR_Id2__c = CloneAttachment.Id;
                            
                            Update OpAttachmentsToUpdate;
                            
                            Delete objAttachment;
                            
                            Database.emptyRecycleBin(IdsToPurge);
                        }
                    }                   
                }
            }// for size > 12 MB End 
            
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='Error Detail : '+e.getmessage()+'<br/><br/>';
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        if(SendBatchCompleteNotification)
        { 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('salesforceemails@openlane.com');
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing KDM_BatchOpCaseAttachReParent.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.sethtmlBody(Summary);
            if(!Test.isRunningTest())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
   
}


//KDM_BatchOpCaseAttachReParent objKDM_BatchOpCaseAttachReParent = new KDM_BatchOpCaseAttachReParent('and Load__c=2',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpCaseAttachReParent,1);