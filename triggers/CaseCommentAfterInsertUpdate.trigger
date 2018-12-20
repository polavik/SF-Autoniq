trigger CaseCommentAfterInsertUpdate on CaseComment (after insert, after update) 
{
    
    // Determine if the seller needs to be notified of this comment in the Seller Portal
    if (Trigger.isInsert)
    {
        // Retrieve data from DB 
        List<ID> caseIds = new List<ID>();
        Set<Id> allCaseIds = new Set<Id>();
        Map<Id, CaseComment> caseToCaseComments = new Map<Id, CaseComment>();
        for (CaseComment cc : Trigger.new)
        {
            if (cc.IsPublished) // Private Comments don't get sent to the seller
            {
                caseIds.add(cc.ParentId);
            }
            allCaseIds.add(cc.ParentId);
            caseToCaseComments.put(cc.ParentId, cc); 
 
        }
        
        
        
        List<Case> cases = 
        [
            SELECT Id, Escalated_To_Seller__c, Private_Label__c, Seller__c, Notification_Step__c, Notification_Recipient__c,
                (
                    SELECT Id, Assigned_To__c, Assigned_To__r.Id,Assigned_To__r.Email, Assigned_To__r.Name, Assigned_To__r.Phone
                    FROM Case_Escalations__r
                )
            FROM Case
            WHERE Id IN :caseIds
        ];
        
       
        
        // Determine which Case Escalations need to have notifications sent
        List<Case> casesToUpdate = new List<Case>();
        for (Case c : cases)
        {
            // Only run if there is a single Escalation on the case
            //  The apex email won't generate properly if there is more than one Escalation
            //  Since we currently have at most one escalation per case, this is not a problem
            if (c.Case_Escalations__r.size() == 1)
            {
                Seller_Portal_Config__c spc = SellerPortalConfigHelper.getSellerPortalConfig(c.Seller__c, c.Private_Label__c);
                // If permissions set and escalation has been assigned to an individual
                if (spc != null && spc.Send_Comment_Notifications__c )
                {
                    if (c.Case_Escalations__r.get(0).Assigned_To__r != null)
                    {
                        // Solve Portal user unable to retrieve Email from User object .Start 
                        //c.Notification_Step__c = 'COMMENT_ADDED';
                        String tempuserid = c.Case_Escalations__r.get(0).Assigned_To__c;
                        System.debug('### debug:c.Case_Escalations__r.get(0).Assigned_To__r.Name  ' + c.Case_Escalations__r.get(0).Assigned_To__r.Name);
                        System.debug('### debug:c.Case_Escalations__r.get(0).Assigned_To__r.Email  ' + c.Case_Escalations__r.get(0).Assigned_To__r.Email);
                        System.debug('### debug:c.Case_Escalations__r.get(0).Assigned_To__r.Phone  ' + c.Case_Escalations__r.get(0).Assigned_To__r.Phone);
                        
                        Portal_User_Info__c tempuser = [SELECT Name, Email__c FROM Portal_User_Info__c WHERE User__c = :tempuserid ];
                        
                        If (tempuser != null)
                        {
                          System.debug('### User ID    = ' + tempuserid);
                          System.debug('### User Name  = ' + tempuser.Name);
                          System.debug('### User Email = ' + tempuser.Email__c);
                          //System.debug('### Before c.Notification_Recipient__c = ' + c.Notification_Recipient__c);
                          c.Notification_Step__c = 'COMMENT_ADDED';
                          c.Notification_Recipient__c = tempuser.Email__c;                          
                          casesToUpdate.add(c);
                          System.debug('### After** c.Notification_Recipient__c = ' + c.Notification_Recipient__c);
                        }


                        
                        // Solve Portal user unable to retrieve Email from User object .End 
                        //c.Notification_Recipient__c = c.Case_Escalations__r.get(0).Assigned_To__r.Email;
                        

                                                
                        //casesToUpdate.add(c);
                        
                        
                        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        //mail.setTemplateId('00XR0000000IBXs');
                        //mail.setWhatId(c.Id);
                        //mail.setToAddresses(new String[] {'glorge@openlane.com'});
                        //mail.setTargetObjectId(c.Case_Escalations__r.get(0).Assigned_To__c);
                        //mail.setSaveAsActivity(false);
                        //Messaging.sendEmail(new Messaging.Email[] { mail });
                        
                    }
                }
                System.debug('### debug:c.Name  ' + c.Id);
            }
        }
        
        update casesToUpdate;
        
        try{
           List<Case> cToUpdate = new List<Case>();
           List<Case> allCases = [select id, Secondary_Owner_Notification_Step__c, 
                                      Secondary_Owner_Notification_Recipient__c, 
                                      Secondary_Owner__c, Secondary_Owner__r.Email, Case_Comment_Id__c
                                 from case
                                where id in :allCaseIds];
           for(Case c: allCases){
              CaseComment cc = caseToCaseComments.get(c.id);
              
              String caseuserid = c.Secondary_Owner__c;
              Portal_User_Info__c otempuser = null;
              if (caseuserid != null) {
              
                 otempuser = [SELECT Name, Email__c FROM Portal_User_Info__c WHERE User__c = :caseuserid ];
                 
              }
              
              //if(cc!= null && c.secondary_owner__c != null && c.Secondary_Owner__r.Email != null){
              if(cc!= null && c.secondary_owner__c != null && otempuser.Email__c != null){
                  c.Secondary_Owner_Notification_Step__c = 'Comment Added';
                  System.debug('### debug:c.Secondary_Owner__r.Email  ' + c.Secondary_Owner__r.Email);
                  System.debug('### debug:Portal User Email ' + otempuser.Email__c);
                  //c.Secondary_Owner_Notification_Recipient__c = c.Secondary_Owner__r.Email;
                  c.Secondary_Owner_Notification_Recipient__c = otempuser.Email__c;
                  c.Case_Comment_Id__c = String.valueOf(cc.Id);
                  c.Hidden_Case_Comments__c = cc.CommentBody;
                  cToUpdate.add(c);
              }
           }
           System.debug('### debug:cToUpdate ' + cToUpdate);
           update cToUpdate;
           
        }catch(System.Exception e){
           System.debug('### debug: CaseCommentAfterInsertUpdate - ' + e.getMessage());
        }
        
    }
}