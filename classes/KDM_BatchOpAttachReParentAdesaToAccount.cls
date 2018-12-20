// Add: Attachment_KAR_Id3__c ( After re-parent to Account )
// 

global class KDM_BatchOpAttachReParentAdesaToAccount implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    // Constructor  
    public KDM_BatchOpAttachReParentAdesaToAccount(String strCondition,boolean blnSendBatchCompleteNotification, string strToEmail)   
    {
      query = 'SELECT ID,Attachment_KAR_ParentId__c,AttachmentParent_KAR_AdesaComDetail_Id__c,Attachment_KAR_Id2__c FROM Openlane_Attachments__c ' +strCondition;  
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
            List<String> List_KAR_Adesa_Id = new List<String>();
            Map<String,String>  mapKARAttachIdToKARAdesaId = new Map<String, String>(); 
            Map<String,Openlane_Attachments__c>  mapKARAttachIdToOpenlaneAttachmentsObject = new Map<String, Openlane_Attachments__c>(); 
            for(Openlane_Attachments__c obj: List_Openlane_Attachments){
                 
                List_KAR_Attachment_Id.Add(obj.Attachment_KAR_Id2__c);
                List_KAR_Adesa_Id.Add(obj.AttachmentParent_KAR_AdesaComDetail_Id__c);
                mapKARAttachIdToKARAdesaId.put(obj.Attachment_KAR_Id2__c,obj.AttachmentParent_KAR_AdesaComDetail_Id__c);
                mapKARAttachIdToOpenlaneAttachmentsObject.put(obj.Attachment_KAR_Id2__c,obj); //new for 12 MB
            }
            
            
            System.debug('>>> List_KAR_Attachment_Id'+List_KAR_Attachment_Id);
            System.debug('>>> mapKARAttachIdToKARAdesaId'+mapKARAttachIdToKARAdesaId);
            System.debug('>>> List_KAR_Adesa_Id'+List_KAR_Adesa_Id);
            
            // Find Accout from Adesa
             //3. Get List of Openlane Case belongs to 200 records 
            List<Adesa_com_Detail__c> ListAdesa = [SELECT Id,Account__c FROM Adesa_com_Detail__c WHERE ID IN :List_KAR_Adesa_Id];
            
            If(ListAdesa.size()==0)
            {
                return;
            }
            
            // 4. Get List of Openlane_id to search in all object 
            Map<String,String> mapAdesaIdToAccountId = new Map<String, String>(); 
            for(Adesa_com_Detail__c  oc: ListAdesa){
            
                mapAdesaIdToAccountId.put(oc.Id,oc.Account__c);             
            }           
            //
                        
            
            //3. Get real attachment 
            
            List<Attachment> List_KAR_Attachment = [SELECT Id, Body, BodyLength, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength<12000000 AND Id IN:List_KAR_Attachment_Id];
            
            if(List_KAR_Attachment.size()>0)
            {
                List<Id> KARAdesaAttachmentIds = new List<Id>();
                List<Attachment> ListNewAttachmet = new List<Attachment>();
                List<Attachment> ListReparentedAttachmentToDelete = new List<Attachment>();
                
                for(Attachment objAttachment: List_KAR_Attachment){             
                    if(mapKARAttachIdToKARAdesaId.get(objAttachment.Id)!=null)
                    {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false); //clone(Boolean opt_preserve_id, Boolean opt_IsDeepClone, Boolean opt_preserve_readonly_timestamps, Boolean opt_preserve_autonumber)                
                        CloneAttachment.ParentId = mapAdesaIdToAccountId.get(mapKARAttachIdToKARAdesaId.get(objAttachment.Id)); 
                        ListNewAttachmet.Add(CloneAttachment);
                        //ListReparentedAttachmentToDelete.Add(objAttachment);
                        KARAdesaAttachmentIds.Add(objAttachment.Id);
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
                
                if(KARAdesaAttachmentIds.size()>0)
                {                    
                    List<Openlane_Attachments__c> ListOpAttachmentsToUpdate = new List<Openlane_Attachments__c>();
                    
                    for(String strId:KARAdesaAttachmentIds)
                    {
                        Openlane_Attachments__c objOLA = mapKARAttachIdToOpenlaneAttachmentsObject.get(strId);
                        
                        If(ListNewAttachmet.size()>0 && ListNewAttachmet[0].Id!=null) // Use batch size = 1 
                        {
                            objOLA.Attachment_KAR_Id3__c = ListNewAttachmet[0].Id; 
                            objOLA.Attachment_KAR_ParentId__c = mapAdesaIdToAccountId.get(mapKARAttachIdToKARAdesaId.get(strId)); 
                        }
                        ListOpAttachmentsToUpdate.Add(objOLA);
                    }
                    
                    Update ListOpAttachmentsToUpdate;
                    
                    
                }
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
        if(SendBatchCompleteNotification)
        { 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('salesforceemails@openlane.com');
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing KDM_BatchOpAttachReParentAdesaToAccount.'); 
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


//KDM_BatchOpAttachReParentAdesaToAccount objKDM_BatchOpAttachReParentAdesaToAccount = new KDM_BatchOpAttachReParentAdesaToAccount(' WHERE Is_ReParented__c = true and AttachmentParent_KAR_AdesaComDetail_Id__c!=\'\' and Parent_Object_Type__c=\'Account\' limit 10',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpAttachReParentAdesaToAccount,1);