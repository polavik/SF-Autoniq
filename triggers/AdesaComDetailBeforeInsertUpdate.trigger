trigger AdesaComDetailBeforeInsertUpdate on Adesa_com_Detail__c (before insert,before update) {

    //Update ATC_Organization_ID__c on Account if not exist for before insert and before update
    Set<Id> AccountIds = new Set<Id>();
    Map<Id,String> MapAccountId_To_ATCOrgId = new Map<Id,String>();
    for (Adesa_com_Detail__c objAdesa : Trigger.new) {
        AccountIds.add(objAdesa.Account__c);
        MapAccountId_To_ATCOrgId.put(objAdesa.Account__c,objAdesa.ATC_Organization_ID__c);
    }
    if(AccountIds.size()>0)
    {
        System.debug('>>>AdesaComDetailBeforeInsertUpdate  AccountIds : '+AccountIds );
        List<Account> ListAccounts = [SELECT ID,ATC_Organization_ID__c FROM ACCOUNT WHERE ID IN:AccountIds];
        If(ListAccounts.size()>0)
        {
             for (Account objAccount : ListAccounts)
             {             
                if(objAccount.ATC_Organization_ID__c != MapAccountId_To_ATCOrgId.get(objAccount.Id))
                {
                 objAccount.ATC_Organization_ID__c = MapAccountId_To_ATCOrgId.get(objAccount.Id);
                }
             }
             System.debug('>>>AdesaComDetailBeforeInsertUpdate  ListAccounts: '+ListAccounts);
             Update ListAccounts;
             
        }
    }
    //End Update ATC_Organization_ID__c on Account if not exist

    if(Trigger.isBefore && Trigger.isUpdate)
    {
        // since detail doesn't have Arbitrations__c ,removed from this trigger
        for (Adesa_com_Detail__c org : Trigger.new) {
         org.IDEAL_Arbitrations__c = 0; 
        } 
         // Get list of Arbitrations in the past 180s for vehicles sold by orgs in trigger.
        for (Case c : [SELECT ADESA_com_Detail_Seller__c,Seller__c, Type, Used_For_Seller_Rating__c, VIN__r.ATC_Sale_Date__c
                       FROM Case 
                       WHERE Type='Arbitration'
                       AND Used_For_Seller_Rating__c = 'Yes'
                       //AND VIN__r.ATC_Sale_Date__c > :Datetime.now().addDays(-180)
                       AND CreatedDate > :Datetime.now().addDays(-180)
                       AND ADESA_com_Detail_Seller__c IN :Trigger.newMap.keySet()])
        {
            Trigger.newMap.get(c.ADESA_com_Detail_Seller__c).IDEAL_Arbitrations__c += 1;
        }    
    }
}