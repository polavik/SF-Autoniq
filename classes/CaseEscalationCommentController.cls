public class CaseEscalationCommentController 
{
    public Case_Escalation__c escalation {get; set;}
    public String newComment {get; set;}
    public boolean editCommentPermission {get; set;}
    public boolean visibleToBuyer {get; set;}
    public boolean sendEmailToBuyer {get; set;}
    
    public CaseEscalationCommentController(ApexPages.StandardController stdController) 
    {
        
        visibleToBuyer = false;
        sendEmailToBuyer = false;
        
        ID escalationId = stdController.getId();
        escalation = 
        [
            SELECT 
                Id, 
                Case__c, 
                Case__r.Private_Label__c,
                Case__r.Seller__c,
                Case__r.ContactId,
                Case__r.Notification_Step__c,
                Case__r.Notification_Recipient__c,
                Last_Comment__c, 
                Last_Comment_Date__c
            FROM Case_Escalation__c 
            WHERE Id = :escalationId
        ];
    
        Seller_Portal_Config__c spc = SellerPortalConfigHelper.getSellerPortalConfig(escalation.Case__r.Seller__c, escalation.Case__r.Private_Label__c);
        if (spc != null && spc.Edit_Case_Comments__c)
        {
            editCommentPermission = true;
        }
        else
        {
            editCommentPermission = false;
        }       
    }
    
    public PageReference submit()
    {
		Set<String> ListFLSUpdate = new Set<String>();
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();

        System.debug('visibleToBuyer: ' + visibleToBuyer);
        try
        {
            String createdBy = 'Created By: ' + UserInfo.getName() + ' (' + DateTime.now().format('dd-MMM-yyyy HH:mm:ss', 'z-0800') + ')';
            
            if (editCommentPermission && visibleToBuyer)
            {
                CaseComment cc = new CaseComment();
				if (Schema.sObjectType.CaseComment.fields.ParentId.isCreateable() || blnFLSOverride)
				{
					cc.ParentId = escalation.Case__c;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.CaseComment.getName()+'.'+Schema.sObjectType.CaseComment.fields.ParentId.getName());
				}
				if (Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() || blnFLSOverride)
				{
					cc.CommentBody = newComment;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.CaseComment.getName()+'.'+Schema.sObjectType.CaseComment.fields.CommentBody.getName());
				}
				if (Schema.sObjectType.CaseComment.fields.IsPublished.isCreateable() || blnFLSOverride)
				{
					cc.IsPublished = true;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.CaseComment.getName()+'.'+Schema.sObjectType.CaseComment.fields.IsPublished.getName());
				}
				if(ListFLSCreate.size()==0)
				{		 	
					insert cc;
				}
            }
            else
            {
                Note n = new Note();
				if (Schema.sObjectType.Note.fields.Title.isCreateable() || blnFLSOverride)
				{
					n.Title = createdBy;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Note.getName()+'.'+Schema.sObjectType.Note.fields.Title.getName());
				}
				if (Schema.sObjectType.Note.fields.Body.isCreateable() || blnFLSOverride)
				{
					n.Body = newComment;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Note.getName()+'.'+Schema.sObjectType.Note.fields.Body.getName());
				}
				if (Schema.sObjectType.Note.fields.parentId.isCreateable() || blnFLSOverride)
				{
					n.parentId = escalation.Id;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Note.getName()+'.'+Schema.sObjectType.Note.fields.parentId.getName());
				}
				if (Schema.sObjectType.Note.fields.IsPrivate.isCreateable() || blnFLSOverride)
				{
					n.IsPrivate = false;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Note.getName()+'.'+Schema.sObjectType.Note.fields.IsPrivate.getName());
				}
				if(ListFLSCreate.size()==0)
				{		 	
					insert n;
				}
            }
            if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:CaseEscalationCommentController', ListFLSCreate);
				return null;
			}
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.Case_Escalation__c.fields.Last_Comment__c.isUpdateable() || blnFLSOverride)
			 {						 
				escalation.Last_Comment__c = createdBy + '\n' + newComment;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Case_Escalation__c.getName()+'.'+Schema.sObjectType.Case_Escalation__c.fields.Last_Comment__c.getName());
			 }
			 if (Schema.sObjectType.Case_Escalation__c.fields.Last_Comment_Date__c.isUpdateable() || blnFLSOverride)
			 {						 
				escalation.Last_Comment_Date__c = DateTime.now();
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Case_Escalation__c.getName()+'.'+Schema.sObjectType.Case_Escalation__c.fields.Last_Comment_Date__c.getName());
			 }
			 if(ListFLSUpdate.size()==0)
			 {
				update escalation;			 	
			 }
            
            if (visibleToBuyer != null && sendEmailToBuyer != null  && sendEmailToBuyer)
            {
                //User buyerUserAccount = null;
                Portal_User_Info__c buyerUserAccount = null;
                if (escalation.Case__r.ContactId != null)
                {
                    //buyerUserAccount = [SELECT Id, Email FROM User WHERE ContactId = :escalation.Case__r.ContactId];
                    buyerUserAccount = [SELECT Id, contact__c, Email__c FROM Portal_User_Info__c WHERE contact__c = :escalation.Case__r.ContactId];
                    //System.debug('!!!$$$ Email : ' + buyerUserAccount.Email );
                    System.debug('!!!$$$ Email : ' + buyerUserAccount.Email__c );
                    System.debug('!!!$$$ Contact ID  : ' + escalation.Case__r.ContactId );
                }
                if (buyerUserAccount != null)
                {
                    //System.debug('!!! Case is updated, Email will be fired!' );
                    Case c = escalation.Case__r;
					if (Schema.sObjectType.Case.fields.Notification_Step__c.isUpdateable() || blnFLSOverride)
					{	
						c.Notification_Step__c = 'SP_COMMENT_ADDED';
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Notification_Step__c.getName());
					}
                    //c.Notification_Recipient__c = buyerUserAccount.Email;
					if (Schema.sObjectType.Case.fields.Notification_Recipient__c.isUpdateable() || blnFLSOverride)
					{	
						c.Notification_Recipient__c = buyerUserAccount.Email__c;
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Notification_Recipient__c.getName());
					}
					if(ListFLSUpdate.size()==0)
					{
						update c;
					}
                }
            }
            
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:CaseEscalationCommentController', ListFLSUpdate);
				return null;
			}
            
            PageReference pr = Page.case_escalation;
            pr.getParameters().put('id', escalation.Id);
            return pr;
        }
        catch(DmlException ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }

    }
    
    public PageReference cancel()
    {
        PageReference pr = Page.case_escalation;
        pr.getParameters().put('id', escalation.Id);
        return pr;
    }
}