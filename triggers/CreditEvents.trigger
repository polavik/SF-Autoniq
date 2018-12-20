/*******************************************************************************************
*   Author: Modern Apple
*   Purpose: Trigger for Credit Events that updates the Account and Contact lookup fields
*            before insert.
*
*   Date of Change          Author                  Change Summary
*   ---------------------   ---------------------   ---------------------------------------
*   12/02/2016              Rick May                Initial development.
*******************************************************************************************/

trigger CreditEvents on Credit_Event__c (before insert, before update) {
    List<String> sSNs = new List<String>();
    List<String> dealerIds = new List<String>();
    Map<String, Id> contractIdMap = new Map<String, Id>();
    Map<String, Id> contactIdMap = new Map<String, Id>();
    
    for(Credit_Event__c ce: Trigger.new){
        if(ce.Social_Security_Number__c != Null && ce.Social_Security_Number__c.length() == 9){
            sSNs.add(ce.Social_Security_Number__c);
        }
        
        if(ce.Dealer_ID__c != Null){
            dealerIds.add(ce.Dealer_ID__c);
        }
    }
    
    //for(Account acct: [select AFC_Dealer_ID__c from Account where AFC_Dealer_ID__c in: dealerIds]){
    //    accountIdMap.put(acct.AFC_Dealer_ID__c, acct.Id);
    //}

    for(AFC_Contracts__c contract : [select id, AFC_Dealer_ID__c from AFC_Contracts__c where AFC_Dealer_ID__c in: dealerIds]){
        contractIdMap.put(contract.AFC_Dealer_ID__c, contract.Id);
    }    
    
    for(Contact con: [select SSN__c from Contact where SSN__c in: sSNs]){
        contactIdMap.put(con.SSN__c, con.Id);
    }
    
    for(Credit_Event__c ceUpdate: Trigger.new){
        // Update the Account field.
        if(contractIdMap.get(ceUpdate.Dealer_ID__c) != Null){
            //ceUpdate.Account__c = contractIdMap.get(ceUpdate.Dealer_ID__c);
            ceUpdate.AFC_Contract__c = contractIdMap.get(ceUpdate.Dealer_ID__c);
        }
        
        // Update the Contact field.
        if(contactIdMap.get(ceUpdate.Social_Security_Number__c) != Null){
            ceUpdate.Contact__c = contactIdMap.get(ceUpdate.Social_Security_Number__c);
        }
        
        // Update the Type field.
        if(ceUpdate.FICO_Auto_Score_5_NF__c != Null){
            ceUpdate.Type__c = 'Equifax';
        } else{
            ceUpdate.Type__c = 'TransUnion';
        }
        
        // Update the Date field if it is blank.
        if(ceUpdate.Date__c == Null){
            ceUpdate.Date__c = system.today();
        }
    }
}