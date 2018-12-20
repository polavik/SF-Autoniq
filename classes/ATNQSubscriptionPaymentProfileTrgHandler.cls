public class ATNQSubscriptionPaymentProfileTrgHandler {
    /*
        Description : Get API Token for authentication to external system
    */
    public static string getATNQToken(){
        string urlStr = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndPoint(urlStr);
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        string responseBody = res.getBody();
        system.debug('responseStatus code ---    '+res.getStatusCode());
        system.debug('responseBody ---    '+responseBody);
        return responseBody;
    }
    
    /*
        Description : Out bound web serice callout, to update 'Autoniq Subscription Payment Profile', from the given record ids.
                      This future method gets called from the trigger on the object 'Autoniq Subscription Payment Profile'
    */
    @Future(callout=true)
    public static void updateATNQPaymentProfile(set<id> paymentProfileIdSet){
        // Quering all 'Autoniq Subscription Payment Profile' from the given record ids
        list<Autoniq_Subscription_Payment_Profile__c> subscriptionPaymentProfileList = 
                                [SELECT Billing_First_Name__c, Billing_Last_Name__c, CC_Expiration_Date__c, 
                                        Credit_Card_Number__c,Billing_City__c, Billing_State__c, Billing_Street__c, Billing_Postal_Code__c, Billing_Country__c, 
                                        Autoniq_Subscription__c, Credit_Card_Type__c,External_Id__c,Name,Payment_Type__c 
                                        FROM Autoniq_Subscription_Payment_Profile__c WHERE id IN :paymentProfileIdSet];

        if(!subscriptionPaymentProfileList.isEmpty()){
            //Creating payment info JSON request body, by reading 'Billing' and 'CreditCard' data
            Autoniq_Subscription_Payment_Profile__c subscriptionPaymentProfileRec = subscriptionPaymentProfileList[0];
            AutoniqMyAccountUpdatePaymentInfoRequest requestWrapper = new AutoniqMyAccountUpdatePaymentInfoRequest();
            requestWrapper.ccFirstName = subscriptionPaymentProfileRec.Billing_First_Name__c;
            requestWrapper.ccLastName = subscriptionPaymentProfileRec.Billing_Last_Name__c;
            requestWrapper.ccNumber = subscriptionPaymentProfileRec.Credit_Card_Number__c;
            if(subscriptionPaymentProfileRec.CC_Expiration_Date__c != null){
                requestWrapper.ccExpiresMonth = subscriptionPaymentProfileRec.CC_Expiration_Date__c.substringBefore('/');
                requestWrapper.ccExpiresYear = subscriptionPaymentProfileRec.CC_Expiration_Date__c.substringAfter('/');
            }
            requestWrapper.ccAddress = subscriptionPaymentProfileRec.Billing_Street__c;
            requestWrapper.ccCity = subscriptionPaymentProfileRec.Billing_City__c;
            requestWrapper.ccState = subscriptionPaymentProfileRec.Billing_State__c;
            requestWrapper.ccCountry = subscriptionPaymentProfileRec.Billing_Country__c;
            requestWrapper.ccPostalCode = subscriptionPaymentProfileRec.Billing_Postal_Code__c;
            //requestWrapper.ccFirstName = subscriptionPaymentProfileRec.Autoniq_Subscription__r.Contact__r.firstName;
            //requestWrapper.ccLastName = subscriptionPaymentProfileRec.Autoniq_Subscription__r.Contact__r.lastName;
            string requestJson = JSON.serialize(requestWrapper);
            
            // Getting the API Token for authentication to external system.
            //string APIToken = getATNQToken();
            string APIToken = '2Zagqjw3fA2WKPVh74HJF1LFUmwDmCAv2nlsZoB2';
            
            if(!string.isEmpty(APIToken)){
                // Make http callout to the external system with the API Token, request body and end point URL
                string urlStr = '';
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(urlStr);
                //req.setHeader('Authorization',APIToken);
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