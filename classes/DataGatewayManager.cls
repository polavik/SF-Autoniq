public with sharing class DataGatewayManager {
    public DataGatewayManager() {   
    }

    // Determines whether a field on an Account is "Flipping" between values from two different systems.  Characteristics of this function are determined by Custom Settings.
    public static List<GatewayViolation> checkAccountFlipping(Map<Id,Account> oldMap,Map<Id,Account> newMap){
        List<GatewayViolation> result = DataGatewayAccountHelper.checkAccountFlipping(oldMap,newMap);
        return result;
    }

    // Determines whether a field on a Contact is "Flipping" between values from two different systems.  Characteristics of this function are determined by Custom Settings.
    public static List<GatewayViolation> checkContactFlipping(Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
        return DataGatewayContactHelper.checkContactFlipping(oldMap,newMap);
    }

    // Ensures that no critical fields are "nulled out" if they have existing values.  Characteristics of this function are determined by Custom Settings.
    public static List<GatewayViolation> checkAccountKeyFieldDeletion(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap){
        return DataGatewayAccountHelper.checkAccountKeyFieldDeletion(oldAccountMap, newAccountMap);
    }

    // Ensures that no critical fields are "nulled out" if they have existing values.  Characteristics of this function are determined by Custom Settings.
    public static List<GatewayViolation> checkContactKeyFieldDeletion(Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap){
        return DataGatewayContactHelper.checkContactKeyFieldDeletion(oldContactMap, newContactMap);
    }

    public static void updateAccountsFromMdm(List<Account> accountList){
        List<Id> accountIdList = new List<Id>();
        for(Account a : accountList){
            accountIdList.add(a.Id);
        }
        DataGatewayMDMServiceAccountHelper.getOrganizationMatch(accountIdList);
    }

    public static void updateContactsFromMdm(List<Contact> contactList){
        List<Id> contactIdList = new List<Id>();
        for(Contact c : contactList){
            contactIdList.add(c.Id);
        }
        DataGatewayMDMServiceContactHelper.getPersonMatch(contactIdList);
    }

    public static List<GatewayViolation> verifyContacts(List<Contact> contactList, boolean applyMDMUpdates){
        return new List<GatewayViolation>();
    }

    public static boolean sourceCanInsert(String entityType){
        boolean result = true;
        for(Data_Gateway_Update_Only_Users__c insertUser : Data_Gateway_Update_Only_Users__c.getAll().values()){
            if(insertUser.Username__c == UserInfo.getUserName() && insertUser.Object_Name__c == entityType){
              result = false;
            }
        }
        return result;
    }
    

    // Supporting classes, used by the Data Gateway *Helper classes and by consumers of these functions (triggers, etc.)
    public class DataGatewayException extends Exception{}

    public class DataGatewayTestingException extends Exception{} // Assists with the Unit Testing process

    public class GatewayViolation{
        public Id recordId{get;set;}
        public String type{get;set;}
        public String result{get;set;} // "Update Declined" or "Update Applied"
        public List<GatewayChange> reasonList{get;set;}
        public GatewayViolation(){
            reasonList = new List<GatewayChange>();
            result = 'Update Applied'; // Just a default value.  It is set contextually by the calling code
        }
        public GatewayViolation(Id recordId, String type){
            this();
            this.recordId = recordId;
            this.type = type;
        }
    }
    
    public class GatewayChange{
        public String field{get;set;}
        public String oldValue{get;set;}
        public String newValue{get;set;}
        public GatewayChange(String field, String oldValue, String newValue){
            this.field = field;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
    }
}