trigger ATNQSubscriptionPaymentProfileTrigger on Autoniq_Subscription_Payment_Profile__c (after update) {
    if(Trigger.isUpdate){
        ATNQSubscriptionPaymentProfileTrgHandler.updateATNQPaymentProfile(Trigger.newMap.keySet());
    }
}