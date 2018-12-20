trigger leadToAccountValidate on Lead (before update) {
    Set<String> aans = new Set<String>();
    //Set<String> tins = new Set<String>();
    List<Account> accts = new List<Account>();
    List<Account> accts1 = new List<Account>();
    Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('ADESA DST Leads').getRecordTypeId();
    
    for(Lead ld:Trigger.new){
        if(ld.IsConverted && ld.RecordTypeId != leadRecordTypeId){
            if(ld.Street == null || ld.City == null || ld.State == null || ld.PostalCode == null){
                ld.addError('Please complete the address field for lead');
                return;
            }
            if(!ld.Verified_Create_Account__c){
                ld.addError('In order to convert a lead to an account, you need to check "Verified - Create Account" in the lead');
                return;
            }
            if(ld.Auction_Access_Number__c != null){
                aans.add(ld.Auction_Access_Number__c);              
            }
            /*if(ld.TIN__c != null){
                tins.add(ld.TIN__c);
            }*/
        }
        
    }

    if(aans != null){
        //accts = [SELECT Name, Auction_Access_Number__c FROM Account WHERE Auction_Access_Number__c IN :aans];
        accts = [SELECT Auction_Access_Number__c FROM Account WHERE Auction_Access_Number__c IN :aans];
    }
    /*if(tins != null){
        accts1 = [SELECT Name, TIN_Search__c FROM Account WHERE TIN_Search__c != null AND TIN_Search__c IN :tins]; 
    }*/
    
    for(Lead ld:Trigger.new){

        if(ld.IsConverted && ld.RecordTypeId != leadRecordTypeId){
            if(!ld.Disable_Convert_Validation__c){
                if(ld.Auction_Access_Number__c == null && ld.TIN__c == null){
                    ld.addError('Both Auction Access Number and TIN are empty.');
                    return;
                }
           
               for(Account a: accts){
                    if(ld.Auction_Access_Number__c != null){
                        if(ld.Auction_Access_Number__c == a.Auction_Access_Number__c){
                            ld.addError('Account with Auction Access Number "' + a.Auction_Access_Number__c +'" already exist');
                            return;
                        }
                    }
                }
            
            /*for(Account a1: accts1){
                if(ld.TIN__c != null){
                    if(ld.TIN__c == a1.TIN_Search__c){
                        ld.addError('Account with TIN "' + a1.TIN_Search__c +'" already exist');
                        return;
                    }
                }
            }*/

            }   
        }    
    }
                        
}