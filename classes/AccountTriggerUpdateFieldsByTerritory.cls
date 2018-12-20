public class AccountTriggerUpdateFieldsByTerritory {
    Public Static void updateFieldsByTerritoryMethod (List<Account> newAccountList) {

        Set<String> usZip = new Set<String>();
        List<Territory__c> zips = new List<Territory__c>();
        
        String ActiveDealershipUSRecordTypeId = Utils.getRecordTypeId('Account', 'Dealership Account US');
       // String dealershipCARecordType = Utils.getRecordTypeId('Account', 'Dealership Account CA');
       // String dealershipIntlRecordType = Utils.getRecordTypeId('Account', 'Dealership Account Intl');  
        Set<String> TerritoryRecordTypeIds = Utils.getTerritoryRecTypeIds('Account');
        
        
        if(ActiveDealershipUSRecordTypeId==null)
        {
            return;
        }
        
        for(Account acct:newAccountList){
        //'01260000000Dl5v' -> Dealership Account - US-> Dealership Account US
        // if(acct.RecordTypeId == ActiveDealershipUSRecordTypeId || acct.RecordTypeId == dealershipCARecordType  || acct.RecordTypeId == dealershipIntlRecordType ){  // PPM 108679 Cretieria re defined by Kelly on 7/7/2016
        // Story B-44304 - Adding new territory Record types and refactoring it by Custom Settings
         if( TerritoryRecordTypeIds.contains(acct.RecordTypeId)){           
            if(acct.BillingPostalCode != null){
                if( acct.BillingPostalCode.length() >= 5){
                    usZip.add(acct.BillingPostalCode.substring(0,5));
                }
            }
          }      
        }
    
        if(usZip!= null){
            for(Territory__c myzip : [SELECT Account_Owner__r.Id, D2D_Specialist__c, DOSS__c, DST_Outside_Sales_Rep__c, Zipcode__c, ADESA_Territory_Name__c, ISS__c FROM Territory__c WHERE Zipcode__c IN :usZip]){
        		zips.add(myzip);
            }
               }
    
        for(Account acct:newAccountList){ 
            //'01260000000Dl5v' -> Dealership Account - US-> Dealership Account US   
            // PPM 108679 Cretieria re defined by Product owner on 7/7/2016
            //if(acct.RecordTypeId == ActiveDealershipUSRecordTypeId || acct.RecordTypeId == dealershipCARecordType  || acct.RecordTypeId == dealershipIntlRecordType){  
            // Story B-44304 - Adding new territory Record types and refactoring it by Custom Settings  
            if( TerritoryRecordTypeIds.contains(acct.RecordTypeId)){    
               boolean matchZip = false; 
                
               for(Territory__c z: zips){
                   if(acct.BillingPostalCode != null){
                    if( acct.BillingPostalCode.length() >= 5){
                        if(acct.BillingPostalCode.substring(0,5) == z.Zipcode__c){
                            if(!acct.Assignment_Exception_Account_Owner__c && z.Account_Owner__r.Id != null)         
                                acct.OwnerId = z.Account_Owner__r.Id;
                            if(!acct.Assignment_Exception_D2D_Specialist__c)
                                acct.iDeal_Spl__c = z.D2D_Specialist__c;
                            if(!acct.Assignment_Exception_DOSS__c)
                                acct.Field_Sales_Rep__c = z.DOSS__c;
                            if(!acct.Assignment_Exception_Outside_Rep__c)
                                acct.DST_Outside_Sales_Rep_Lookup__c = z.DST_Outside_Sales_Rep__c;
                            if(!acct.Assignment_Exception_ADESA_Territory_N__c)
                                acct.ADESA_Territory_Name__c = z.ADESA_Territory_Name__c;
                            if(!acct.Assignment_Exception_ISS__c)
                                acct.ISS__c = z.ISS__c ;
                            matchZip = true;
                        }
                    }
                   }
               }
               
               if(!matchZip){
                   if(!acct.Assignment_Exception_Account_Owner__c)
                        //acct.OwnerId = null;
                   if(!acct.Assignment_Exception_D2D_Specialist__c)
                        acct.iDeal_Spl__c = null;
                   if(!acct.Assignment_Exception_Outside_Rep__c)
                        acct.Outside_Sales_Rep__c = null;  
                   if(!acct.Assignment_Exception_DOSS__c)
                        acct.Field_Sales_Rep__c = null;
                    if(!acct.Assignment_Exception_ADESA_Territory_N__c)
                        acct.ADESA_Territory_Name__c = null;
                    if(!acct.Assignment_Exception_ISS__c)
                        acct.ISS__c = null;
               }
            } // PPM 108679 Cretieria re defined by Kelly on 7/7/2016
        }
    }
}