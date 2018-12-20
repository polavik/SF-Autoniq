public class InspectionRequestHelper 
{
    Inspection_Request__c ir;
    Set<String> ListFLSCreate = new Set<String>();
    Boolean blnFLSOverride = Utils.GetFLS();
    
    public InspectionRequestHelper(Inspection_Request__c ir)
    {
        this.ir = ir;
    }
    
    public void psiPassed()
    {
        
        Logger.info(ir, 'Sending Email');
        // Create new Send notification email for each passed PSI
        
        Contact recipt = 
        [
        Select Id
        From Contact
        Where Id = :ir.Purchase__r.ATC_Buyer_Contact__c
        ];
        
        if( ir.Inspection_Type__c.equalsIgnoreCase('PSI') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 7-day Full') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 14-day Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Partial') )
        {
            if (!Sandbox.isSandbox()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Contact recipient = [SELECT id, firstname FROM Contact LIMIT 1];
                //EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'PSI_Passed'];
                ID templateId = '00Xa0000001rCcu';//PSI 7 and 14 day Email
                if(ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Partial'))
                {
                    templateId = '00X13000001rLrl';//Buyer Protection Email
                }         
                EmailTemplate et = [SELECT id FROM EmailTemplate WHERE Id = :templateId];
                mail.setSenderDisplayName('NoReply'); 
                mail.setTargetObjectId(recipt.id); // Specify who the email should be sent to.
                mail.setTemplateId(et.id);
                mail.setWhatId(ir.Id); //What object should be looked at.
                if(!Test.isRunningTest())
                { 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                }
            }
        }
        
        Logger.info(ir, 'psiPassed() called.  Calling future method: callCancelPSI()');
        callCancelPSI(ir.Id);
        Logger.flush();      
    }
    
    public void psiFailed()
    {
        Logger.info(ir, 'psiFailed() called. Inserting Case.');
        Case c = new Case();
        
        //Story B-44003 : FLS CREATE ACCESS CHECK
        ListFLSCreate = new Set<String>();
        blnFLSOverride = Utils.GetFLS();
        if (Schema.sObjectType.Case.fields.Description.isCreateable() || blnFLSOverride)
        {
            c.Description = 'PSI FAILED: ' + ir.PSI_Review_Comments__c;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Description.getName());
        }
        if (Schema.sObjectType.Case.fields.Reason.isCreateable() || blnFLSOverride)
        {
            c.Reason = 'Undisclosed Damage';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Reason.getName());
        }
        if (Schema.sObjectType.Case.fields.Type.isCreateable() || blnFLSOverride)
        {
            c.Type = 'Arbitration';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Type.getName());
        }
        if (Schema.sObjectType.Case.fields.Inspection_Request__c.isCreateable() || blnFLSOverride)
        {
            c.Inspection_Request__c = ir.Id;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Inspection_Request__c.getName());
        }
        if (Schema.sObjectType.Case.fields.OwnerId.isCreateable() || blnFLSOverride)
        {
            c.OwnerId = UserInfo.getUserId();
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.OwnerId.getName());
        }
        if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
        {
            c.RecordTypeId = Utils.getRecordTypeId('Case', 'Arbitration - Open');
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
        }
        if (Schema.sObjectType.Case.fields.VIN__c.isCreateable() || blnFLSOverride)
        {
            c.VIN__c = ir.Purchase__c;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.VIN__c.getName());
        }
        
        
        try{
            if(ListFLSCreate.size()>0)
            {
                Utils.SendEmailforFLS('FLS_CREATE','CLASS:InspectionRequestHelper', ListFLSCreate);
            }
            else
            {
               insert c;                
            }
        }catch(System.DmlException e){
             for (Integer i = 0; i < e.getNumDml(); i++) {
                if(e.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                   //ir.addError(e.getDmlMessage(i));
                   c.addError(e.getDmlMessage(i));  /* ss */
                }
             }
        }
        Logger.flush();        
    }
    
    public void psiCanceled()
    {
        Logger.info(ir, 'psiCanceled() called.  Calling future method: callRestoreVehicleFromPSI()');
        callRestoreVehicleFromPSI(ir.Id);
//-----------------------------
        Logger.info(ir, 'psiCanceled() called. Inserting Case.');
        Case c = new Case();
        ListFLSCreate = new Set<String>();
        blnFLSOverride = Utils.GetFLS();
        if (Schema.sObjectType.Case.fields.Type.isCreateable() || blnFLSOverride)
        {
            c.Type = 'Payment Inquiry';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Type.getName());
        }   
        
        //Case Reason = Cancel PSI or Cancel PDI based on Inspection Type on Inspection Request
        if (Schema.sObjectType.Case.fields.Reason.isCreateable() || blnFLSOverride)
        {
            if('PSI by Processing Auction 7-day Full'.equalsIgnoreCase(ir.Inspection_Type__c)  || 'PSI by Processing Auction 14-day Full'.equalsIgnoreCase(ir.Inspection_Type__c)  || 'Buyer Protection Plan-Full'.equalsIgnoreCase(ir.Inspection_Type__c) || 'Buyer Protection Plan-Partial'.equalsIgnoreCase(ir.Inspection_Type__c) || 'PSI'.equalsIgnoreCase(ir.Inspection_Type__c))  
            {
                c.Reason = 'Cancel PSI';            
            }
            else
            {
                c.Reason = 'Cancel PDI';            
            }           
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Reason.getName());
        }
        string strCreditReason = c.Reason;  
        
        if (Schema.sObjectType.Case.fields.Description.isCreateable() || blnFLSOverride)
        {           
            c.Description = 'Refund request for canceled PSI/PDI ';        
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Description.getName());
        }
        if (Schema.sObjectType.Case.fields.Inspection_Request__c.isCreateable() || blnFLSOverride)
        {           
            c.Inspection_Request__c = ir.Id;        
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Inspection_Request__c.getName());
        }
        if (Schema.sObjectType.Case.fields.OwnerId.isCreateable() || blnFLSOverride)
        {           
            c.OwnerId = ir.LoggedUser__c;   //ir.Ownerid;  '00G60000000w6Fq';      // UserInfo.getUserId();  Prod = '00G60000001YiqG' 
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.OwnerId.getName());
        }       
        if (Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() || blnFLSOverride)
        {           
            c.RecordTypeId = Utils.getRecordTypeId('Case', 'Payment Inquiry - Open');
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.RecordTypeId.getName());
        }
        if (Schema.sObjectType.Case.fields.Assigned_To__c.isCreateable() || blnFLSOverride)
        {           
            c.Assigned_To__c = 'Customer Srvc/Dealer Services';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Assigned_To__c.getName());
        }
        if (Schema.sObjectType.Case.fields.Claim_Resolution__c.isCreateable() || blnFLSOverride)
        {           
            c.Claim_Resolution__c = 'Credit';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Claim_Resolution__c.getName());
        }
        if (Schema.sObjectType.Case.fields.Claim_Resolution_Comments__c.isCreateable() || blnFLSOverride)
        {           
            c.Claim_Resolution_Comments__c= 'Refund request for canceled PSI/PDI';
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.Claim_Resolution_Comments__c.getName());
        }
        if (Schema.sObjectType.Case.fields.VIN__c.isCreateable() || blnFLSOverride)
        {           
            c.VIN__c = ir.Purchase__c;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.VIN__c.getName());
        }
        if (Schema.sObjectType.Case.fields.ContactId.isCreateable() || blnFLSOverride)
        {           
            c.ContactId = ir.Purchase__r.ATC_Buyer_Contact__c;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.ContactId.getName());
        }
        if (Schema.sObjectType.Case.fields.AccountId.isCreateable() || blnFLSOverride)
        {           
            c.AccountId = ir.Purchase__r.ATC_Buyer__c;
        }
        else
        {                       
            ListFLSCreate.add(Schema.sObjectType.Case.getName()+'.'+Schema.sObjectType.Case.fields.AccountId.getName());
        }
        //  Purchase__r.ATC_Seller__c,        
        
        try
        {
            if(ListFLSCreate.size()>0)
            {
                Utils.SendEmailforFLS('FLS_CREATE','CLASS:InspectionRequestHelper', ListFLSCreate);
            }
            else
            {
                insert c;
            }
        }catch(System.DmlException e){
             for (Integer i = 0; i < e.getNumDml(); i++) {
                if(e.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                   //ir.addError(e.getDmlMessage(i));
                   c.addError(e.getDmlMessage(i));  /* ss */
                }
             }
        }
         Logger.info(c, 'Case number '+ c.Id);
        //Logger.flush();
  
        if(c.Id != null)
        {
            Action_Package__c ap = new Action_Package__c();
            ListFLSCreate = new Set<String>();
            blnFLSOverride = Utils.GetFLS();
            if (Schema.sObjectType.Action_Package__c.fields.Case__c.isCreateable() || blnFLSOverride)
            {
                ap.Case__c = c.Id; //99000000l; //c.CaseNumber;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Case__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Credit_To__c.isCreateable() || blnFLSOverride)
            {
                ap.Credit_To__c ='Buyer';
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Credit_To__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Credit_Amount__c.isCreateable() || blnFLSOverride)
            {
                ap.Credit_Amount__c=ir.Purchase__r.Inspection_Fee__c;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Credit_Amount__c.getName());
            }           
            
            if('PSI by Processing Auction 7-day Full'.equalsIgnoreCase(ir.Inspection_Type__c)  || 'PSI by Processing Auction 14-day Full'.equalsIgnoreCase(ir.Inspection_Type__c)  || 'Buyer Protection Plan-Full'.equalsIgnoreCase(ir.Inspection_Type__c) || 'Buyer Protection Plan-Partial'.equalsIgnoreCase(ir.Inspection_Type__c) || 'PSI'.equalsIgnoreCase(ir.Inspection_Type__c))  
            {
                if (Schema.sObjectType.Action_Package__c.fields.Seller_Amount__c.isCreateable() || blnFLSOverride)
                {
                    ap.Seller_Amount__c=ir.Purchase__r.Inspection_Fee__c;                   
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Seller_Amount__c.getName());
                }
                
            }
            else
            {
                if (Schema.sObjectType.Action_Package__c.fields.House_Amount__c.isCreateable() || blnFLSOverride)
                {                   
                    ap.House_Amount__c = ir.Purchase__r.Inspection_Fee__c;            
                }
                else
                {                       
                    ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.House_Amount__c.getName());
                }
            }
            
            if (Schema.sObjectType.Action_Package__c.fields.Credit_Reason__c.isCreateable() || blnFLSOverride)
            {               
                ap.Credit_Reason__c = strCreditReason ; // 'Canceled PSI'; // (New credit reason
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Credit_Reason__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Issuing_Department__c.isCreateable() || blnFLSOverride)
            {               
                ap.Issuing_Department__c = 'Customer Service - Canada';
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Issuing_Department__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Tax__c.isCreateable() || blnFLSOverride)
            {               
                ap.Tax__c = 'Standard';
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Tax__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
            {               
                ap.RecordTypeId= Utils.getRecordTypeId('Action_Package__c', 'CRF - Adjustment');  
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.RecordTypeId.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Package_Type__c.isCreateable() || blnFLSOverride)
            {               
                ap.Package_Type__c='Adjustment';
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Package_Type__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.OwnerId.isCreateable() || blnFLSOverride)
            {               
                ap.OwnerId = ir.LoggedUser__c;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.OwnerId.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Require_Approval__c.isCreateable() || blnFLSOverride)
            {               
                ap.Require_Approval__c=false;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Require_Approval__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Auto_Approve_Override__c.isCreateable() || blnFLSOverride)
            {               
                ap.Auto_Approve_Override__c = true;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Auto_Approve_Override__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Directions_for_Accounting__c.isCreateable() || blnFLSOverride)
            {               
                ap.Directions_for_Accounting__c=c.Claim_Resolution_Comments__c;
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Directions_for_Accounting__c.getName());
            }
            if (Schema.sObjectType.Action_Package__c.fields.Tax__c.isCreateable() || blnFLSOverride)
            {               
                ap.Tax__c='Standard';
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Tax__c.getName());
            }
            
            //ap.Country__c=ir.Purchase__r.Country__c;
            if (Schema.sObjectType.Action_Package__c.fields.Issuing_Department__c.isCreateable() || blnFLSOverride)
            {               
                if('United States'.equalsIgnoreCase(ir.Purchase__r.Country__c))  
                {
                    ap.Issuing_Department__c='Customer Service - US';                   
                }
                else
                {
                    ap.Issuing_Department__c='Customer Service - Canada';                   
                }
            }
            else
            {                       
                ListFLSCreate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Issuing_Department__c.getName());
            }           
                
           System.debug('Inserting AP');
             
            try{
              
                if(ListFLSCreate.size()>0)
                {
                    Utils.SendEmailforFLS('FLS_CREATE','CLASS:InspectionRequestHelper', ListFLSCreate);
                }
                else
                {
                   insert ap;
                }
               
            }catch(System.DmlException e){
                 for (Integer i = 0; i < e.getNumDml(); i++) {
                    if(e.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                      Logger.error(c, e.getDmlMessage(i) );
                      System.debug(e.getDmlMessage(i));
                    }
                 }
                 
                
            }
            
            System.debug('AP Inserted.  ap.Id = ' + ap.Id);
            
            if(ap.Id != null)
            {
                Approval.ProcessSubmitRequest req1 =
                new Approval.ProcessSubmitRequest();
                req1.setComments('Auto Approved');
                req1.setObjectId(ap.id);
                
                Approval.ProcessResult result = Approval.process(req1);
                            
                if(result.isSuccess())
                {
                    ap.Approved__c = true;
                    //ap.Send_Results__c = 'AUTOMATIC - NO SAP accounting entries required.';   
                    update ap;        
                }
                
                //AutoDispatcherActionPkgDetails.processPDF(ap.Id); //This starts the CRF process normally started by viewing the AP page
                    /*
                    Action_Package__c pkg;
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
                    FROM Action_Package__c WHERE Id = :ap.Id];
                    
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
                   
                    //For now we just want to send the email without a CRF until 12a 2014
                    
                    
                    List<String> sendAddresses = new List<String>();
                    
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
                        sendAddresses.add(distList.Email__c);
                    }
                    
                    // Define Notification Email 
                    String subject = '[' + pkg.Package_Type__c + ' #' + pkg.Name + '] '+pkg.VIN__c+' - '+pkg.Seller__c+' - '+pkg.Account_Name__c+' - Package is Approved';
                    String body = 'A New Action Package Has Been Approved.\n\n' +
                        'https://na4.salesforce.com/' + pkg.Id + '\n\n' + 
                        'Action Package Number: ' + pkg.Name + '\n\n' + 
                        'VIN: ' + pkg.VIN__c + '\n\n' +
                        'Owner: ' + pkg.Owner.Name + '\n\n' +
                        'Case Number: ' + pkg.Case__r.CaseNumber + '\n\n' + 
                        'Case Type: ' + pkg.Case__r.Type + '\n\n' +
                        'Type of Action Package: ' + pkg.Package_Type__c + '\n\n' +
                        'No Attched CRF currently for auto-approved Action Packages. ';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject(subject);
                    mail.setPlainTextBody(body);
                    mail.setUseSignature(false);
                    
                    // Send PDF Only to noAttachmentsAddresses group
                    mail.setToAddresses(sendAddresses);
                    Messaging.sendEmail(new Messaging.Email[] { mail });
                    
                    ap.Emailed_To__c = Utils.joinList(sendAddresses, '; ');
                    ap.Accounting_Notified__c = true;
                    ap.Accounting_Notified_Date__c = Date.today();
            
                }           
                else
                {
                    String validationMessages = null;
                    for (Database.Error err : result.getErrors()) 
                    {
                        String validationErrors = err.getMessage().substring(21, err.getMessage().length());
                        for (String validationErr : validationErrors.split('\n')) 
                        {
                            validationMessages += ('\n' + validationErr);
                        }
                    }
                    ap.Send_Results__c = validationMessages;
                }
            update ap;
            */    
            }
        

        }
