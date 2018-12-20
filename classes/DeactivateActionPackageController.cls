public class DeactivateActionPackageController {

    private final ApexPages.StandardController controller;  
    public Action_Package__c pkg {get; set;}
    
    public boolean isAvailable {get; set;}
    
    public boolean getIsUnavailable() {return !isAvailable;}
 
    public DeactivateActionPackageController (ApexPages.StandardController controller) 
    {  
        this.controller = controller;
        ID pkgId = controller.getId();
        isAvailable = true;
        
        pkg = 
            [SELECT
                Account_Name__c,
                Contact_Name__c,
                Case__r.VIN__r.Name,
                Case__r.VIN__r.Transport_Void_Package__c,
                Case__r.VIN__r.Vehicle_Void_Package__c,
                Case__r.VIN__r.Vehicle_ID__c,
                Deactivation_Comments__c,
                Emailed_To__c,
                Notification_Step__c,
                Seller__c,
                Status__c,
                (
                    SELECT 
                        Account__c,
                        Action_Package__c,
                        Credit_Amount__c,
                        Date_Time_Applied__c,
                        Expires__c,
                        Name,
                        Purchase__c,
                        Status__c
                    FROM Auction_Credits__r
                ),
                Void_House_Transport__c,
                Void_Vehicle__c
             FROM Action_Package__c
             WHERE Id = :pkgId];
        
        if ('Approved'.equals(pkg.Status__c)) 
        {
            if (validateProfile()) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Insufficient privileges to Deactivate an Approved Action Package.'));
                isAvailable = false;
            } 
            else 
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,
                    'This Action Package has already been approved.  Any changes made in SAP and V1 will need to be reversed manually.');
                ApexPages.addMessage(msg);
            }
        } 
        else if ('Pending...'.equals(pkg.Status__c)) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Can not Deactivate a package in Pending Approval status.  Recall, Reject, or Approve package first'));
            isAvailable = false;
        } 
        else if ('Deactivated'.equals(pkg.Status__c) || 'Canceled'.equals(pkg.Status__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'This Action Package has already been Deactivated.'));
            isAvailable = false;
        } 
        else 
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,
                    'This action cannot be reversed.');
            ApexPages.addMessage(msg);
        }
    }
    
    public boolean validateProfile() 
    {
        Profile prof = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        
        Set<String> allowedApprovers = new Set<String>(); 
/*                 
        allowedApprovers.add('ADESA System Administrator');
        allowedApprovers.add('ADESA Canada Admin');
        allowedApprovers.add('Program Coordination-US');
        allowedApprovers.add('Arbitration Manager - Canada');
        allowedApprovers.add('Arbitration Manager - US');
        allowedApprovers.add('Openlane Super User');
        allowedApprovers.add('Openlane-Admin Canada');
        allowedApprovers.add('Openlane Operations Manager Canada');
        allowedApprovers.add('Openlane Operations Manager US');
        allowedApprovers.add('Openlane Sales Manager Canada');
        allowedApprovers.add('Openlane Sales Manager US');
        allowedApprovers.add('Program Coordination Manager-Canada');
        allowedApprovers.add('Transportation Manager');
        allowedApprovers.add('System Administrator');
        allowedApprovers.add('Dealer Service/Arb Coordinator-Canada');
        allowedApprovers.add('ADESA Delegated Support');
        // PPM 111119 
        allowedApprovers.add('ADESA Canada Super User') ;
*/

		// PPM 111119 & improvement use custom setting instead of hard coding 		
	 	Integer i=0;
	 	System.debug('prof name = ' + prof.Name);
		for(Allowed_Approvers__c allowed_Approver : Allowed_Approvers__c.getAll().values() )
		{
			i++;
			String approver = allowed_Approver.approver_profile_name__c ;
			allowedApprovers.add(approver);		
		 	System.debug('---allowedApprovers_' +i+ ' = '+  approver);
		}
        
        return !allowedApprovers.contains(prof.Name);
    }
    
    public PageReference back() 
    {
        return controller.view();
    }
    
    public PageReference deactivate() 
    {
        Logger.info(pkg, 'Deactivating Package');
        if ('Approved'.equals(pkg.Status__c)) 
        {
            pkg.Status__c = 'Deactivated';
        
            if (pkg.Case__r.VIN__r.Transport_Void_Package__c == pkg.Id) 
            {
                Logger.info(pkg, 'Unsetting Transport Void Package on Case');
                pkg.Case__r.VIN__r.Transport_Void_Package__c = null;
            }
            
            if (pkg.Case__r.VIN__r.Vehicle_Void_Package__c == pkg.Id) 
            {
                Logger.info(pkg, 'Unsetting Vehicle Void Package on Case');
                pkg.Case__r.VIN__r.Vehicle_Void_Package__c = null;
            }
            
            if (pkg.Auction_Credits__r.size() > 0)
            {
                Logger.info(pkg, 'Deactivating Auction Credits');
                AuctionCreditHelper.deactivateCredits(pkg.Auction_Credits__r);
            }
            
            Logger.info(pkg, 'Void_House_Transport__c: ' + pkg.Void_House_Transport__c);
            Logger.info(pkg, 'Void_Vehicle__c: ' + pkg.Void_Vehicle__c);
            
            if (pkg.Void_House_Transport__c || pkg.Void_Vehicle__c)
            {
                if (pkg.Case__r != null && pkg.Case__r.VIN__r != null)
                {
                    Logger.info(pkg, 'Reversing Void Status in Post Sales');
                    reverseVoid(pkg.Id);
                }
            }
            
            // Send notification email about deactivation to all 
            // recipients of the original void form.  Include original PDF as attachment 
            if (pkg.Emailed_To__c != null) 
            {
                Logger.info(pkg, 'Sending Email Notification');
                List<String> emailAddys = pkg.Emailed_To__c.split('; ');
                
                String body = 'An Action Package has been deactivated: \n\n' + 
                    'VIN: ' + pkg.Case__r.VIN__r.Name + '\n' +
                    'VEHICLE ID: ' + pkg.Case__r.VIN__r.Vehicle_ID__c + '\n' +
                    'BUYER: ' + pkg.Account_Name__c + '\n' + 
                    'BUYER CONTACT: ' + pkg.Contact_Name__c + '\n' + 
                    'SELLER: ' + pkg.Seller__c + '\n\n' + 
                    'COMMENTS: ' + pkg.Deactivation_Comments__c + '\n\n' +
                    'The original void form has been attached for your reference.  ' + 
                    'All reversals will need to be performed manually in V1 and SAP.\n';
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddys);
                mail.setSubject('An Action Package has been Deactivated');
                mail.setPlainTextBody(body);
                mail.setUseSignature(false);
                
                List<Attachment> attachments = [SELECT Name, Body, ParentId FROM Attachment WHERE ParentId = :pkg.Id]; 
                if (attachments.size() == 1) 
                {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(attachments[0].Name);
                    efa.setBody(attachments[0].Body);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                }
                
                if (!Sandbox.isSandbox())
                    Messaging.sendEmail(new Messaging.Email[] { mail });
            }
            
            if (pkg.Case__r != null && pkg.Case__r.VIN__r != null)
            {
                update pkg.Case__r.VIN__r;
            }
            
        } 
        else 
        {
            pkg.Status__c = 'Deactivated';
        }
        
        
        update pkg;
        
        Logger.flush();
        
        return controller.view();
    }
    
    @future(callout=true)
    private static void reverseVoid(ID pkgId)
    {
        Action_Package__c pkg =
        [
            SELECT Id, Notification_Step__c, Case__r.VIN__r.Vehicle_ID__c
            FROM Action_Package__c
            WHERE Id = :pkgId
        ];
        
        Logger.info(pkg, 'Reversing Void Status in Post Sales...');
        
        Logger.info(pkg, 'Calling Mediator...');
        Long vehicleId = Long.valueOf(pkg.Case__r.VIN__r.Vehicle_ID__c);
        try
        {
            Mediator.MediatorService mediator = MediatorWrapper.getInstance().getMediatorService();
            Mediator.reverseVoidResponse_element response = mediator.reverseVoid(vehicleId);
            Logger.info(pkg, 'Response Code: ' + response.returnCode);
            logger.info(pkg, 'Error Message: ' + response.errorMsg);
            if (!'SUCCESS'.equalsIgnoreCase(response.returnCode))
            {
                Logger.info(pkg, 'Sending Error Notification Email');
                pkg.Notification_Step__c = 'REVERSE_VOID_FAILURE';
                update pkg;
            }
        }
        catch (Exception e)
        {
            Logger.error(pkg, 'Unexpected Error:');
            Logger.error(pkg, e.getMessage());
        }
        Logger.flush();
    }
}