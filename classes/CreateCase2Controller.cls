public class CreateCase2Controller {
    
    public String test {get; set;}
    public ApexPages.StandardController stdController;
    public List<String> validationMessages {get; set;} 
    
    public Case myCase {get; set;}
    public String welcomeMsg {get; set;}
    public String reminderMsg {get; set;}
    public String saleDate {get; set;}
    public String YMMS {get; set;}
    public List<SelectOption> caseReasons {get; set;}
    
    public boolean renderDeliveryDate {get; set;}
    public boolean renderLoadOrderNumber {get; set;}
    public boolean renderEditableVIN {get; set;}
    public boolean renderEditableReason {get; set;}
    public boolean renderSubmitButton {get; set;}
    public boolean renderYMMS {get; set;}
    
    
    public static final transient String ARBITRATION = 'Arbitration';
    public static final transient String TITLE_INQUIRY = 'Title Inquiry';
    public static final transient String OWNERSHIP_INQUIRY = 'Ownership Inquiry';
    public static final transient String PAYMENT_INQUIRY = 'Payment Inquiry';
    public static final transient String TRANSPORTATION_INQUIRY = 'Transportation Inquiry';
    public static final transient String CUSTOMER_SERVICE_INQUIRY = 'Customer Service Inquiry';
    public static final transient String SELLER_INQUIRY = 'Seller Inquiry';
    
    public boolean requireVIN;
	
    Set<String> ListFLSCreate = new Set<String>();
	
    public CreateCase2Controller(ApexPages.StandardController stdController) {      
        this.stdController = stdController;
        myCase = (Case)stdController.getRecord();
        init(); 
    }
    
    /************************ ACTION METHODS *************************/
    
    public PageReference submit() {
	Boolean blnFLSOverride = Utils.GetFLS();
        // This is always used to resolve the Purchase since resolvePurchaseByVid has not been used in a while.
        // That's because we don't get the VID from OL.com anymore
        if (myCase.VIN__c == null) {
            Purchase__c purchase = resolvePurchaseByVin(myCase.Vehicle_Identification_Number__c);
            if (purchase != null) {
                YMMS = purchase.YMMS__c;
                renderYMMS = true;
                renderEditableVIN = false;
				if (Schema.sObjectType.Case.fields.VIN__c.isCreateable() || blnFLSOverride)
				{
					myCase.VIN__c = purchase.Id;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.VIN__c.getName());
				}
            }
            else
            {
                //This means either the VIN didn't exist in the system or it was INLANE or TRANSPORT ONLY and was not picked up in the query
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The vehicle you are attempting to open a case on was not purchased on ADESA.com (ADESA.ca for Canadian purchases). Please refer to your Confirmation of Sale and contact the auction the vehicle was purchased from. For additional questions, please contact ADESA Customer Connection @ 1-888-526-7326 or CustomerConnection@ADESA.com'));
                return null;
            }
            if(purchase.ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c != null)
            {
                if(purchase.ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c == '254793')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Case cannot be opened for this type of purchase.  Please contact Customer Connection at 1-888-526-7326, for further assistance.'));
                    return null;
                }
                
            }
        }
        
        
        //If a Purchase exists, the Case Account should be equal to the Buyer Account on the Purchase (D-02639)
        if (myCase.VIN__c != null) {
            Purchase__c purch = [SELECT Id, ATC_Buyer__r.Id FROM Purchase__c WHERE Id = :myCase.VIN__c]; 
			if (Schema.sObjectType.Case.fields.AccountId.isCreateable() || blnFLSOverride)
			{
				myCase.AccountId = purch.ATC_Buyer__r.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.AccountId.getName());
			}
        }
        
        boolean arbValidationFailed = false;
        Database.SaveResult saveResult;
        
        // Determines which emails get sent when new case is inserted
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        if ('TRUE'.equalsIgnoreCase(Utils.getProperty('case.auto.response'))) {
            dmo.EmailHeader.triggerAutoResponseEmail = true;
        }
		
        if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:CreateCase2Controller', ListFLSCreate);
			return null;
		}
        saveResult = Database.Insert(myCase, dmo);
        
        if (saveResult.isSuccess()) {
            return new PageReference('/' + myCase.Id);
        } else {
            for (Database.Error err : saveResult.getErrors()) {
                if (err.getMessage().startsWith('ARB_VALIDATION_ERROR:')) {
                    arbValidationFailed = true;
                    String validationErrors = err.getMessage().substring(21, err.getMessage().length());
                    for (String validationErr : validationErrors.split('\n')) {
                        validationMessages.add(validationErr);
                    }
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
            }
            
            if (arbValidationFailed) {
                renderEditableVIN = false;
                renderEditableReason = false;
                renderSubmitButton = false;
                myCase.Validation_Outcome_Override__c = true;
                
            }
            
            return null;
        }

    }
    
    public PageReference cancel() {
        
        String toAddress = Utils.getProperty('case.cancel.notif.address');
        
        if (toAddress == null) {
            return Page.dispatcher_case_tab;
        }
        
        String acctName = 'Unknown';
        String location = 'Unknown';
        String privateLabel = 'Unknown';
        List<Account> accts = [select id, BillingCity, BillingState, Name from Account where id = :myCase.AccountId];
        
        if (myCase.VIN__c != null) {
            Purchase__c p = [select Private_Label__c from Purchase__c where Id = :myCase.VIN__c];
            privateLabel = p.Private_Label__c;
        }
        
        if (accts.size() == 1) {
            acctName = accts[0].Name;
            location = accts[0].BillingCity + ', ' + accts[0].BillingState;
        }
        
        String outcomeReason = '';
        for (String msg : validationMessages) {
            outcomeReason = outcomeReason + msg + '\n';
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setBccSender(false);
        mail.setSenderDisplayName('Customer Service Portal');
        mail.setToAddresses(new String[]{toAddress});
        mail.setSubject('Dealer abandons Arbitration Case in Customer Service Portal');
        String body = 
            'An Arbitration Case was started but not completed in the Customer Service Portal.  The dealer abandoned the process after receiving an Invalid Arbitration message.\n\n' +
            'VIN: ' + myCase.Vehicle_Identification_Number__c + '\n\n' +
            'Private Label: ' + privateLabel + '\n\n' +
            'Contact: ' + UserInfo.getName() + '\n\n' +
            'Dealership: ' + acctName + '\n\n' +
            'Dealership Location: ' + location + '\n\n' +
            'Case Reason: ' + myCase.Reason + '\n\n' +
            'Validation Outcome Reason(s): \n' + outcomeReason;
            
            
        mail.setPlainTextBody(body);
        if (!Sandbox.isSandbox())
            messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
        return Page.dispatcher_case_tab;
    }
    
    
    /*********************** INIT METHODS ****************************/
    
    private void init() {
        
		Boolean blnFLSOverride = Utils.GetFLS();

        validationMessages = new List<String>();
        
        User usr = [select ID, Contact.ID, Contact.Account.Id from User where Id = :UserInfo.getUserId()];
		if (Schema.sObjectType.Case.fields.ContactId.isCreateable() || blnFLSOverride)
		{
			myCase.ContactId = usr.Contact.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.ContactId.getName());
		}
        if (Schema.sObjectType.Case.fields.AccountId.isCreateable() || blnFLSOverride)
		{
			myCase.AccountId = usr.Contact.Account.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.AccountId.getName());
		}
		if (Schema.sObjectType.Case.fields.Origin.isCreateable() || blnFLSOverride)
		{
			myCase.Origin = 'Web';
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Origin.getName());
		}
		if (Schema.sObjectType.Case.fields.Validation_Outcome_Override__c.isCreateable() || blnFLSOverride)
		{
			myCase.Validation_Outcome_Override__c = false;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Validation_Outcome_Override__c.getName());
		}
        renderEditableReason = true;
        renderSubmitButton = true;
        renderYMMS = false;

		if (Schema.sObjectType.Case.fields.Type.isCreateable() || blnFLSOverride)
		{
			myCase.Type = ApexPages.currentPage().getParameters().get('type');
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Type.getName());
		}
        
        if (ARBITRATION.equals(myCase.Type))
            initArbitration();
        else if (TITLE_INQUIRY.equals(myCase.Type))
            initTitleInq();
        else if (OWNERSHIP_INQUIRY.equals(myCase.Type))
            initOwnershipInq();
        else if (PAYMENT_INQUIRY.equals(myCase.Type))
            initPaymentInq();
        else if (TRANSPORTATION_INQUIRY.equals(myCase.Type))
            initTransportInq();
        else if (CUSTOMER_SERVICE_INQUIRY.equals(myCase.Type))
            initCustServInq();
        else if (SELLER_INQUIRY.equals(myCase.Type))
            initSellerInq();
        
    }
    
    private void initArbitration() {
	Boolean blnFLSOverride = Utils.GetFLS();
        welcomeMsg = 
            '<h3>You have chosen to log a new Arbitration</h3>' +
            '<p>Please enter the following information to log an arbitration.</p>';
            
        reminderMsg = 
            'Please upload any relevant documents such as shop reports, photos, and/or ' +
            'the bill of lading as attachments on the following page.';
            
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('Odometer Discrepancy', 'Odometer Discrepancy'));
        caseReasons.add(new SelectOption('Undisclosed Poor Prior Repair', 'Undisclosed Poor Prior Repair'));
        caseReasons.add(new SelectOption('Undisclosed Previous Repair', 'Undisclosed Previous Repair'));
        caseReasons.add(new SelectOption('Mechanical Problems', 'Mechanical Problems'));
        caseReasons.add(new SelectOption('Structural/Frame Damage', 'Structural/Frame Damage'));
        caseReasons.add(new SelectOption('Missing Equipment', 'Missing Equipment'));
        caseReasons.add(new SelectOption('Undisclosed Damage', 'Undisclosed Damage'));
        caseReasons.add(new SelectOption('Title Issues', 'Title Issues'));
        caseReasons.add(new SelectOption('Vehicle Unavailable', 'Vehicle Unavailable'));
        caseReasons.add(new SelectOption('Purchased in Error', 'Purchased in Error'));
        caseReasons.add(new SelectOption('Recall', 'Recall'));
        
        renderVehicleInfo();
        renderDeliveryDate = true;
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Arbitration - New'];
		
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
        
        
    }
    
    private void initTitleInq() {
	
		Boolean blnFLSOverride = Utils.GetFLS();
        
        welcomeMsg = 
            '<h3>You have chosen to log a new Title Inquiry</h3>' +
            '<p>Please enter the following information to create a Title Inquiry.</p>';
        
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('Where is my title?', 'Where is my title?'));
        caseReasons.add(new SelectOption('Question on title', 'Question on title'));
        
        renderVehicleInfo();
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Title Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
        
    }
    
    private void initOwnershipInq() {
	
		Boolean blnFLSOverride = Utils.GetFLS();
        
        welcomeMsg = 
            '<h3>You have chosen to log a new Ownership Inquiry</h3>' +
            '<p>Please enter the following information to create a new Ownership Inquiry.</p>';
            
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('Where is my Ownership?', 'Where is my Ownership?'));
        caseReasons.add(new SelectOption('Question on Ownership', 'Question on Ownership'));
        
        renderVehicleInfo();
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Ownership Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
        
    }
    
    private void initPaymentInq() {
        
		Boolean blnFLSOverride = Utils.GetFLS();

        welcomeMsg = 
            '<h3>You have chosen to log a new Payment Inquiry</h3>' +
            '<p>Please enter the following information to create a Payment Inquiry.</p>';
        
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('Refund Status', 'Refund Status'));
        caseReasons.add(new SelectOption('Payment Question', 'Payment Question'));
        caseReasons.add(new SelectOption('Floorplan Question', 'Floorplan Question'));
        caseReasons.add(new SelectOption('Request Invoice', 'Request Invoice'));
        caseReasons.add(new SelectOption('Request to Change Payment Method', 'Request to Change Payment Method'));
    
        renderVehicleInfo();
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Payment Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;  
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
    }
    
    private void initTransportInq() {
	
		Boolean blnFLSOverride = Utils.GetFLS();
        
        welcomeMsg = 
            '<h3>You have chosen to log a new Transportation Inquiry</h3>' +
            '<p>Please enter the following information to create a Transportation Inquiry.</p>';
        
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('General Transportation Question', 'General Transportation Question'));
        caseReasons.add(new SelectOption('Damage Claim', 'Damage Claim'));
        caseReasons.add(new SelectOption('Where is my car?', 'Where is my car?'));
        caseReasons.add(new SelectOption('Transport Quote', 'Transport Quote'));
        caseReasons.add(new SelectOption('Cancel Transport', 'Cancel Transport'));
        
        renderLoadOrderNumber = true;
        renderVehicleInfo();
        renderDeliveryDate = true;
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Transportation Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;  
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
    }
    
    private void initCustServInq() {
        
		Boolean blnFLSOverride = Utils.GetFLS();

        welcomeMsg = 
            '<h3>You have chosen to log a new Customer Service Inquiry</h3>' +
            '<p>Please enter the following information to create a Customer Service Inquiry.</p>';
        
        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('New User Set Up/Modify User', 'New User Set Up/Modify User'));
        caseReasons.add(new SelectOption('Request Vehicle Release', 'Request Vehicle Release'));
        caseReasons.add(new SelectOption('Request for Lein Release (Canada)', 'Request for Lein Release (Canada)'));
        caseReasons.add(new SelectOption('Request Confirmation/Bill of Sale', 'Request Confirmation/Bill of Sale'));
        caseReasons.add(new SelectOption('Update Dealership Information', 'Update Dealership Information'));
        caseReasons.add(new SelectOption('Question on Vehicle', 'Question on Vehicle'));
        caseReasons.add(new SelectOption('Reset Password', 'Reset Password'));
        caseReasons.add(new SelectOption('Technical Support', 'Technical Support'));
        caseReasons.add(new SelectOption('Locate Vehicle', 'Locate Vehicle'));
        caseReasons.add(new SelectOption('Locate Equipment', 'Locate Equipment'));
        caseReasons.add(new SelectOption('Vehicle Grounding', 'Vehicle Grounding'));
        caseReasons.add(new SelectOption('Other', 'Other'));
        
        renderVehicleInfo();
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Customer Service Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;  
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
    }
    
    private void initSellerInq() {
        
		Boolean blnFLSOverride = Utils.GetFLS();

        welcomeMsg = 
            '<h3>You have chosen to log a new Seller Inquiry</h3>' +
            '<p>Please enter the following information to create a Seller Inquiry.</p>';

        caseReasons = new List<SelectOption>();
        caseReasons.add(new SelectOption('','- Please choose a Case Reason -'));
        caseReasons.add(new SelectOption('Seller Funding Inquiry', 'Seller Funding Inquiry'));
        caseReasons.add(new SelectOption('Vehicle Pickup Update', 'Vehicle Pickup Update'));
        caseReasons.add(new SelectOption('Seller Performance Inquiry', 'Seller Performance Inquiry'));
        
        renderVehicleInfo();
        
        RecordType rt = [select Id, SObjectType from RecordType where SObjectType = 'Case' and name= 'Seller Inquiry - New'];
		if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
		{
			myCase.RecordTypeId = rt.Id;  
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
		}
        
    }
    
    
    /****************************** HELPER METHODS ************************/
    
    private void renderVehicleInfo() {
        
		Boolean blnFLSOverride = Utils.GetFLS();

        String vid = ApexPages.currentPage().getParameters().get('vid');
        String vin = ApexPages.currentPage().getParameters().get('vin');
        
        
        
        Purchase__c purchase = resolvePurchaseByVid(vid);
        
        if (purchase != null) {
			if (Schema.sObjectType.Case.fields.VIN__c.isCreateable() || blnFLSOverride)
			{
				myCase.VIN__c = purchase.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.VIN__c.getName());
			}
			if (Schema.sObjectType.Case.fields.Vehicle_Identification_Number__c.isCreateable() || blnFLSOverride)
			{
				myCase.Vehicle_Identification_Number__c = purchase.Name;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Vehicle_Identification_Number__c.getName());
			}
            YMMS = purchase.YMMS__c;
            renderYMMS = true;
            renderEditableVIN = false;
        } else if (vin != null && vin.length() == 17 && !vin.equalsIgnoreCase('null')) {
			if (Schema.sObjectType.Case.fields.Vehicle_Identification_Number__c.isCreateable() || blnFLSOverride)
			{
				myCase.Vehicle_Identification_Number__c = vin;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Vehicle_Identification_Number__c.getName());
			}
            renderEditableVIN = false;
        } else {
            renderEditableVIN = true;
        }
    }
    
    public Purchase__c resolvePurchaseByVid(String vid) {
        
        Purchase__c purchase;
        List<Purchase__c> purchases;
        
        if (vid != null && vid != '' && !vid.equalsIgnoreCase('null')) {
            purchases = [SELECT Id, Name, YMMS__c FROM Purchase__c WHERE Vehicle_ID__c = :vid];
        }
        
        if (purchases != null && purchases.size() == 1) {
            purchase = purchases.get(0);
        }
        
        return purchase;
    }
    
     public Purchase__c resolvePurchaseByVin(String vin) {
        
        String adesaRecordType = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase');
        Purchase__c purchase;
        List<Purchase__c> purchases;
        
        if (vin != null && vin != '' && !vin.equalsIgnoreCase('null')) {
            purchases = [SELECT Id, Name, ATC_Sale_Date__c, YMMS__c, ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c
                         FROM Purchase__c 
                         WHERE Name = :vin
                         AND Segment_Name__c != 'Transport'
                         AND RecordTypeId != :adesaRecordType
                         ORDER BY ATC_Sale_Date__c DESC
                         LIMIT 1];
        } 
        
        if (purchases != null && purchases.size() == 1) {
            purchase = purchases.get(0);
        }
        
        return purchase;
    }

    /************************* CUSTOM GETTER/SETTERS ***************************/
    
    // Visualforce pages aren't smart enough to apply "not" logic to "renderEditableVIN"
     // so create getter that returns its opposite
    public boolean getRenderStaticVIN() {
        return !renderEditableVIN;
    }
    
    public boolean getRenderStaticReason() {
        return !renderEditableReason;
    }
    
    public boolean getRenderContinueCancelButton() {
        return !renderSubmitButton;
    }
}