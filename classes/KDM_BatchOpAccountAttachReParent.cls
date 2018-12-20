global class KDM_BatchOpAccountAttachReParent implements Database.Batchable<SObject>, Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    // Constructor  
    public KDM_BatchOpAccountAttachReParent(String strCondition,boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      query = 'SELECT ID,Attachment_KAR_Id__c,AttachmentParent_KAR_AdesaComDetail_Id__c FROM Openlane_Attachments__c WHERE Is_ReParented__c=false and Parent_Object_Type__c = \'Account\' '+strCondition;  
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
           
           //2. Get Ids from 200 Openlane Attachment records
            List<String> List_KAR_Attachment_Id = new List<String>();
            Map<String,Openlane_Attachments__c>  mapKARAttachIdToOpenlaneAttachmentsObject = new Map<String, Openlane_Attachments__c>(); 
            Map<String,String>  mapKARAttachIdToKARParentAdesaId = new Map<String, String>(); 
            for(Openlane_Attachments__c obj: List_Openlane_Attachments){
                List_KAR_Attachment_Id.Add(obj.Attachment_KAR_Id__c);
                mapKARAttachIdToKARParentAdesaId.put(obj.Attachment_KAR_Id__c,obj.AttachmentParent_KAR_AdesaComDetail_Id__c);
                mapKARAttachIdToOpenlaneAttachmentsObject.put(obj.Attachment_KAR_Id__c,obj); 
            }            
            
            List<Attachment> List_KAR_Attachment = [SELECT Id, Body, BodyLength, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength<12000000 AND Id IN:List_KAR_Attachment_Id];
            
            if(List_KAR_Attachment.size()>0)
            {
                List<Id> IdsToPurge = new List<Id>();
                List<Attachment> ListNewAttachmet = new List<Attachment>();
                
                for(Attachment objAttachment: List_KAR_Attachment){             
                   if(mapKARAttachIdToKARParentAdesaId.get(objAttachment.Id)!=null)
                   {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false); //clone(Boolean opt_preserve_id, Boolean opt_IsDeepClone, Boolean opt_preserve_readonly_timestamps, Boolean opt_preserve_autonumber)                
                        CloneAttachment.ParentId = mapKARAttachIdToKARParentAdesaId.get(objAttachment.Id); 
                        ListNewAttachmet.Add(CloneAttachment);
                        IdsToPurge.Add(objAttachment.Id);
                    }    
                }
                
                System.debug('>>>> Before Insert1:');
                //Insert Reparented Attachment ;
                Database.SaveResult[] ListSR = Database.Insert(ListNewAttachmet);
                System.debug('>>>> After Insert1:');
                
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
                System.debug('>>>> Exit from Save Result1:');
                //System.debug('>>>> ListNewAttachmet:'+ListNewAttachmet);
                //System.debug('>>>> ListNewAttachmet[0]:'+ListNewAttachmet[0]);
                //System.debug('>>>> ListNewAttachmet[0].Id:'+ListNewAttachmet[0].Id);
                //System.debug('>>>> ListNewAttachmet.size():'+ListNewAttachmet.size());
                //System.debug('>>>> ListNewAttachmet[0].Id != null:'+ListNewAttachmet[0].Id != null);
                //System.debug('>>>> ListNewAttachmet[0].Id != null:'+ListNewAttachmet[0].Id != '');
                System.debug('>>>> Before Enter in Loop:');
                
                //if(ListNewAttachmet.size()>0 && ListNewAttachmet[0].Id != null && ListNewAttachmet[0].Id != '') // Keep Batch Size =1 
                //If(ListNewAttachmet[0].Id!='')
                If(ListNewAttachmet.size()>0 && ListNewAttachmet[0].Id!=null)
                {
                System.debug('>>>> Inside Loop:');
                
                    if(IdsToPurge.size()>0)
                    {
                        System.debug('>>>> Inside Loop2:');
                        List<Openlane_Attachments__c> ListOpAttachmentsToUpdate = new List<Openlane_Attachments__c>();
                        
                        for(String strId:IdsToPurge)
                        {
                            System.debug('>>>> Inside Loop3:');
                            Openlane_Attachments__c objOLA = mapKARAttachIdToOpenlaneAttachmentsObject.get(strId);
                            objOLA.Is_ReParented__c = true;
                            objOLA.Attachment_KAR_Id2__c = ListNewAttachmet[0].Id; //new for Account
                            ListOpAttachmentsToUpdate.Add(objOLA);
                        }                  
                        
                        System.debug('>>>> Before Update OpAttach:');
                        Update ListOpAttachmentsToUpdate;
                        
                        System.debug('>>>> Before Delete Attach:');
                        Delete List_KAR_Attachment;
                        
                        System.debug('>>>> Before Purge:');
                        Database.emptyRecycleBin(IdsToPurge);
                    }
                }
            }
            else // for size > 12 MB // Always Keep Batch Size = 1
            {
                List<Attachment> List_KAR_Attachment2 = [SELECT Id, ContentType, CreatedById, CreatedDate, IsDeleted, Description, Name, LastModifiedById, LastModifiedDate, OwnerId,Owner.Name, ParentId, IsPrivate, SystemModstamp FROM Attachment WHERE BodyLength>=12000000 AND Id IN:List_KAR_Attachment_Id];
                if(List_KAR_Attachment2.size()==1)
                {
                    Attachment objAttachment = List_KAR_Attachment2[0];
                    
                    List<Id> IdsToPurge = new List<Id>();
                    
                    if(mapKARAttachIdToKARParentAdesaId.get(objAttachment.Id)!=null)
                    {
                        Attachment CloneAttachment = objAttachment.clone(false,true,true,false);                
                        CloneAttachment.ParentId = mapKARAttachIdToKARParentAdesaId.get(objAttachment.Id); 
                        CloneAttachment.body= Blob.valueof('Dummy Attachment');
                        IdsToPurge.Add(objAttachment.Id);
                        Insert CloneAttachment ;
                        if(CloneAttachment.Id!=null && CloneAttachment.Id!='')
                        {
                            if(IdsToPurge.size()>0)
                            {
                                //Update Openlane_Attachments Object
                                Openlane_Attachments__c OpAttachmentsToUpdate = mapKARAttachIdToOpenlaneAttachmentsObject.get(objAttachment.Id);
                                
                                OpAttachmentsToUpdate.Is_ReParented__c = true;
                                OpAttachmentsToUpdate.Attachment_KAR_Id2__c = CloneAttachment.Id;
                                OpAttachmentsToUpdate.Attachment_BodyLength_GE_12000000__c = true;
                                
                                Update OpAttachmentsToUpdate;
                                
                                Delete objAttachment;
                                
                                Database.emptyRecycleBin(IdsToPurge);
                            }
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
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished processing KDM_BatchOpAccountAttachReParent.'); 
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


//KDM_BatchOpAccountAttachReParent objKDM_BatchOpAccountAttachReParent = new KDM_BatchOpAccountAttachReParent('and Load__c=2',true,'dipesh.patel@openlane.com');
//Database.executeBatch(objKDM_BatchOpAccountAttachReParent,1);