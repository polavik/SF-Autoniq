public class DispatcherActionPkgDetails2Controller 
{

    private final ApexPages.StandardController controller;  
    
    Action_Package__c pkg;
    User owner;
        
    public DispatcherActionPkgDetails2Controller(ApexPages.StandardController controller) 
    {  
        this.controller = controller;
    }
    
    public PageReference redirect() 
    { 
        
        ID pkgId = controller.getId();
        
        pkg = 
            [SELECT
                Account_Name__c,
                Accounting_Notified__c,
                Accounting_Notified_Date__c,
                Case__c,
                Case__r.CaseNumber,
                Case__r.Type,
                Case__r.VIN__r.Actual_Pickup__c,
                Case__r.VIN__r.Car_Group_Config_Id__c,
                Case__r.VIN__r.Country__c,
                Case__r.VIN__r.Handles_Title__c,
                Emailed_To__c,
                Name,
                Owner.Name,
                Package_Type__c,
                Seller__c,
                VIN__c,
                Void_House_Transport__c,
                Is_Dealer_Block__c
            FROM Action_Package__c WHERE Id = :pkgId];
        
        if(pkg!=null && pkg.Case__c!=null &&  pkg.Case__r.VIN__c !=null)
        {        
            sendVoidNotification();        
            update pkg;     
        }
        PageReference ref = controller.view();
        Map<String, String> params = ref.getParameters();
        params.put('nooverride','1');
        return ref;
    }
    
    public void sendVoidNotification() 
    {   
        Purchase__c purchase = pkg.Case__r.VIN__r;
        
        String country = purchase.Country__c;
        String cgc = String.valueOf((Integer) purchase.Car_Group_Config_Id__c);
        Long transport = isTransportCancelled(pkg);
        String packageType = pkg.Package_Type__c;
        String handlesTitle = purchase.Handles_Title__c;
        //String dealer_block = pkg.Is_Dealer_Block__c;
        String is_dealer_block = 'N';
        if ('Yes'.equalsIgnoreCase(pkg.Is_Dealer_Block__c)) {
            
           is_dealer_block = 'Y'; 
        }
       
        // Some distribution lists get sent all attachments on the case, others only receive
        //  the void pdf.  
        List<String> receiveAttachmentsAddresses = new List<String>();
        List<String> noAttachmentsAddresses = new List<String>();
        
        // Query database for list of notification recipients
        for (Action_Pkg_Distribution_List__c distList :
                [SELECT Email__c, Send_Attachments__c
                 FROM Action_Pkg_Distribution_List__c
                 WHERE (Countries__c INCLUDES (:country) OR Countries__c = '')
                 AND (Car_Group_Config_Ids__c INCLUDES (:cgc) OR Car_Group_Config_Ids__c = '')
                 AND (Package_Types__c INCLUDES (:packageType) OR Package_Types__c = '')
                 AND (Includes_Transport__c = :transport OR Includes_Transport__c = null)
                 AND (DealerBlock__c = :is_dealer_block OR DealerBlock__c = '')
                 AND (Handles_Title__c = :handlesTitle OR Handles_Title__c = '')]) 
        {   
                        
            if (distList.Send_Attachments__c == 1) 
            {
                receiveAttachmentsAddresses.add(distList.Email__c);
            } 
            else 
            {
                noAttachmentsAddresses.add(distList.Email__c);
            }
        }
        
		/*
        // Generate Valid instance base URL
        String HostURL = URL.getSalesforceBaseUrl().getHost();
        String CurrentUrlNode ;
        //String HostURL = 'c.na19.salesforce.com';
        Integer parts = HostURL.countMatches('.');                        
        if(parts== 2)
        {                        
            CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0));
        }else{
        
            CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2));
        }
        HostURL = 'https://' + CurrentUrlNode+'.salesforce.com/';
        System.Debug('>>> HostURL: '+HostURL );
        // Generate Valid instance base URL
        */
		
		//djpatel on 18-Nov-2016 (B-43977) for get Production URL
		// Get Valid instance URL Start 
		
		String HostURL = URL.getSalesforceBaseUrl().toExternalForm();
		System.Debug('>>> HostURL: '+HostURL );
		
		/*
		if(!Sandbox.isSandbox())
		{
			HostURL = Utils.getProdUrl('production.url'); 
			if(HostURL == null || HostURL == '')
			{
				HostURL = 'https://login.salesforce.com';
			}			
		}
		else
		{
			HostURL = Utils.getSandboxUrl('sandbox.url'); 
			if(HostURL == null || HostURL == '')
			{
				HostURL = 'https://test.salesforce.com';
			}
		}
		*/
		
		// Get Valid instance URL End
		
        // Define Notification Email 
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        String attachmentFileName = getAttachmentName(pkg);
        String subject = '[' + pkg.Package_Type__c + ' #' + pkg.Name + '] '+pkg.VIN__c+' - '+pkg.Seller__c+' - '+pkg.Account_Name__c+' - Package is Approved';
        String body = 'A New Action Package Has Been Approved.\n\n' +
            HostURL +'/'+ pkg.Id + '\n\n' + 
            'Action Package Number: ' + pkg.Name + '\n\n' + 
            'VIN: ' + pkg.VIN__c + '\n\n' +
            'Owner: ' + pkg.Owner.Name + '\n\n' +
            'Case Number: ' + pkg.Case__r.CaseNumber + '\n\n' + 
            'Case Type: ' + pkg.Case__r.Type + '\n\n' +
            'Type of Action Package: ' + pkg.Package_Type__c + '\n\n' +
            'Please see ' + attachmentFileName + ' (attached) for additional details. ';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setUseSignature(false);
        
        // Generate Void Form PDF
        PageReference pdf = getPdfReference(pkg);

        Blob b = pdf.getContent();
        Messaging.EmailFileAttachment voidPDF = new Messaging.EmailFileAttachment();
        voidPDF.setFileName(attachmentFileName);
        voidPDF.setBody(b);
        emailFileAttachments.add(voidPDF);
        
        // Send PDF Only to noAttachmentsAddresses group
        mail.setToAddresses(noAttachmentsAddresses);
        mail.setFileAttachments(emailFileAttachments);
        if (!Sandbox.isSandbox()) 
            Messaging.sendEmail(new Messaging.Email[] { mail });
        
        // Retrieve all attachments from parent case
        List<Attachment> evidence = 
        [
            SELECT BodyLength, Id, Name, ParentId 
            FROM Attachment 
            WHERE ParentId = :pkg.Case__c 
            OR ParentId = :pkg.Id
        ];
        
        // Since inbound email file size is limited to 10 MB by IT, first verify that the file size...
        //  ...of all evidence is less than 9.5 MB (leave a little buffer for PDF + email body)
        Integer attachmentSize = 0;
        boolean includeEvidence = false;
        for (Attachment a : evidence) 
        {
            attachmentSize += a.BodyLength;
        }
        if (attachmentSize < 9500000) 
        {
            includeEvidence = true;
        }
        
        // If the size isn't too large, include all attachments.  
        if (includeEvidence) {
            System.debug('>>> Size < 10 MB');
            // Retrieve all attachments from parent case
            List<Attachment> evidence2 = 
            [
                SELECT Body, BodyLength, Id, Name, ParentId 
                FROM Attachment 
                WHERE ParentId = :pkg.Case__c 
                OR ParentId = :pkg.Id
            ];
        
            for (Attachment a : evidence2) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                emailFileAttachments.add(efa);
            }
        }
            
        if (!includeEvidence) {
            body = body + '\n\n' +
                'Unfortunately, due to the size and number of attachments on this Case, ' +
                'orginal evidence could not be included with this email.  Please visit the above URL if ' +
                'you need to view any of the attachments submitted with this Case.';
                System.debug('>>> Size > 10 MB ');
        mail.setPlainTextBody(body);
        }        
        //Send Void Form and All Attachments on Case to receiveAttachmentsAddresses group
        mail.setToAddresses(receiveAttachmentsAddresses);
        mail.setFileAttachments(emailFileAttachments);
        mail.setSubject(subject);
        if (!Sandbox.isSandbox()) 
            Messaging.sendEmail(new Messaging.Email[] { mail });
        System.debug('>>> Send email');
        
        // Save PDF on Action Package record
        Attachment a = new Attachment();
		
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();

		if (Schema.sObjectType.Attachment.fields.Name.isCreateable() || blnFLSOverride)
		{			
			a.Name = attachmentFileName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.Name.getName());
		}
		if (Schema.sObjectType.Attachment.fields.Body.isCreateable() || blnFLSOverride)
		{			
			a.Body = b;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.Body.getName());
		}
		if (Schema.sObjectType.Attachment.fields.ParentId.isCreateable() || blnFLSOverride)
		{			
			a.ParentId = pkg.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.ParentId.getName());
		}

		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:DispatcherActionPkgDetails2Controller', ListFLSCreate);
		}
        insert a;
        
        // Record list of email recipients for auditing
        List<String> allRecipients = new List<String>();
        allRecipients.addAll(noAttachmentsAddresses);
        allRecipients.addAll(receiveAttachmentsAddresses);
		
		Set<String> ListFLSUpdate = new Set<String>();
 
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		if (Schema.sObjectType.Action_Package__c.fields.Emailed_To__c.isUpdateable() || blnFLSOverride)
		{
			pkg.Emailed_To__c = Utils.joinList(allRecipients, '; ');
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Emailed_To__c.getName());
		}
		 
        if (Schema.sObjectType.Action_Package__c.fields.Accounting_Notified__c.isUpdateable() || blnFLSOverride)
		{
			pkg.Accounting_Notified__c = true;
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Accounting_Notified__c.getName());
		}
		
		if (Schema.sObjectType.Action_Package__c.fields.Accounting_Notified_Date__c.isUpdateable() || blnFLSOverride)
		{
			pkg.Accounting_Notified_Date__c = Date.today();
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Accounting_Notified_Date__c.getName());
		}
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:DispatcherActionPkgDetails2Controller', ListFLSUpdate);
		}
        
    }   
    
    public PageReference getPdfReference(Action_Package__c pkg)
    {
        PageReference pdf;
        if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) || 
            'TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) ||
            'CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            pdf = Page.crf_form;        
            pdf.getParameters().put('id', controller.getId());
            pdf.getParameters().put('src', 'ACTION_PACKAGE__C');
            pdf.setRedirect(true);
        }
        else
        {
            pdf = Page.void_form;       
            pdf.getParameters().put('id', controller.getId());
            pdf.setRedirect(true);
        }
        return pdf;
    }
    
    public static String getAttachmentName(Action_Package__c pkg)
    {
        String fileName;
        if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) || 
            'TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) ||
            'CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            fileName = 'crf_form' + DateTime.now().format('yyyyMMdd_hhmmss')+ '.pdf';
        }
        else
        {
            fileName = 'void_form_' + DateTime.now().format('yyyyMMdd_hhmmss')+ '.pdf';
        }
        return fileName;
    }
    
    public static Long isTransportCancelled(Action_Package__c pkg) 
    {
        return (pkg.Void_House_Transport__c && (pkg.Case__r.VIN__r.Actual_Pickup__c == null)) ? 1 : 0;
    }
    
}