trigger CaseBeforeInsertUpdate on Case (before insert, before update) 
{
    
    // Get a list of Cases where Purchase or Vehicle is not null
    List<ID> purchaseIds = new List<ID>();
    List<ID> vehicleIds = new List<ID>();
    List<Case> cases = new List<Case>();
    String StewardshipRecordTypeId = Utils.getRecordTypeId('Case', 'Stewardship'); //01213000001RY0qAAG
    Map<String, Case> StewardshipSubtoCasesMap = new Map<String, Case>();
    Set<String> ListStuCaseSubjectDesc = new Set<String>();
    for (Case c : Trigger.new) 
    {
        if( Trigger.isInsert)
        {
            if(c.RecordTypeid == StewardshipRecordTypeId && c.subject.containsIgnoreCase('Error'))
            {
                if(ListStuCaseSubjectDesc.add(c.subject+c.description))
                {
                    StewardshipSubtoCasesMap.put(c.subject,c);
                }
                else
                {
                     System.debug('Duplicate Stewardship case found in same context, subject :' +c.subject+ ' Description:' +c.description); 
                     c.subject.addError('Duplicate Case Found for case subject : '+c.subject);                       
                }
            }
        }
    // djpatel (10-Nov-14): Added condition for Case Migration Process
        if(!c.Is_Migrated_Openlane_Case__c)
        {
            if (c.VIN__c != null) 
            {
                purchaseIds.add(c.VIN__c);
                cases.add(c);
            }
            else if (c.Asset__C != null)
            {
                vehicleIds.add(c.Asset__C);
                cases.add(c);
            }
        }
    }
   
   if(StewardshipSubtoCasesMap.size()>0)
    {
        System.debug('StewardshipSubtoCasesMap.size():' +StewardshipSubtoCasesMap.size());      
        
        List<String> ListSubjects = new List<String>();
        
        for (String strSub : StewardshipSubtoCasesMap.keySet()) 
        {
            if(strSub!=null && strSub!='')
            {
                ListSubjects.Add(strSub.trim());
                System.debug('strSub.trim():' +strSub.trim());
            }
        }
        if(ListSubjects.size()>0)
        {
            // Check If duplicate Case Exist - Subject + Description
            List<Case> ListAllStuMatchCases = [SELECT Id,SUBJECT, DESCRIPTION FROM CASE WHERE RecordTypeId=:StewardshipRecordTypeId and CreatedDate=TODAY and SUBJECT IN : ListSubjects];//and Status='Open' and SUBJECT IN : ListSubjects ];
            
            Set<String> ListStuCaseSubjects = new Set<String>();
            Map<String, Case> AllStewardshipSubtoCasesMap = new Map<String, Case>();
            for (Case c : ListAllStuMatchCases) 
            {
                ListStuCaseSubjects.add(c.subject);     
                AllStewardshipSubtoCasesMap.put(c.subject,c);
            }
            
            List<Case> ListMatchCases = new List<Case>();
            
            for (String strSubject : ListSubjects) 
            {
                if(ListStuCaseSubjects.add(strSubject)==false)
                {
                    if(AllStewardshipSubtoCasesMap.get(strSubject)!=null)
                    {
                        ListMatchCases.add(AllStewardshipSubtoCasesMap.get(strSubject));
                    }
                }
            }
            
            System.debug('ListMatchCases.size():'+ListMatchCases.size());
            for (Case c : ListMatchCases) 
            {
                Case stewardshipCase = StewardshipSubtoCasesMap.get(c.subject);
                System.debug('Checking Description duplicate for c.subject:' +c.subject);
                
                if(stewardshipCase!=null && stewardshipCase.description.equalsIgnoreCase(c.description))
                {
                    stewardshipCase.subject.addError('Duplicate Case Found for case : '+c.subject);     
                    System.debug('Duplicate Case Found for case:' +c.subject);
                    StewardshipSubtoCasesMap.remove(c.subject);
                }
            }
            
        }
                 
    }
            
            
            
            
    // Retrieve Vehicle data for all Cases
    Map<ID, Asset__C> vehicleMap = new Map<ID, Asset__C>(
        [
            SELECT
                Id,
                Seller_Account__c
            FROM Asset__C
            WHERE Id IN :vehicleIds
        ]
    );
  
    
    // Retrieve Purchase data for all Cases
    Map<ID, Purchase__c> purchaseMap = new Map<ID, Purchase__c>(
        [
            SELECT 
                Id, 
                Asset__c,
                Actual_Dropoff__c, 
                ATC_Buyer__c, 
                ATC_Buyer_Contact__c, 
                ATC_Seller__c, 
                ATC_Sale_Date__c, 
                ATC_Transporter__c, 
                Transporter__r.ATC_Organization_ID__c, 
                Handles_Payment__c, 
                Payment_Received__c, 
                Private_Label__c,
                sale_class__c, 
                Transport_Preference__c,
                Adesa_com__r.ATC_Organization_ID__c,
                (
                    SELECT Id, 
                        CaseNumber, 
                        ContactId, Type, 
                        Reason 
                    FROM Cases__r
                ),
                (
                    SELECT Id, Inspection_Type__c,
                        PSI_Passed__c, Request_Status__c, Request_Type__c
                    FROM Inspection_Requests__r
                    ORDER BY Order_Request_Date__c DESC
                )
            FROM Purchase__c 
            WHERE Id in :purchaseIds
         ]
    );
    
    // Attach Purchase and Vehicle data to Cases
    for (Case c : cases) 
    {
        c.VIN__r = purchaseMap.get(c.VIN__c);
        c.Asset__c = c.VIN__r.Asset__c;
        if (c.Asset__c == null) {
           c.Asset__r = vehicleMap.get(c.Asset__c);
        }
    }
    
    // BEFORE INSERT
    
    if (Trigger.isInsert)
    {       
        
        // Set Buyer, Seller, Transporter, and Inspection Request on Case
        for (Case c : cases)
        {
            
            Purchase__c purchase = c.VIN__r;
            Asset__c veh = c.Asset__r;
            
            if (purchase != null)
            {
                ID newAccountId = null;
                ID newContactId = null;
                
                // In Seller Inquiries, the Account comes from the Purchase Seller.  Contact cannot be resolved.
                if (c.Type.equalsIgnoreCase('Seller Inquiry')) 
                {
                    newAccountId = purchase.ATC_Seller__c;
                } 
                else 
                { // In all other Case Types, the Account and Contact come from the Purchase Buyer
                    newAccountId = purchase.ATC_Buyer__c;
                    newContactId = purchase.ATC_Buyer_Contact__c;
                }
                
                // Only set the Account and Buyer if they are null - prevents overwriting values obtained from cust. portal
                if (c.AccountId == null) 
                {
                    c.AccountId = newAccountId;
                } 
                
                if (c.ContactId == null) 
                {
                    c.ContactId = newContactId;
                }
                
                c.Seller__c = purchase.ATC_Seller__c;
                c.Transporter__c = purchase.ATC_Transporter__c;
                if (purchase.Inspection_Requests__r != null && purchase.Inspection_Requests__r.size() > 0)
                {
                    c.Inspection_Request__c = purchase.Inspection_Requests__r.get(0).Id;
                     if(c.type.equals('Arbitration') && ( c.status.equals('Open') || c.status.equals('New')) ){
                       for(Inspection_Request__c ir: purchase.Inspection_Requests__r){
                           if(ir.Inspection_Type__c != null  && (ir.Inspection_Type__c.equalsIgnoreCase('PDI') || ir.Inspection_Type__c.equalsIgnoreCase('PSI') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 7-day Full') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 14-day Full')|| ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Partial')) &&
                              ir.Request_Type__c != null  && ir.Request_Type__c.equalsIgnoreCase('New') &&
                              ir.Request_Status__c != null && ir.Request_Status__c.equalsIgnoreCase('SUCCESS') &&
                              ir.PSI_Passed__c == null){
                              //c.addError('There is currently an outstanding PSI. Please cancel the PSI prior to creating an Arbitration Case');
                              c.addError('There is an inspection pending on the vehicle, as a result an Arbitration case cannot be opened until the inspection has been completed or cancelled. For further assistance please call Customer Connection @ 888-526-7326');
                              break;
                           }   
                       }
                     }
                }
            }
            else if (c.Asset__C != null)
            {
                c.Seller__c = veh.Seller_Account__c;
            }
        }
        
        
        // Check for Cases with duplicate contact/type/reason, and run Arbs Validation.  
        for (Case c : Trigger.new) 
        {
    // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!c.Is_Migrated_Openlane_Case__c)
            {
                boolean duplicate = false;
                
                Purchase__c purchase = c.VIN__r;
                if (purchase != null) {
                    for (Case c2 : purchase.Cases__r) {
                        if (c.contactId != null && c2.contactId != null && c.Type != null && c2.Type != null && c.Reason != null && c2.Reason != null) {
                            if (c.contactId == c2.contactId && c.Type.equals(c2.Type) && c.Reason.equals(c2.Reason)) {
                                c.addError('A case with this Case Reason has already been created for this VIN.  Please see Case #' + c2.CaseNumber);
                                duplicate = true;
                            }
                        }
                    }
                }
                
                if ('Arbitration'.equals(c.Type) && !duplicate) 
                {
                    ArbsValidator.ValidationResults results = ArbsValidator.validate(c);
                    List<String> errorMessages = new List<String>();
                    
                    if (results.paymentError) 
                    {
                        errorMessages.add('The vehicle has not been paid for.');
                    }
                    if (results.groundingDealerError) 
                    {
                        errorMessages.add('As the grounding dealer, you can only arbitrate for title problems.');
                    }
                    if (results.salesDateError) 
                    {
                        errorMessages.add('Too much time has passed since the sale date.');
                    }
                    if (results.deliveryDateError) 
                    {
                        errorMessages.add('Too much time has passed since the vehicle was delivered.');
                    }
                    
                    if (errorMessages.size() > 0) 
                    {
                        c.Validation_Outcome__c = 'Invalid';
                        c.Validation_Outcome_Reason__c = Utils.joinList(errorMessages, '\n'); 
                        if (!c.Validation_Outcome_Override__c) 
                        {
                            c.addError('ARB_VALIDATION_ERROR:' + c.Validation_Outcome_Reason__c);
                        }
                    } 
                    else if (results.undecided) 
                    {
                        c.Validation_Outcome__c = 'Undecided';
                    } 
                    else 
                    {
                        c.Validation_Outcome__c = 'Valid';
                    }
                }
            }
        }
    }
    
    // BEFORE UPDATE
    
    if (Trigger.isUpdate)
    {
        for (Case newCase : Trigger.new)
        {
    // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!newCase.Is_Migrated_Openlane_Case__c)
            {
                Case oldCase = Trigger.oldMap.get(newCase.Id);
                Purchase__c purchase = newCase.VIN__r;
                newCase.Previous_Status__c = oldCase.Status;
                if (newCase.archived__c != 'Yes' && newCase.Previous_Status__c != newCase.Status)
                {
                    newCase.Status_Changed__c = true;
                }
                if(newCase.Seller__C == null && purchase != null && purchase.ATC_Seller__c != null){
                    newCase.Seller__c = purchase.ATC_Seller__c;
                }
            }
        }
    }
    
    // BEFORE INSERT OR UPDATE
    
    // Check for cases that need to be auto-escalated.  If so, change record type & Escalated_to_Seller__c
    for (Case c : cases)
    {
        if ('ARBITRATION'.equalsIgnoreCase(c.Type) && !c.Escalated_To_Seller__c)
        {
            Seller_Portal_Config__c spc = SellerPortalConfigHelper.getSellerPortalConfig(c.Seller__c, c.VIN__r.Private_Label__c);
            if (spc != null && 'CASE CREATED'.equalsIgnoreCase(spc.Escalate_On__c))
            {
                c.RecordTypeId = Utils.getRecordTypeId('Case', 'Arbitration - Open');
                c.Escalated_to_Seller__c = true;
                c.Status = 'Escalated to Seller';
                if (spc.Internal_Owner__c != null)
                {
                    c.OwnerId = spc.Internal_Owner__c;
                }
            }
        }
         Purchase__c purchase = c.VIN__r;

         if(purchase != null && c.type.equals('Arbitration') && ( c.status.equals('Open') || c.status.equals('New'))){
           for(Inspection_Request__c ir: purchase.Inspection_Requests__r){
               if(ir.Inspection_Type__c != null  && (ir.Inspection_Type__c.equalsIgnoreCase('PDI') || ir.Inspection_Type__c.equalsIgnoreCase('PSI') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 7-day Full') || ir.Inspection_Type__c.equalsIgnoreCase('PSI by Processing Auction 14-day Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Full') || ir.Inspection_Type__c.equalsIgnoreCase('Buyer Protection Plan-Partial')) &&
                  ir.Request_Type__c != null && ir.Request_Type__c.equalsIgnoreCase('New') &&
                  ir.Request_Status__c != null && ir.Request_Status__c.equalsIgnoreCase('SUCCESS') &&
                  ir.PSI_Passed__c == null){
                  //c.addError('There is currently an outstanding PSI. Please cancel the PSI prior to creating an Arbitration Case');
                  c.addError('There is an inspection pending on the vehicle, as a result an Arbitration case cannot be opened until the inspection has been completed or cancelled. For further assistance please call Customer Connection @ 888-526-7326');
                  break;
               }   
           }
        }
        // Avoid dup ARB open case
        Boolean closed_case = false;
        Boolean arb_case = false;
                       
        if ( c.Status == 'Closed'  || c.Status == 'Claim Closed' || c.Status == 'Complete' || c.Status == 'Inquring Closed' ){
            closed_case = true;
        }

        if ( 'ARBITRATION'.equalsIgnoreCase(c.Type) || 'Arbitration Claim'.equalsIgnoreCase(c.Type)|| 'Arbitration Inquiry'.equalsIgnoreCase(c.Type))
        {
            arb_case = true;
        }
       
        if ( arb_case  && !closed_case  )
        {
            List<Case> caselist1 = [ SELECT  Id, Type, Status, VIN__c FROM Case  
                                     WHERE  Type in ('Arbitration', 'Arbitration Claim', 'Arbitration Inquiry')and 
                                     ( Status != 'Closed' and Status != 'Claim Closed' and Status !='Complete' and Status != 'Inquring Closed') and
                                      vin__c = :c.VIN__c ];

            if (caselist1.size() > 0) 
            {
                if (Trigger.isInsert)  // Can not insert new Case if an existing is still Not closed
                {
                    c.addError('There is currently an open arbitration case on this vehicle and therefore another  cannot be created at this time.  Please contact the Arbitration Team, if you have further questions.');
                }
                else  // Update - can not re-open if an existing is still open
                {
                    if (caselist1.size() > 1)  {
                      for (Case cl : caselist1)
                      {
                         if (!closed_case) {
                           c.addError('There is currently an open arbitration case on this vehicle and therefore another  cannot be created at this time.  Please contact the Arbitration Team, if you have further questions.');
                         } 
                      
                      }

                    }                
                }
            }
        }

    }
}