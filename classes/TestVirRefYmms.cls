public class TestVirRefYmms {
  static testMethod void testInvalid() {    
    VIR__c v = new VIR__c();
    v.VIR_Id__c = 'VA123456-9362';
    v.Dealer_Org_Id__c = '9362';
    v.Vehicle_ID__c = 'VA123456';
    v.name = 'abcdefghijklmn';
    
    insert v;
    
    System.assertEquals(v.Asset__c, null);
    
  }
  
  static testMethod void testValid() {
     /*ID validVaType = 
           [select Id, Name, SobjectType 
            from RecordType 
            where SobjectType = 'Vehicle_at_Auction__c' 
     and Name = 'Auction'].Id;*/
        
    Asset__c va = new Asset__c();    
    va.Vehicle_ID__c = '654321';
    va.Name = 'cyan test va';
    //va.RecordTypeId = validVaType;  
    va.CurrencyIsoCode = 'CAD';
    /* FIXME: insert va;
    
    Asset__c validVa = 
               [select Id, CurrencyIsoCode, Vehicle_ID__c
                from Asset__c 
                where Vehicle_ID__c = '654321']; 
                    
    System.assertEquals(validVa.Vehicle_ID__c, '654321');
    */
    
    VIR__c v = new VIR__c();
    v.VIR_Id__c = '654321-9362';
    v.Dealer_Org_Id__c = '9362';
    v.Vehicle_ID__c = '654321';
    v.name = 'nmlgfedbca123';
    insert v;         
    
    /*VIR__c v2 = [select Id, CurrencyIsoCode, Asset__c
                from Vir__c 
                where Vehicle_ID__c = '654321'];   
    */             
    
    /* FIXME: System.assertEquals(v2.Asset__c, validVa.Id);
    System.assertEquals(v2.CurrencyIsoCode, validVa.CurrencyIsoCode);
    */
  }
}