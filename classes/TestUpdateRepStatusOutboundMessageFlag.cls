@isTest
private class TestUpdateRepStatusOutboundMessageFlag {

    static testmethod void test1() {
             
       Test.startTest();
       UpdateRepStatusOutboundMessageFlag objUpdateRepStatusOutboundMessageFlag = new UpdateRepStatusOutboundMessageFlag();
       Database.executeBatch(objUpdateRepStatusOutboundMessageFlag);
       Test.stopTest();
       
    }
    static testmethod void test2() {
           
       
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='1020');
       Insert acct1;
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='1020',Account__c=acct1.Id);
        Insert Adesa1;
        
        Contact Contact1 = new Contact(LastName='Patel',OpenLane_Details__c=Adesa1.Id,Login_ID__c='1020',Email='test@test1.com');
        Insert Contact1;
        
        Auction_Detail__c ad = new Auction_Detail__c(                                
                                Name='Auction Detail 1',
                                Account__c=acct1.Id,
                                Source_Id__c='12375'
                            );
       insert ad; 
       
       Rep_Status_ADESA_Auction__c  objRepStatus = new Rep_Status_ADESA_Auction__c (                               
                                Name='Rep_Status_ADESA_Auction 1',
                                ADESA_Auction_Detail__c = ad.id,
                                Send_Qualtrics_Survey_Today__c = true,
                                Contact__c = Contact1.Id
                                
                            );          
        Insert objRepStatus;

        
        AuctionContact__c objAuctionContact = new AuctionContact__c(
                                AuctionIdEmail__c = 'test1',
                                Last_Updated_by_Rep_Status_Id__c = objRepStatus.Id          
        );
        Insert objAuctionContact;
       Test.startTest();
        UpdateRepStatusOutboundMessageFlag objUpdateRepStatusOutboundMessageFlag = new UpdateRepStatusOutboundMessageFlag();
       Database.executeBatch(objUpdateRepStatusOutboundMessageFlag);
       Test.stopTest();
       
    }
}