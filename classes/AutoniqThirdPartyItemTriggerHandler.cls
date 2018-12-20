public with sharing class AutoniqThirdPartyItemTriggerHandler {
    /*
        Description : Out bound web serice callout, to update 'Autoniq Third Party Item', from the given record ids.
                      This future method gets called from the trigger on the object 'Autoniq Third Party Item'
    */
    @Future(callout = true)
    public static void updateAutoniqThirdPartyItem(set<id> thirdPartyItemIdSet){
        // Quering all 'Autoniq Third Party Item' along with its subscription item and products information
        list<Autoniq_Third_Party_Item__c> thirdPartyItemList = [SELECT AAX_Security_Token__c, AAX_Client_ID__c, AAX_Dealer_ID__c,
                        AAX_User_ID__c, Username__c, Password__c, Auto_Purchase__c, 
                    Autoniq_Subscription_Item__r.product__r.Name, Autoniq_Subscription_Item__r.Subscription__r.Contact__c 
                    FROM Autoniq_Third_Party_Item__c WHERE Id IN :thirdPartyItemIdSet];
        if(!thirdPartyItemList.isEmpty()){
            string requestJson;
            string urlStr = '';
            Autoniq_Third_Party_Item__c rec = thirdPartyItemList[0];
            // Creating a JSON request wrapper body, from the thirdPartyItem records, by reading the 'CarFax' or 'AutoCheck' or 'AAX Integration' data
            AutoniqMyAccountUpdateVHRRequest requestWrapper = new AutoniqMyAccountUpdateVHRRequest();
            requestWrapper.contactId = rec.Autoniq_Subscription_Item__r.Subscription__r.Contact__c;
            if(rec.Autoniq_Subscription_Item__r.product__r.Name == 'CarFax'){
                requestWrapper.carfaxId = rec.Username__c;
                requestWrapper.carfaxPasswd = rec.Password__c;
                requestWrapper.carfaxAutoPurchase = rec.Auto_Purchase__c;
                urlStr = '';
            }
            if(rec.Autoniq_Subscription_Item__r.product__r.Name == 'AutoCheck'){
                requestWrapper.autoCheckId = rec.Username__c;
                requestWrapper.autoCheckPasswd = rec.Password__c;
                requestWrapper.autoCheckAutoPurchase = rec.Auto_Purchase__c;
                urlStr = '';
            } 
            requestJson = JSON.serialize(requestWrapper);
            // If the product type is 'AAX Integration', create DMS Information request body
            if(rec.Autoniq_Subscription_Item__r.product__r.Name == 'AAX Integration'){
                CacheContract.aax DMSInfo = new CacheContract.aax();
                DMSInfo.aaxSecurityToken = rec.AAX_Security_Token__c;
                DMSInfo.aaxClientId = rec.AAX_Client_ID__c;
                DMSInfo.aaxDealerId = rec.AAX_Dealer_ID__c;
                DMSInfo.aaxUserId = rec.AAX_User_ID__c;

                urlStr = '';
                requestJson = JSON.serialize(DMSInfo);
            }   
            
             
            // Getting the API Token for authentication to external system.
            //string APIToken = getATNQToken();
            string APIToken = '2Zagqjw3fA2WKPVh74HJF1LFUmwDmCAv2nlsZoB2';
            
            if(!string.isEmpty(APIToken)){
                // Make http callout to the external system with the API Token, request body and end point URL
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(urlStr);
                req.setHeader('x-api-key',APIToken);
                req.setMethod('POST');
                req.setBody(requestJson);
                HttpResponse res = h.send(req);
                string responseBody = res.getBody();
                system.debug('responseStatus code ---    '+res.getStatusCode());
                system.debug('responseBody ---    '+responseBody);
            }

        }
    }
}