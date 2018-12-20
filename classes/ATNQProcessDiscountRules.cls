public with sharing class ATNQProcessDiscountRules {
    public static List <Subscription> Process(Set <Id> subscriptionIds) {
        Autoniq_Discount_Assignment_Rule__c [] rules = [
            SELECT Id, Autoniq_Discount_Type__c, Autoniq_Discount_Type__r.Value__c, Autoniq_Discount_Type__r.Unit__c,
                (SELECT Id, Value__c, Field__c,  Operand__c, RecordType.DeveloperName
                FROM Autoniq_Discount_Assign_Rule_Criteria__r)
            FROM Autoniq_Discount_Assignment_Rule__c
            ];

        Set <String> allFields = new Set <String>();
        for (Autoniq_Discount_Assignment_Rule__c ruleAssignment : rules) {
            for (Autoniq_Discount_Assignment_Rule_Criteri__c criteria : ruleAssignment.Autoniq_Discount_Assign_Rule_Criteria__r ) {
                allFields.add(criteria.Field__c);
            }
        }
        List <String> allFieldsList = new List <String>();
        allFieldsList.addAll(allFields);

        string queryString = 'SELECT Id, ' +
            //'(SELECT ProductCode__c, ' + string.join(allFieldsList, ',') + ' ' +
            '(SELECT ' + string.join(allFieldsList, ',') + ' ' +
            'FROM Subscription_Item__r) ' + 
            'FROM Subscription__c ' +
            'WHERE Id IN : subscriptionIds ';
        
        Subscription__c [] subscriptions = (Subscription__c [] ) Database.query(queryString);
        
        List <Subscription> subscriptionsReturned = new List <Subscription>();

        for (Subscription__c subscription : subscriptions) {
            Subscription subscriptionReturned = new Subscription();
            subscriptionReturned.id = subscription.Id;
            subscriptionReturned.subItems = new List<SubscriptionItem>();
            
            for (Subscription_Item__c subItem : subscription.Subscription_Item__r) {
                SubscriptionItem subItemReturned = new SubscriptionItem();
                subItemReturned.Id = subItem.Id;
                subItemReturned.productCode = subItem.ProductCode__c;
                subItemReturned.discountTypes = new List<DiscountType>();

                for (Autoniq_Discount_Assignment_Rule__c rule : rules) {

                    List <string> fields = new List <String>();
                    List <string> values = new List <String>();
                    List <string> operands = new List <String>();
                    List <string> recordTypes = new List <String>();
                    for (Autoniq_Discount_Assignment_Rule_Criteri__c criteria : rule.Autoniq_Discount_Assign_Rule_Criteria__r ) {   
                        system.debug('- - criteria ' + criteria);
                        fields.add(criteria.Field__c);
                        values.add(criteria.Value__c);
                        operands.add(criteria.Operand__c);
                        recordTypes.add(criteria.RecordType.DeveloperName);
                    }
                    boolean success = ATNQRulesEngine.test( ATNQRulesEngine.parse(subItem, fields, values , operands, recordTypes));
                    if (success) {
                        if (rule.Autoniq_Discount_Type__r.Value__c != null && rule.Autoniq_Discount_Type__r.Unit__c != null) {
                            DiscountType discType = new DiscountType();
                            discType.type = rule.Autoniq_Discount_Type__c; 
                            discType.value = rule.Autoniq_Discount_Type__r.Value__c;
                            discType.unit = rule.Autoniq_Discount_Type__r.Unit__c;
                            subItemReturned.discountTypes.add(discType);
                        }
                    }
                }
                subscriptionReturned.subItems.add(subItemReturned);             
            }
            subscriptionsReturned.add(subscriptionReturned);            
        }       
        return subscriptionsReturned;       
    }

    public class Subscription {

        public string id;
        public List <SubscriptionItem> subItems;
    }
    public class SubscriptionItem {
        public string id;
        public string productCode;
        public List <DiscountType> discountTypes;
    }
    public class DiscountType {
        public string type; // This is the Id of the Autoniq_Discount_Type__c
        public Decimal value; 
        public string unit;
    }
}