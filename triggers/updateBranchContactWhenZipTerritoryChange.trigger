trigger updateBranchContactWhenZipTerritoryChange on Zip_Territory__c (after insert, after update) {
    String usZip;
    String canZip;
    boolean usCon = true; //determine the first entry
    boolean canCon = true;
    List<Account> canAcct = new List<Account>();
    List<Account> usAcct = new List<Account>();    

    for(Zip_Territory__c zipTer:Trigger.new){
        if(zipTer.Zip_Code__c != null){//US Zip
            if(zipTer.Zip_Code__c.length() >= 5){
                if(usCon){
                    usZip = 'SELECT Id, Primary_Postalcode__c FROM Account WHERE AFC_Assignment_exception__c = false AND (primary_postalcode__c LIKE \'' + zipTer.Zip_Code__c.substring(0,5) + '%\'';
                }else{
                    usZip += ' or Primary_Postalcode__c LIKE \'' + zipTer.Zip_Code__c.substring(0,5) + '%\'';
                } //append % for SOQL Wildcard searching
                usCon = false;
            }
        }else if(ZipTer.CANADA_Zip__c != null){//Canada Postalcode
            if(zipTer.CANADA_Zip__c.length() >= 3){
                if(canCon){
                    canZip = 'SELECT Id, Primary_Postalcode__c FROM Account WHERE AFC_Assignment_exception__c = false AND (primary_postalcode__c LIKE \'' + zipTer.CANADA_Zip__c.substring(0,3) + '%\'';
                }else{
                    canZip += ' or Primary_Postalcode__c LIKE \'' + zipTer.CANADA_Zip__c.substring(0,3) + '%\'';
                } //append % for SOQL Wildcard searching
                canCon = false;
            }      
        }
    }
    
    if(usZip!= null){
        usZip += ')';
        usAcct = Database.query(usZip);
    }
    if(canZip!= null){
        canZip += ')';
        canAcct = Database.query(canZip);
    }
    
    List<Account> updateUsAccts = new List<Account>();
    List<Account> updateCanAccts = new List<Account>();    
    
    for(Zip_Territory__c zipTer:Trigger.new){      
          for(Account acct: usAcct){
              if(zipTer.Zip_Code__c.length() >= 5){
               if(zipTer.Zip_Code__c == acct.Primary_Postalcode__c.substring(0,5)){
                   acct.AFCBranchSalesarea__c = zipTer.AFC_Branch__c;
                   acct.AFC_Area_Sales_Manager__c = zipTer.AFCSalesContact__c;
                   updateUsAccts.add(acct);
               }
              }
          }
          
          for(Account acct1: canAcct){
              if(zipTer.CANADA_Zip__c.length() >= 3){
               if(zipTer.CANADA_Zip__c == acct1.Primary_Postalcode__c.substring(0,3)){
                   acct1.AFCBranchSalesarea__c = zipTer.AFC_Branch__c;
                   acct1.AFC_Area_Sales_Manager__c = zipTer.AFCSalesContact__c;
                   updateCanAccts.add(acct1);
               }
              }
          }     
    }

    try {
        update updateUsAccts;
        update updateCanAccts;
    } catch (DmlException e) {
    // Process exception here
    }
}