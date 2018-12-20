global class KDM_BatchOpCollectionAttachReParent implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    // Constructor  
    public KDM_BatchOpCollectionAttachReParent(String strCondition,boolean blnSendBatchCompleteNotification, string strToEmail)   
    {
      query = 'SELECT ID,Attachment_KAR_Id__c,Attachment_OL_ParentId__c,Attachment_KAR_ParentId__c FROM Openlane_Attachments__c ' +strCondition;  
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
            
            List<String> List_KAR_Attachment_Id = new List<String>();
            Map<String,String>  mapKARAttachIdToKARCollectionId = new Map<String, String>(); 
            Map<String,Openlane_Attachments__c>  mapKARAttachIdToOpenlaneAttachmentsObject = new Map<String, Openlane_Attachments__c>(); 
            for(Openlane_Attachments__c obj: List_Openlane_Attachments){
                 
                List_KAR_Attachment_Id.Add(obj.Attachment_KAR_Id__c);
                mapKARAttachIdToKARCollectionId.put(obj.Attachment_KAR_Id__c,obj.Attachment_KAR_ParentId__c);
                mapKARAttachIdToOpenlaneAttachmentsObject.put(obj.Attachment_KAR_Id__c,obj); //new for 12 MB
            }
            
            
            System.debug('>>> List_KAR_Attachment_Id'+List_KAR_Attachment_Id);
            System.debug('>>> mapKARAttachIdToKARCollectionId'+mapKARAttachIdToKARCollectionId);
            
                        
            
            //3. Get real attachment 
            
            List<Attachment> List_KAR_Attachment = [SELECT Id, Body, BodyLength, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength<12000000 AND Id IN:List_KAR_Attachment_Id];
            
            if(List_KAR_Attachment.size()>0)
            {
                List<Id> IdsToPurge = new List<Id>();
                List<Attachment> ListNewAttachmet = new List<Attachment>();
                List<Attachment> ListReparentedAttachmentToDelete = new List<Attachment>();
                
                for(Attachment objAttachment: List_KAR_Attachment){             
                    if(mapKARAttachIdToKARCollectionId.get(objAttachment.Id)!=null)
                    {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false); //clone(Boolean opt_preserve_id, Boolean opt_IsDeepClone, Boolean opt_preserve_readonly_timestamps, Boolean opt_preserve_autonumber)                
                        CloneAttachment.ParentId = mapKARAttachIdToKARCollectionId.get(objAttachment.Id); 
                        ListNewAttachmet.Add(CloneAttachment);
                        ListReparentedAttachmentToDelete.Add(objAttachment);
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
                        If(ListNewAttachmet.size()>0 && ListNewAttachmet[0].Id!=null) // Use batch size = 1 
                        {
                            objOLA.Attachment_KAR_Id2__c = ListNewAttachmet[0].Id; 
                        }
                        ListOpAttachmentsToUpdate.Add(objOLA);
                    }
                    
                    Update ListOpAttachmentsToUpdate;
                    
                    Delete ListReparentedAttachmentToDelete;
                    
                    Database.emptyRecycleBin(IdsToPurge);
                }
            }
            else // for size > 12 MB
            {
                List<Attachment> List_KAR_Attachment2 = [SELECT Id, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength>=12000000 AND Id IN:List_KAR_Attachment_Id];
                if(List_KAR_Attachment2.size()==1) // Use batch size = 1 
                {
                    Attachment objAttachment = List_KAR_Attachment2[0];
                    
                    List<Id> IdsToPurge = new List<Id>();
                    
                    if(mapKARAttachIdToKARCollectionId.get(objAttachment.Id)!=null)
                    {
                        //Attachment CloneAttachment = objAttachment.clone(false,true,true,false);                
                        //CloneAttachment.ParentId = mapKARAttachIdToKARCollectionId.get(objAttachment.Id); 
                        //CloneAttachment.body= Blob.valueof('Dummy Body');
                        IdsToPurge.Add(objAttachment.Id);
                        //Insert CloneAttachment ;
                        
                        if(IdsToPurge.size()>0)
                        {
                            //Update Openlane_Attachments Object
                            Openlane_Attachments__c OpAttachmentsToUpdate = mapKARAttachIdToOpenlaneAttachmentsObject.get(objAttachment.Id);
                            
                            //OpAttachmentsToUpdate.Is_ReParented__c = true;
                            //OpAttachmentsToUpdate.Attachment_KAR_Id2__c = CloneAttachment.Id;
                            OpAttachmentsToUpdate.Attachment_BodyLength_GE_12000000__c = true;
                            
                            Update OpAttachmentsToUpdate;
                            
                            //Delete objAttachment;
                            
                            //Database.emptyRecycleBin(IdsToPurge);
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
            mail.setSubject('Finished processing KDM_BatchOpCollectionAttachReParent.'); 
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


//KDM_BatchOpCollectionAttachReParent objKDM_BatchOpCollectionAttachReParent = new KDM_BatchOpCollectionAttachReParent(' WHERE Is_ReParented__c=false and Parent_Object_Type__c=\'Collection\' limit 10',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpCollectionAttachReParent,1);