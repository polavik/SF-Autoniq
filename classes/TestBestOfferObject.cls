@isTest
private class TestBestOfferObject {

    static testMethod void myUnitTest() {
    Account acct = new Account();
    //acct.ATC_Organization_ID__c = '123456';
    acct.Name = 'Mr Stevebobs Volvo';
    insert acct;
    
    Asset__c v = new Asset__c(vehicle_id__c='v12345', source_id__c='v12345');
    insert v;
    
    Best_Offers__c bo = new Best_Offers__c(best_offer_id__c='bo12345', 
                                           Buyer_organization__c=acct.id, 
                                           Seller_Organization__c=acct.id, 
                                           Vehicle__c=v.id, 
                                           offer_Status__c='Open');
    insert bo;
    bo.Offer_Status__c = 'Contact Attempted';
    update bo;    

    }
}