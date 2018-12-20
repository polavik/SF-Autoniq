public class CaseEscalationController 
{
    public Case_Escalation__c escalation {get; set;}
    public List<CaseCommentDisplay> allComments {get; set;}
    public List<AttachmentDisplay> allAttachments {get; set;}
    public List<HistoryDisplay> histories {get; set;}
    
    public CaseEscalationController(ApexPages.StandardController stdController) 
    {
        ID escalationId = stdController.getId();
        
        escalation = 
            [SELECT 
                Case__c,
                Goodwill__c,
                Case_Number__c,
                CreatedDate,
                Location__c,
                Name,
                Owner.Name,
                Date_Time_Opened__c,
                Case_Type__c,
                Date_Time_Closed__c,
                Status__c,
                Days_Escalated__c,
                Account_Name__c,
                Contact_Name__c,
                Contact_Phone__c,
                Alternative_Contact_Phone__c,
                Contact_Email__c,
                Alternative_Contact_Email__c,
                Alternative_Contact_Name__c,
                VIN__c,
                YMMS__c,
                Grounding_Dealership__c,
                Sale_Date__c,
                Sale_Price__c,
                Actual_Dropoff__c,
                Case_Reason__c,
                Reference_Number__c,
                Escalation_Resolution__c,
                Concession_Amount__c,
                Resolution_Details__c,
                Payment_sent_to_OPENLANE__c,
                Assigned_To__c,
                Approver__c,
                Approval_Status__c,
                Approver__r.Name,
                Approver__r.Email,
                Assigned_To__r.Name,
                Assigned_To__r.Email,
                Consignee__c,
                Segment__c,
                Openlane_CaseEsc_Number__c,
                (SELECT
                    Body,
                    CreatedBy.Name,
                    CreatedDate
                 FROM Notes
                 ORDER BY CreatedDate),
                (SELECT 
                    Name,
                    BodyLength,
                    CreatedDate,
                    CreatedBy.Name
                 FROM Attachments
                 ORDER BY CreatedDate),
                (SELECT 
                    OldValue, 
                    NewValue, 
                    Field, 
                    CreatedDate, 
                    CreatedBy.Name
                 FROM Histories
                 ORDER BY CreatedDate)
            FROM Case_Escalation__c
            WHERE Id = :escalationId];
        
        // Retrieve Comments and Attachments from parent Case
        escalation.Case__r = 
            [SELECT 
                Owner.Name, 
                Description,
                (SELECT CommentBody, CreatedDate, CreatedBy.Name
                 FROM CaseComments
                 WHERE IsPublished = true
                 ORDER BY CreatedDate),
                (SELECT Name, BodyLength, CreatedDate, CreatedBy.Name
                 FROM Attachments
                 WHERE IsPrivate = false
                 ORDER BY CreatedDate),
                 
                 Has_Mechanical_Issues__c,
                 Has_Missing_Equipment__c,
                 Has_Structural_Frame_Damage__c,
                 Has_Undisclosed_Damage__c,
                 Has_Undisclosed_Poor_Previous_Repairs__c,  
                 Has_Undisclosed_Previous_Repairs__c,
                 Addl_Mechanical_Issues__c,
                 Addl_Missing_Equipment__c,
                 Addl_Structural_Frame_Damage__c,
                 Addl_Undisclosed_Damage__c,
                 Addl_Undisclosed_Poor_Previous_Repairs__c,
                 Addl_Undisclosed_Previous_Repairs__c                
                 
             FROM Case
             WHERE Id = :escalation.Case__c];
             
        
        // Merge CaseComments and Notes into an ordered list of CaseCommentDisplays
        allComments = new List<CaseCommentDisplay>();
        List<CaseCommentDisplay> dcc1 = new List<CaseCommentDisplay>();
        List<CaseCommentDisplay> dcc2 = new List<CaseCommentDisplay>();
        for (CaseComment cc : escalation.Case__r.CaseComments)
        {
            dcc1.add(new CaseCommentDisplay(cc));
        }
        for (Note n : escalation.Notes)
        {
            dcc2.add(new CaseCommentDisplay(n));
        }
        for (Object o : Utils.mergeLists(dcc1, dcc2))
        {
            allComments.add((CaseCommentDisplay) o);
        }

        
        allAttachments = new List<AttachmentDisplay>();
        List<AttachmentDisplay> ad1 = new List<AttachmentDisplay>();
        List<AttachmentDisplay> ad2 = new List<AttachmentDisplay>();
        for (Attachment a : escalation.Attachments)
        {
            ad1.add(new AttachmentDisplay(a));
        }    
        for (Attachment a : escalation.Case__r.Attachments)
        {
            ad2.add(new AttachmentDisplay(a));
        }
        for (Object o : Utils.mergeLists(ad1, ad2))
        {
            allAttachments.add((AttachmentDisplay) o);
        }
        
        processHistory();
    }
    
    // Working with Salesforce history data is awful and I never want to do it again
    public void processHistory()
    {
        
        histories = new List<HistoryDisplay>();
        for (Case_Escalation__History h : escalation.Histories)
        {
            boolean newValueIsAnId = false;
            if (h.newValue != null)
            {
                try
                {
                    ID foo = (ID) h.newValue;
                    newValueIsAnId = true;
                }
                catch (Exception e)
                {
                    //do nothing
                }
            }
            
            if (h.Field.equals('created'))
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Created.'
                ));
            }
            else if(newValueIsAnId)
            {
                //Don't want to mess with IDs
            }
            else if (h.Field.equals('Assigned_To__c'))
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Assigned to ' + h.NewValue + '.'
                ));
            }
            else if (h.Field.equals('Approver__c'))
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Approver set to ' + h.NewValue + '.'
                ));
            }
            else if (h.Field.equals('Notify_Assignee__c') && h.newValue == true)
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Case assigned notification sent.'
                ));
            }
            else if (h.Field.equals('Notify_Approver__c') && h.newValue == true)
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Approval request notification sent.'
                ));
            }
            else if (h.Field.equals('Escalation_Resolution__c'))
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Resolution set to ' + h.newValue + '.'
                ));
            }
            else if (h.Field.equals('Approved__c') && h.newValue == true)
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Approved.'
                ));
            }
            else if (h.Field.equals('Case_Status_History__c'))
            {
                histories.add(new HistoryDisplay(
                    h.CreatedDate,
                    h.CreatedBy.Name,
                    'Case Status set to ' + h.newValue + '.'
                ));
            }
        }
    }
    
    public pageReference editResolution()
    {
        PageReference pr = Page.case_escalation_edit;
        pr.getParameters().put('id', escalation.Id);
        return pr;
    }
