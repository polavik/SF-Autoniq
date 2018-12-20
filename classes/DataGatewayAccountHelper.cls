public with sharing class DataGatewayAccountHelper {
    public DataGatewayAccountHelper() {   
    }

    public static List<DataGatewayManager.GatewayViolation> checkAccountFlipping(Map<Id,Account> oldMap,Map<Id,Account> newMap){
    
        List<DataGatewayManager.GatewayViolation> result = new List<DataGatewayManager.GatewayViolation>();
        DateTime dateReference = System.now();
        Integer longestTimeFrame = 0;

        Set<String> fieldSet = new Set<String>();
        Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap = new Map<String,Data_Gateway_Flip_Fields__c>();
        for(Data_Gateway_Flip_Fields__c dgff : Data_Gateway_Flip_Fields__c.getAll().values()){
            if(dgff.Object_Name__c == 'Account'){
                fieldSet.add(dgff.Name);
                flipFieldMap.put(dgff.Name,dgff);
                if(dgff.Timeframe__c > longestTimeFrame){
                    longestTimeFrame = Integer.valueOf(dgff.Timeframe__c);
                }
            }
        }

        DateTime timeFrameLimit = dateReference.addDays(-Integer.valueOf(longestTimeFrame));
        List<Account> accountList = [select id, name, (select AccountId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                                            from Histories where Field in :fieldSet and CreatedDate > :timeFrameLimit order by CreatedDate desc limit 25) from Account where id in :newMap.keySet()];

        for(Account a : accountList){
             Map<String,Integer> fieldChangeCountMap = checkNumberOfChanges(flipFieldMap,a.Histories);

            // If there are any violations for this Account, create a DataGatewayManager.GatewayViolation and add it to the result
            List<DataGatewayManager.GatewayChange> fieldChanges = new List<DataGatewayManager.GatewayChange>();

            for(String field: fieldChangeCountMap.keySet()){
                if(fieldChangeCountMap.get(field) >= 2 && oldMap.get(a.Id).get(field) != newMap.get(a.Id).get(field)){
                    fieldChanges.add(new DataGatewayManager.GatewayChange(field,String.valueOf(oldMap.get(a.Id).get(field)),String.valueOf(newMap.get(a.Id).get(field))));
                }
            }
            if(fieldChanges.size() > 0){
                DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation();
                gv.type = 'Attribute Flipping';
                gv.recordId = a.id;
                gv.result = 'TBD';
                gv.reasonList.addAll(fieldChanges);
                result.add(gv);
            }
        }
        return result;
    }


    //Because creating History records in tests is not allowed, we have broken out this functionality into a separate method (for easier testing)
    @TestVisible    
    private static Map<String,Integer> checkNumberOfChanges(Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap,List<AccountHistory> accountHistoryList){
        DateTime dateReference = System.now();
        // Initialize to zero for all fields
        if(flipFieldMap == null){
            flipFieldMap = new Map<String,Data_Gateway_Flip_Fields__c>();
        }
        Map<String,Integer> result = new Map<String,Integer>();
        Set<String> fieldSet = new Set<String>();
        for(String field : flipFieldMap.keySet()){
            result.put(field,0);
            fieldSet.add(field);
        }

        // Populate Change Map by iterating the History records for each Account
        for(AccountHistory ah : filterHistory(accountHistoryList)){
                if(result.get(ah.Field) != null && ah.createdDate > dateReference.addDays(-Integer.valueOf(flipFieldMap.get(ah.Field).Timeframe__c))){
                    result.put(ah.Field,result.get(ah.Field)+1);
                }
        }   
        return result;     
    }


    // If I reject the update (and set newValue = oldValue in the Trigger), Salesforce actually creates two history records, one for
    // the update and one for the "put back." These should not count in the total, because they net out to a non-event.  
    // If a field is updated twice with the same CreatedDate timestamp, those History records are filtered out of the flipping calculation.
    @TestVisible
    private static List<AccountHistory> filterHistory(List<AccountHistory> accountHistory){
        Map<String,AccountHistory> historyMap = new Map<String,AccountHistory>();
        for(AccountHistory ah : accountHistory){
            if(historyMap.get(ah.field+ah.CreatedDate) == null){
                historyMap.put(ah.field+ah.CreatedDate,ah);
            } else {
                AccountHistory tempAh = historyMap.get(ah.field+ah.CreatedDate);
                if(ah.oldValue == tempAh.newValue || ah.newValue == tempAh.oldValue){ 
                    historyMap.remove(ah.field+ah.CreatedDate);
                }
            }
        }
        return historyMap.values();
    }


    // Ensures that no critical fields are "nulled out" if they have existing values.  Characteristics of this function are determined by Custom Settings.
    public static List<DataGatewayManager.GatewayViolation> checkAccountKeyFieldDeletion(Map<Id,Account> oldAccountMap, Map<Id,Account>newAccountMap){
        List<DataGatewayManager.GatewayViolation> result = new List<DataGatewayManager.GatewayViolation>();

        List<String> fieldNames = new List<String>();
        for(Data_Gateway_Key_Fields__c fieldSet : Data_Gateway_Key_Fields__c.getall().values()){
            if(fieldSet.Object_Name__c == 'Account'){
                fieldNames.add(fieldSet.Field_Name__c);
            }
        }

        for(Account updatedAccount : newAccountMap.values()){
            for(String fieldName: fieldNames){
               if(updatedAccount.get(fieldName) == null && oldAccountMap.get(updatedAccount.Id).get(fieldName) != null){
                    DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation();
                    gv.type = 'Key Field Deletion';
                    gv.recordId = updatedAccount.Id;
                    gv.result = 'Update Declined';
                    String oldValue = String.valueOf(oldAccountMap.get(updatedAccount.Id).get(fieldName));
                    String newValue = String.valueOf(newAccountMap.get(updatedAccount.Id).get(fieldName));
                    DataGatewayManager.GatewayChange gc = new DataGatewayManager.GatewayChange(fieldName, oldValue, newValue);
                    gv.reasonList.add(gc);                    
                    result.add(gv);
                }
            }
        }
        return result;
    }
}