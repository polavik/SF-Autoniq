@isTest private class TestTriggerAccounts {    
    String dealershipUSRecordType = Utils.getRecordTypeId('Account', 'Dealership Account US'); 
    String dealershipCARecordType = Utils.getRecordTypeId('Account', 'Dealership Account CA'); 
    //String dealershipRecordType = Utils.getRecordTypeId('Account', 'Dealership Active'); 
    String auctionRecordType = Utils.getRecordTypeId('Account', 'Auction'); 
    String institutionConsignorRecordType = Utils.getRecordTypeId('Account', 'Institution/Consignor'); 
    String prospectRecordType = Utils.getRecordTypeId('Account', 'KAR Prospect'); 
    String duplicateRecordType = Utils.getRecordTypeId('Account', 'Duplicate Account');
    String invalidOOBRecordType = Utils.getRecordTypeId('Account', 'Invalid/OOB');
    String repoPARRecordType = Utils.getRecordTypeId('Account', 'Repo/PAR');
    String carsarriveRecordType = Utils.getRecordTypeId('Account', 'CarsArrive Transporter');
            
    static testMethod void testTriggerAccounts (){
        Account a = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345');
        insert a;
        
        a.Fax = '1234567';
        update a;
        //  if(a.Duplicate__c && a.Duplicate_with_Master_Index__c != ''){ 
        //    a.recordTypeId = duplicateRecordType; //Duplicate Account
        Account a1 = New Account(Name='Test0_a1',Master_Index__c='Test0_a1',AFC_Dealer_ID__c='1234567',Duplicate__c = true, Duplicate_with_Master_Index__c = '12345' );
        insert a1;
              
        // if(a.Name.containsIgnoreCase('Carmax Auction')){ 
        //    a.recordTypeId = auctionRecordType; //Auction
        a1.Name='Test0_a1_Carmax Auction';
        a1.Duplicate_with_Master_Index__c = '';
        a1.Duplicate__c = false;
        update a1;
        
        // if(a.AFC_Dealer_ID__c == null && a.SOURCE_ID__C == null){ 
        //    a.recordTypeId = prospectRecordType ;
        a1.Name='Test0_a1_another';
        a1.AFC_Dealer_ID__c = null;
        a1.SOURCE_ID__C = null;
        update a1;
        
        //if( a.Primary_Country__c == 'Canada' ){ 
        //    a.recordTypeId = dealershipCARecordType;
        //a1.Name='Test0_a1_another';
        a1.AFC_Dealer_ID__c = '123456789';
        a1.SOURCE_ID__C = 'OpenLane';
        a1.Primary_Country__c = 'Canada';
        update a1;
        
        // a.recordTypeId = dealershipUSRecordType ;
        a1.Primary_Country__c = 'US';
        update a1; 
        
             
        Account B1 = new Account(Master_Index__c='Bad_Test0',AFC_Dealer_ID__c='123453456');
        if (B1.Name == null)
        { B1.Name = 'ACD123';
          insert B1;
        }
        else {
          insert B1;
        }
        
             
        Account B2 = new Account(Master_Index__c='Bad_Test02',AFC_Dealer_ID__c='123453456222');
        insert B2;
           
    }
}