/*
    public pageReference editMiscReasons()
    {
        PageReference pr = Page.additional_reasons_edit;
        pr.getParameters().put('id', escalation.Id);
        return pr;
    } */    
    public PageReference addComment() 
    {
        PageReference pr = Page.case_escalation_comment;
        pr.getParameters().put('id', escalation.Id);
        return pr;
    }
    
    public PageReference addAttachment()
    {
        PageReference pr = new PageReference('/p/attach/NoteAttach');
        pr.getParameters().put('pid', escalation.Id);
        pr.getParameters().put('retURL', '/' + escalation.Id);
        return pr;
    }
    
    // Used to convert CaseComment and Note objects into a format that will display nicely in the UI
    public class CaseCommentDisplay implements Utils.Comparable
    {
        public DateTime createdDate {get; set;}
        public String createdBy {get; set;}
        public String body {get; set;}
        
        public CaseCommentDisplay(CaseComment cc)
        {
            createdDate = cc.CreatedDate;
            createdBy = cc.CreatedBy.Name;
            body = cc.CommentBody;
        }
        
        public CaseCommentDisplay(Note n)
        {
            createdDate = n.CreatedDate;
            createdBy = n.CreatedBy.Name;
            body = n.Body;
        }
        
        public String getFormattedCreatedDate()
        {
            return createdDate.format();
        }
        
        public Integer compare(Object o2)
        {
            CaseCommentDisplay ccd2 = (CaseCommentDisplay) o2;
            if (this.createdDate.getTime() <=  ccd2.createdDate.getTime())
            {
                return -1;
            }
            else 
            {
                return 1;
            }
        }
    }
    
    public class HistoryDisplay
    {
        public DateTime createdDate {get; set;}
        public String userName {get; set;}
        public String action {get; set;}
        
        public HistoryDisplay(DateTime createdDate, String userName, String action)
        {
            this.createdDate = createdDate;
            this.userName = userName;
            this.action = action;
        }
    }
    
    public class AttachmentDisplay implements Utils.Comparable
    {
        
        public String name {get; set;}
        public Integer bodyLength {get; set;}
        public DateTime createdDate {get; set;}
        public String createdBy {get; set;}
        public String url {get; set;}
        
        public AttachmentDisplay(Attachment a)
        {
            this.name = a.name;
            this.bodyLength = a.bodyLength;
            this.createdDate = a.CreatedDate;
            this.createdBy = a.CreatedBy.Name;
            this.url = '/servlet/servlet.FileDownload?file=' + a.Id;
        }
        
        public String getFormattedCreatedDate()
        {
            return createdDate.format();
        }
        
        public Integer compare(Object o2)
        {
            AttachmentDisplay ad2 = (AttachmentDisplay) o2;
            if (this.createdDate.getTime() < ad2.createdDate.getTime())
            {
                return -1;
            }
            else
            {
                return 1;
            }
        }
    }
}