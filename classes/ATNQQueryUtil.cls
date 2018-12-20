public class ATNQQueryUtil {
    
    

    public static List<Contact> getContactsByAutoniqUserId(String userId){
        List<Contact> cList;
        
        return cList;
    }
    
    public static List<Autoniq_Account__c> getAutoniqAccountsByName(String name){
        System.debug('=========> getAutoniqAccountsByName Entered');
        List<Autoniq_Account__c> aList;
        aList = [select Id, AccountStatus__c,Account_Type__c,Auction_Access_Number__c, Latitude__c, Longitude__c, Dealership_AuctionACCESS_Number__c, Name, Street__c,Street_2__c,City__c,State__c,Country__c,Email__c,Phone__c,PostalCode__c, No_Of_Subscriptions__c from Autoniq_Account__c where Name=: name];
        return aList;
    }
    
    public static List<Product2> getProducts(){
        return [select Id, Family, ProductCode, Name from Product2];
    }
    
    public static List<Autoniq_Subscription_Payment_Profile__c> getPaymentProfilesBySubscriptionId(Id subId){
        System.debug('=========> getPaymentProfilesBySubscriptionId Entered');
        List<Autoniq_Subscription_Payment_Profile__c> ppList;
        ppList = [Select Payment_Type__c, Credit_Card_Type__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Street__c, Billing_Street_2__c, Billing_City__c, Billing_State__c, Billing_Country__c, Billing_Postal_Code__c, Credit_Card_Number__c, CC_Expiration_Date__c, Last_Four_Digits__c, CVV_Code__c, Autoniq_Subscription__c, IsActive__c From Autoniq_Subscription_Payment_Profile__c Where Autoniq_Subscription__c =: subId];
        return ppList;
    }
    
    //public static List<Autoniq_User_Applilcation_Setting__c> getUserApplicationSettingsById(Id id){// Work in progress
    //    System.debug('=========> getUserApplicationSettingsById Entered');
    //    List<Autoniq_User_Applilcation_Setting__c> auasList;
    //    auasList = [select Id,Vehicle_Selector_Style__c,Valuation_region__c,Default_Black_Book__c,Default_NADA__c,Default_Kelley_Blue_Book__c From Autoniq_User_Applilcation_Setting__c Where Id =: id];
    //    //auasList = [select Id,AAX_Client_ID__c, AAX_Dealer_ID__c, aaxIntegration__c, AAX_Security_Token__c, AAX_User_ID__c, aqPro__c, clCars__c, clSMC__c, CLCL__c, Contact__c, CurrencyIsoCode, dcAPI__c, dcAL__c,demoAccount__c, GDMS__c, Home_region_zip_code__c, immrLink__c, menuStyle__c, Mobile_Device_Type__c, multipleLogin__c, My_vehicle_bucket_size__c, optOut__c, peBBKTable, peRegion__c, peKBBTable__c, peNADATable__c, Valuation_region__c, webSite__c
    //    return auasList;
    //}
    
    public static List<Subscription__c> getSubscriptionsByAutoniqAccountId(Id aaccid){
        System.debug('=========> getSubscriptionsByAutoniqAccountId Entered');
        List<Subscription__c> subList;
        subList = [select Promo_Code__c, Status__c, Autoniq_Account__c, Referral__c, Contact__c, Term__c, Sign_Up_Date__c, Next_Bill_Date__c From Subscription__c Where Id =: aaccId];
        return subList;
    }
    
    public static List<Subscription_Item__c> getSubscriptionItemsBySubscriptionId(Id subId){
        System.debug('=========> getSubscriptionItemsBySubscriptionId Entered');
        List<Subscription_Item__c> subItemList;
        subItemList = [Select Status__c, Recurring__c, Product__c, iSActive__c, Subscription__c, Start_Date__c  From Subscription_Item__c Where Subscription__c =: subId];
        return subItemList;
    }
    
    public static List<Autoniq_Third_Party_Item__c> getThirdPartyItemsBySubscriptionItemId(Id subItemId){
        System.debug('=========> getThirdPartyItemsBySubscriptionItemId Entered');
        List<Autoniq_Third_Party_Item__c> atpiList;
        atpiList = [Select Id, Username__c,Password__c,Auto_Purchase__c, Autoniq_Subscription_Item__c, Autoniq_Subscription_Item__r.Product__r.ProductCode, AAX_Client_ID__c, AAX_Dealer_ID__c, AAX_User_ID__c, AAX_Security_Token__c, AutoCheck_T_C__c , AutoCheck_T_C_Date__c , CARFAX_T_C__c , CARFAX_T_C_Date__c, Client_Id__c, URI__c, Name From Autoniq_Third_Party_Item__c Where Autoniq_Subscription_Item__c =: subItemId];
        return atpiList;
    }
    
    public static CacheContract getLatestCacheContractForContact(Contact c){
        System.debug('=========> getLatestCacheContractForContact Entered');
        CacheContract cc = new CacheContract();
        //List<Subscription__c> subList = [Select Id, Promo_Code__c, Status__c, Autoniq_Account__c, Referral__c, Contact__c, Term__c, Sign_Up_Date__c, Next_Bill_Date__c, (Select Status__c, Recurring__c, Product__c, Product__r.ProductCode,Product__r.Name,  iSActive__c, Subscription__c, Start_Date__c  From Subscription_Item__r), (Select Payment_Type__c, Credit_Card_Type__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Street__c, Billing_Street_2__c, Billing_City__c, Billing_State__c, Billing_Country__c, Billing_Postal_Code__c, Credit_Card_Number__c, CC_Expiration_Date__c, Last_Four_Digits__c, CVV_Code__c, Autoniq_Subscription__c, IsActive__c From Autoniq_Subscription_Payment_Profile__r) from Subscription__c Where Autoniq_Account__c =: c.Autoniq_Account__c];
        List<Subscription__c> subList = [Select Id, Promo_Code__c, Status__c, Autoniq_Account__c, Autoniq_Account__r.Id, Autoniq_Account__r.Dealership_AuctionACCESS_Number__c, Autoniq_Account__r.Name, Autoniq_Account__r.Street__c, Autoniq_Account__r.Street_2__c, Autoniq_Account__r.City__c, Autoniq_Account__r.Country__c, Autoniq_Account__r.Email__c, Autoniq_Account__r.Phone__c, Autoniq_Account__r.PostalCode__c, Autoniq_Account__r.No_Of_Subscriptions__c, Referral__c, Contact__c, Term__c, Sign_Up_Date__c, Next_Bill_Date__c, (Select Status__c, Recurring__c, Product__c, Product__r.ProductCode,Product__r.Name,  iSActive__c, Subscription__c, Start_Date__c  From Subscription_Item__r) from Subscription__c Where Autoniq_Account__c =: c.Autoniq_Account__c order by CreatedDate DESC];

        List<String> productCodeList = new List<String>();
        Subscription__c sub = subList[0];
        for(Subscription_Item__c si: sub.Subscription_Item__r){
            productCodeList.add(si.Product__r.ProductCode);
        }
        List<Autoniq_Subscription_Payment_Profile__c> ppList = getPaymentProfilesBySubscriptionId(sub.Id);
        if(ppList.size()>0){
            cc = CacheContractUtil.populateCacheContractPaymentProfile(cc, ppList[0]);
        }
        List<Autoniq_Account__c> accList = getAutoniqAccountsByName(sub.Autoniq_Account__r.Name);
        System.debug('=========> getLatestCacheContractForContact accList: '  + accList);
        if(accList.size()>0){
            cc = CacheContractUtil.populateAccountDetail(cc, accList[0], sub.Referral__c);
        }
        for(Subscription_Item__c si: sub.Subscription_Item__r){
            List<Autoniq_Third_Party_Item__c> stpiList = getThirdPartyItemsBySubscriptionItemId(si.Id);
            if(stpiList.size()>0){
                cc = CacheContractUtil.populateVhrSettings(cc,stpiList);
            }
        }
        //List<Autoniq_Third_Party_Item__c> stpiList = getThirdPartyItemsBySubscriptionItemId(sub.Id);
        //if(stpiList.size()>0){
        //    cc = CacheContractUtil.populateVhrSettings(cc,stpiList);
        //}
        if(cc.subscriptionItems==null){
            cc.subscriptionItems = new CacheContract.SubscriptionItems();
        }
        cc.subscriptionItems.subscriptionItemList = productCodeList;
        cc = CacheContractUtil.populateUserDetail(cc,c);
        cc.Options = null;
        cc.Preferences = null;
        return cc;
    }
}