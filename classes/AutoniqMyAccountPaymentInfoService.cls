@RestResource(urlMapping='/autoniq/myaccount/paymentInfo/*')
global class AutoniqMyAccountPaymentInfoService {
    /*
     Description : Inbound web-service for updating 'Autoniq Subscription Payment Profile' object
                   for the Subscription from the given unique 'contact id' in request body.
    */
    @HttpPost global static string updatePaymentInfo () {
        RestRequest req = RestContext.request;
        string paymentInfoStr = req.requestBody.toString().trim();
        AutoniqMyAccountUpdatePaymentInfoRequest paymentInfo = (AutoniqMyAccountUpdatePaymentInfoRequest) json.deserialize(paymentInfoStr,AutoniqMyAccountUpdatePaymentInfoRequest.class);
        string responseMsg;
        if(paymentInfo != null){
            if(paymentInfo.ccContactId != null && !string.isEmpty(paymentInfo.ccContactId)){
                // Querying contact and its related 'Subscription'
                list<Contact> contactList = [SELECT firstName, lastName, (SELECT Id FROM Subscription__r limit 1) FROM Contact 
                                            WHERE Id = :paymentInfo.ccContactId];
                if(contactList != null && !contactList.isEmpty()){
                    Contact con = contactList[0];
                    if(con.Subscription__r != null && !con.Subscription__r.isEmpty()){
                        // Querying 'Autoniq Subscription Payment Profile' under the parent Subscription record
                        list<Autoniq_Subscription_Payment_Profile__c> subscriptionPaymentProfileList = 
                                [SELECT Billing_First_Name__c, Billing_Last_Name__c, CC_Expiration_Date__c, 
                                        Credit_Card_Number__c, Autoniq_Subscription__c,Credit_Card_Type__c,External_Id__c,Name,Payment_Type__c,
                                        Billing_Street__c, Billing_City__c, Billing_State__c, Billing_Postal_Code__c, Billing_Country__c 
                                        FROM Autoniq_Subscription_Payment_Profile__c WHERE Autoniq_Subscription__c = :con.Subscription__r[0].id];
                        Autoniq_Subscription_Payment_Profile__c subscriptionPaymentProfile;
                        if(!subscriptionPaymentProfileList.isEmpty()){
                            // Updating 'Autoniq Subscription Payment Profile' with the request body and returning response message. 
                            subscriptionPaymentProfile = subscriptionPaymentProfileList[0];

                            //subscriptionPaymentProfile.Autoniq_Subscription__c = con.Subscription__r[0].id;
                            subscriptionPaymentProfile.Billing_First_Name__c = paymentInfo.ccFirstName;
                            subscriptionPaymentProfile.Billing_Last_Name__c = paymentInfo.ccLastName;
                            subscriptionPaymentProfile.CC_Expiration_Date__c = paymentInfo.ccExpiresMonth+'/'+paymentInfo.ccExpiresYear;
                            subscriptionPaymentProfile.Billing_Street__c = paymentInfo.ccAddress;
                            subscriptionPaymentProfile.Billing_City__c = paymentInfo.ccCity;
                            subscriptionPaymentProfile.Billing_State__c = paymentInfo.ccState;
                            subscriptionPaymentProfile.Billing_Postal_Code__c = paymentInfo.ccPostalCode;
                            subscriptionPaymentProfile.Billing_Country__c = paymentInfo.ccCountry;
                            if(!string.isEmpty(paymentInfo.ccNumber)){
                                subscriptionPaymentProfile.Credit_Card_Number__c = paymentInfo.ccNumber;
                            }
                            subscriptionPaymentProfile.Payment_Type__c = 'Credit Card';

                            update subscriptionPaymentProfile;
                            responseMsg = 'Updated successfully';
                            return responseMsg;

                        }

                    }else{
                        // If there is no Subscription under the contact, returns error response as 'No subscription found.'
                        responseMsg = 'No subscription found.';
                        return responseMsg;
                    }
                }
            }else{
                //If in the request, 'ccContactId' is not given, then return error response as 'ccContactId needs to be provided'
                responseMsg = 'ccContactId needs to be provided.';
                return responseMsg;
            }
        }
        return responseMsg;
        
    }
}