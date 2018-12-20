trigger ActionPackageSetActionSummary on Action_Package__c (before insert, before update) {
    
    List<ID> actionPackageIds = new List<ID>();
    
    for (Action_Package__c ap : Trigger.new) {
        actionPackageIds.add(ap.Id);
    }
    
    Map<ID, Action_Package__c> packagesWithECs = new Map<ID, Action_Package__c>(
        [
            SELECT 
                Id,  
                (
                    SELECT 
                        Net_Amount__c, 
                        CurrencyIsoCode, 
                        Extra_Cost_Type__c, 
                        Extra_Cost_Responsible_Party__c, 
                        Tax_Type__c 
                    FROM Extra_Costs__r
                ) 
            FROM Action_Package__c
            WHERE Id IN :actionPackageIds
        ]
    );
                                           
    for (Action_Package__c pkg : Trigger.new)
    {       
        List<String> actions = new List<String>();
        
        if (pkg.Void_House_Transport__c && pkg.House_Transport_Responsible_Party__c != null) 
        {
            actions.add('Void House Transport, to be paid by ' + pkg.House_Transport_Responsible_Party__c); 
        }
        
        if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) ||
            'CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            String creditAmount = '$' + Utils.format(pkg.Credit_Amount__c, 2);
            List<String> breakdown = new List<String>();
            if (pkg.Seller_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.Seller_Amount__c, 2) + ' Seller');
            }
            
            if (pkg.House_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.House_Amount__c, 2) + ' House');
            }
            
            if (pkg.Transporter_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.Transporter_Amount__c, 2) + ' Transporter');
            }
            
            if (pkg.Inspector_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.Inspector_Amount__c, 2) + ' Inspector');
            }
            
            if (pkg.Discretionary_Fund_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.Discretionary_Fund_Amount__c, 2) + ' Discretionary Fund');
            }
            
            if (pkg.Other_Party_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.Other_Party_Amount__c, 2) + ' Other');
            }
            //introduce TradeRev 
            if (pkg.TradeRev_Amount__c != null)
            {
                breakdown.add('$' + Utils.format(pkg.TradeRev_Amount__c, 2) + ' TradeRev');
            }

            
            actions.add(creditAmount + ' / ' + Utils.joinList(breakdown, ', '));
        }
        
        if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            actions.add(Utils.format(pkg.Credit_Amount__c, 2) + ' / ' + pkg.Credit_Reason__c);
        }
        
        if ('AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c)||
            'SELLER AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            actions.add('$' + Utils.format(pkg.Number_Of_Credits__c * pkg.Credit_Amount__c, 2) + ' / ' + Utils.format(pkg.Number_Of_Credits__c, 1) + ' credit(s) x $' + Utils.format(pkg.Credit_Amount__c, 2));
        }
        
        Action_Package__c pkgWithECs = packagesWithECs.get(pkg.Id);
        if (pkgWithECs != null)
        {
            for (Extra_Cost__c ec : pkgWithECs.Extra_Costs__r) 
            {           
                actions.add('Extra Cost - ' + ec.Extra_Cost_Type__c + ': ' +
                             ec.CurrencyIsoCode +  ' '  + ec.Net_Amount__c + ' + ' + ec.Tax_Type__c +
                             ' to be paid by ' + ec.Extra_Cost_Responsible_Party__c);
            }
        }
        
        String actionSummary = Utils.joinList(actions, '\n');
        pkg.Action_Summary__c = actionSummary;
    }
        
    
}