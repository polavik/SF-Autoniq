trigger ActionPackageBeforeInsertUpdate on Action_Package__c (before insert, before update) {
    
    List<ID> caseIds = new List<ID>();
    List<ID> purchaseIds = new List<ID>();
    List<Action_Package__c> validationList = new List<Action_Package__c>();
    List<Action_Package__c> setVoidTypeList = new List<Action_Package__c>();
    
    for (Action_Package__c pkg : Trigger.new) {
        
        // Need to set (or re-set) void type (vehicle, transport, or both) on all Action Packages that have yet to
        //  be approved or deactivated every time they are updated, because vehicle status could change over time.
        if ('Rejected'.equals(pkg.Status__c) || 'Open'.equals(pkg.Status__c) || 'Pending...'.equals(pkg.Status__c)) {
            system.debug('Inside the status line 13');
            setVoidTypeList.add(pkg);
            //pkg.Arbitration_Fee__c = String.valueOf(pkg.Arbitration_Fees__c);
            
            
        }
        
        // Only run validation on Happy Path states.  This will allow invalid cases to be moved to 
        // Deactivated, Rejected, and Recalled statues.  
        if ('Open'.equals(pkg.Status__c) || 'Pending...'.equals(pkg.Status__c)) {
            validationList.add(pkg);
            //pkg.Arbitration_Fee__c = String.valueOf(pkg.Arbitration_Fees__c);
            system.debug('Inside at line 25');
        }
        
        caseIds.add(pkg.Case__c);
        system.debug('Inside at line 29');
    }
    
    Map<ID, Case> cases = new Map<ID, Case>(
        [SELECT 
           AccountId,
           ContactId,
           CurrencyIsoCode,
           Claim_Resolution__c,
           Resolution_Subtype__c,
           Seller__r.Organization_type__c,
           Type,
           VIN__c,
           VIN__r.Actual_Pickup__c,
           VIN__r.ATC_Sale_Date__c,
           VIN__r.ATC_Transporter__c,
           VIN__r.Country__c,
           VIN__r.PS_Hold_Package__c,
           VIN__r.Transport_Incentive__c,
           VIN__r.Transport_Type__c,
           VIN__r.Transport_Void_Package__c,
           VIN__r.Vehicle_Void_Package__c,
           VIN__r.Segment_Name__c,
           VIN__r.Is_Dealer_Block__c,
           VIN__r.Payment_Method__c,
           VIN__r.Buyer_Org_Name__c 
         FROM Case
         WHERE Id IN :caseIds
        ]
    );
    
    for(Case c: cases.values()){
       purchaseIds.add(c.vin__c);
       system.debug('Inside at line 61');
    }
    
    Map<ID, Purchase__c> purchaseMap = new Map<ID, Purchase__c>(
        [
            SELECT 
                Id,
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
    
    // Set CurrencyCode to be based of the vehicle's country of sale
    for (Action_Package__c pkg : Trigger.new) {
        pkg.Case__r = cases.get(pkg.Case__c);
        if (pkg.Case__r != null) {
            if ('CANADA'.equalsIgnoreCase(pkg.Case__r.VIN__r.Country__c)) {
                pkg.CurrencyIsoCode = 'CAD';
            } else {
                pkg.CurrencyIsoCode = 'USD';
            }
        }
    }
    system.debug('Inside at line 90');
    // Set House_Amount__c for Transport Adjustments and Auction Credit package type
    for (Action_Package__c pkg : Trigger.new)
    {
        if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) || 'AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c) ||
            'SELLER AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            Double creditAmount = pkg.Credit_Amount__c == null ? 0 : pkg.Credit_Amount__c;
            Double numberOfCredits = pkg.Number_Of_Credits__c == null ? 0 : pkg.Number_Of_Credits__c;
            pkg.House_Amount__c = creditAmount * numberOfCredits;
        }
    }
    system.debug('Inside at line 102');
    for (Action_Package__c pkg : setVoidTypeList) {
        
        pkg.Case__r = cases.get(pkg.Case__c);
        if (pkg.Case__r != null) {
            // For Transport Void packages, we require transport to be voided, and throw an error later if
            //  it causes a conflict with any validation rules.  
            if ('Transport Void'.equals(pkg.Package_Type__c)) {
                pkg.Void_Vehicle__c = false;
                pkg.Void_House_Transport__c = true;     
            } else if (
                'Auction Void'.equals(pkg.Package_Type__c) ||
                'Auction Void - Rec'.equals(pkg.Package_Type__c) ||
                'Auction Void - SWAP'.equals(pkg.Package_Type__c) ||
                'House Void - 3rd Party'.equals(pkg.Package_Type__c) ||
                'House Void - 3rd Party Rec'.equals(pkg.Package_Type__c) ||
                'House Void - AIA Rec'.equals(pkg.Package_Type__c) ||
                'House Void - Rec'.equals(pkg.Package_Type__c)){
                
                pkg.Void_Vehicle__c = true;
                
                // For Vehicle Void types, we void transport if it exists, has not already been voided,
                //  and the buyer is not being held responsible.  
                if (pkg.Case__r.VIN__r.Transport_Type__c > 0 &&
                    pkg.Case__r.VIN__r.Transport_Void_Package__c == null &&
                    !'Buyer'.equals(pkg.House_Transport_Responsible_Party__c)) {
                    pkg.Void_House_Transport__c = true;
                } else {
                    pkg.Void_House_Transport__c = false;
                }
                Purchase__c p = purchaseMap.get(pkg.case__r.vin__c);
                if(p != null && p.Inspection_Requests__r != null){
                    for(Inspection_Request__c ir: p.Inspection_Requests__r){
                       if(ir.Inspection_Type__c != null  && (ir.Inspection_Type__c.equalsIgnoreCase('PSI') || ir.Inspection_Type__c.equalsIgnoreCase('PDI')) && //Added PDI for 9a2012
                          ir.Request_Type__c != null  && ir.Request_Type__c.equalsIgnoreCase('New') &&
                          ir.Request_Status__c != null && ir.Request_Status__c.equalsIgnoreCase('SUCCESS') &&
                          ir.PSI_Passed__c == null){
                          pkg.addError('There is currently an outstanding PSI. Please cancel the PSI prior to creating an Arbitration Case');
                          break;
                       }   
                   }
               }
            } else {
                // All other action packages are assumed to not be of type void.  
                pkg.Void_Vehicle__c = false;
                pkg.Void_House_Transport__c = false;
            }
        }
    }
system.debug('Inside at line 151');    
    for (Action_Package__c pkg : validationList) {
        
        pkg.Case__r = cases.get(pkg.Case__c);
        boolean isValid = true;
        
        isValid = ActionPackageValidator.validateGeneral(pkg);
system.debug('Inside at line 158');
system.debug('validate isvalid' + isValid );                
        if ('Transport Void'.equals(pkg.Package_Type__c)) {
            ActionPackageValidator.validateTransportVoid(pkg);          
        } else if (
        
            'Auction Void'.equals(pkg.Package_Type__c) ||
            'Auction Void - Rec'.equals(pkg.Package_Type__c) ||
            'Auction Void - SWAP'.equals(pkg.Package_Type__c) ||
            'House Void - 3rd Party'.equals(pkg.Package_Type__c) ||
            'House Void - 3rd Party Rec'.equals(pkg.Package_Type__c) ||
            'House Void - AIA Rec'.equals(pkg.Package_Type__c) ||
            'House Void - Rec'.equals(pkg.Package_Type__c)){
system.debug('Inside at line 171');            
            ActionPackageValidator.validateVehicleVoid(pkg);
system.debug('Inside at line 173');
system.debug('validate validate void' + pkg.Package_Type__c );            
        } else if ('Extra Cost'.equals(pkg.Package_Type__c)) {
            ActionPackageValidator.validateExtraCostPackage(pkg);
        }
    }
    system.debug('Inside at line 177');
    // Set the Approved By field
  
    if (Trigger.isUpdate)
    {
        for (Action_Package__c pkgWithApprovers :
        [
            SELECT 
                (SELECT
                    CreatedDate,
                    Id, 
                    TargetObjectId, 
                    StepStatus, 
                    ActorId
                 FROM ProcessSteps
                 ORDER BY CreatedDate DESC)
            FROM Action_Package__c
            WHERE Id IN :Trigger.newMap.keySet()
        ])
        {
            if (pkgWithApprovers.ProcessSteps != null && pkgWithApprovers.ProcessSteps.size() > 0)
            {
                User approver = [SELECT Name FROM User WHERE Id = :pkgWithApprovers.ProcessSteps.get(0).ActorId];
                Trigger.newMap.get(pkgWithApprovers.Id).Approved_By__c = approver.Name;
                system.debug('Inside at line 201');
            }
        }
    }
}