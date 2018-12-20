trigger updateBranchContactbyZipTerritory on Account (before insert, before update) {
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
        //djpatel on 25-Sep-2014 ( B-31398 )
        String creditAccountRecordType = Utils.getRecordTypeId('Account', 'Credit Account');      
        
        
        
                
        Set<String> usZip = new Set<String>();
        Set<String> canZip = new Set<String>();
        List<Zip_Territory__c> zips = new List<Zip_Territory__c>();
        List<Zip_Territory__c> zips1 = new List<Zip_Territory__c>();    

        for(Account acct:Trigger.new){  
            if( acct.recordTypeId != creditAccountRecordType) //djpatel on 29-Sep-2014 ( B-31398 )  
            { 
                    if(acct.Primary_Postalcode__c != null && acct.AFC_Assignment_exception__c == false){
                        if((acct.Primary_country__c == 'USA' || acct.Primary_country__c == 'UNITED STATES') && acct.Primary_Postalcode__c.length() >= 5){
                            usZip.add(acct.Primary_Postalcode__c.substring(0,5));
                        }else if(acct.Primary_country__c == 'Canada' && acct.Primary_Postalcode__c.length() >= 3){
                            canZip.add(acct.Primary_Postalcode__c.substring(0,3));
                        }
                    }            
            }       
        }

        if(usZip.size()>0){
            zips = [SELECT AFC_Branch__c, AFCSalesContact__c, Zip_Code__c FROM Zip_Territory__c WHERE Zip_Code__c IN :usZip];
        }
        if(canZip.size()>0){
            zips1 = [SELECT AFC_Branch__c, AFCSalesContact__c, CANADA_Zip__c FROM Zip_Territory__c WHERE CANADA_Zip__c IN :canZip]; 
        }
        //System.debug('>>>usZip'+usZip);
        //System.debug('>>>canZip'+canZip);
        
        for(Account acct:Trigger.new){
            
                if( acct.recordTypeId != creditAccountRecordType) //djpatel on 29-Sep-2014 ( B-31398 )  
                {
                   boolean matchZip = false; 

                   for(Zip_Territory__c z: zips){
                       if(acct.Primary_Postalcode__c != null && acct.AFC_Assignment_exception__c == false){
                        if((acct.Primary_country__c == 'USA' || acct.Primary_country__c == 'UNITED STATES') && acct.Primary_Postalcode__c.length() >= 5){
                            if(acct.Primary_Postalcode__c.substring(0,5) == z.Zip_Code__c){
                                acct.AFCBranchSalesarea__c = z.AFC_Branch__c;
                                acct.AFC_Area_Sales_Manager__c = z.AFCSalesContact__c;
                                matchZip = true;
                            }
                        }
                       }
                       
                   }
                    
                   for(Zip_Territory__c z1: zips1){
                        if(acct.Primary_Postalcode__c != null && acct.AFC_Assignment_exception__c == false){
                         if(acct.Primary_country__c == 'Canada' && acct.Primary_Postalcode__c.length() >= 3){
                            if(acct.Primary_Postalcode__c.substring(0,3) == z1.CANADA_Zip__c){
                                acct.AFCBranchSalesarea__c = z1.AFC_Branch__c;
                                acct.AFC_Area_Sales_Manager__c = z1.AFCSalesContact__c;
                                matchZip = true;
                            }
                         }
                        }
                        if(acct.AFC_Assignment_exception__c){
                             matchZip = true; //set it to true so it won't update the fields to blanks
                        } 
                   }
                   
                   if(!matchZip && !acct.AFC_Assignment_exception__c){
                       acct.AFCBranchSalesarea__c = null;
                       acct.AFC_Area_Sales_Manager__c = null;  
                   }
               }
            
        } 
    }
    
}