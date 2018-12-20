public with sharing class ATNQSubscriptionPanelController {

    @AuraEnabled
    public static ThirdPartyItem [] getThirdPartyItems (string contactId) {
        List <ThirdPartyItem> thirsPartyItems = new List <ThirdPartyItem>();        
        for (Autoniq_Third_Party_Item__c item : [
            SELECT Username__c, Password__c, Autoniq_Subscription_Item__r.Product__r.Name
            FROM Autoniq_Third_Party_Item__c
            WHERE Autoniq_Subscription_Item__r.Subscription__r.Contact__c = : contactId  
                OR Autoniq_User_Applilcation_Setting__r.Contact__c = : contactId] ) {
            thirsPartyItems.add(new ThirdPartyItem(item));
        }
        return thirsPartyItems;
    }

    @AuraEnabled
    public static Autoniq_User_Applilcation_Setting__c getUserSetting (string contactId) {
         Autoniq_User_Applilcation_Setting__c [] settings = [
            SELECT Id, demoAccount__c, Contact__c, Valuation_region__c, menuStyle__c, Mobile_Device_Type__c, Home_region_zip_code__c
             FROM Autoniq_User_Applilcation_Setting__c WHERE Contact__c = :contactId];
         if (settings.size() > 0 ) {
            return settings[0];
         }
         else return null;
    }

    @AuraEnabled
    public static Subscription getSubscriptionItems (string contactId) {
        List <SubscriptionItem> items = new List <SubscriptionItem>();
        
        Subscription__c [] subscriptions = [SELECT Id, Cancel_Reason__c, Status__c, Next_Bill_Date__c, Sign_up_Date__c, Term__c 
            FROM Subscription__c 
            WHERE Contact__c = : contactId];

        for (Subscription_Item__c subItem : [select id, Product__r.Name,  Recurring__c,
                (SELECT Id, Start_Date__c, End_Date__c,  Autoniq_Discount_Type__r.Type__c, Autoniq_Discount_Type__r.Name, Code__c
                FROM Autoniq_Discount_Assignments__r) , 
                Start_Date__c , Name, Status__c  
                from Subscription_Item__c 
                where Subscription__c = : subscriptions[0].Id]) {
            SubscriptionItem item = new SubscriptionItem(subItem);
            for (Autoniq_Discount_Assignment__c discount :  subItem.Autoniq_Discount_Assignments__r) {          
                item.discounts.add(new Discount(discount));
            }           
            items.add(item);
        }
        return new Subscription(subscriptions[0], items);
        
    }

    @AuraEnabled
    public static SubscriptionItem [] getSubscriptionItemsToAdd (string contactId) {
        Subscription subscription = getSubscriptionItems (contactId);
        Product2 [] products = [SELECT Id, Name FROM Product2];
        List <SubscriptionItem> items = new List <SubscriptionItem>();
        for (Product2 p : products) {
            boolean isFound = false;
            for (SubscriptionItem i : subscription.subscriptionItems) {     
                if (p.name == i.name) {
                    isFound = true;
                }
            }
            if (!isFound) {
                SubscriptionItem newItem = new SubscriptionItem();
                newItem.name = p.name;
                newItem.isViewMode = true;
                items.add(newItem);
            }
        }
        
        system.debug('items ' + items);
        return items;
        //return new List <SubscriptionItem>();
        
    }

    @AuraEnabled
    public static boolean updateUserSetting (Autoniq_User_Applilcation_Setting__c setting) {
        update setting;
        return true;
    }

    class ThirdPartyItem {
        public ThirdPartyItem(Autoniq_Third_Party_Item__c item) {
            username = item.Username__c;
            password = item.Password__c;
            name = item.Autoniq_Subscription_Item__r.Product__r.Name;
        }
        @AuraEnabled public string username;
        @AuraEnabled public string password;
        @AuraEnabled public string name;
    }

    class Subscription {        
        @AuraEnabled public string status;
        @AuraEnabled public string cancelReason;
        @AuraEnabled public string billDate;
        @AuraEnabled public string term;
        @AuraEnabled public string signUpDate;
        @AuraEnabled public string id;
        public Subscription(Subscription__c subscription, List <SubscriptionItem> items) {
            subscriptionItems = items;      
            status = subscription.status__c;
            cancelReason = string.isNotBlank(subscription.Cancel_Reason__c) ? subscription.Cancel_Reason__c : '';
            billDate = subscription.Next_Bill_Date__c.format();
            term = subscription.Term__c;
            id = subscription.id;
            signUpDate = subscription.Sign_Up_Date__c.format();
        }
        @AuraEnabled public List <SubscriptionItem> subscriptionItems; 
    }

    class Discount {
        public Discount(Autoniq_Discount_Assignment__c discount) {
            code = discount.Code__c;
            //offAmount = discount.Off_Amount__c + '';
            //percent = discount.Precent__c + '';
            name = discount.Autoniq_Discount_Type__r.Name;
            //startDate =  discount.Start_Date__c.format() ;
            endDate = discount.End_Date__c.format();
            type = discount.Autoniq_Discount_Type__r.Type__c;
        }
        @AuraEnabled public string code;
        @AuraEnabled public string offAmount;
        @AuraEnabled public string percent;
        @AuraEnabled public string type;
        @AuraEnabled public string startDate;
        @AuraEnabled public string endDate;
        @AuraEnabled public string name;
    }
    
    class SubscriptionItem {
        public SubscriptionItem () {}
        public SubscriptionItem(Subscription_Item__c subItem) {
            discounts = new List <Discount>();
            startDate = subItem.Start_Date__c.format();  
            recurring = subItem.Recurring__c;       
            status = subItem.Status__c;
            title = subItem.Product__r.Name ;
            name = subItem.Product__r.Name;
            
            isChecked = true;
            isViewMode = true;
        }
        @AuraEnabled public List <Discount> discounts;
        @AuraEnabled public string startDate;
        @AuraEnabled public string recurring;
        @AuraEnabled public string endDate;
        @AuraEnabled public string rate;
        @AuraEnabled public string tax;
        @AuraEnabled public string status;
        @AuraEnabled public string title;
        @AuraEnabled public string name;
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public boolean isViewMode;
    }

}