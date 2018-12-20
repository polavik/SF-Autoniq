public with sharing class DataGatewayContactHelper {
    public DataGatewayContactHelper() {   
    }

    public static List<DataGatewayManager.GatewayViolation> checkContactFlipping(Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
    
        List<DataGatewayManager.GatewayViolation> result = new List<DataGatewayManager.GatewayViolation>();
        DateTime dateReference = System.now();
        Integer longestTimeFrame = 0;

        Set<String> fieldSet = new Set<String>();
        Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap = new Map<String,Data_Gateway_Flip_Fields__c>();
        for(Data_Gateway_Flip_Fields__c dgff : Data_Gateway_Flip_Fields__c.getAll().values()){
            if(dgff.Object_Name__c == 'Contact'){
                fieldSet.add(dgff.Name);
                flipFieldMap.put(dgff.Name,dgff);
                if(dgff.Timeframe__c > longestTimeFrame){
                    longestTimeFrame = Integer.valueOf(dgff.Timeframe__c);
                }
            }
        }

        DateTime timeFrameLimit = dateReference.addDays(-Integer.valueOf(longestTimeFrame));
        List<Contact> contactList = [select id, name, (select ContactId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                                            from Histories where Field in :fieldSet and CreatedDate > :timeFrameLimit order by CreatedDate desc limit 25) from Contact where id in :newMap.keySet()];

        for(Contact a : contactList){
Map<String,Integer> fieldChangeCountMap = checkNumberOfChanges(flipFieldMap,a.Histories);

            // If there are any violations for this Contact, create a DataGatewayManager.GatewayViolation and add it to the result
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
    private static Map<String,Integer> checkNumberOfChanges(Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap,List<ContactHistory> contactHistoryList){
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

        // Populate Change Map by iterating the History records for each Contact
        for(ContactHistory ah : filterHistory(contactHistoryList)){
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
    private static List<ContactHistory> filterHistory(List<ContactHistory> contactHistory){
        Map<String,ContactHistory> historyMap = new Map<String,ContactHistory>();
        for(ContactHistory ah : contactHistory){
            if(historyMap.get(ah.field+ah.CreatedDate) == null){
                historyMap.put(ah.field+ah.CreatedDate,ah);
            } else {
                ContactHistory tempAh = historyMap.get(ah.field+ah.CreatedDate);
                if(ah.oldValue == tempAh.newValue || ah.newValue == tempAh.oldValue){ 
                    historyMap.remove(ah.field+ah.CreatedDate);
                }
            }
        }
        return historyMap.values();
    }


    // Ensures that no critical fields are "nulled out" if they have existing values.  Characteristics of this function are determined by Custom Settings.
    public static List<DataGatewayManager.GatewayViolation> checkContactKeyFieldDeletion(Map<Id,Contact> oldContactMap, Map<Id,Contact>newContactMap){
        List<DataGatewayManager.GatewayViolation> result = new List<DataGatewayManager.GatewayViolation>();

        List<String> fieldNames = new List<String>();
        for(Data_Gateway_Key_Fields__c fieldSet : Data_Gateway_Key_Fields__c.getall().values()){
            if(fieldSet.Object_Name__c == 'Contact'){
                fieldNames.add(fieldSet.Field_Name__c);
            }
        }

        for(Contact updatedContact : newContactMap.values()){
            for(String fieldName: fieldNames){
               if(updatedContact.get(fieldName) == null && oldContactMap.get(updatedContact.Id).get(fieldName) != null){
                    DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation();
                    gv.type = 'Key Field Deletion';
                    gv.recordId = updatedContact.Id;
                    gv.result = 'Update Declined';
                    String oldValue = String.valueOf(oldContactMap.get(updatedContact.Id).get(fieldName));
                    String newValue = String.valueOf(newContactMap.get(updatedContact.Id).get(fieldName));
                    DataGatewayManager.GatewayChange gc = new DataGatewayManager.GatewayChange(fieldName, oldValue, newValue);
                    gv.reasonList.add(gc);                    
                    result.add(gv);
                }
            }
        }
        return result;
    }
}