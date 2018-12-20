global class AuctionCreditHelper
{
    
    // Format: RecordType.Name -> RecordType.Id
    private static Map<String, ID> sapDocTypeMap;

    public static List<Auction_Credit__C> createCreditsFromActionPackage(Action_Package__c pkg)
    {
        ID goodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Goodwill');
        ID sellerGoodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Seller Auction Credit - Goodwill');
        
        List<Auction_Credit__c> auctionCredits = new List<Auction_Credit__c>();
        
        Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
        for (Integer i = 0; i<pkg.Number_Of_Credits__c; i++)
        {
            Auction_Credit__c credit = new Auction_Credit__c();
			//Story B-44003 : FLS CREATE ACCESS CHECK
			if (Schema.sObjectType.Auction_Credit__c.fields.Credit_Amount__c.isCreateable() || blnFLSOverride)
			{
				credit.Credit_Amount__c = pkg.Credit_Amount__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.Credit_Amount__c.getName());
			}
			if (Schema.sObjectType.Auction_Credit__c.fields.Action_Package__c.isCreateable() || blnFLSOverride)
			{
				credit.Action_Package__c = pkg.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.Action_Package__c.getName());
			}
            
            if(pkg.package_type__c == 'Seller Auction Credit'){
				if (Schema.sObjectType.Auction_Credit__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
				{
					credit.RecordTypeId = sellerGoodwillRT;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.RecordTypeId.getName());
				}
				if (Schema.sObjectType.Auction_Credit__c.fields.Account__c.isCreateable() || blnFLSOverride)
				{
					credit.Account__c = pkg.Case__r.Seller__c;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.Account__c.getName());
				}
				if (Schema.sObjectType.Auction_Credit__c.fields.Contact__c.isCreateable() || blnFLSOverride)
				{
					credit.Contact__c = pkg.Seller_Contact__c;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.Contact__c.getName());
				}
            }else{
				if (Schema.sObjectType.Auction_Credit__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
				{
					credit.RecordTypeId = goodwillRT;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.RecordTypeId.getName());
				}
				if (Schema.sObjectType.Auction_Credit__c.fields.Account__c.isCreateable() || blnFLSOverride)
				{
					credit.Account__c = pkg.Case__r.AccountId;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Auction_Credit__c.getName()+'.'+Schema.sObjectType.Auction_Credit__c.fields.Account__c.getName());
				}
            }
            
            auctionCredits.add(credit);
        }
		
        if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:AuctionCreditHelper', ListFLSCreate);
			return null;
		}
		
        insert auctionCredits;
        return auctionCredits;
    }
    
    public static void deactivateCredits(List<Auction_Credit__c> auctionCredits)
    {
        for (Auction_Credit__c credit : auctionCredits)
        {
            if ('AVAILABLE'.equalsIgnoreCase(credit.Status__c))
            {
                credit.Status__c = 'Deactivated';
            }
            else if ('PENDING APPLICATION'.equalsIgnoreCase(credit.Status__c))
            {
                credit.Status__c = 'Deactivated';
            }
            else if ('USED'.equalsIgnoreCase(credit.Status__c))
            {
                credit.Status__c = 'Deactivated';
                credit.Notification_Step__c = 'CREDIT_DEACTIVATED';
            }
            else if ('EXPIRED'.equalsIgnoreCase(credit.Status__c))
            {
                // Nothing to do here
            }
        }
        
        update auctionCredits;
    }
    
    public static void expireCredits(List<Auction_Credit__c> auctionCredits)
    {
        for (Auction_Credit__c credit : auctionCredits)
        {
            if ('AVAILABLE'.equalsIgnoreCase(credit.Status__c))
            {
                credit.Status__c = 'Expired';
            }
        }
        
        update auctionCredits;
    }
    
    webservice static void applyCredit(String id)
    {
        Auction_Credit__c credit = 
        [
            SELECT name,
                Id, 
                CurrencyIsoCode, 
                Credit_Amount__c, 
                Expires__c, 
                Credit_Reason__c,
                Promotional_Credit_Reason__c, 
                Response_Messages__c, 
                Send_Results__c, 
                Status__c, 
                RecordTypeId,
                Action_Package__r.Credit_Reason__c, 
                Action_Package__r.CurrencyIsoCode, 
                Action_Package__r.Name, 
                Action_Package__r.Standard_SAP_Transactions__c,
                Purchase__r.Vehicle_ID__c, 
                Purchase__r.ATC_Buyer__r.Name, 
                Purchase__r.ATC_Buyer__r.SAP_Customer_Number__c, 
                Purchase__r.ATC_Seller__r.Name, 
                Purchase__r.ATC_Seller__r.SAP_Customer_Number__c, 
                Purchase__r.Vehicle_Payment_Method_Id__c, 
                Purchase__r.Car_Group_Config_Id__c, 
                Purchase__r.Country__c, 
                Purchase__r.Handles_Title__c, 
                Purchase__r.Name, Purchase__r.Transport_Payment_Method_Id__c 
             FROM Auction_Credit__c 
             WHERE Id = :id
        ];
        if(credit != null){
            sendToMediator(new Auction_Credit__c[] {credit});     
        }
    }
    
    webservice static void sendNotification(String id)
    {
        Auction_Credit__c credit = 
        [
            SELECT Id, 
                CurrencyIsoCode, 
                Credit_Amount__c, 
                Expires__c, 
                Promotional_Credit_Reason__c, 
                Name,
                Response_Messages__c, 
                Send_Results__c, 
                Status__c, 
                RecordTypeId,
                Auction_Credit_Type__c,
                Contact__r.Email,
                Action_Package__r.Credit_Reason__c, 
                Action_Package__r.CurrencyIsoCode, 
                Action_Package__r.Name, 
                Action_Package__r.Standard_SAP_Transactions__c,
                Action_Package__r.Seller_Contact__r.Email,
                Purchase__r.Vehicle_ID__c, 
                Purchase__r.ATC_Buyer__r.Name, 
                Purchase__r.ATC_Buyer__r.SAP_Customer_Number__c, 
                Purchase__r.ATC_Buyer_Contact__r.Email,
                Purchase__r.ATC_Seller__r.Name, 
                Purchase__r.ATC_Seller__r.SAP_Customer_Number__c, 
                Purchase__r.Vehicle_Payment_Method_Id__c, 
                Purchase__r.Car_Group_Config_Id__c, 
                Purchase__r.Country__c, 
                Purchase__r.Handles_Title__c, 
                Purchase__r.Name, 
                Purchase__r.Transport_Payment_Method_Id__c 
             FROM Auction_Credit__c 
             WHERE Id = :id
        ];
        
        sendCRFNotification(new Auction_Credit__c[] {credit});       
    }
    
    public static void sendToMediator(List<Auction_Credit__c> credits)
    {
        List<Action_Package_Document__c> docs = new List<Action_Package_Document__c>();
        for (Auction_Credit__c credit : credits)
        {   
            try
            {
                credit.Status__c = 'Used';
                credit.Purchase__c = credit.Purchase__r.Id;
                credit.Date_Time_Applied__c = DateTime.now();
                
                SendResponse sr = sendToMediator(credit);
                credit.Send_Results__c = sr.results;
                credit.Response_Messages__c = Utils.joinList(sr.messages, '\n');
                docs.addAll(sr.docs);
            }
            catch (Exception e)
            {
                Logger.error(credit, 'Error sending Auction Credit to Mediator');
                credit.Send_Results__c = 'An unexpected error occured.  Please contact production support.';
                credit.Response_Messages__c = e.getMessage();
                throw e;
            }
        }
        
        update credits;
        
        Integer maxBlockSize = 200;
        for (Integer i = 0; i < docs.size(); i+=200) 
        {
            Integer blockSize = Math.min(maxBlockSize, docs.size() - i);
            List<Action_Package_Document__c> block = new List<Action_Package_Document__c>();
            for (Integer j = i; j < i + blockSize; j++) 
            {
                block.add(docs.get(j));
            }           
            insert block;
        }
    }
    
    private static SendResponse sendToMediator(Auction_Credit__c credit)
    {
        Logger.info(credit, 'sendToMediator() called');

        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();

        Logger.info(credit, 'Converting to Mediator format');
        
        Purchase__c purchase = credit.Purchase__r;
        
        Long vehicleId = Long.valueOf(purchase.Vehicle_ID__c);
        //Story B-18601 requries us to send a prefix of AC- or AP- depending on if credit was created by AP or on account directly
        String actionPackageId = credit.Action_Package__r.Name;
        if (actionPackageId == null) {
        	actionPackageId = 'AC-' + credit.Name;
        }
        else {
        	actionPackageId = 'AP-' + credit.Action_Package__r.Name;
        }
        DateTime approvalDate = DateTime.now();
        Boolean standardSapTransactions = credit.Action_Package__r.Standard_SAP_Transactions__c;
        String buyerSapCustomerNumber = purchase.ATC_Buyer__r.SAP_Customer_Number__c;
        String sellerSapCustomerNumber = purchase.ATC_Seller__r.SAP_Customer_Number__c;
        Long vehiclePaymentMethodId = (purchase.Vehicle_Payment_Method_Id__c != null) ? Long.valueOf(purchase.Vehicle_Payment_Method_Id__c) : -1;
        Long transportPaymentMethodId = (purchase.Transport_Payment_Method_Id__c != null) ? Long.valueOf(purchase.Transport_Payment_Method_Id__c) : -1;
        ID sellerPromoRT = Utils.getRecordTypeId('Auction_Credit__c', 'Seller Auction Credit - Promotional');
        ID sellerGoodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Seller Auction Credit - Goodwill');
        
        String crfReasonCode;
        
        
        if (credit.Promotional_Credit_Reason__c != null)
        {
            if('Welcome back to OPENLANE'.equalsIgnoreCase(credit.Promotional_Credit_Reason__c) && credit.RecordTypeId == sellerPromoRT){
                crfReasonCode = Utils.getPicklistMapping('Auction_Credit__c', 'Promotional_Credit_Reason__c', 'Welcome back to OPENLANE - Seller');
             }else{
                crfReasonCode = Utils.getPicklistMapping('Auction_Credit__c', 'Promotional_Credit_Reason__c', credit.Promotional_Credit_Reason__c);
            }
            if (crfReasonCode == null)
            {
                throw new AuctionCreditHelperException('Could not find a Mapping for Promotional Credit Reason: ' + credit.Promotional_Credit_Reason__c);
            }
        }
        else
        {
            if('Goodwill - Arbitration Auction Credit'.equalsIgnoreCase(credit.Credit_Reason__c) && credit.RecordTypeId == sellerGoodwillRT){
                crfReasonCode = Utils.getPicklistMapping('Action_Package__c', 'Credit_Reason__c', 'Goodwill - Arbitration Seller Auction Credit');
            }else{
                crfReasonCode = Utils.getPicklistMapping('Action_Package__c', 'Credit_Reason__c', credit.Credit_Reason__c);
            }
            if (crfReasonCode == null)
            {
                throw new AuctionCreditHelperException('Could not find a Mapping for Action Package Credit Reason: ' + credit.Action_Package__r.Credit_Reason__c);
            }
        }
        
        Logger.info(credit, 'vehicleId: ' + vehicleId);
        Logger.info(credit, 'actionPackageId: ' + actionPackageId);
        Logger.info(credit, 'approvalDate: ' + approvalDate);
        Logger.info(credit, 'standardSapTransactions: ' + standardSapTransactions);
        Logger.info(credit, 'buyerSapCustomerNumber: ' + buyerSapCustomerNumber);
        Logger.info(credit, 'sellerSapCustomerNumber: ' + sellerSapCustomerNumber);
        Logger.info(credit, 'vehiclePaymentMethodId: ' + vehiclePaymentMethodId);
        Logger.info(credit, 'transportPaymentMethodId: ' + transportPaymentMethodId);
        Logger.info(credit, 'crfReasonCode: ' + crfReasonCode);
        
        List<Mediator.AdjustmentLineItem> adjustmentLineItems = new List<Mediator.AdjustmentLineItem>();
        Mediator.AdjustmentLineItem ali = new Mediator.AdjustmentLineItem();
        ali.currency_x = credit.CurrencyIsoCode;
        ali.netAmount = credit.Credit_Amount__c * -1.0;
        if(credit.recordTypeId == sellerPromoRT || credit.recordTypeId == sellerGoodwillRT){
           ali.partnerType = 'S';
        }else{
           ali.partnerType = 'B';
        }
        adjustmentLineItems.add(ali);
        
        Logger.info(credit, 'Buyer/Seller adjustmentLineItem netAmount: ' + ali.netAmount);
        Logger.info(credit, 'Buyer/Seller adjustmentLineItem currency: ' + ali.currency_x);
        Logger.info(credit, 'Buyer/Seller adjustmentLineItem partnerType: ' + ali.partnerType);
        
        Logger.info(credit, 'Calling mediator applyAuctionCredit operation');
        Mediator.applyAuctionCreditResponseType response = ms.applyAuctionCredit(
            vehicleId,
            actionPackageId,
            approvalDate,
            crfReasonCode,
            buyerSapCustomerNumber,
            sellerSapCustomerNumber,
            vehiclePaymentMethodId,
            transportPaymentMethodId,
            adjustmentLineItems
        );
        
        response.errorMsg = processResponseMessages(response.returnCode, response.errorMsg, response.msg);
        return new SendResponse(response, credit);
    }
    
    public class SendResponse
    {
        String results {get; set;}
        List<String> messages {get; set;}
        List<Action_Package_Document__c> docs {get; set;}
        public SendResponse(Mediator.applyAuctionCreditResponseType response, Auction_Credit__c credit) 
        {
            // Send_Result__c field
            Logger.info(credit, 'Processing Mediator Response');
            String returnCode = response.returnCode;
            Logger.info(credit, 'returnCode: ' + returnCode);
            if ('ADJUSTMENT_SUCCESS'.equals(returnCode))
            {
                results = 'AUTOMATIC - Transactions created successfully in SAP';
            }
            else if ('SAP_ADJUSTMENT_FAIL'.equals(returnCode))
            {
                results = 'MANUAL - Transactions need to be created manually in SAP';
            }
            else if ('SAP_VOID_SUCCESS_WITHOUT_DOC'.equals(returnCode)) 
            {
            	results = 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
            }
            else 
            {
                throw new AuctionCreditHelperException('Invalid Mediator Return Code: ' + returnCode);
            }
            Logger.info(credit, 'Translated Results: ' + results);
            
            // Response_Messages__c field
            messages = new List<String>();
            if (response.errorMsg != null)
            {
                for (String msg : response.errorMsg)
                {
                    Logger.info(credit, 'errorMsg: ' + msg);
                    messages.add(msg);
                }
            }
            
            // Action_Package_Documents list
            docs = new List<Action_Package_Document__c>();
            Logger.info(credit, 'Processing Returned FI Documents');
			Set<String> ListFLSCreate = new Set<String>();
			Boolean blnFLSOverride = Utils.GetFLS();
            if (response.fiDocument != null) 
            {
                for (Mediator.FIDocument fiDoc : response.fiDocument) 
                {
                    Logger.info(credit, 'FI Document Number: ' + fiDoc.documentNumber);
                    Logger.info(credit, 'Company Code: ' + fiDoc.companyCode);
                    Logger.info(credit, 'Fiscal Year: ' + fiDoc.fiscalYear);
                    Logger.info(credit, 'Reverse Step: ' + fiDoc.revStep);
                    Action_Package_Document__c doc = new Action_Package_Document__c();					
					if (Schema.sObjectType.Action_Package_Document__c.fields.Auction_Credit__c.isCreateable() || blnFLSOverride)
					{
						doc.Auction_Credit__c = credit.Id;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Auction_Credit__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
					{
						doc.RecordTypeId = Utils.getRecordTypeId('Action_Package_Document__c', 'FI Document');
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.RecordTypeId.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Name.isCreateable() || blnFLSOverride)
					{
						doc.Name = fiDoc.documentNumber;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Name.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Company_Code__c.isCreateable() || blnFLSOverride)
					{
						doc.Company_Code__c = fiDoc.companyCode;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Company_Code__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Fiscal_Year__c.isCreateable() || blnFLSOverride)
					{
						doc.Fiscal_Year__c = fiDoc.fiscalYear;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Fiscal_Year__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Reverse_Step__c.isCreateable() || blnFLSOverride)
					{
						doc.Reverse_Step__c = fiDoc.revStep;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Reverse_Step__c.getName());
					}					
                    docs.add(doc);
                }
            }			
		
            Logger.info(credit, 'Processing Returned SD Documents');
            if (response.sdDocument != null) 
            {
                for (Mediator.SDDocument sdDoc : response.sdDocument) 
                {
                    Logger.info(credit, 'SD Document Number: ' + sdDoc.documentNumber);
                    Logger.info(credit, 'Line Number: ' + sdDoc.lineNumber);
                    Logger.info(credit, 'Extra Cost Id' + sdDoc.extraCostId);
                    Logger.info(credit, 'Reverse Step: ' + sdDoc.revStep);
                    Action_Package_Document__c doc = new Action_Package_Document__c();
					
					if (Schema.sObjectType.Action_Package_Document__c.fields.Auction_Credit__c.isCreateable() || blnFLSOverride)
					{
						doc.Auction_Credit__c = credit.Id;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Auction_Credit__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
					{
						doc.RecordTypeId = Utils.getRecordTypeId('Action_Package_Document__c', 'SD Document');
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.RecordTypeId.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Name.isCreateable() || blnFLSOverride)
					{
						doc.Name = sdDoc.documentNumber;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Name.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Line_Number__c.isCreateable() || blnFLSOverride)
					{
						doc.Line_Number__c = sdDoc.lineNumber;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Line_Number__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Extra_Cost_Id__c.isCreateable() || blnFLSOverride)
					{
						doc.Extra_Cost_Id__c = sdDoc.extraCostId;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Extra_Cost_Id__c.getName());
					}
					if (Schema.sObjectType.Action_Package_Document__c.fields.Reverse_Step__c.isCreateable() || blnFLSOverride)
					{
						doc.Reverse_Step__c = sdDoc.revStep;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Action_Package_Document__c.getName()+'.'+Schema.sObjectType.Action_Package_Document__c.fields.Reverse_Step__c.getName());
					}
					
                    docs.add(doc);
                }
				
            }
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:AuctionCreditHelper', ListFLSCreate);
			}
        }
    }
    
    public static void sendCRFNotification(List<Auction_Credit__c> credits)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> attachments = new List<Attachment>();
        for (Auction_Credit__c credit : credits)
        {
            // Determine who the email recipients will be
            List<String> recipients = new List<String>();
            String packageType = 'Auction Credit';
            String country = credit.Purchase__r.Country__c;
            String cgc = String.valueOf(credit.Purchase__r.Car_Group_Config_Id__c);
            String handlesTitle = credit.Purchase__r.Handles_Title__c;
            try               
            {
            	List<Action_Pkg_Distribution_List__c> distLists = ActionPkgDistributionListHelper.getDistributions(country, cgc, packageType, null, handlesTitle);
                for (Action_Pkg_Distribution_List__c distList : distLists)
                {
                	recipients.add(distList.Email__c);
                }
            }
            catch (Exception e)
            { 
            	Logger.error(credit, 'Unable to determine recipients for CRF FORM.');
            }

        
            // Define Notification Email
            String fileName = 'crf_form' + DateTime.now().format('yyyyMMdd_hhmmss')+ '.pdf'; 
            List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
            String subject = '[Auction Credit #' + credit.Name + '] '+credit.Purchase__r.Name +' - '+credit.Purchase__r.ATC_Seller__r.Name +' - '+credit.Purchase__r.ATC_Buyer__r.Name +' - Credit has been applied';
            String body = 'A New Auction Credit Has Been Applied.\n\n' +
                URL.getSalesforceBaseUrl().toExternalForm() + '/'  + credit.Id + '\n\n' + 
                'Auction Credit Number: ' + credit.Name + '\n\n' + 
                'VIN: ' + credit.Purchase__r.Name + '\n\n' +
                'Please see ' + fileName + ' (attached) for additional details. ';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            mail.setUseSignature(false);
            mail.setToAddresses(recipients);
            
            // Generate CRF Form PDF
            PageReference pdf = Page.crf_form;      
            pdf.getParameters().put('id', credit.Id);
            pdf.getParameters().put('src', 'Auction_Credit__c');
            pdf.setRedirect(true);
            Blob b = pdf.getContent();
            Messaging.EmailFileAttachment crfPDF = new Messaging.EmailFileAttachment();
            crfPDF.setFileName(fileName);
            crfPDF.setBody(b);
            emailFileAttachments.add(crfPDF);
            mail.setFileAttachments(emailFileAttachments);
            

            Attachment a = new Attachment();
            a.Name = fileName;
            a.Body = b;
            a.ParentId = credit.Id;
            attachments.add(a);
            
            mails.add(mail);
            
            credit.Accounting_Notified__c = true;
            credit.Accounting_Notified_Date__c = Date.today();
            credit.Notification_Step__c = 'CREDIT_APPLIED';
            if (credit.Auction_Credit_Type__c.equalsIgnoreCase('Buyer Auction Credit') && credit.Purchase__r.ATC_Buyer_Contact__r != null)
            {
                credit.Notification_Recipient__c = credit.Purchase__r.ATC_Buyer_Contact__r.Email;
            }else if(credit.Auction_Credit_Type__c.equalsIgnoreCase('Seller Auction Credit') && credit.Contact__r != null){
                credit.Notification_Recipient__c = credit.Contact__r.Email;
            }
        }
        
        Messaging.sendEmail(mails);
        insert attachments;
        
        update credits;
        
        
    }

    // Currently just prints reponse messages to log.  
    public static List<String> processResponseMessages(List<String> returnMessages) {
        if (returnMessages != null) {
        	return returnMessages;
        }
        else
        {
            return new List<String>();
        }
    }
    

    public static List<String> processResponseMessages(String resultCode, List<String> returnMessages, List<String> extraMessages) {
        List<String> messages = null;
        if (returnMessages == null || 'SAP_VOID_SUCCESS_WITHOUT_DOC'.equals(resultCode)) {
        	messages = extraMessages;
        } else {
        	messages = returnMessages;
        }
        return processResponseMessages(messages);
    }
        
    public class AuctionCreditHelperException extends Exception {}
}