//---------------------------------------------        
    }
    
    @future(callout=true)
    public static void callRestoreVehicleFromPSI(ID inspectionRequestId)
    {
        Inspection_Request__c ir = [SELECT Purchase__r.Vehicle_ID__c, V1_Update_Results__c  FROM Inspection_Request__c WHERE Id = :inspectionRequestId];
        Logger.info(ir, 'callRestoreVehicleFromPSI() called.');
        
        Long vehicleId;
        String results;     
        
        try
        {
            Logger.info(ir, 'Determining vehicle id...');
            vehicleId = Long.valueOf(ir.Purchase__r.Vehicle_ID__c);
        }
        catch(Exception e)
        {
            results = 'ERROR. Could not determine Vehicle ID. ' + e.getMessage();
            Logger.error(ir, results);
        }
        
        if (vehicleId != null)
        {
            try
            {
                Logger.info(ir, 'Calling Mediator: restoreVehicleFromPSI('+vehicleId+')');
                Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
                Mediator.restoreVehicleFromPSIResponseType response = ms.restoreVehicleFromPSI(vehicleId, 1);
                results = response.returnCode;
                if (response.errorMsg != null && response.errorMsg.size() > 0)
                {
                    results = results + ': ' + Utils.joinList( response.errorMsg, ';');
                    ir.V1_Update_Results__c = 'Failed to restore to workflow. ' + results;
                }else{
                    ir.V1_Update_Results__c = 'Restored to workflow';
                }
                Logger.info(ir, 'RESPONSE: ' + results);
            }
            catch(Exception e)
            {
                results = 'ERROR. Could not call mediator service: ' + e.getMessage();
                ir.V1_Update_Results__c = 'Failed to restore to workflow';
                Logger.error(ir, results);
            }
            try{
               update ir;
            }catch(Exception e){
               Logger.error( ir, 'Unable to update ' + e);
            }   
        }
        Logger.flush();
    }
    
    @future(callout=true)
    public static void callCancelPSI(ID inspectionRequestId)
    {
        Inspection_Request__c ir = [SELECT Purchase__r.Vehicle_ID__c FROM Inspection_Request__c WHERE Id = :inspectionRequestId];
        Logger.info(ir, 'callCancelPSI() called.');
        
        Long vehicleId;
        String results;     
        
        try
        {
            Logger.info(ir, 'Determining vehicle id...');
            vehicleId = Long.valueOf(ir.Purchase__r.Vehicle_ID__c);
        }
        catch(Exception e)
        {
            results = 'ERROR. Could not determine Vehicle ID. ' + e.getMessage();
            Logger.error(ir, results);
        }
        
        if (vehicleId != null)
        {
            try
            {
                Logger.info(ir, 'Calling Mediator: cancelPsi('+vehicleId+')');
                Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
                Mediator.cancelPsiResponseType response = ms.cancelPsi(vehicleId);
                results = response.returnCode;
                if (response.errorMsg != null && response.errorMsg.size() > 0)
                {
                    results = results + ': ' + Utils.joinList( response.errorMsg, ';');
                    ir.V1_Update_Results__c = 'Failed to restore to workflow. ' + results;
                }else{
                    ir.V1_Update_Results__c = 'Restored to workflow';
                }
                Logger.info(ir, 'RESPONSE: ' + results);
            }
            catch(Exception e)
            {
                results = 'ERROR. Could not call mediator service: ' + e.getMessage();
                Logger.error(ir, results);
                ir.V1_Update_Results__c = 'Failed to restore to workflow';
            }
            try{
               update ir;
            }catch(Exception e){
               Logger.error( ir, 'Unable to update ' + e);
            }
        }
        Logger.flush();
    }
    
    public static Long isTransportCancelled(Action_Package__c pkg) 
    {
        return (pkg.Void_House_Transport__c && (pkg.Case__r.VIN__r.Actual_Pickup__c == null)) ? 1 : 0;
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
}