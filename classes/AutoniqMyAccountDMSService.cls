@RestResource(urlMapping='/autoniq/myaccount/updateDMS')
global with sharing class AutoniqMyAccountDMSService {
    /*
    Description : Inbound web service for updating 'Autoniq Third Party Item' for the subscription of the product type 'AAX Integration' from the given unique 'contact' in request body 
    */
    @HttpPost global static string updateGeneral () {
        RestRequest req = RestContext.request;
        string DMSInfoStr = req.requestBody.toString().trim();
        CacheContract.aax DMSInfo = (CacheContract.aax) json.deserialize(DMSInfoStr,CacheContract.aax.class);
        string responseMsg;
        if(DMSInfo != null){
            string contactId = '0032D000005cb5m';
            /*
            if(DMSInfo.contactId != null && !string.isEmpty(DMSInfo.contactId)){
                contactId = DMSInfo.contactId;
            }
            */
            if(contactId != null && !string.isEmpty(contactId)){
                // Quering contact and its related 'Subscription'
                list<Contact> contactList = [SELECT firstName, lastName, (SELECT Id FROM Subscription__r limit 1) FROM Contact 
                                            WHERE Id = :contactId];
                if(contactList != null && !contactList.isEmpty()){
                    Contact con = contactList[0];
                    if(con.Subscription__r != null && !con.Subscription__r.isEmpty()){
                        string productName = 'AAX Integration';
                        // Quering 'Subscription Item' and its related 'Autoniq Third Party Item' by the subscription and product name
                        List<Subscription_Item__c> subscriptionItemList = [SELECT Product__r.Name, 
                                            (SELECT AAX_Client_ID__c, AAX_Dealer_ID__c, AAX_Security_Token__c, AAX_User_ID__c FROM Autoniq_Third_Party_Items__r)
                                        FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id AND 
                                                                    Product__r.Name = :productName];
                        
                        if(subscriptionItemList != null && !subscriptionItemList.isEmpty()){
                            
                            List<Autoniq_Third_Party_Item__c> thirdPartyItemList_ToUpdate = new List<Autoniq_Third_Party_Item__c>();
                            // Looping on subscription items and updating its related 'Autoniq Third Party Item' with the webservice request informations
                            for(Subscription_Item__c subscriptionItem : subscriptionItemList){
                                List<Autoniq_Third_Party_Item__c> thirdPartyItemList = subscriptionItem.Autoniq_Third_Party_Items__r;
                                if(thirdPartyItemList != null && !thirdPartyItemList.isEmpty()){
                                    thirdPartyItemList[0].AAX_Security_Token__c = DMSInfo.aaxSecurityToken;
                                    thirdPartyItemList[0].AAX_Client_ID__c = DMSInfo.aaxClientId;
                                    thirdPartyItemList[0].AAX_Dealer_ID__c = DMSInfo.aaxDealerId;
                                    thirdPartyItemList[0].AAX_User_ID__c = DMSInfo.aaxUserId;

                                    thirdPartyItemList_ToUpdate.add(thirdPartyItemList[0]);
                                }
                            }
                            // updating the 'Third Party Item', after checking it is not null or empty and on successfull update, returning response message as 'success' 
                            if(thirdPartyItemList_ToUpdate != null && !thirdPartyItemList_ToUpdate.isEmpty()){
                                update thirdPartyItemList_ToUpdate;
                                responseMsg = 'success';
                            }
                            
                        }else{
                            responseMsg = 'No subscription item found.';
                        }
                        
                    }
                }else{
                    responseMsg = 'No contact found.';
                }
            }
        }
        return responseMsg;
    }
}