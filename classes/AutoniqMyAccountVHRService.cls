@RestResource(urlMapping='/autoniq/myaccount/updateVHR')
global class AutoniqMyAccountVHRService {
    /*
     Description : Inbound web service for updating 'Autoniq Third Party Item' 
                   for the subscription of the product type 'CarFax' or 'AutoCheck' from the given unique 'contact' in request body 
    */
    @HttpPost global static string updateGeneral () {
        RestRequest req = RestContext.request;
        string VHRInfoStr = req.requestBody.toString().trim();
        AutoniqMyAccountUpdateVHRRequest VHRInfo = (AutoniqMyAccountUpdateVHRRequest) json.deserialize(VHRInfoStr,AutoniqMyAccountUpdateVHRRequest.class);
        string responseMsg;
        if(VHRInfo != null){
            if(VHRInfo.contactId != null && !string.isEmpty(VHRInfo.contactId)){
                // Quering contact and its related 'Subscription'
                list<Contact> contactList = [SELECT firstName, lastName, (SELECT Id FROM Subscription__r limit 1) FROM Contact 
                                            WHERE Id = :VHRInfo.contactId];
                if(contactList != null && !contactList.isEmpty()){
                    Contact con = contactList[0];
                    if(con.Subscription__r != null && !con.Subscription__r.isEmpty()){
                        // Get the product name and user name from the request body data 'carfaxId' , 'autoCheckId'.
                        string productName_CarFax;
                        string productName_AutoCheck;
                        string userName;
                        if(!string.isEmpty(VHRInfo.carfaxId)){
                            productName_CarFax = 'CarFax';
                            userName = VHRInfo.carfaxId;
                        }
                        if(!string.isEmpty(VHRInfo.autoCheckId)){
                            productName_AutoCheck = 'AutoCheck';
                            userName = VHRInfo.autoCheckId;
                        }
                        //If 'carfaxId' and 'autoCheckId', both data are not given, then returns error message saying 'Please provide User Name'
                        if(string.isEmpty(userName)){
                            return 'Please provide User Name';
                        }
                        // Quering 'Subscription Item' and its related 'Autoniq Third Party Item' by the subscription and product name
                        List<Subscription_Item__c> subscriptionItemList = [SELECT Product__r.Name, 
                                            (SELECT Username__c, Password__c, Auto_Purchase__c FROM Autoniq_Third_Party_Items__r)
                                        FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id AND 
                                                                    (Product__r.Name = :productName_CarFax OR Product__r.Name = :productName_AutoCheck)];
                        
                        if(subscriptionItemList != null && !subscriptionItemList.isEmpty()){
                            
                            List<Autoniq_Third_Party_Item__c> thirdPartyItemList_ToUpdate = new List<Autoniq_Third_Party_Item__c>();
                            // Looping on subscription items and updating its related 'Autoniq Third Party Item' with the webservice request informations
                            for(Subscription_Item__c subscriptionItem : subscriptionItemList){
                                List<Autoniq_Third_Party_Item__c> thirdPartyItemList = subscriptionItem.Autoniq_Third_Party_Items__r;
                                if(thirdPartyItemList != null && !thirdPartyItemList.isEmpty()){
                                    if(subscriptionItem.Product__r.Name == 'CarFax' && !string.isEmpty(VHRInfo.carfaxId)){
                                        thirdPartyItemList[0].Username__c = VHRInfo.carfaxId;
                                        thirdPartyItemList[0].Password__c = VHRInfo.carfaxPasswd;
                                        thirdPartyItemList[0].Auto_Purchase__c = VHRInfo.carfaxAutoPurchase;
                                        //thirdPartyItemList_ToUpdate.add(thirdPartyItemList[0]);
                                        
                                    }
                                    if(subscriptionItem.Product__r.Name == 'AutoCheck' && !string.isEmpty(VHRInfo.autoCheckId)){
                                        thirdPartyItemList[0].Username__c = VHRInfo.autoCheckId;
                                        thirdPartyItemList[0].Password__c = VHRInfo.autoCheckPasswd;
                                        thirdPartyItemList[0].Auto_Purchase__c = VHRInfo.autoCheckAutoPurchase;
                                        //thirdPartyItemList_ToUpdate.add(thirdPartyItemList[0]);
                                    }
                                    thirdPartyItemList_ToUpdate.add(thirdPartyItemList[0]);
                                }
                            }
                            // updating the 'Third Party Item', after checking it is not null or empty and on successfull update, returning response message as 'success' 
                            if(thirdPartyItemList_ToUpdate != null && !thirdPartyItemList_ToUpdate.isEmpty()){
                                update thirdPartyItemList_ToUpdate;
                                responseMsg = 'success - '+thirdPartyItemList_ToUpdate.size();
                            }
                            
                        }
                        
                    }
                }
            }
        }
        return responseMsg;
    }
}