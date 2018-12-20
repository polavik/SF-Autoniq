public with sharing class ATNQModifySubscriptions {
    @AuraEnabled public Subscription_Item__c subItemRecord;
    public ATNQModifySubscriptions() {
        subItemRecord = new Subscription_Item__c();
    }
}